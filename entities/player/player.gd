extends "res://addons/fpc/character.gd"

#region Variable Init

var confetti_ref = preload("res://entities/player/confetti.tscn")

@export var village_respawn_point : RespawnPoint

@onready var weapon_sprite : Sprite2D = $Weapon/WeaponOrigin/WeaponSprite
@export var cellphone_sprite : Sprite2D
@onready var direction_ray: Marker3D = $Head/Direction
@onready var interactable_finder: Area3D = $Head/Direction/InteractableFinder
signal health_changed
signal item_picked_up
# A signal to update the ammo amount in the ui
signal shooting
signal talking

# Used for the hud
signal voice_line_trigger

# This will be used with the final staircase to know how many segments to rise
var figurine_count := 0

const MAX_HEALTH : int = 100
var health : int = MAX_HEALTH
var dead = false
var in_dialogue : bool = false

# Used for the final cutscene
var invincible := false

# Shotgun recoil system
@export var shotgun_recoil_strength: float = 4.0  # Horizontal knockback force
@export var shotgun_upward_boost: float = 1.0     # Upward boost component
@export var max_recoil_speed: float = 8.0        # Cap to prevent crazy speeds

# Inventory system
var inventory: Dictionary = {}  # item_name -> {description, quantity}
var max_inventory_size: int = 20

# States to determine which held item should be shown
var HELD_ITEM_STATES := {
	"gun" :0,
	"cellphone" : 1
}

var held_item := 0

#endregion

#region Built-in Functions and Signals

func _ready():
	switch_held_item_state(HELD_ITEM_STATES.gun)
	super._ready()
	# Add player to global settings to enemies can find it
	g.player = self
	add_to_group("player")

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	g.world_toggled.connect(set_shotgun_texture)
	
	g.hide_hud.connect(hide_weapon)
	g.reveal_hud.connect(reveal_weapon)

func hide_weapon():
	$Weapon/WeaponOrigin/WeaponSprite.visible = false

func reveal_weapon():
	$Weapon/WeaponOrigin/WeaponSprite.visible = true


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)

	if Input.is_action_just_pressed("interact"):
		var interactables = interactable_finder.get_overlapping_areas()
		if interactables.size() > 0:
			emit_signal("talking")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			interactables[0].action()
			return


func _on_dialogue_ended(resource : DialogueResource):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	in_dialogue = false
	immobile = false
	jumping_enabled = true
	g.question_asked = false
	
	await get_tree().create_timer(0.5).timeout
	shooting_enabled = true

#region Logic Handling


func take_damage(dmg : int):
	if dead:
		return

	health -= dmg
	
	if invincible:
			health = clampi(health, 1, MAX_HEALTH)
	else:
		health = clampi(health, 0, MAX_HEALTH)
		if health <= 70:
			$RickVoiceLines.play_line_conditional("hungry")
	
	emit_signal("health_changed", health)

	if g.hitflash_enabled:
		$Weapon/HitFlash/HitFlashAnim.play("hitflash")
	if health <= 0:
		die()

func heal(heal_amount: int) -> void:
	if dead:
		return

	var old_health = health
	health = min(health + heal_amount, MAX_HEALTH)
	emit_signal("health_changed", health)
	var actual_heal = health - old_health

	if actual_heal > 0:
		Log.info("Healed for %s. Health: %s/%s" % [actual_heal, health, MAX_HEALTH])
	else:
		Log.info("Health already full!")

func die():
	if dead:
		return
	$Dying.play()
	dead = true
	immobile = true
	health = 0
	respawn()

#endregion

#region Inventory System

func add_to_inventory(item_name: String, description: String, quantity: int = 1, is_figurine:=false) -> bool:
	# Check if inventory has space
	if get_inventory_count() >= max_inventory_size and not inventory.has(item_name):
		Log.info("Inventory full! Cannot pick up ", item_name)
		return false

	# Add or stack item
	if inventory.has(item_name):
		inventory[item_name]["quantity"] += quantity
	else:
		inventory[item_name] = {
			"description": description,
			"quantity": quantity
		}
	Log.info("Added %s x %s to inventory (%s/%s)" % [quantity, item_name, get_inventory_count(), max_inventory_size])

	# Emit the signal to the hud can pick it up
	emit_signal("item_picked_up", item_name)
	
	# Keep track of the figurines for the final staircase
	if is_figurine:
		figurine_count += 1
		
		if figurine_count == 1:
			play_line("ive_always_wanted_one")
		if figurine_count == 2:
			play_line("figurine_collected")
		#print("Player figurine count: " + str(figurine_count))
	
	return true

func remove_from_inventory(item_name: String, quantity: int = 1) -> bool:
	if not inventory.has(item_name):
		return false

	inventory[item_name]["quantity"] -= quantity

	if inventory[item_name]["quantity"] <= 0:
		inventory.erase(item_name)

	Log.info("Removed %s x %s from inventory" % [quantity, item_name])
	return true

func has_item(item_name: String) -> bool:
	return inventory.has(item_name)

func get_item_quantity(item_name: String) -> int:
	if inventory.has(item_name):
		return inventory[item_name]["quantity"]
	return 0

func get_inventory_count() -> int:
	var total = 0
	for item in inventory:
		total += inventory[item]["quantity"]
	return total

func print_inventory():
	if inventory.is_empty():
		Log.info("Inventory is empty")
		return

	Log.info("=== INVENTORY (%s/%s) ===" % [get_inventory_count(), max_inventory_size])
	for item_name in inventory:
		var item = inventory[item_name]
		Log.info("- %s x %s (%s)" % [item["quantity"], item_name, item["description"]])

#endregion

#region Respawn System

func respawn():
	# Disable player input during death
	immobile = true
	shooting_enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Create red transparent overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0.8, 0.0, 0.0, 0.4)  # Semi-transparent red
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().current_scene.add_child(overlay)

	# Create death message
	var death_label = Label.new()
	death_label.text = "YOU DIED\nRespawning in 5 seconds..."
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_label.add_theme_font_size_override("font_size", 24)
	death_label.modulate = Color.WHITE
	var custom_font = load("res://ui/UAV-OSD-Mono.ttf")
	if custom_font:
		death_label.add_theme_font_override("font", custom_font)

	get_tree().current_scene.add_child(death_label)

	# Fade in the overlay and text
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple tweens to run simultaneously

	overlay.modulate.a = 0.0
	death_label.modulate.a = 0.0

	tween.tween_property(overlay, "modulate:a", 1.0, 1.0)
	tween.tween_property(death_label, "modulate:a", 1.0, 1.0)

	# Countdown from 5 seconds
	for i in range(5, 0, -1):
		death_label.text = "YOU DIED\nRespawning in %d seconds..." % i
		await get_tree().create_timer(1.0).timeout

	# Clean up UI elements before respawning
	overlay.queue_free()
	death_label.queue_free()

	var last_checkpoint = g.get_last_activated_checkpoint()

	if last_checkpoint == null or not is_instance_valid(last_checkpoint):
		Log.info("No last activated checkpoint found! Respawning at current position.")
		# Just reset player state without moving
		reset_player_state()
		return

	# Move player to respawn point
	global_position = last_checkpoint.global_position
	var respawn_name = last_checkpoint.get_respawn_name() if last_checkpoint.has_method("get_respawn_name") else "Unknown"

	# Reset only player state, keep inventory and world state
	reset_player_state()

	Log.info("Respawned at: %s" % respawn_name)

func reset_player_state():
	# Reset only essential player state
	dead = false
	immobile = false
	shooting_enabled = true
	health = MAX_HEALTH
	velocity = Vector3.ZERO

	# Reset camera and input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#endregion

#region Game Mechanics

# Called from the cellphone pickup
func cellphone_picked_up():
	switch_held_item_state(HELD_ITEM_STATES.cellphone)
	cellphone_sprite.picked_up()
	await cellphone_sprite.get_node("CellPhoneAnimation").animation_finished
	switch_held_item_state(HELD_ITEM_STATES.gun)

func switch_held_item_state(new_state:=0):
	match new_state:
		# Gun
		0:
			weapon_sprite.visible = true
			cellphone_sprite.visible = false
		1:
			weapon_sprite.visible = false
			cellphone_sprite.visible = true

func handle_shooting():
	if shooting_enabled:
		if continuous_shooting:
			if Input.is_action_pressed(controls.SHOOT):
				#WEAPON_SPRITE.play()
				if RAYCAST.is_colliding() and RAYCAST.get_collider().has_method("take_damage"):
					RAYCAST.get_collider().take_damage(1)
		else:
			if Input.is_action_just_pressed(controls.SHOOT) and not in_dialogue:
				if not reloading:
					reloading = true
					
					if g.cuddly_world:
						$Weapon/WeaponAnim.play("cuddly_fire")
					else:
						$Weapon/WeaponAnim.play("demon_fire")
					
					emit_signal("shooting")
					
		
					$Weapon/ReloadTimer.start()
					
					shooting_enabled = false

					if !g.cuddly_world:
						SHOOT_SOUND.pitch_scale = 1.0
					else:
						SHOOT_SOUND.pitch_scale = 2.0
					SHOOT_SOUND.play()
					
					if g.cuddly_world:
						var confetti = confetti_ref.instantiate()
						g.game.add_child(confetti)
						confetti.rotation.y = rotation.y
						confetti.global_position = global_position
						var material = confetti.process_material as ParticleProcessMaterial
						material.direction = -HEAD.transform.basis.z
						
						##CONFETTI_SOUND.play()
						#Log.info("Confetti!!")
						
					# Shoot to kill enemies, throw confetti at villagers
					if RAYCAST.is_colliding() and RAYCAST.get_collider().has_method("take_damage"):
						Log.info("Player shot hit: " + str(RAYCAST.get_collider().get_name()))
						RAYCAST.get_collider().take_damage(1)
					elif RAYCAST.is_colliding() and RAYCAST.get_collider().has_method("have_party"):
						Log.info("Player shot confetti at: " + str(RAYCAST.get_collider().get_name()))
						RAYCAST.get_collider().have_party()
						
					# Shotgun momentum boost - only when airborne
					if g.recoil_unlocked or g.dev_mode:
						if not is_on_floor():
							apply_shotgun_recoil()

func apply_shotgun_recoil():
	# Get camera's forward direction (where we're aiming)
	var camera_forward = -CAMERA.global_transform.basis.z

	# Calculate recoil direction (opposite of where we're aiming)
	var recoil_direction = -camera_forward

	# Split into horizontal and vertical components
	var horizontal_recoil = Vector3(recoil_direction.x, 0, recoil_direction.z).normalized()
	var vertical_component = Vector3.UP * shotgun_upward_boost

	# Calculate the boost velocity
	var boost_velocity = horizontal_recoil * shotgun_recoil_strength + vertical_component

	# Add to current velocity
	velocity += boost_velocity

	# Cap the total speed to prevent exploits
	if velocity.length() > max_recoil_speed:
		velocity = velocity.normalized() * max_recoil_speed

	# Log.info("Shotgun boost applied! Velocity: ", velocity.length())

#endregion

# A function to pass down to the voice lines so this can be easily triggered
func play_line(line_name:String):
	$RickVoiceLines.play_line(line_name)


func _on_weapon_anim_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"cuddly_fire", "demon_fire", "fire":
			shooting_enabled = true

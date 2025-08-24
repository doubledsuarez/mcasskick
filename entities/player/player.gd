extends "res://addons/fpc/character.gd"

@export var weapon_sprite : AnimatedSprite2D
@export var cellphone_sprite : Sprite2D
@onready var direction_ray: Marker3D = $Head/Direction
@onready var interactable_finder: Area3D = $Head/Direction/InteractableFinder
signal health_changed
signal item_picked_up
# A signal to update the ammo amount in the ui
signal shooting

# This will be used with the final staircase to know how many segments to rise
var figurine_count := 0

const MAX_HEALTH : int = 100
var health : int = MAX_HEALTH
var dead = false
var in_dialogue : bool = false


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

func _ready():
	switch_held_item_state(HELD_ITEM_STATES.gun)
	super._ready()
	# Add player to global settings to enemies can find it
	g.player = self
	add_to_group("player")

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Check if we need to respawn at a specific position
	check_for_respawn_position()


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)

	if Input.is_action_just_pressed("interact"):
		var interactables = interactable_finder.get_overlapping_areas()
		if interactables.size() > 0:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			interactables[0].action()
			return


func _on_dialogue_ended(resource : DialogueResource):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	in_dialogue = false
	immobile = false
	shooting_enabled = true
	g.question_asked = false

#region Logic Handling


func take_damage(dmg : int):
	if dead:
		return

	health -= dmg
	health = clampi(health, 0, MAX_HEALTH)
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

	# Respawn at last activated checkpoint
	respawn_at_last_checkpoint()

func get_last_activated_respawn_point() -> Node3D:
	# Get the last activated checkpoint from global
	var last_checkpoint = g.get_last_activated_checkpoint()

	if last_checkpoint == null or not is_instance_valid(last_checkpoint):
		Log.info("No last activated checkpoint found! Using scene reload.")
		return null

	# Verify it's still activated (in case of scene reload)
	if last_checkpoint.has_method("is_activated") and not last_checkpoint.is_activated():
		Log.info("Last checkpoint no longer activated! Using scene reload.")
		return null

	return last_checkpoint

func respawn_at_last_checkpoint():
	var respawn_point = get_last_activated_respawn_point()

	if respawn_point == null:
		# Fallback to scene reload if no respawn points found
		get_tree().reload_current_scene()
		return

	# Store respawn position for after scene reload
	var respawn_position = respawn_point.global_position
	var respawn_name = respawn_point.get_respawn_name() if respawn_point.has_method("get_respawn_name") else "Unknown"

	# Store respawn data in global singleton
	g.set_respawn_data(respawn_position, respawn_name)

	# Reload scene to reset all enemies and world state
	get_tree().reload_current_scene()

func check_for_respawn_position():
	# Check if global has stored a respawn position
	if g.has_respawn_data():
		var respawn_data = g.get_and_clear_respawn_data()

		# Move player to respawn position
		global_position = respawn_data.position

		# Reset player state
		dead = false
		immobile = false
		shooting_enabled = true
		health = MAX_HEALTH
		velocity = Vector3.ZERO

		# Reset camera and input
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		Log.info("Respawned at: %s" % respawn_data.name)

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
					emit_signal("shooting")
					reloading = true
					WEAPON_SPRITE.stop()
					WEAPON_SPRITE.play("shoot")
					if !g.cuddly_world:
						SHOOT_SOUND.play()
					#else:
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

extends "res://addons/fpc/character.gd"

const MAX_HEALTH : int = 100
var health : int = MAX_HEALTH
var dead = false

# Inventory system
var inventory: Dictionary = {}  # item_name -> {description, quantity}
var max_inventory_size: int = 20

func _ready():
	super._ready()
	# Add player to group so enemies can find it
	add_to_group("player")

#region Logic Handling

func take_damage(dmg : int):
	if dead:
		return

	health -= dmg
	health = clampi(health, 0, MAX_HEALTH)

	if health <= 0:
		die()

func heal(heal_amount: int) -> void:
	if dead:
		return

	var old_health = health
	health = min(health + heal_amount, MAX_HEALTH)
	var actual_heal = health - old_health

	if actual_heal > 0:
		print("Healed for ", actual_heal, ". Health: ", health, "/", MAX_HEALTH)
	else:
		print("Health already full!")

func respawn():
	# Disable player input during death
	immobile = true
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
	death_label.add_theme_font_size_override("font_size", 48)
	death_label.modulate = Color.WHITE
	get_tree().current_scene.add_child(death_label)

	# Fade in the overlay and text
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple tweens to run simultaneously

	overlay.modulate.a = 0.0
	death_label.modulate.a = 0.0

	tween.tween_property(overlay, "modulate:a", 1.0, 1.0)
	tween.tween_property(death_label, "modulate:a", 1.0, 1.0)

	# Wait 5 seconds then reload scene
	await get_tree().create_timer(5.0).timeout
	get_tree().reload_current_scene()

func die():
	if dead:
		return

	dead = true
	immobile = true
	health = 0
	respawn()

#endregion

#region Inventory System

func add_to_inventory(item_name: String, description: String, quantity: int = 1) -> bool:
	# Check if inventory has space
	if get_inventory_count() >= max_inventory_size and not inventory.has(item_name):
		print("Inventory full! Cannot pick up ", item_name)
		return false

	# Add or stack item
	if inventory.has(item_name):
		inventory[item_name]["quantity"] += quantity
	else:
		inventory[item_name] = {
			"description": description,
			"quantity": quantity
		}

	print("Added ", quantity, "x ", item_name, " to inventory (", get_inventory_count(), "/", max_inventory_size, ")")
	return true

func remove_from_inventory(item_name: String, quantity: int = 1) -> bool:
	if not inventory.has(item_name):
		return false

	inventory[item_name]["quantity"] -= quantity

	if inventory[item_name]["quantity"] <= 0:
		inventory.erase(item_name)

	print("Removed ", quantity, "x ", item_name, " from inventory")
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
		print("Inventory is empty")
		return

	print("=== INVENTORY (", get_inventory_count(), "/", max_inventory_size, ") ===")
	for item_name in inventory:
		var item = inventory[item_name]
		print("- ", item["quantity"], "x ", item_name, " (", item["description"], ")")

#endregion

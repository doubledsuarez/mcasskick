extends "res://addons/fpc/character.gd"

const MAX_HEALTH : int = 100
var health : int = MAX_HEALTH
var dead = false

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

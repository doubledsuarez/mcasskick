extends Node3D
class_name RespawnPoint

@export var respawn_name: String = "Respawn Point"
@export var show_debug_visual: bool = true
@export var player_activated: bool = false  # Only allow respawn after activation

@onready var debug_visual: MeshInstance3D = $DebugVisual
@onready var checkpoint_area: Area3D = $CheckpointArea

func _ready() -> void:
	# Add to respawn points group so player can find it
	add_to_group("respawn_points")

	# Show/hide debug visual based on export flag
	if debug_visual:
		debug_visual.visible = show_debug_visual

	# Set up checkpoint detection if enabled
	if checkpoint_area:
		checkpoint_area.body_entered.connect(_on_player_entered)
		checkpoint_area.collision_mask = 1  # Player layer
	elif checkpoint_area:
		# Disable checkpoint area if not needed
		checkpoint_area.monitoring = false

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		activate_checkpoint()

func activate_checkpoint() -> void:
	if not player_activated:
		player_activated = true
		Log.info("Checkpoint activated: %s" % respawn_name)

		# Register as the last activated checkpoint globally
		g.set_last_activated_checkpoint(self)

		# Visual feedback for activation
		if debug_visual:
			var tween = create_tween()
			tween.tween_property(debug_visual, "scale", Vector3(1.2, 1.2, 1.2), 0.2)
			tween.tween_property(debug_visual, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func get_respawn_position() -> Vector3:
	return global_position

func get_respawn_name() -> String:
	return respawn_name

func is_activated() -> bool:
	return player_activated

func set_activated(activated: bool) -> void:
	player_activated = activated

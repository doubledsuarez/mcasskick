extends ToggleVillager
class_name Villager

# Breathing animation settings
@export var breathing_enabled: bool = true
@export var breathing_intensity: float = 0.05  # How much the villager moves
@export var breathing_speed: float = 2.0       # How fast they breathe

# Internal breathing state
var breathing_time: float = 0.0
var original_scale: Vector3

func _ready() -> void:
	super._ready()

	# Store the original scale for breathing animation
	original_scale = scale

func _process(delta: float) -> void:
	if breathing_enabled:
		handle_breathing_animation(delta)

func handle_breathing_animation(delta: float) -> void:
	breathing_time += delta

	# Create a subtle breathing effect using sine wave
	var breathing_offset = sin(breathing_time * breathing_speed) * breathing_intensity

	# Apply breathing to scale - makes villager slightly bigger/smaller
	scale.y = original_scale.y + breathing_offset
	scale.x = original_scale.x + breathing_offset * 0.3  # Less horizontal movement
	scale.z = original_scale.z + breathing_offset * 0.3

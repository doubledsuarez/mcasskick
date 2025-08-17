extends TogglePickup
class_name Pickup

# Pickup system with immediate use and inventory collection
@export var pickup_name: String = "Unknown Item"
@export var pickup_description: String = "A mysterious item"
@export var pickup_value: int = 1  # Amount for health/ammo, or quantity for inventory

# Immediate use pickup types
enum PickupType {
	HEALTH,
	FIGURINE
}

@export var pickup_type: PickupType = PickupType.HEALTH

# Visual and audio feedback
@export var rotate_speed: float = 2.0
@export var float_amplitude: float = 0.3
@export var float_speed: float = 3.0

#@onready var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var initial_y_position: float
var time_passed: float = 0.0

func _ready() -> void:
	# Connect pickup detection
	body_entered.connect(_on_body_entered)

	# Store initial position for floating animation
	if mesh_instance:
		initial_y_position = mesh_instance.position.y

func _process(delta: float) -> void:
	time_passed += delta

	# Rotate the pickup
	if mesh_instance:
		mesh_instance.rotation.y += rotate_speed * delta

		# Float up and down
		mesh_instance.position.y = initial_y_position + sin(time_passed * float_speed) * float_amplitude

func _on_body_entered(body: Node3D) -> void:
	# Check if it's the player
	if not body.is_in_group("player"):
		return

	# Handle pickup based on type
	pickup(body)

	# Remove pickup from scene
	queue_free()

func pickup(player: Node3D) -> void:
	match pickup_type:
		PickupType.HEALTH:
			if player.has_method("heal"):
				player.heal(pickup_value)
				Log.info("Healed for %s HP" % pickup_value)
		PickupType.FIGURINE:
			if player.has_method("add_to_inventory"):
				player.add_to_inventory(pickup_name, pickup_description, pickup_value)
				Log.info("Collected: ", pickup_name)
			else:
				Log.info("Player has no inventory system")
		_:
			Log.info("Used unknown pickup type")

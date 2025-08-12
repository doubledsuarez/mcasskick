extends Area3D
class_name Pickup

# Pickup system with immediate use and inventory collection
@export var pickup_name: String = "Unknown Item"
@export var pickup_description: String = "A mysterious item"
@export var is_inventory_item: bool = false  # false = immediate use, true = add to inventory
@export var pickup_value: int = 1  # Amount for health/ammo, or quantity for inventory

# Immediate use pickup types
enum PickupType {
	HEALTH,
	AMMO,
	INVENTORY_ITEM
}

@export var pickup_type: PickupType = PickupType.HEALTH

# Visual and audio feedback
#@export var pickup_sound: AudioStream
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

	# Set up audio
	#add_child(audio_player)
	#if pickup_sound:
		#audio_player.stream = pickup_sound

	# Set collision detection for player only
	collision_mask = 1  # Player layer

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
	if is_inventory_item:
		collect_to_inventory(body)
	else:
		use_immediately(body)

	# Play pickup sound
	#if pickup_sound and audio_player:
		#audio_player.play()
		## Wait for sound to finish before destroying
		#await audio_player.finished

	# Remove pickup from scene
	queue_free()

func use_immediately(player: Node3D) -> void:
	match pickup_type:
		PickupType.HEALTH:
			if player.has_method("heal"):
				player.heal(pickup_value)
				print("Healed for ", pickup_value, " HP")
			else:
				# Fallback for basic health system
				if player.has_property("health") and player.has_property("MAX_HEALTH"):
					player.health = min(player.health + pickup_value, player.MAX_HEALTH)
					print("Health restored: ", pickup_value)

		PickupType.AMMO:
			if player.has_method("add_ammo"):
				player.add_ammo(pickup_value)
				print("Added ", pickup_value, " ammo")

		_:
			print("Used unknown pickup type")

func collect_to_inventory(player: Node3D) -> void:
	if player.has_method("add_to_inventory"):
		player.add_to_inventory(pickup_name, pickup_description, pickup_value)
		print("Collected: ", pickup_name)
	else:
		print("Player has no inventory system")

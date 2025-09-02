extends Area3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var speed = 8.0
@export var damage = 15
@export var lifetime = 5.0
@export var gravity_factor = 0.5
@export var arc : float = 2.0
@export var tracking_strength: float = 1.2  # Increased power for high-flying enemies
@export var tracking_duration: float = 2.5  # How long tracking lasts

var velocity: Vector3
var time_alive = 0.0
var target_player: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	## Set collision layers and masks
	## Layer 4 for enemy projectiles, collide with player (layer 1) and world (layer 3)
	#collision_layer = 8  # Layer 4 (2^3 = 8)
	#collision_mask = 5   # Layers 1 and 3 (2^0 + 2^2 = 1 + 4 = 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	time_alive += delta

	# Apply gravity
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_factor * delta

	# Apply enhanced tracking toward player (for high-flying enemies like bats)
	if target_player and is_instance_valid(target_player) and time_alive < tracking_duration:
		var direction_to_player = (target_player.global_position - global_position).normalized()
		velocity = velocity.lerp(direction_to_player * speed, tracking_strength * delta)

	# Move the fireball
	global_position += velocity * delta

	# Rotate for visual effect
	mesh_instance_3d.rotation.x += 5.0 * delta
	mesh_instance_3d.rotation.z += 3.0 * delta

	# Destroy after lifetime expires
	if time_alive >= lifetime:
		explode()

func launch(direction: Vector3, start_position: Vector3) -> void:
	global_position = start_position
	velocity.y += arc
	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Set tracking target to player
	target_player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body: Node3D) -> void:
	# Only explode if hitting player or world - ignore enemies entirely
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		explode()
	elif not body.is_in_group("enemies"):
		# Hit world geometry or other non-enemy objects
		explode()

func _on_area_entered(area: Area3D) -> void:
	# Ignore checkpoint areas (respawn points)
	if area.is_in_group("respawn_points"):
		return

	# Handle collision with other areas if needed
	explode()

func explode() -> void:
	# TODO: Add explosion effect/sound here if desired
	queue_free()

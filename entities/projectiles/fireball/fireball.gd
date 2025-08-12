extends Area3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var speed = 8.0
@export var damage = 25
@export var lifetime = 5.0
@export var gravity_factor = 0.5
@export var arc : float = 2.0

var velocity: Vector3
var time_alive = 0.0

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

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	explode()

func _on_area_entered(area: Area3D) -> void:
	# Handle collision with other areas if needed
	explode()

func explode() -> void:
	# TODO: Add explosion effect/sound here if desired
	queue_free()

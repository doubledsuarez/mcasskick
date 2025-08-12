extends CharacterBody3D
class_name Enemy

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var death_sound: AudioStreamPlayer = $DeathSound

@export var health = 5
@export var move_speed = 1.5
@export var attack_range = 8.0
@export var fireball_cooldown = 3.0
@export var fireball_speed = 12.0

@export var fireball_scene: PackedScene = preload("res://entities/projectiles/fireball/fireball.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

@onready var player : CharacterBody3D = $"../../Player/Player"
var dead = false
var attack_timer = fireball_cooldown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_3d.animation_finished.connect(_on_animated_sprite_3d_animation_finished)
	animated_sprite_3d.play("walking")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update attack timer
	if attack_timer > 0:
		attack_timer -= delta


func _physics_process(delta: float) -> void:
	if dead:
		return
	if player == null:
		return

	if not is_on_floor() and gravity:
		velocity.y -= gravity * delta

	# Call virtual move function that can be overridden by subclasses
	move()
	move_and_slide()
	attack()

	if health <= 0:
		die()


# Virtual move function - can be overridden by subclasses
func move():
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()

	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed

func attack():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return

	# Check if attack is ready (cooldown finished)
	if attack_timer > 0:
		return

	fire_projectile()
	attack_timer = fireball_cooldown

func fire_projectile():
	# Create fireball instance
	var fireball = fireball_scene.instantiate()

	# Add to scene (parent it to the main scene, not the enemy)
	get_tree().current_scene.add_child(fireball)

	# Calculate direction to player
	var direction = (player.global_position - global_position).normalized()

	# Launch position slightly in front of enemy at hand height
	var launch_position = global_position + direction * 1.0 + Vector3.UP * 1.2

	# Launch the fireball
	fireball.launch(direction, launch_position)

func take_damage(dmg : int):
	if dead:
		return

	health -= dmg

	if health <= 0:
		die()

func die() -> void:
	dead = true
	var layer_to_disable = 2
	self.collision_layer &= ~(1 << (layer_to_disable - 1))
	animated_sprite_3d.play("dying")
	death_sound.play()


func _on_animated_sprite_3d_animation_finished() -> void:
	#queue_free()
	pass

extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var death_sound: AudioStreamPlayer = $DeathSound

@export var move_speed = 2.0
@export var attack_range = 2.0

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_3d.animation_finished.connect(_on_animated_sprite_3d_animation_finished)
	animated_sprite_3d.play("walking")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _physics_process(delta: float) -> void:		
	if dead:
		return
	#if player == null:
		#return
		
	if not is_on_floor() and gravity:
		velocity.y -= gravity * delta
		
	#var dir = player.global_position - global_position
	#dir.y = 0.0
	#dir = dir.normalized()
	#
	#velocity = dir * move_speed
	move_and_slide()
	
	
func kill() -> void:
	dead = true
	var layer_to_disable = 2
	self.collision_layer &= ~(1 << (layer_to_disable - 1))
	animated_sprite_3d.play("dying")
	death_sound.play()


func _on_animated_sprite_3d_animation_finished() -> void:
	queue_free()

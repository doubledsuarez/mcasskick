extends Enemy
class_name Sniper

# Sniper-specific behavior variables
@export var preferred_distance = 10.0  # Optimal distance to maintain from player
@export var strafe_speed = 2.0         # Speed when strafing left/right
@export var retreat_speed = 3.0        # Speed when retreating from player
@export var strafe_duration = 3.0      # How long to strafe in one direction
@export var aim_pause_duration = 0.1   # Brief pause before shooting

# Cliff detection variables (commented out for now)
# @export var cliff_check_distance = 1.5  # How far ahead to check for cliffs
# @export var cliff_drop_threshold = 3.0  # How far down before considering it a cliff

var strafe_timer = 0.0
var strafe_direction = 1  # 1 for right, -1 for left
var aim_timer = 0.0
var is_aiming = false

func _ready():
	super._ready()
	animated_sprite_3d.modulate = Color.BLUE

	# Snipers have different stats than base enemies
	move_speed = 2.0  # Slower base movement
	attack_range = 12.0  # Longer attack range
	fireball_cooldown = 2.5  # Slower rate of fire but more deliberate

	# Initialize strafe timer with random offset so snipers don't all move in sync
	strafe_timer = randf() * strafe_duration

	# Make sure we have a player reference
	if player == null:
		player = get_node("../../Player/Player")
		if player == null:
			# Try to find player in scene
			player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	super._process(delta)

	# Update strafe timer
	strafe_timer -= delta

	# Update aim timer
	if is_aiming:
		aim_timer -= delta
		if aim_timer <= 0:
			is_aiming = false

# Override the base move function with sniper-specific behavior
func move():
	if dead or player == null:
		velocity.x = 0
		velocity.z = 0
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	var dir_to_player = (player.global_position - global_position)
	dir_to_player.y = 0.0
	dir_to_player = dir_to_player.normalized()

	# Get perpendicular direction for strafing (cross product with up vector)
	var strafe_dir = Vector3.UP.cross(dir_to_player).normalized() * strafe_direction

	# Change strafe direction periodically
	if strafe_timer <= 0:
		strafe_direction *= -1  # Reverse direction
		strafe_timer = strafe_duration + randf() * 1.0  # Add some randomness

	# Determine movement behavior based on distance to player
	if distance_to_player < preferred_distance * 0.7:
		# Too close - retreat while strafing
		var retreat_dir = (-dir_to_player + strafe_dir * 0.5).normalized()
		velocity.x = retreat_dir.x * retreat_speed
		velocity.z = retreat_dir.z * retreat_speed
	elif distance_to_player > preferred_distance * 1.3:
		# Too far - advance while strafing
		var advance_dir = (dir_to_player + strafe_dir * 0.3).normalized()
		velocity.x = advance_dir.x * move_speed
		velocity.z = advance_dir.z * move_speed
	else:
		# Good distance - just strafe
		velocity.x = strafe_dir.x * strafe_speed
		velocity.z = strafe_dir.z * strafe_speed

	# Cliff detection commented out for now
	# if is_cliff_ahead():
	#	 velocity.x = 0
	#	 velocity.z = 0

# Override attack to add aiming behavior
func attack():
	if dead or player == null:
		return

	var dist_to_player = global_position.distance_to(player.global_position)

	if dist_to_player > attack_range:
		return

	# Check if attack is ready (cooldown finished)
	if attack_timer > 0:
		return

	# Fire immediately
	fire_projectile()
	attack_timer = fireball_cooldown

# Override fire_projectile for sniper-specific behavior
func fire_projectile():
	# Create fireball instance
	var fireball = fireball_scene.instantiate()

	# Add to scene
	get_tree().current_scene.add_child(fireball)

	# Calculate direction with slight prediction for moving targets
	var player_velocity = player.velocity if player.has_method("get_velocity") else Vector3.ZERO
	var time_to_target = global_position.distance_to(player.global_position) / fireball_speed
	var predicted_position = player.global_position + player_velocity * time_to_target

	var direction = (predicted_position - global_position).normalized()

	# Launch position
	var launch_position = global_position + direction * 1.0 + Vector3.UP * 0.5

	# Launch the fireball with sniper-specific speed
	fireball.speed = fireball_speed
	fireball.launch(direction, launch_position)

	# Visual feedback - brief muzzle flash or recoil animation could go here

# Cliff detection commented out for now
# func is_cliff_ahead() -> bool:
#	var space_state = get_world_3d().direct_space_state
#	var start_pos = global_position + Vector3.UP * 0.1
#	var movement_dir = Vector3(velocity.x, 0, velocity.z).normalized()
#
#	if movement_dir.length() == 0:
#		return false
#
#	# Check point ahead in movement direction
#	var check_pos = start_pos + movement_dir * cliff_check_distance
#	var ground_check_end = check_pos + Vector3.DOWN * cliff_drop_threshold
#
#	var query = PhysicsRayQueryParameters3D.create(check_pos, ground_check_end)
#	query.collision_mask = 1
#	var result = space_state.intersect_ray(query)
#
#	# If no ground found within cliff_drop_threshold distance, it's a cliff
#	return not result

extends Enemy
class_name Zombie

# Zombie-specific behavior variables
@export var melee_range = 1.5          # How close to get for melee attack
@export var melee_damage = 15          # Damage dealt by melee attack
@export var melee_cooldown = 2.0       # Time between melee attacks
@export var lunge_speed = 8.0          # Speed boost during attack lunge

var is_attacking = false
var attack_lunge_timer = 0.0
var lunge_duration = 0.3

func _ready() -> void:
	super._ready()
	animated_sprite_3d.modulate = Color.DARK_GRAY

	# Zombies are slow and shambling
	move_speed = 0.5       # Much slower than other enemies
	attack_range = melee_range  # Use melee range for attack detection
	fireball_cooldown = melee_cooldown

func _process(delta: float) -> void:
	super._process(delta)

	# Handle attack lunge
	if is_attacking:
		attack_lunge_timer -= delta
		if attack_lunge_timer <= 0:
			is_attacking = false

# Override move function for zombie shambling behavior
func move():
	if dead or player == null:
		velocity.x = 0
		velocity.z = 0
		return

	# Simple shambling movement toward player
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()

	# Use lunge speed if attacking, normal speed otherwise
	var current_speed = lunge_speed if is_attacking else move_speed

	velocity.x = dir.x * current_speed
	velocity.z = dir.z * current_speed

# Override attack for melee behavior
func attack():
	if dead or player == null:
		return

	var dist_to_player = global_position.distance_to(player.global_position)

	# Only attack when very close (melee range)
	if dist_to_player > melee_range:
		return

	# Check if attack is ready (cooldown finished)
	if attack_timer > 0:
		return

	# Perform melee attack
	melee_attack()
	attack_timer = melee_cooldown

# Melee attack function
func melee_attack():
	# Start attack lunge
	is_attacking = true
	attack_lunge_timer = lunge_duration

	# Deal damage to player if still in range
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player <= melee_range:
		if player.has_method("take_damage"):
			player.take_damage(melee_damage)

	# Play attack animation if available
	if animated_sprite_3d and not dead:
		# You could add an "attacking" animation here
		# animated_sprite_3d.play("attacking")
		Log.info("Zombie attacked!")
		pass

# Override fire_projectile to do nothing (zombies don't shoot)
func fire_projectile():
	# Zombies don't fire projectiles, they use melee attacks
	pass

extends Node3D

# Zone Base

# This is a zone of the world that will contain a demon and a cuddly variant of the map
# It will handle switching between the two

@onready var world_demon = $WorldDemon
@onready var world_cuddly = $WorldCuddly

func _ready():
	g.world_toggled.connect(match_world_state)
	match_world_state()


func match_world_state():
	if g.cuddly_world:
		enable_world(world_cuddly, true)
		enable_world(world_demon, false)
	else:
		enable_world(world_cuddly, false)
		enable_world(world_demon, true)


func enable_world(world:FuncGodotMap, is_enabled:bool):
	if is_instance_valid(world):
		world.visible = is_enabled
		
		if is_enabled:
			world.global_position = Vector3.ZERO
		else:
			world.global_position = Vector3(999999, 999999, 999999)

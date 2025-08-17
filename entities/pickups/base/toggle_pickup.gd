extends Area3D
class_name TogglePickup

# This is a base class for all objects that will only exist in one world state

@export_enum("cuddly", "demon") var world_state : String = "cuddly"

# This is the position the object will return to when enabled
var base_position := Vector3.ZERO

func _ready():
	base_position = global_position
	match_world_state()
	
	g.world_toggled.connect(match_world_state)


func match_world_state():
	if world_state == "cuddly":
		if g.cuddly_world:
			enable_object(true)
			return
	elif world_state == "demon":
		if !g.cuddly_world:
			enable_object(true)
			return
	
	enable_object(false)


func enable_object(is_enabled:bool):
	visible = is_enabled
	set_physics_process(is_enabled)

	if is_enabled:
		global_position = base_position
	else:
		base_position = global_position
		global_position = Vector3(99999,99999,99999)

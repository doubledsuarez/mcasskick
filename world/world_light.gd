extends OmniLight3D

# This is a class for lights that will only exist in one world

@export_enum("cuddly", "demon") var world_state : String = "demon"

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

	if is_enabled:
		global_position = base_position
	else:
		base_position = global_position
		global_position = Vector3(99999,99999,99999)

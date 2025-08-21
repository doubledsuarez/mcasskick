extends Node3D

# This is a base class for all objects that will only exist in one world state

@export var complete_texture : Texture
@export var broken_texture : Texture
var complete := true

# This is the position the object will return to when enabled
var base_position := Vector3.ZERO

func _ready():
	base_position = global_position
	match_world_state()
	
	g.world_toggled.connect(match_world_state)


func match_world_state():
	var material = $MeshInstance3D.get_surface_override_material(0)
	if g.cuddly_world == true:
		material.albedo_texture = complete_texture
		complete = true

	elif g.cuddly_world == false:
		material.albedo_texture = broken_texture
		complete = false
		$CollisionShape3D.disabled = false
		visible = true


func take_damage(_dmg : int):
	print("Toggle block shot")
	if complete == false:
		if g.cuddly_world == false:
			complete = false
			$CollisionShape3D.disabled = true
			visible = false

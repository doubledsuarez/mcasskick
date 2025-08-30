extends Sprite3D

@export var speed := .01

func _process(delta):
	rotation.z += speed

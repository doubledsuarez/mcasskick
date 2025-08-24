extends Node3D
class_name StaircaseSegment

# This is a staircase segment that can be lifted

var risen := false

func _ready():
	$StaticBody3D/CollisionShape3D.disabled = true

func rise():
	if risen == false:
		risen = true
		$AnimationPlayer.play("rise")
		$StaticBody3D/CollisionShape3D.set_deferred("disabled", false)

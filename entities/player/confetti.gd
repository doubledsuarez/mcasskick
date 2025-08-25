extends GPUParticles3D

func _ready():
	emitting = true
	await get_tree().create_timer(3.0).timeout
	queue_free()

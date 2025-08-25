extends AudioStreamPlayer

func _ready():
	g.world_toggled.connect(play_sound)

func play_sound():
	pitch_scale = randf_range(.9, 1.2)
	play()

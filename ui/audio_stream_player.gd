extends AudioStreamPlayer

func play_sound(_var,_var2_,_var3):
	randomize()
	pitch_scale = randf_range(1.05, .95)
	volume_db = randf_range(-5, -2)
	play()

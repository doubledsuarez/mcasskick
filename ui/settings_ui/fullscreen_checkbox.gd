extends CheckBox


func _on_toggled(toggled_on):
	if !toggled_on:
		print("Set windowed")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		print("Set fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

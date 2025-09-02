extends CheckBox


func _on_toggled(toggled_on):
	if !toggled_on:
		Log.info("Set windowed")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		Log.info("Set fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

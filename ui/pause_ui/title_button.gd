extends Button


func _on_pressed() -> void:
	g.toggle_pause()
	Music.stop()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://ui/start_ui/start_screen_ui.tscn")

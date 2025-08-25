extends Button


# Goes back to main menu
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/start_ui/start_screen_ui.tscn")

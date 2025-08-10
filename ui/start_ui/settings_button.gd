extends Button



#switch to settings UI
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/settings_ui/settings_screen_ui.tscn")

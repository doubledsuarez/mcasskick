extends Button

func _on_pressed() -> void:
	g.settings.visible = true
	g.pause_menu.visible = false
	
	g.settings.enable()

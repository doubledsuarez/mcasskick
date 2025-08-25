extends Control

func _ready() -> void:
	visible = false
	g.pause_menu = self



func _on_resume_button_pressed():
	g.toggle_pause()

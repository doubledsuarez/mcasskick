extends CheckBox


func _on_toggled(toggled_on: bool) -> void:
	g.hud.game_timer_label.visible = toggled_on
	Log.info("Timer visibility toggled.")

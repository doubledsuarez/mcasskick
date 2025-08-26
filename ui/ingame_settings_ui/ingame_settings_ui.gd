extends Control

func _ready() -> void:
	g.settings = self
	visible = false
	
	var current_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	$main_container/settings_box/volume_container/volume_slider.value = db_to_linear(current_volume_db)

func enable():
	pass

func _on_h_slider_drag_ended(value_changed):
	pass # Replace with function body.


func _on_h_slider_value_changed(value):
	if is_instance_valid(g.player):
		g.player.mouse_sensitivity = value


func _on_volume_slider_value_changed(value):
# Convert linear value (0-1) to decibels for AudioServer
	# Use a minimum of -80 dB for "silent" instead of -inf
	var volume_db = linear_to_db(value) if value > 0.0 else -80.0
	
	# Set the master bus volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

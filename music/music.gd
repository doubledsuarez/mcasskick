extends AudioStreamPlayer

var muted := false
var bus_index = AudioServer.get_bus_index("Master")

func _input(event):
	if event.is_action_pressed("mute"):
		if muted == false:
			muted = true
			AudioServer.set_bus_volume_db(bus_index, -99999)
		else:
			muted = false
			AudioServer.set_bus_volume_db(bus_index, 0)
			

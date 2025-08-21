extends AudioStreamPlayer

var muted := false
var bus_index = AudioServer.get_bus_index("Master")

@export var demon_level_1 : AudioStream
@export var cuddly_descent : AudioStream

@export var cuddly_level_1 : AudioStream

func _input(event):
	if event.is_action_pressed("mute"):
		if muted == false:
			muted = true
			AudioServer.set_bus_volume_db(bus_index, -99999)
		else:
			muted = false
			AudioServer.set_bus_volume_db(bus_index, 0)


func play_track(track_name:String):
	print("music called")
	if track_name in self:
		print("music Switching track")
		stream = get(track_name)
		play()

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
	if track_name == "cuddly_descent":
		$DescentIntoCuddliness.play()
		stop()
		return

	Log.info("music called")
	if track_name in self:
		Log.info("music Switching track")
		stream = get(track_name)
		play()


func _on_descent_into_cuddliness_finished():
	await get_tree().create_timer(15.0).timeout
	$ChillJam1.play()
	


func _on_chill_jam_1_finished():
	await get_tree().create_timer(15.0).timeout
	$ChillJam2.play()

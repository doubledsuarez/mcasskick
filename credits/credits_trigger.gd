extends Area3D


func _on_body_entered(body):
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			#get_tree().paused = false
		Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	get_tree().call_deferred("change_scene_to_file", "res://credits/credits.tscn")

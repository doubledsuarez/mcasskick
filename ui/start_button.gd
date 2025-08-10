extends Button


#start button calls game
func _on_pressed() -> void:
	#print("the button is being pressed")
	get_tree().change_scene_to_file("res://game.tscn")

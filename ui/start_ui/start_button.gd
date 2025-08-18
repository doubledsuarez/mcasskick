extends Button


#start button calls game
func _on_pressed() -> void:
	#print("the button is being pressed")
	
	
	# change "res://" path to proper
	# Begins the game by calling game scene
	get_tree().change_scene_to_file("res://game.tscn")

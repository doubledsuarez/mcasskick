extends Node2D

var speed := 0

func _ready():
	Music.stop()
	Music.play_track("demon_level_1")

func _input(event):
	if event.is_action_released("shoot"):
		speed += 1
		$AnimationPlayer.speed_scale += speed
		
		if speed >= 4:
			end_credits()


func end_credits():
	Music.stop()
	get_tree().change_scene_to_file("res://ui/start_ui/start_screen_ui.tscn")


func _on_animation_player_animation_finished(anim_name):
	end_credits()

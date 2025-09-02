extends Node2D

var speed := 0

func _ready():
	Music.stop_all_tracks()
	Music.play_track("demon_level_1")

	# Log final runtime when credits start
	g.log_final_runtime()

func _input(event):
	if event.is_action_released("shoot"):
		speed += 1
		$AnimationPlayer.speed_scale += speed

		if speed >= 4:
			end_credits()


func end_credits():
	# reset globals
	g.y_look_unlocked = false
	g.recoil_unlocked = false
	g.world_switch_unlocked = false
	g.jumping_unlocked = false
	g.low_gravity = false
	g.cuddly_world = false
	g.tutorial_done = false
	g.question_asked = false

	# clear respawn checkpoint
	g.last_activated_checkpoint = null

	# reset player reference
	g.player = null

	# reset music stopped variable
	# (without this cuddly songs won't play after descent)
	Music.stopped = false

	get_tree().change_scene_to_file("res://ui/start_ui/start_screen_ui.tscn")

	Log.info("Game Reset")


func _on_animation_player_animation_finished(anim_name):
	end_credits()

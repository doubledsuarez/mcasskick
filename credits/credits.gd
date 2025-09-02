extends Node2D

@onready var credits_text: RichTextLabel = $"Credit Root/MarginContainer/VBoxContainer/Credits Text"

var speed := 0

var credits_done : bool = false

func _ready():
	Music.stop_all_tracks()
	Music.play_track("demon_level_1")

	set_end_time()

func _input(event):
	if event.is_action_released("shoot") and not credits_done:
		speed += 1
		$AnimationPlayer.speed_scale += speed

		if speed >= 4:
			$AnimationPlayer.seek(89.9, true)
	elif event.is_action_released("shoot") and credits_done:
		end_credits()

func set_end_time():
	var final_time = g.get_current_runtime()
	var minutes = int(final_time / 60)
	var seconds_total = final_time - (minutes * 60)
	var seconds = int(seconds_total)
	var milliseconds = int((seconds_total - seconds) * 100)
	credits_text.append_text("\n\n\n\n\n\n\n\n\nCLEAR TIME\n%d:%02d:%02d\n%.2f total seconds\n\n\nTHANK YOU FOR PLAYING :)" % [minutes, seconds, milliseconds, final_time])

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

	credits_done = false
	g.clear_runtime_timer()

	get_tree().change_scene_to_file("res://ui/start_ui/start_screen_ui.tscn")

	Log.info("Game Reset")


func _on_animation_player_animation_finished(anim_name):
	credits_done = true
	#end_credits()

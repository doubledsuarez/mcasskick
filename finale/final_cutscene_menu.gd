extends CanvasLayer


# This will play the initial cutscene that is the fake main menu

@export var camera : Camera2D
@export var anim : AnimationPlayer

signal started 

func _ready():
	visible = false
	g.final_menu = self


#func _input(event):
	#if event.is_action_pressed("crouch"):
		#start_finale()

func hide_game():
	g.game_viewport.visible = false

func start_finale():
	emit_signal("started")
	Music.stop_all_tracks()
	visible = true
	get_tree().paused = true
	anim.play("start")

func play_rick_line(line_name:String):
	g.final_lines.play_line(line_name, "rick")

func play_demon_line(line_name:String):
	g.final_lines.play_line(line_name, "demon_king")

func end_menu_scene():
	g.final_scene_3d.begin()
	g.game_viewport.visible = true
	get_tree().paused = false

func end_menu_fully():
	print("Final menu ending menu fully")
	visible = false

func start_music():
	Music.play_track("Final")

func begin_credits():
	#visible = true
	#get_tree().paused = true
	#anim.play("credits")
	#
	#await anim.animation_finished
	
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	get_tree().call_deferred("change_scene_to_file", "res://credits/credits.tscn")

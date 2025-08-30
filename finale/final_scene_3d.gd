extends Node3D

@export var fish := preload("res://entities/enemies/fish/fish_weak.tscn")

@export var anim : AnimationPlayer

signal rick_still_talking

func _ready():
	g.final_scene_3d = self
	g.final_lines.demon_line.connect(demon_talking)
	$Camera3D.clear_current()

#func _input(event):
	#if event.is_action_pressed("interact"):
		#begin()
	#if event.is_action_pressed("mute"):
		#part_2()

func spawn_fish():
	g.player.invincible = true
	
	for i in 3:
		var f = fish.instantiate()
		add_child(f)
		f.global_position = $fish_pos.global_position + Vector3(randf_range(-10,10),randf_range(-10,10),randf_range(-10,10))

func begin():
	print("Final 3d beginning")
	g.player.global_position = $PlayerPos.global_position
	g.player.get_node("Head").rotation_degrees.y = $PlayerPos.rotation_degrees.y
	g.player.get_node("Weapon/RayCast").rotation_degrees.y = $PlayerPos.rotation_degrees.y
	anim.play("start")

func part_2():
	g.emit_signal("hide_hud")
	$Camera3D.make_current()
	anim.play("part_2")

func part_3():
	g.emit_signal("reveal_hud")
	$Camera3D.clear_current()
	anim.play("part_3")

func play_rick_line(line_name:String):
	g.final_lines.play_line(line_name, "rick")

func play_demon_line(line_name:String):
	g.final_lines.play_line(line_name, "demon_king")

func demon_talking():
	$demon_king/demon_talking.play("talk")

func rick_till_talking():
	emit_signal("rick_still_talking")

func start_credits():
	g.final_menu.begin_credits()
	
func give_kitty():
	g.emit_signal("give_kitty_away")

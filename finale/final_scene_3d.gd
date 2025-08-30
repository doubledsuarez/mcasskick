extends Node3D

@export var anim : AnimationPlayer

signal rick_still_talking

func _ready():
	g.final_scene_3d = self
	g.final_lines.demon_line.connect(demon_talking)
	$Camera3D.clear_current()

func _input(event):
	if event.is_action_pressed("interact"):
		begin()
	if event.is_action_pressed("mute"):
		part_2()

func begin():
	g.player.global_position = $PlayerPos.global_position
	g.player.get_node("Head").rotation_degrees.y = $PlayerPos.rotation_degrees.y
	anim.play("start")

func part_2():
	g.emit_signal("hide_hud")
	$Camera3D.make_current()
	anim.play("part_2")

func part_3():
	g.emit_signal("reveal_hud")
	$Camera3D.clear_current()

func play_rick_line(line_name:String):
	g.final_lines.play_line(line_name, "rick")

func play_demon_line(line_name:String):
	g.final_lines.play_line(line_name, "demon_king")

func demon_talking():
	$demon_king/demon_talking.play("talk")

func rick_till_talking():
	emit_signal("rick_still_talking")

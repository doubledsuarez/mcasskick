extends Area3D

var triggered := false

func _ready():
	g.final_menu.started.connect(disable)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if !triggered:
			triggered = true
			g.final_menu.start_finale()

func disable():
	triggered = true

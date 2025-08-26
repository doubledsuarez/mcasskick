extends Area3D

@export var line_name := ""

# A trigger to cause rick to play a voice line

func _on_body_entered(body):
	if body.is_in_group("player"):
		g.player.play_line(line_name)
		queue_free()

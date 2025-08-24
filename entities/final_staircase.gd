extends Node3D

# Final staircase
# this will rise all the staircase segments based on how many figurines the player has

var segments := []

var player_near := false

func _ready():
	for child in get_children():
		if child is StaircaseSegment:
			segments.append(child)
	await get_tree().create_timer(.1).timeout
	g.player.item_picked_up.connect(update_stairs)


func _on_area_3d_body_entered(body):
	player_near = true
	update_stairs("")

func update_stairs(_item_name=""):
	print("Rinal staircase Player near " + str(g.player.figurine_count))
	if player_near:
		for segment in g.player.figurine_count:
			print("Final staircase rising stair")
			segments[segment].rise()
			await get_tree().create_timer(2.0).timeout


func _on_area_3d_body_exited(body):
	player_near = false

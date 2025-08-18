extends Node

# Cell Phone Script
# This will enable looking around, world switching, etc

func _on_cell_phone_picked_up():
	g.y_look_unlocked = true
	g.recoil_unlocked = true
	g.world_switch_unlocked = true
	g.world_switch()

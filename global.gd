extends Node

# Global Singleton

# Variable and a signal for nodes to hook into if they need to switch their
# state when the demon and cuddly worlds switch

var game
var player

# Emitted from the player (when the player is implemented)
var cuddly_world := false
signal world_toggled

# Temporary solution for activating the world toggle until the player input is handled
func _input(event):
	if event.is_action_pressed("toggle"):
		if cuddly_world == false:
			cuddly_world = true
			emit_signal("world_toggled")
		else:
			cuddly_world = false
			emit_signal("world_toggled")

extends Node

# Global Singleton

# Variable and a signal for nodes to hook into if they need to switch their
# state when the demon and cuddly worlds switch

# this will be a cheat mode that will allow the player to switch the
# worlds without getting the cell phone and probably other stuff
# it will be set in the game script
var dev_mode := false

var game
var player = null

var question_asked : bool = false

# Game State Variables

# This is unlocked when the player gets the cell phone and uses the cheat code
# it will handle if they can look around like in doom
var y_look_unlocked := false
var recoil_unlocked := false
var world_switch_unlocked := false

# Accessibility setting for the hit flash (screen flashes red when the player is hit)
var hitflash_enabled := true

# Emitted from the player (when the player is implemented)
var cuddly_world := false
signal world_toggled

# Temporary solution for activating the world toggle until the player input is handled
func _input(event):
	if event.is_action_pressed("toggle"):
		if world_switch_unlocked or dev_mode:
			world_switch()

func world_switch():
	if cuddly_world == false:
		cuddly_world = true
		emit_signal("world_toggled")
	else:
		cuddly_world = false
		emit_signal("world_toggled")

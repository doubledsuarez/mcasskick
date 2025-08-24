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
var jumping_unlocked := false

# This is used for the descent scene
var low_gravity := false

# Accessibility setting for the hit flash (screen flashes red when the player is hit)
var hitflash_enabled := true

# Emitted from the player (when the player is implemented)
var cuddly_world := false
signal world_toggled

# Respawn system variables
var has_respawn_data_stored: bool = false
var stored_respawn_position: Vector3
var stored_respawn_name: String
var last_activated_checkpoint: Node3D = null

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

func set_respawn_data(position: Vector3, respawn_name: String = "Unknown") -> void:
	stored_respawn_position = position
	stored_respawn_name = respawn_name
	has_respawn_data_stored = true
	Log.info("Global: Stored respawn data - Position: %s, Name: %s" % [position, respawn_name])

func set_last_activated_checkpoint(checkpoint: Node3D) -> void:
	last_activated_checkpoint = checkpoint
	Log.info("Global: Last activated checkpoint set to: %s" % (checkpoint.get_respawn_name() if checkpoint.has_method("get_respawn_name") else "Unknown"))

func get_last_activated_checkpoint() -> Node3D:
	return last_activated_checkpoint

func has_respawn_data() -> bool:
	return has_respawn_data_stored

func get_and_clear_respawn_data() -> Dictionary:
	var data = {
		"position": stored_respawn_position,
		"name": stored_respawn_name
	}

	clear_respawn_data()

	return data

func clear_respawn_data() -> void:
	has_respawn_data_stored = false
	stored_respawn_position = Vector3.ZERO
	stored_respawn_name = ""
	Log.info("Cleared respawn data")

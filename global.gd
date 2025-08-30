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
var pause_menu = null
var settings = null
var introship = null
var game_viewport = null
var final_lines = null
var final_scene_3d = null

var tutorial_done : bool = false
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

# Used for the final cutscene camera
signal hide_hud
signal reveal_hud

# Respawn system variables
var last_activated_checkpoint: Node3D = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Temporary solution for activating the world toggle until the player input is handled
func _input(event):
	if event.is_action_pressed("toggle"):
		if world_switch_unlocked or dev_mode:
			world_switch()
	

	if event.is_action_pressed("pause"):
		toggle_pause()


func world_switch():
	if cuddly_world == false:
		cuddly_world = true
		emit_signal("world_toggled")
	else:
		cuddly_world = false
		emit_signal("world_toggled")



func set_last_activated_checkpoint(checkpoint: Node3D) -> void:
	last_activated_checkpoint = checkpoint
	Log.info("Global: Last activated checkpoint set to: %s" % (checkpoint.get_respawn_name() if checkpoint.has_method("get_respawn_name") else "Unknown"))

func get_last_activated_checkpoint() -> Node3D:
	return last_activated_checkpoint

func toggle_pause():
	print("Toggling mouse mode")
# You may want another node to handle pausing, because this player may get paused too.
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			g.pause_menu.visible = true
			get_tree().paused = true
		
		Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			g.pause_menu.visible = false

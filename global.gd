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
var final_menu = null

var hud = null

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

signal give_kitty_away

# Respawn system variables
var last_activated_checkpoint: Node3D = null

# Runtime timer for showcase analytics
var runtime_timer: Timer
var total_play_time: float = 0.0

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
	Log.info("Toggling mouse mode")
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			g.pause_menu.visible = true
			get_tree().paused = true
			pause_runtime_timer()

		Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			g.pause_menu.visible = false
			resume_runtime_timer()

# Runtime timer functions
func setup_runtime_timer():
	runtime_timer = Timer.new()
	runtime_timer.wait_time = 0.01  # Update every 0.01 seconds (10ms)
	runtime_timer.autostart = false  # Don't auto-start
	runtime_timer.timeout.connect(_on_runtime_tick)
	add_child(runtime_timer)

func start_runtime_timer():
	if runtime_timer:
		runtime_timer.start()
		total_play_time = 0.0  # Reset timer
		Log.info("Runtime timer started")

func _on_runtime_tick():
	total_play_time += 0.01

func get_current_runtime() -> float:
	return total_play_time

func pause_runtime_timer():
	if runtime_timer:
		runtime_timer.paused = true
		Log.info("Runtime paused at: %d seconds" % total_play_time)

func resume_runtime_timer():
	if runtime_timer:
		runtime_timer.paused = false
		Log.info("Runtime resumed")

func log_final_runtime():
	var final_time = total_play_time
	var minutes = int(final_time / 60)
	var seconds = final_time - (minutes * 60)
	Log.info("FINAL TIME: %d minutes, %.2f seconds (%.2f total seconds)" % [minutes, seconds, final_time])

func clear_runtime_timer():
	if runtime_timer:
		runtime_timer.queue_free()

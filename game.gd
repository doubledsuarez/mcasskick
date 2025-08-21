extends Node3D
#@onready var hud_scene = preload("res://ui/hud/hud.tscn")

@export var dev_mode := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	g.game = self
	
	g.dev_mode = dev_mode
	

extends Node3D
#@onready var hud_scene = preload("res://ui/hud/hud.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	g.game = self
	

extends Node3D
@onready var hud_scene = preload("res://ui/hud/hud.tscn")
var hud_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	g.game = self
	hud_instance = hud_scene.instantiate()
	add_child(hud_instance)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HealthLabel.text = "HP: %s" % g.player.health

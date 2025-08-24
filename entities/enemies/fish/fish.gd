extends Enemy
class_name Fish

# slowly walks towards the player and shoots fireballs

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

extends Enemy

func _ready() -> void:
	super._ready()
	animated_sprite_3d.modulate = Color.RED

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

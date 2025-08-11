extends ToggleObject

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_3d.play("walking")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func kill() -> void:
	animated_sprite_3d.play("dying")


func _on_animated_sprite_3d_animation_finished() -> void:
	queue_free()

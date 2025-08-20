extends CanvasLayer


@onready var health_label = $main_box/MarginContainer/MarginContainer/display_seperator/health/header_content_seperator/health_content

# rick head icon
@onready var chill_icon = %rick_head

# preloaded textures
@onready var full_chill_icon = preload("res://ui/sprite/rick_glasses.png")
@onready var low_chill_icon = preload("res://ui/sprite/rick_no_glasses.png")

func _ready() -> void:
	g.player.health_changed.connect(_on_health_changed)
	
	
func _process(delta: float) -> void:
	health_label.text = str(g.player.health)
	
func _on_health_changed(new_health: int) -> void:
	health_label.text = str(new_health)

	if new_health <= 75:
		chill_icon.texture = low_chill_icon
	
	else:
		chill_icon.texture = full_chill_icon
	
	

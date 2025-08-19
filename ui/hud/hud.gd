extends CanvasLayer


@onready var health_label = $main_box/MarginContainer/MarginContainer/display_seperator/health/header_content_seperator/health_content

func _ready() -> void:
	g.player.health_changed.connect(_on_health_changed)
	
	
func _process(delta: float) -> void:
	health_label.text = str(g.player.health)
	
func _on_health_changed(new_health: int) -> void:
	health_label.text = str(new_health)
	
	
	

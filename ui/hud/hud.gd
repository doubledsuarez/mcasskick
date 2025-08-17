extends CanvasLayer


@onready var health_label = $main_box/MarginContainer/MarginContainer/display_seperator/health/header_content_seperator/health_content

func _on_health_changed(new_health: int) -> void:
	health_label.text = new_health

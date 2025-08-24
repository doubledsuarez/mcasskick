extends CanvasLayer


@onready var health_label = $main_box/MarginContainer/MarginContainer/display_seperator/health/header_content_seperator/health_content
@export var trinket_grid : GridContainer = null

func _ready() -> void:
	g.player.health_changed.connect(_on_health_changed)
	g.player.item_picked_up.connect(_item_picked_up)
	
	
func _process(delta: float) -> void:
	health_label.text = str(g.player.health)
	
func _on_health_changed(new_health: int) -> void:
	#health_label.text = str(new_health)
	pass

func _item_picked_up(figurine_name:String):
	if trinket_grid != null:
		# Loop through the TriketGrids children, and see if any have a figurine name
		# that matches the item picked up name
		for display in trinket_grid.get_children():
			if display.figurine_name == figurine_name:
				if display.has_method("set_collected"):
					display.set_collected()
	

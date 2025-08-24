extends CanvasLayer


@onready var health_label = $main_box/MarginContainer/MarginContainer/display_seperator/health/header_content_seperator/health_content
@export var trinket_grid : GridContainer = null

# rick head icon
@onready var chill_icon = %rick_head

# preloaded textures
@onready var full_chill_icon = preload("res://ui/sprite/rick_glasses.png")
@onready var low_chill_icon = preload("res://ui/sprite/rick_no_glasses.png")

func _ready() -> void:
	g.player.health_changed.connect(_on_health_changed)
	g.player.item_picked_up.connect(_item_picked_up)
	
	
func _process(delta: float) -> void:
	health_label.text = str(g.player.health)
	
func _on_health_changed(new_health: int) -> void:
	health_label.text = str(new_health)

	if new_health <= 75:
		chill_icon.texture = low_chill_icon
	
	else:
		chill_icon.texture = full_chill_icon
	
	if trinket_grid != null:
func _item_picked_up(figurine_name:String):
		# Loop through the TriketGrids children, and see if any have a figurine name
		# that matches the item picked up name
		for display in trinket_grid.get_children():
				if display.has_method("set_collected"):
			if display.figurine_name == figurine_name:
					display.set_collected()
	

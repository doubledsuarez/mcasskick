extends CanvasLayer


@export var health_label : RichTextLabel
@export var chill_label : RichTextLabel
@export var ammo_label : RichTextLabel
@export var trinket_grid : GridContainer = null

# rick head icon
@onready var chill_icon = %rick_head

# preloaded textures
@onready var full_chill_icon = preload("res://ui/sprite/rick_glasses.png")
@onready var low_chill_icon = preload("res://ui/sprite/rick_no_glasses.png")

var chill_amount := 0.0

var ammo_amount := 9923

func _ready() -> void:
	g.player.health_changed.connect(_on_health_changed)
	g.player.item_picked_up.connect(_item_picked_up)
	g.player.shooting.connect(_set_ammo_count)
	g.player.voice_line_trigger.connect(_voice_line)
	g.final_lines.rick_line.connect(_voice_line)
	g.final_scene_3d.rick_still_talking.connect(_voice_line)
	g.hide_hud.connect(hide_hud)
	g.reveal_hud.connect(reveal_hud)
	g.give_kitty_away.connect(give_kitty_away)
	_set_ammo_count()

func hide_hud():
	visible = false

func reveal_hud():
	visible = true
	
	
func _process(delta: float) -> void:
	health_label.text = str(g.player.health)
	
func _on_health_changed(new_health: int) -> void:
	health_label.text = str(new_health)


func _item_picked_up(figurine_name:String):
	if trinket_grid != null:
		# Loop through the TriketGrids children, and see if any have a figurine name
		# that matches the item picked up name
		for display in trinket_grid.get_children():
			if display.has_method("set_collected"):
				if display.figurine_name == figurine_name:
						display.set_collected()
						
		# Set the chill %
		chill_amount += 12.5
		chill_label.text = str(int(chill_amount), "%")
		
		if chill_amount >= 50:
			chill_icon.texture = low_chill_icon
	
		else:
			chill_icon.texture = full_chill_icon

func give_kitty_away():
	$main_box/MarginContainer/HudContents/display_seperator/trinkets/GridContainer/TrinketDisplay2.set_not_collected()

func _set_ammo_count():
	ammo_amount -= 1
	ammo_label.text = str(ammo_amount)
	
	
func _voice_line():
	$TalkAnim.play("talk")

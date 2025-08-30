extends MarginContainer

@export var figurine_name := ""
@export var figurine_texture : Texture2D
@onready var trinket_display := $MarginContainer/trinket_display

func _ready():
	trinket_display.visible = false
	trinket_display.texture = figurine_texture

func set_collected():
	trinket_display.visible = true

func set_not_collected():
	trinket_display.visible = false

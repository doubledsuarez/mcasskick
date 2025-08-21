extends RichTextLabel
class_name CellPhoneText

# Cellphone Text

# This will display text showing what is unlocked

func _ready():
	visible = false

func set_cellphonetext(new_text:String):
	visible = true
	text = ""
	
	for i in new_text:
		# The & sign will be used to detect a slightly larger pause
		# so we can have a more dramatic buildup to "A gentler world"
		if i == "&":

			await get_tree().create_timer(1.5).timeout
			i += "[color=#ff61a8]"
			#add_theme_color_override("default_color", Color("ff61a8"))
			continue
	
		text += i
		await get_tree().create_timer(.01).timeout

func set_not_visible():
	visible = false
	#add_theme_color_override("default_color", Color("29ff0a"))

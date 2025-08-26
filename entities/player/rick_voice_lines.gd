extends AudioStreamPlayer

# This will play rick voice lines

@export var blast_demons : AudioStream
@export var chew_bubblegum : AudioStream
@export var what_the_heck : AudioStream
@export var kittycutie_spotted : AudioStream
@export var ive_always_wanted_one : AudioStream
@export var hungry : AudioStream
@export var who_am_i : AudioStream
@export var cellphone_spotted : AudioStream
@export var cellphone_used : AudioStream
@export var cuddly_descent : AudioStream
@export var figurine_collected : AudioStream
@export var final_staircase : AudioStream

func play_line(line_name:String):
	if line_name in self:
		stream = get(line_name)
		play()
		get_parent().emit_signal("voice_line_trigger")
		
func play_line_conditional(line_name:String):
	if playing == false:
		if line_name in self:
			stream = get(line_name)
			play()
			get_parent().emit_signal("voice_line_trigger")

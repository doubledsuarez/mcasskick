extends Node

@export var dk_meet_again : AudioStream
@export var you_took_everything : AudioStream
@export var dk_pathetic_toy : AudioStream
@export var mr_snuggles : AudioStream
@export var dk_sentimental_fool : AudioStream
@export var making_new_friends : AudioStream
@export var its_not_killing_demons : AudioStream
@export var dk_what : AudioStream
@export var the_evil_is_bad : AudioStream
@export var dont_you_get_tired : AudioStream
@export var dk_rethinking : AudioStream
@export var gift : AudioStream
@export var dk_is_that : AudioStream
@export var kittie_cutie_description : AudioStream
@export var dk_giving_this_to_me : AudioStream
@export var you_bet_your_ass_i_am: AudioStream
@export var dk_final : AudioStream
@export var forever : AudioStream

@onready var rick := $Rick
@onready var demon_king := $DemonKing

signal demon_line
signal rick_line

func _ready():
	g.final_lines = self

func play_line(line_name:String, speaker_name:String):
	if line_name in self:
		if speaker_name in self:
			var speaker = get(speaker_name)
			speaker.stream = get(line_name)
			speaker.play()
		
		if speaker_name == "rick":
			emit_signal("rick_line")
		elif speaker_name == "demon_king":
			emit_signal("demon_line")

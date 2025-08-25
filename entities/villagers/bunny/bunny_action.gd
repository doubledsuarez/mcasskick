extends Area3D

const BALLOON = preload("res://ui/balloon.tscn")

@export var tutorial_resource: DialogueResource
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"


func action() -> void:
	g.player.immobile = true
	g.player.shooting_enabled = false
	g.player.in_dialogue = true
	g.player.jumping_enabled = false
	
	if g.tutorial_done:
		DialogueManager.show_dialogue_balloon_scene(BALLOON, dialogue_resource, dialogue_start)
	else:
		DialogueManager.show_dialogue_balloon_scene(BALLOON, tutorial_resource, dialogue_start)
	

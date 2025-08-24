extends Villager

const BALLOON = preload("res://ui/balloon.tscn")

@export var confetti_resource: DialogueResource
@export var dialogue_start: String = "start"

func have_party() -> void:
	DialogueManager.show_dialogue_balloon_scene(BALLOON, confetti_resource, dialogue_start)

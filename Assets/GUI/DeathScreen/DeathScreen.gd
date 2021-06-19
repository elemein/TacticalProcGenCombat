extends Node

# Sound effects
onready var death_sounds = $Audio

func _ready():
	var num_audio_effects = death_sounds.get_children().size()
	death_sounds.get_children()[randi() % num_audio_effects].play()

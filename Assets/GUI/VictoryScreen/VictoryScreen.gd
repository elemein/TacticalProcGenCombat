extends Node

# Sound effects
onready var victory_sounds = $Audio

func _ready():
	var num_audio_effects = self.victory_sounds.get_children().size()
	self.victory_sounds.get_children()[randi() % num_audio_effects].play()

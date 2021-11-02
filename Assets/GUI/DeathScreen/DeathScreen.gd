extends Node

# Sound effects
onready var death_sounds = $Audio

func _ready():
	var num_audio_effects = death_sounds.get_children().size()
	death_sounds.get_children()[randi() % num_audio_effects].play()
	
	# Reset server info
	Server.player_list = []
	GlobalVars.server_mapset = null
	GlobalVars.server_map_data = null
	GlobalVars.server_player = null
	GlobalVars.total_mapsets = []
	GlobalVars.total_maps = []
	GlobalVars.self_instanceID = null
	GlobalVars.self_instanceObj = null

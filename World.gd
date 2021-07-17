extends Node

onready var player = get_node("Player")
onready var turn_timer = get_node("TurnTimer")

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")
var map_generator = MAP_GEN.new()

var maps = []

func _ready():
	var generated_map = map_generator.generate('Dungeon Floor 1', 1)
	
	maps.append(generated_map)

	player.set_parent_map(generated_map)
	var player_pos = generated_map.place_player_on_map(player)
	player.set_map_pos_and_translation(player_pos)
	player.add_sub_nodes_as_children()
	
	turn_timer.set_map(generated_map)

	generated_map.print_map_grid()
	
	add_child(generated_map)
	
	first_turn_workaround_for_player_sight()

func first_turn_workaround_for_player_sight():
	player.viewfield = player.view_finder.find_view_field(player.get_map_pos()[0], player.get_map_pos()[1])	
	player.get_parent_map().hide_non_visible_from_player()

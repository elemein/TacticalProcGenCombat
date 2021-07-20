extends Node

const BASE_PLAYER = preload("res://Assets/Objects/PlayerObjects/Player.tscn")
var player = BASE_PLAYER.instance()

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")
var map_generator = MAP_GEN.new()

var maps = []

func _ready():
	var floor_1 = map_generator.generate('Dungeon Floor 1', 1)
	var floor_2 = map_generator.generate('Dungeon Floor 2', 2)
	
	maps.append(floor_1)
	maps.append(floor_2)

	# setup player on map
	player.set_parent_map(floor_1)
	var player_pos = floor_1.place_player_on_map(player)
	player.set_map_pos_and_translation(player_pos)

	floor_1.print_map_grid()
	
	add_child(floor_1)
	add_child(floor_2)
	
	first_turn_workaround_for_player_sight()

func move_to_map(object, target_map_id):
	var map_to_move_to
	for map in maps:
		if map.map_id == target_map_id:
			map_to_move_to = map
			
	object.get_parent_map().hide_all()
			
	object.set_parent_map(map_to_move_to)
	var player_pos = map_to_move_to.place_player_on_map(object)
	object.set_map_pos_and_translation([map_to_move_to.spawn_room.center.x, map_to_move_to.spawn_room.center.z])
	
	first_turn_workaround_for_player_sight()
	
func first_turn_workaround_for_player_sight():
	player.viewfield = player.view_finder.find_view_field(player.get_map_pos()[0], player.get_map_pos()[1])	
	player.get_parent_map().hide_non_visible_from_player()

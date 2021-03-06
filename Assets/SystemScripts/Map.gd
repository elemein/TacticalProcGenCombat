extends Node

# This script is way overloaded and needs to be refactored.
# Things to move OUT:
# ALL mapgen shit. The map should contain the map; it shouldnt generate itself.
# Revealing and hiding things from the player.

const TIMER_SCENE = preload("res://Assets/Objects/TurnTimer.tscn")
var turn_timer = TIMER_SCENE.instance()

var rng = RandomNumberGenerator.new()

var in_view_objects = []

# MAP is meant to be accessed via [x][z] where '0' is a blank tile.
var parent_mapset
var map_name = ''
var map_id = 1
var map_server_id 
var map_grid = []
var rooms

var map_type
var spawn_room
var exit_room

var catalog_of_ground_tiles = []

var current_number_of_enemies = 0

func _init(name, id, type):
	map_name = name
	map_id = id
	map_type = type

func _ready():
	map_server_id = get_instance_id()
	rng.randomize()
	turn_timer.set_map(self)
	add_child(turn_timer)
	
	add_map_objects_to_tree()
	
	catalog_ground_tiles()

func set_map_grid_and_dict(grid, dict):
	map_grid = grid
	rooms = dict
	
func add_map_objects_to_tree():
	for line in map_grid.size():
		for column in map_grid[0].size():
			for object in map_grid[line][column]:
				if object.get_parent() != null:
					object.get_parent().remove_child(object)
				add_child(object)
				if object.get_id()['CategoryType'] == 'Enemy':
					object.setup_actor()
					current_number_of_enemies += 1

func place_player_on_map(object):
	var player = object
	
	for room in rooms:
		if room['type'] == 'Player Spawn':
			var tile = [room.center[0], room.center[1]]
			map_grid[tile[0]][tile[1]].append(object)
			
			# WORKAROUND
			var players_node = get_node('Players')
			if players_node != null:
				players_node.add_child(player)
			else:
				add_child(player)
				
			turn_timer.add_to_timer_group(player)
			return tile

func move_on_map(object, old_pos, new_pos):
	map_grid[new_pos[0]][new_pos[1]].append(object)
	map_grid[old_pos[0]][old_pos[1]].erase(object)
	
	return [new_pos[0], new_pos[1]]

func print_map_grid():
	print('-----') # Divider
	var print_grid = map_grid.duplicate()
	print_grid.invert()
	for line in print_grid:
		var converted_row = []
		for tile in line:
			var to_append = ''
			
			for object in tile:
				match object.get_id()['Identifier']:
					'BaseWall':
						if (to_append in ['X', 'E', 't','c','s', 'm']) == false: 
							to_append = '.'
					'BaseGround':
						if (to_append in ['X', 'E', 't','c','s', 'm']) == false: 
							to_append = '0'
					'Player': to_append = 'X'
					'Imp': to_append = 'i'
					'Fox': to_append = 'f'
					'Minotaur': to_append = 'B'
					'Spike Trap': to_append = 't'
					'Coins': to_append = 'c'

					'Sword': to_append = 's'
					'Magic Staff': to_append = 'm'
			
			converted_row.append(to_append)
		print(converted_row)

func catalog_ground_tiles():
	for x in range(0, map_grid.size()-1):
		for z in range(0, map_grid[0].size()-1):
			if tile_available(x,z): catalog_of_ground_tiles.append([x,z])

func choose_random_ground_tile():
	return catalog_of_ground_tiles[rng.randi_range(0, catalog_of_ground_tiles.size()-1)]

func get_tile_contents(x,z):
	if !tile_in_bounds(x,z): 
		return 'Out of Bounds'
	
	return map_grid[x][z]

func tile_in_bounds(x,z):
	return (x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size())

func tile_available(x,z):
	if tile_in_bounds(x,z): 
		for object in map_grid[x][z]:
			if object.get_id()['CategoryType'] in GlobalVars.NON_TRAVERSABLES: return false
			
			if (object.get_id()['CategoryType'] == 'Enemy') or \
				(object.get_id()['CategoryType'] == 'Player'):
				if object.get_is_dead() == true: continue
				else: return false
		return true
	return false

func is_tile_wall(x,z):
	if tile_in_bounds(x,z): 
		for object in map_grid[x][z]:
			if object.get_id()['CategoryType'] in ['Wall', 'TempWall']: return true
	return false

func get_map():
	return map_grid

func add_map_object(object):
	var tile = object.get_map_pos()
	
	map_grid[tile[0]][tile[1]].append(object)
	add_child(object)

# REMOVE FROM MAP FUNCS --------------------
func remove_map_object(object):
	var tile = object.get_map_pos()
	
	map_grid[tile[0]][tile[1]].erase(object)
	object.get_parent().remove_child(object)

func remove_from_map_grid_but_keep_node(object):
	var tile = object.get_map_pos()
	map_grid[tile[0]][tile[1]].erase(object)

func remove_from_map_tree(object):
	remove_child(object)
# -----------------------------------------

func check_for_map_events():
	
	var relevant_player_list = []
	for player in Server.get_player_list():
		if player.get_id()['Map ID'] == get_map_server_id():
			relevant_player_list.append(player)
	
	# Check if rooms should lock:
	for room in rooms:
		room.check_if_locking(relevant_player_list)

# Getters
func get_turn_timer() -> Object: return turn_timer

func get_parent_mapset() -> Object: return parent_mapset

func get_map_name() -> String: return map_name

func get_map_type() -> String: return map_type

func get_map_server_id(): return map_server_id

# Setters
func set_parent_mapset(mapset): parent_mapset = mapset

func log_enemy_death(dead_enemy): 
	current_number_of_enemies -= 1
	
	for room in rooms:
		var in_room = room.pos_in_room(dead_enemy.get_map_pos())
		if in_room == true:
			room.log_enemy_death(dead_enemy)

func return_map_grid_encoded_to_string():
	var to_return = []
	
	for x in range(map_grid.size()):
		to_return.append([])
		for z in range(map_grid[0].size()):
			to_return[x].append([])
			for obj in range(map_grid[x][z].size()):
				to_return[x][z].append([])
				to_return[x][z][obj].append(map_grid[x][z][obj].get_id())
#				print(map_grid[x][z][obj].get_id()['Identifier'])

	return to_return

func return_rooms_encoded_to_dict():
	var to_return = []
	
	for room in rooms:
		var dict_to_add = {}
		
		dict_to_add['parent_map_id'] = room.parent_map.map_server_id
		dict_to_add['id'] = room.id
		dict_to_add['type'] = room.type

		dict_to_add['split'] = room.split
		dict_to_add['center'] = room.center
		
		dict_to_add['x'] = room.x
		dict_to_add['z'] = room.z
		dict_to_add['w'] = room.w
		dict_to_add['l'] = room.l
		dict_to_add['area'] = room.area
		
		dict_to_add['topleft'] = room.topleft
		dict_to_add['topright'] = room.topright
		dict_to_add['bottomleft'] = room.bottomleft
		dict_to_add['bottomright'] = room.bottomright
		
		dict_to_add['enemy_count'] = room.enemy_count
		dict_to_add['exits'] = room.exits
		dict_to_add['distance_to_spawn'] = room.distance_to_spawn
		
		to_return.append(dict_to_add)
		
	return to_return

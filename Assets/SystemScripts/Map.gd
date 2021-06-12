extends Node

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")

var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_enemy = preload("res://Assets/Objects/EnemyObjects/Enemy.tscn")

var rng = RandomNumberGenerator.new()
var map_generator = MAP_GEN.new()

var in_view_objects = []
var player

onready var turn_timer = get_node("/root/World/TurnTimer")

# MAP is meant to be accessed via [x][z] where '0' is a blank tile.
var map_grid = []
var map_dict
var catalog_of_ground_tiles = []

var current_number_of_enemies = 0

func _ready():
	rng.randomize()

	var generated_map = map_generator.generate()
	
	map_grid = generated_map[0]
	map_dict = generated_map[1]
	
	add_map_objects_to_tree()
	
	catalog_ground_tiles()

func add_map_objects_to_tree():
	for line in map_grid.size():
		for column in map_grid[0].size():
			for object in map_grid[line][column]:
				add_child(object)
				if object.get_obj_type() == 'Enemy':
					object.setup_actor()
					current_number_of_enemies += 1

func place_player_on_map(object):
	player = object # caches player for future funcs
	
	for room in map_dict:
		if room['type'] == 'Player Spawn':
			var tile = []
			tile.append(room['center'].x)
			tile.append(room['center'].y)
			map_grid[tile[0]][tile[1]].append(object)
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
				match object.get_obj_type():
					'Wall':
						if (to_append in ['X', 'E', 't','c','s']) == false: 
							to_append = '.'
					'Ground':
						if (to_append in ['X', 'E', 't','c','s']) == false: 
							to_append = '0'
					'Player': to_append = 'X'
					'Enemy': to_append = 'E'
					'Spike Trap': to_append = 't'
					'Coins': to_append = 'c'
					'Sword': to_append = 's'
			
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
			if object.get_obj_type() == 'Wall': return false
			
			if object.get_obj_type() in ['Enemy', 'Player']:
				if object.get_is_dead() == true: continue
				else: return false
		return true
	return false

func is_tile_wall(x,z):
	if tile_in_bounds(x,z): 
		for object in map_grid[x][z]:
			if object.get_obj_type() == 'Wall': return true
	return false

func get_map():
	return map_grid

func hide_non_visible_from_player():
	var viewfield = player.get_viewfield()
	
	for tile in in_view_objects: 
		var objects_on_tile = get_tile_contents(tile[0], tile[1])
		for object in objects_on_tile:
			object.visible = false
	
	for tile in viewfield: 
		var objects_on_tile = get_tile_contents(tile[0], tile[1])
		
		for object in objects_on_tile:
			if object.get_obj_type() != 'Spike Trap': # dont reveal traps
				object.visible = true
		
	in_view_objects = viewfield

func add_map_object(object):
	var tile = object.get_map_pos()
	
	map_grid[tile[0]][tile[1]].append(object)
	add_child(object)

func remove_map_object(object):
	var tile = object.get_map_pos()
	
	map_grid[tile[0]][tile[1]].erase(object)
	remove_child(object)
	

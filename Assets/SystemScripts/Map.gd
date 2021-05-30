extends Node

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2
const NUMBER_OF_ENEMIES = 10

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")
const PATHFINDER = preload("res://Assets/SystemScripts/PathFinder.gd")

var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_enemy = preload("res://Assets/Objects/EnemyObjects/Enemy.tscn")

var rng = RandomNumberGenerator.new()
var map_generator = MAP_GEN.new()
var pathfinder = PATHFINDER.new()

var in_view = []
var player

onready var turn_timer = get_node("/root/World/TurnTimer")

# MAP is meant to be accessed via [x][z] where '0' is a blank tile.
var map_grid = []
var catalog_of_ground_tiles = []

var current_number_of_enemies = 0

func _ready():
	rng.randomize()

	map_grid = map_generator.generate()
	
	add_map_objects_to_tree()
	
	catalog_ground_tiles()
	
	spawn_enemies()
	
	add_child(pathfinder)

func add_map_objects_to_tree():
	for line in map_grid.size():
		for column in map_grid[0].size():
			for object in map_grid[line][column]:
				add_child(object)

func spawn_enemies():
	for enemy_cnt in NUMBER_OF_ENEMIES:
		var tile = null
		
		while tile == null:
			tile = choose_random_ground_tile()
			if !tile_available(tile[0],tile[1]): tile = null

		var enemy = base_enemy.instance()
		add_child(enemy)
		enemy.translation = Vector3(tile[0] * TILE_OFFSET, Y_OFFSET+0.3, tile[1] * TILE_OFFSET)
		enemy.visible = false
		enemy.add_to_group('enemies')
		enemy.setup_actor()
		
		current_number_of_enemies += 1

func place_on_random_avail_tile(object):
	if object.get_obj_type() == 'Player': player = object # caches player for future funcs
	
	var avail = false
	var tile
	
	while avail == false:
		tile = choose_random_ground_tile()
		if tile_available(tile[0], tile[1]) == true:
			avail = true
	
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
				match typeof(object):
					TYPE_STRING:
						converted_row.append(object)
					TYPE_OBJECT:
						if object.get_obj_type() == 'Wall':
							if (to_append in ['X', 'E']) == false: 
								to_append = '.'
						if object.get_obj_type() == 'Ground':
							if (to_append in ['X', 'E']) == false: 
								to_append = '0'
						if object.get_obj_type() == 'Player':
							to_append = 'X'
						if object.get_obj_type() == 'Enemy':
							to_append = 'E'
			
			converted_row.append(to_append)
		print(converted_row)

func catalog_ground_tiles():
	for x in range(0, map_grid.size()-1):
		for z in range(0, map_grid[0].size()-1):
			var only_empty_ground_in_tile = true

			for object in map_grid[x][z]:
				if object.get_obj_type() != 'Ground':
					only_empty_ground_in_tile = false
			
			if only_empty_ground_in_tile: catalog_of_ground_tiles.append([x,z])

func choose_random_ground_tile():
	return catalog_of_ground_tiles[rng.randi_range(0, catalog_of_ground_tiles.size()-1)]

func get_tile_contents(x,z):
	if !(x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size()): 
		return 'Out of Bounds'
	
	return map_grid[x][z]

func tile_available(x,z):
	if (x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size()): 
		var only_empty_ground_in_tile = true
		
		for object in map_grid[x][z]:
			if object.get_obj_type() != 'Ground':
				if object.get_obj_type() in ['Enemy', 'Player']:
					if object.get_is_dead() == true: continue
				else: only_empty_ground_in_tile = false
				
		if only_empty_ground_in_tile: return true
		
	return false

func is_tile_wall(x,z):
	if (x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size()): 
		for object in map_grid[x][z]:
			if object.get_obj_type() == 'Wall':
				return true
	return false

func get_map():
	return map_grid

func pathfind(searcher, start_pos, goal_pos):
	return pathfinder.solve(searcher, start_pos, goal_pos)

func hide_non_visible_from_player():
	var actors = turn_timer.get_actors()
	var viewfield
	
	# Get their view
	viewfield = player.get_viewfield()
	
#	print('- to remove')
#	print(in_view)
	for tile in in_view: 
		var objects_on_tile = get_tile_contents(tile[0], tile[1])
		for object in objects_on_tile:
			object.visible = false
	
#	print('- to add')
#	print(viewfield)
	for tile in viewfield: 
		var objects_on_tile = get_tile_contents(tile[0], tile[1])
		
		for object in objects_on_tile:
#			print("---")
#			print(tile[0], tile[1])
#			print(object)
#			print(object.visible)
			object.visible = true
#			print(object.visible)
		
			
	in_view = viewfield

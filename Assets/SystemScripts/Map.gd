extends Node

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2
const NUMBER_OF_ENEMIES = 7

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")
const PATHFINDER = preload("res://Assets/SystemScripts/PathFinder.gd")

var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_enemy = preload("res://Assets/Objects/EnemyObjects/Enemy.tscn")

var rng = RandomNumberGenerator.new()
var map_generator = MAP_GEN.new()
var pathfinder = PATHFINDER.new()

onready var turn_timer = get_node("/root/World/TurnTimer")

# MAP is meant to be accessed via [x][z] where '0' is a blank tile.
var map_grid = []
var catalog_of_ground_tiles = []

var current_number_of_enemies = 0

func _ready():
	rng.randomize()

	map_grid = map_generator.generate()
	populate_map_ground()
	
	catalog_ground_tiles()
	
	spawn_enemies()
	
	add_child(pathfinder)

func populate_map_ground():
	# create the map based on the map_x and map_y variables
	var x_offset = -TILE_OFFSET
	var z_offset = -TILE_OFFSET
		
	for x in range(0, map_grid.size()-1):
		x_offset += TILE_OFFSET
		z_offset = -TILE_OFFSET # Reset
		for z in range(0, map_grid[0].size()-1):
			z_offset += TILE_OFFSET
			
			if map_grid[x][z] == '0':
				var block = base_block.instance()
				add_child(block)
				block.translation = Vector3(x_offset, Y_OFFSET, z_offset)

func spawn_enemies():
	for enemy_cnt in NUMBER_OF_ENEMIES:
		var tile = null
		
		while tile == null:
			tile = choose_random_ground_tile()
			if !tile_available(tile[0],tile[1]): tile = null

		var enemy = base_enemy.instance()
		add_child(enemy)
		enemy.translation = Vector3(tile[0] * TILE_OFFSET, Y_OFFSET+0.3, tile[1] * TILE_OFFSET)
		enemy.add_to_group('enemies')
		enemy.setup_actor()
		
		current_number_of_enemies += 1

func place_on_map(object):
	var tile = choose_random_ground_tile()
	map_grid[tile[0]][tile[1]] = object
	return tile

func move_on_map(object, old_pos, new_pos):
	map_grid[old_pos[0]][old_pos[1]] = '0'
	map_grid[new_pos[0]][new_pos[1]] = object
	return [new_pos[0], new_pos[1]]

func print_map_grid():
	print('-----') # Divider
	var print_grid = map_grid.duplicate()
	print_grid.invert()
	for line in print_grid:
		var converted_row = []
		for tile in line:
			match typeof(tile):
				TYPE_STRING:
					converted_row.append(tile)
				TYPE_OBJECT:
					converted_row.append(tile.get('object_type'))
		print(converted_row)

func catalog_ground_tiles():
	for x in range(0, map_grid.size()-1):
		for z in range(0, map_grid[0].size()-1):
			if map_grid[x][z] == '0':
				catalog_of_ground_tiles.append([x,z])

func choose_random_ground_tile():
	return catalog_of_ground_tiles[rng.randi_range(0, catalog_of_ground_tiles.size()-1)]

func get_tile_contents(x,z):
	if !(x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size()): 
		return 'Out of Bounds'
	
	return map_grid[x][z]

func tile_available(x,z): # Is a tile 
	if (x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size()): 
		if typeof(map_grid[x][z]) == TYPE_STRING:
			if map_grid[x][z] == '0':
				return true
	return false

func get_map():
	return map_grid

func pathfind(searcher, start_pos, goal_pos):
	return pathfinder.solve(searcher, start_pos, goal_pos)
	

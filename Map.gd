extends Node

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2
const MAX_NUMBER_OF_ENEMIES = 3

var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_enemy = preload("res://Assets/Objects/EnemyObjects/Enemy.tscn")

onready var turn_timer = get_node("/root/World/TurnTimer")

# MAP is meant to be accessed via [x][z] where '0' is a blank tile.
var map_x = 5
var map_z = 7
var map_grid = []

var current_number_of_enemies = 0

func _ready():
	randomize()
	create_empty_map()
	spawn_enemies()

func create_empty_map():
	# create the map based on the map_x and map_y variables
	var map_width = []
	for x in map_x:
		map_width.append('0')

	for z in map_z:
		map_grid.append(map_width.duplicate())
		
	var x_offset = -TILE_OFFSET
	var z_offset = -TILE_OFFSET
		
	for x_coord in map_grid:
		x_offset += TILE_OFFSET
		z_offset = -TILE_OFFSET # Reset
		for z_coord in x_coord:
			z_offset += TILE_OFFSET
			
			var block = base_block.instance()
			add_child(block)
			block.translation = Vector3(x_offset, Y_OFFSET, z_offset)

func spawn_enemies():
	for enemy_cnt in MAX_NUMBER_OF_ENEMIES:
		# Get random x/y coords to spawn enemy
		var enemy_x = null
		var enemy_z = null
		
		# Prevent enemies from being spawned on the same tile.
		while enemy_x == null && enemy_z == null:
			enemy_x = randi() % map_grid.size()
			enemy_z = randi() % map_grid[enemy_x].size()
			if typeof(map_grid[enemy_x][enemy_z]) != TYPE_STRING:
				enemy_x = null
				enemy_z = null
		
		var enemy = base_enemy.instance()
		add_child(enemy)
		enemy.translation = Vector3(enemy_x * TILE_OFFSET, Y_OFFSET+0.3, enemy_z * TILE_OFFSET)
		enemy.add_to_group('enemies')
		enemy.setup_actor()
		
		current_number_of_enemies += 1

func place_on_map(object, curr_pos):
	var x_pos = int(curr_pos.x/TILE_OFFSET)
	var z_pos = int(curr_pos.z/TILE_OFFSET)
	map_grid[x_pos][z_pos] = object
	return [x_pos, z_pos]

func move_on_map(object, old_pos, new_pos):
	# Clear old location.
	map_grid[old_pos[0]][old_pos[1]] = '0'
	map_grid[new_pos[0]][new_pos[1]] = object

	return [new_pos[0], new_pos[1]]

func tile_available(x,z): # Is a tile 
	if (x >= 0 && z >= 0 && x < map_grid.size()): # There's no try-except, so this has to be very explicit.
		if z < map_grid[x].size():
			if typeof(map_grid[x][z]) == TYPE_STRING: # '4' is the integer representation for a string.
				if map_grid[x][z] == '0':
					return true
		
	return false

func print_map_grid():
	map_grid.invert()
	print('---')
	for line in map_grid:
		print(line)
	map_grid.invert()

func get_tile_contents(x,z):
	return map_grid[x][z]

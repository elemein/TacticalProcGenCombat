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
	var x_offset = -TILE_OFFSET
	var z_offset = -TILE_OFFSET

	create_empty_map()
	spawn_enemies()

	for x_coord in map_grid:
		x_offset += TILE_OFFSET
		z_offset = -TILE_OFFSET # Reset
		for z_coord in x_coord:
			z_offset += TILE_OFFSET
			
			var block = base_block.instance()
			add_child(block)
			block.translation = Vector3(x_offset, Y_OFFSET, z_offset)

			if z_coord == '1':
				var enemy = base_enemy.instance()
				add_child(enemy)
				enemy.translation = Vector3(x_offset, Y_OFFSET+0.3, z_offset)
				enemy.add_to_group('enemies')
				enemy.setup_actor()

func create_empty_map():
	# create the map based on the map_x and map_y variables
	var map_width = []
	for x in map_x:
		map_width.append('0')

	for z in map_z:
		map_grid.append(map_width.duplicate())

func spawn_enemies():
	for enemy_cnt in MAX_NUMBER_OF_ENEMIES:

		# Get random x/y coords to spawn enemy
		var enemy_x = 0
		var enemy_z = 0
		while enemy_x == 0 and enemy_z == 0 and map_grid[enemy_x][enemy_z] != '1':
			enemy_x = randi() % map_grid.size()
			enemy_z = randi() % map_grid[enemy_x].size()
		map_grid[enemy_x][enemy_z] = '1'
		current_number_of_enemies += 1

func place_on_map(object, curr_pos):
	var x_pos = int(curr_pos.x/TILE_OFFSET)
	var z_pos = int(curr_pos.z/TILE_OFFSET)
	map_grid[x_pos][z_pos] = object
	return [x_pos, z_pos]

func move_on_map(object, old_pos, new_pos):
	# Place object at new location.
	var new_x_pos = int(stepify(new_pos.x, 0.1)/TILE_OFFSET)
	var new_z_pos = int(stepify(new_pos.z, 0.1)/TILE_OFFSET)
	map_grid[new_x_pos][new_z_pos] = object
	# Clear old location.
	var old_x_pos = int(stepify(old_pos.x, 0.1)/TILE_OFFSET)
	var old_z_pos = int(stepify(old_pos.z, 0.1)/TILE_OFFSET)
	map_grid[old_x_pos][old_z_pos] = '0'

	return [new_x_pos, new_z_pos]

func tile_available(x,z): # Is a tile 
	if (x >= 0 && z >= 0 && x < map_grid.size()): # There's no try-except, so this has to be very explicit.
		if z < map_grid[x].size():
			if typeof(map_grid[x][z]) == 4: # '4' is the integer representation for a string.
				if map_grid[x][z] == '0':
					return true
		
	return false

func print_map_grid():
	map_grid.invert()
	print('---')
	for line in map_grid:
		print(line)
	map_grid.invert()

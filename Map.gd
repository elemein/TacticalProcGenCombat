extends Node

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2

var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")

# MAP is meant to be accessed via [x][z] where '0' is a blank tile.
var map_grid = [['0', '0', '0', '0', '0', '0', '0', '0'],
				['0', '0', '0', '0', '0', '0', '0', '0'],
				['0', '0', '0', '0', '0', '0', '0', '0'],
				['0', '0', '0', '0', '0', '0', '0', '0'],]

func _ready():
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

func place_on_map(object, curr_pos):
	var x_pos = int(curr_pos.x/TILE_OFFSET)
	var z_pos = int(curr_pos.z/TILE_OFFSET)
	map_grid[x_pos][z_pos] = object
	
	return [x_pos, z_pos]

func move_on_map(object, old_pos, new_pos):
	# Place object at new location.
	var new_x_pos = int(stepify(new_pos.x, 0.1)/TILE_OFFSET)
	var new_z_pos = int(stepify(new_pos.z, 0.1)/TILE_OFFSET)
	print ([int(new_pos.x/TILE_OFFSET), int(new_pos.z/TILE_OFFSET)])
	map_grid[new_x_pos][new_z_pos] = object
	# Clear old location.
	var old_x_pos = int(stepify(old_pos.x, 0.1)/TILE_OFFSET)
	var old_z_pos = int(stepify(old_pos.z, 0.1)/TILE_OFFSET)
	map_grid[old_x_pos][old_z_pos] = '0'
	
	for line in map_grid:
		print(line)
		
	return [new_x_pos, new_z_pos]

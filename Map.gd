extends Node

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2

var base_block = preload("res://BaseBlock.tscn")

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

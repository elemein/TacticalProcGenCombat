# The pathfinding algo used here is BFS/Breadth-First Search. I implement it from
# this video: https://www.youtube.com/watch?v=KiCBXu4P-2Y&ab_channel=WilliamFiset
# with some modifications to suit our usecase.

extends Node

onready var map = get_node("/root/World/Map")

var map_width
var map_height

var visited = []

var start_row = 0
var start_col = 0

var target_pos = 0

var reached_end

var row_queue = []
var col_queue = []

var move_count = 0
var nodes_left_in_layer = 0
var nodes_in_next_layer = 0

func _ready():
	map_height = map.get_map().size()
	map_width = map.get_map()[0].size()

func solve(searcher, start_pos, end_pos):
	start_row = start_pos[0]
	start_col = start_pos[1]
	
	target_pos = end_pos
	
	row_queue = []
	col_queue = []

	move_count = 0
	nodes_left_in_layer = 1
	nodes_in_next_layer = 0

	reached_end = false

	visited = []
	
	row_queue.push_front(start_row)
	col_queue.push_front(start_col)
	visited.append([start_row, start_col])
	
	while row_queue.size() > 0:
		var r = row_queue.pop_back()
		var c = col_queue.pop_back()
		
		if [r,c] == target_pos:
			reached_end = true
			break
		
		explore_neighbors(r,c)
		nodes_left_in_layer -= 1
		
		if nodes_left_in_layer == 0 :
			nodes_left_in_layer = nodes_in_next_layer
			nodes_in_next_layer = 0
			move_count += 1
		

	if reached_end:
		print(move_count)
		return move_count
	return -1
			
func explore_neighbors(r,c):
	for direction in ['up', 'down', 'left','right', 
						'upleft', 'upright', 'downleft', 'downright']:
				
		var search_row
		var search_col
		var tile_contents
				
		match direction:
			'up':
				search_row = r + 1
				search_col = c
			'down':
				search_row = r - 1
				search_col = c
			'left':
				search_row = r
				search_col = c - 1
			'right':
				search_row = r
				search_col = c + 1
				
			'upleft':
				search_row = r + 1
				search_col = c - 1
			'upright':
				search_row = r + 1
				search_col = c + 1
			'downleft':
				search_row = r - 1
				search_col = c - 1
			'downright':
				search_row = r - 1
				search_col = c + 1
				
		tile_contents = map.get_tile_contents(search_row, search_col)
		
		if [search_row, search_col] in visited: continue
		
		if typeof(tile_contents) == TYPE_STRING:
			if tile_contents == 'Out of Bounds': continue
			if tile_contents != '0': continue
			
		row_queue.push_front(search_row)
		col_queue.push_front(search_col)
		
		visited.append([search_row, search_col])
		
		nodes_in_next_layer += 1

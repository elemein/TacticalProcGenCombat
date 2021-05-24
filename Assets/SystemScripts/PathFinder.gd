# The pathfinding algo used here is BFS/Breadth-First Search. I implement it from
# this video: https://www.youtube.com/watch?v=KiCBXu4P-2Y&ab_channel=WilliamFiset
# with some modifications to suit our usecase.

extends Node

onready var map = get_node("/root/World/Map")

var visited = []

var start_row = 0
var start_col = 0

var target_pos = 0

var reached_end

var row_queue = []
var col_queue = []

var pos_queue = []

var move_count = 0
var nodes_left_in_layer = 0
var nodes_in_next_layer = 0

func solve(searcher, start_pos, end_pos):
	start_row = start_pos[0]
	start_col = start_pos[1]
	
	target_pos = end_pos
	
	pos_queue = []

	move_count = 0
	nodes_left_in_layer = 1
	nodes_in_next_layer = 0

	reached_end = false

	visited = []
	
	pos_queue.push_front(start_pos)
	visited.append(start_pos)
	
	print([start_pos, end_pos])
	
	var total_counts = []
	
	# Solving ------------------------------------
	while pos_queue.size() > 0:
		var curr_pos = pos_queue.pop_back()
		
		if curr_pos == target_pos:
			reached_end = true
			total_counts.append(move_count)
			break
		
		explore_neighbors(curr_pos)
		nodes_left_in_layer -= 1
		
		if nodes_left_in_layer == 0:
			nodes_left_in_layer = nodes_in_next_layer
			nodes_in_next_layer = 0
			move_count += 1
	
	if reached_end:
		print("%s 's distance to Player: %s via %s" % [searcher, move_count, visited])
		return move_count
	return -1
			
func explore_neighbors(pos):
	for direction in ['up', 'down', 'left','right', 
						'upleft', 'upright', 'downleft', 'downright']:
				
		var search_pos
		var tile_contents
				
		match direction:
			'up': search_pos = [pos[0] + 1, pos[1]]
			'down': search_pos = [pos[0] - 1, pos[1]]
			'left': search_pos = [pos[0], pos[1] - 1]
			'right': search_pos = [pos[0], pos[1] + 1]
				 
			'upleft': search_pos = [pos[0] + 1, pos[1] - 1]
			'upright': search_pos = [pos[0] + 1, pos[1] + 1]
			'downleft': search_pos = [pos[0] - 1, pos[1] - 1]
			'downright': search_pos = [pos[0] - 1, pos[1] + 1]
				
		tile_contents = map.get_tile_contents(search_pos[0], search_pos[1])
		
		if search_pos in visited: continue
		if typeof(tile_contents) == TYPE_STRING:
			if tile_contents == 'Out of Bounds': continue
			if tile_contents != '0': continue
			
		pos_queue.push_front(search_pos)
		
		
		visited.append(search_pos)
		
		nodes_in_next_layer += 1

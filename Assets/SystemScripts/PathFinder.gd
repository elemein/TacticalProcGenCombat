# The pathfinding algo used here is BFS/Breadth-First Search. I implement it from
# this video: https://www.youtube.com/watch?v=KiCBXu4P-2Y&ab_channel=WilliamFiset
# with some modifications to suit our usecase.

extends Node

onready var map = get_node("/root/World/Map")

var visited = []


var target_pos = 0

var reached_end

var start = []

var row_queue = []
var col_queue = []

var path_holder = {}

var pos_queue = []

var move_count = 0
var nodes_left_in_layer = 0
var nodes_in_next_layer = 0

func reset_vars():
	pos_queue = []

	move_count = 0
	nodes_left_in_layer = 1
	nodes_in_next_layer = 0

	reached_end = false

	path_holder = {}

	visited = []
	
	

func solve(searcher, start_pos, end_pos):
	reset_vars()
	start = start_pos
	target_pos = end_pos
	
	pos_queue.push_front(start_pos)
	visited.append(start_pos)
	
	# Solving ------------------------------------
	while pos_queue.size() > 0:
		var curr_pos = pos_queue.pop_back()
		
		if curr_pos == target_pos:
			reached_end = true
			break
		
		explore_neighbors(curr_pos)
		nodes_left_in_layer -= 1
		
		if nodes_left_in_layer == 0:
			nodes_left_in_layer = nodes_in_next_layer
			nodes_in_next_layer = 0
			move_count += 1
	
	if reached_end:
		retrace_path()
		return move_count

	return -1
			
func explore_neighbors(pos): # this function basically just adds adjacent tiles to queue if its valid
	path_holder[pos] = []
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
		
		path_holder[pos].append(search_pos)

func retrace_path():
	var curr_node = target_pos
	
	var taken_path = []
	
	while curr_node != start:
		for key in path_holder.keys():
			if curr_node in path_holder[key]:
				taken_path.append(key)
				curr_node = key
	taken_path.invert()
	print("Start at %s to go to %s via \n %s" % [start, target_pos, taken_path])

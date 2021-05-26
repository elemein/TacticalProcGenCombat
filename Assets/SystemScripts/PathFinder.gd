# The pathfinding algo used here is BFS/Breadth-First Search. I implement it from
# this video: https://www.youtube.com/watch?v=KiCBXu4P-2Y&ab_channel=WilliamFiset
# with some modifications to suit our usecase.

#Current Bugs:
#	- Enemies do not make room for eachother around a player. e.g.:
#		E-0-0-0-.
#		0-E-E-E-.
#		0-E-P-0-.
#		0-E-0-0-.
#		.-.-.-.-.
#		In this situation, there is room around the player for the 
#		top left enemy to crowd, but the other enemies are already
#		adjacent, so they won't move, leaving no room for the top
#		left enemy.
#	- If an enemy is in a 1 wide hallway, it will block pathfinding
#		for all enemies behind that hallway, causing them to not move.

extends Node

onready var map = get_node("/root/World/Map")

var visited = []

var start_pos = []
var curr_pos = []
var end_pos = []

var reached_end = false

var path_holder = {}

var pos_queue = []
var direction_list = ['upleft', 'upright', 'downleft', 'downright', 'up', 'down', 'left', 'right']

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
	
	start_pos = []
	curr_pos = []
	end_pos = []
	
	direction_list = ['upleft', 'upright', 'downleft', 'downright', 'up', 'down', 'left', 'right']
	
func solve(searcher, start, end):
	reset_vars()
	start_pos = start
	end_pos = end
	
	pos_queue.push_front(start_pos)
	visited.append(start_pos)
	
	# Solving ------------------------------------
	while pos_queue.size() > 0:
		curr_pos = pos_queue.pop_back()
		
		if curr_pos == end_pos:
			reached_end = true
			break
		
		explore_neighbors(curr_pos)
		
		nodes_left_in_layer -= 1
		
		if nodes_left_in_layer == 0:
			nodes_left_in_layer = nodes_in_next_layer
			nodes_in_next_layer = 0
			move_count += 1
	
	if reached_end:
		return [move_count, retrace_path()]
		
	return [-1,[[-1, -1]]]
			
func explore_neighbors(pos): # this function basically just adds adjacent tiles to queue if its valid
	path_holder[pos] = []
	
	for direction in direction_list: # diagonals must be processed first
				
		var search_pos
		var tile_contents
		var invalid_cornering = false
		
		match direction: # checking cornering
			'upleft':
				if map.is_tile_wall(pos[0] + 1, pos[1]): invalid_cornering = true
				if map.is_tile_wall(pos[0], pos[1] - 1): invalid_cornering = true
			'upright': 
				if map.is_tile_wall(pos[0] + 1, pos[1]): invalid_cornering = true
				if map.is_tile_wall(pos[0], pos[1] + 1): invalid_cornering = true
			'downleft': 
				if map.is_tile_wall(pos[0] - 1, pos[1]): invalid_cornering = true
				if map.is_tile_wall(pos[0], pos[1] - 1): invalid_cornering = true
			'downright':
				if map.is_tile_wall(pos[0] - 1, pos[1]): invalid_cornering = true
				if map.is_tile_wall(pos[0], pos[1]+1): invalid_cornering = true
		
		if invalid_cornering: continue
		
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
			if tile_contents == '.': continue
			if tile_contents == 'Out of Bounds': continue

		if typeof(tile_contents) == TYPE_OBJECT:
			if tile_contents.get_obj_type() == 'E': continue
			
		pos_queue.push_front(search_pos)
		
		visited.append(search_pos)
		
		nodes_in_next_layer += 1
		
		path_holder[pos].append(search_pos)

func retrace_path():
	curr_pos = end_pos
	
	var taken_path = []
	
	while curr_pos != start_pos:
		for key in path_holder.keys():
			if curr_pos in path_holder[key]:
				taken_path.append(key)
				curr_pos = key

	taken_path.invert()
	taken_path.pop_front()
	taken_path.append(end_pos)

	return taken_path

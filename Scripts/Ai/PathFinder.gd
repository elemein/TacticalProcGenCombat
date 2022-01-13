# The pathfinding algo used here is BFS/Breadth-First Search. I implement it from
# this video: https://www.youtube.com/watch?v=KiCBXu4P-2Y&ab_channel=WilliamFiset
# with some modifications to suit our usecase.

#Current Bugs:
#	- Characters do not make room for eachother around a player. e.g.:
#		E-0-0-0-.
#		0-E-E-E-.
#		0-E-P-0-.
#		0-E-0-0-.
#		.-.-.-.-.
#		In this situation, there is room around the player for the 
#		top left enemy to crowd, but the other enemies are already
#		adjacent, so they won't move, leaving no room for the top
#		left enemy.

extends Node

var visited = []

var start_pos = []
var curr_pos = []
var end_pos = []
var map

var reached_end = false

var path_holder = {}

var pos_queue = []
var direction_list = ['up', 'down', 'left', 'right', 'upleft', 'upright', 'downleft', 'downright']

var move_count = 0
var nodes_left_in_layer = 0
var nodes_in_next_layer = 0

var ignore_enemies

func solve(_searcher, search_map, start, end):
	self.ignore_enemies = true
	var path = pathfind(_searcher, search_map, start, end)
	
	var first_tile_in_path_x = path[1][0][0]
	var first_tile_in_path_z = path[1][0][1]
	
	# the first pathfind ignores enemies so that enemies don't render corridors
	# untraversable. this if makes it so if the next move suggested is illegal,
	# it reruns it taking enemies into consideration
	if search_map.tile_available(first_tile_in_path_x, first_tile_in_path_z) == false:
		self.ignore_enemies = false
		path = pathfind(_searcher, search_map, start, end)
	
	return [path[0], path[1]]

func reset_vars():
	self.pos_queue = []

	self.move_count = 0
	self.nodes_left_in_layer = 1
	self.nodes_in_next_layer = 0

	self.reached_end = false

	self.path_holder = {}

	self.visited = []
	
	self.start_pos = []
	self.curr_pos = []
	self.end_pos = []

func pathfind(_searcher, search_map, start, end):
	reset_vars()
	self.map = search_map
	self.start_pos = start
	self.end_pos = end
	
	self.pos_queue.push_front(self.start_pos)
	self.visited.append(self.start_pos)
	
	# Solving ------------------------------------
	while self.pos_queue.size() > 0:
		self.curr_pos = self.pos_queue.pop_back()
		
		if self.curr_pos == self.end_pos:
			self.reached_end = true
			break
		
		explore_neighbors(self.curr_pos)
		
		self.nodes_left_in_layer -= 1
		
		if self.nodes_left_in_layer == 0:
			self.nodes_left_in_layer = self.nodes_in_next_layer
			self.nodes_in_next_layer = 0
			self.move_count += 1
	
	if self.reached_end:
		return [self.move_count, retrace_path()]
		
	return [-1,[[-1, -1]]]

func check_valid_cornering(pos, direction):
	var valid_cornering = true
	
	match direction: # checking cornering
		'upleft':
			if self.map.tile_blocks_vision(pos[0] + 1, pos[1]): valid_cornering = false
			if self.map.tile_blocks_vision(pos[0], pos[1] - 1): valid_cornering = false
		'upright': 
			if self.map.tile_blocks_vision(pos[0] + 1, pos[1]): valid_cornering = false
			if self.map.tile_blocks_vision(pos[0], pos[1] + 1): valid_cornering = false
		'downleft': 
			if self.map.tile_blocks_vision(pos[0] - 1, pos[1]): valid_cornering = false
			if self.map.tile_blocks_vision(pos[0], pos[1] - 1): valid_cornering = false
		'downright':
			if self.map.tile_blocks_vision(pos[0] - 1, pos[1]): valid_cornering = false
			if self.map.tile_blocks_vision(pos[0], pos[1]+1): valid_cornering = false
			
	return valid_cornering

func get_target_adjacent_pos(pos, direction):
	var adj_pos
	
	match direction:
		'up': adj_pos = [pos[0] + 1, pos[1]]
		'down': adj_pos = [pos[0] - 1, pos[1]]
		'left': adj_pos = [pos[0], pos[1] - 1]
		'right': adj_pos = [pos[0], pos[1] + 1]

		'upleft': adj_pos = [pos[0] + 1, pos[1] - 1]
		'upright': adj_pos = [pos[0] + 1, pos[1] + 1]
		'downleft': adj_pos = [pos[0] - 1, pos[1] - 1]
		'downright': adj_pos = [pos[0] - 1, pos[1] + 1]
		
	return adj_pos

func explore_neighbors(pos): # this function basically just adds adjacent tiles to queue if its valid
	self.path_holder[pos] = []
	for direction in self.direction_list: 
		if check_valid_cornering(pos, direction) == false: continue
		
		var search_pos = get_target_adjacent_pos(pos, direction)
		if search_pos in self.visited: continue
		
		var tile_contents = self.map.get_tile_contents(search_pos[0], search_pos[1])
		
		if typeof(tile_contents) == TYPE_STRING:
			if tile_contents == 'Out of Bounds': continue
	
		var skip_tile = false
		for object in tile_contents:
			if object.get_relation_rules()['Non-Traversable'] == true: skip_tile = true
			if object.get_id()['CategoryType'] == 'Enemy':
				if object.get_is_dead() == false:
					if self.ignore_enemies == false: skip_tile = true
		if skip_tile: continue
			
		self.pos_queue.push_front(search_pos)
		
		self.visited.append(search_pos)
		
		self.nodes_in_next_layer += 1
		
		self.path_holder[pos].append(search_pos)

func retrace_path():
	self.curr_pos = self.end_pos
	
	var taken_path = []
	
	while self.curr_pos != self.start_pos:
		for key in self.path_holder.keys():
			if self.curr_pos in self.path_holder[key]:
				taken_path.append(key)
				self.curr_pos = key

	taken_path.invert()
	taken_path.pop_front()
	taken_path.append(self.end_pos)

	return taken_path

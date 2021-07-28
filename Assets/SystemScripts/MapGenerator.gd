extends Node

# This generator uses BSP (Binary Space Partitioning) to generate a dungeon
# by folding the dungeon into leaflets multiple times to create rooms.

# I followed this link: https://abitawake.com/news/articles/procedural-generation-with-godot-create-dungeons-using-a-bsp-tree
# I had to do some modification to it as the link uses a TileMap, whereas we use a 2D Array. 

const Y_OFFSET = -0.3

const ROOM_CLASS = preload("res://Assets/SystemScripts/Room.gd")

const MAP_CLASS = preload("res://Assets/SystemScripts/Map.gd")
const MAP_FILL = preload("res://Assets/SystemScripts/MapFiller.gd")

var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_wall = preload("res://Assets/Objects/MapObjects/Wall.tscn")

var map_l = 20 # MIN: 12, how many rows
var map_w = 20 # MIN: 12, how long are those rows
var min_room_size = 4 # -1 is min room size.
var min_room_factor = 0.4 # Higher this is, the smaller the rooms are

var room_density = 100 # 0-100. 100 being most dense.

var map_filler = MAP_FILL.new()
var rng = RandomNumberGenerator.new()

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []

var total_map = []

func generate(parent_mapset, name, id, type):
	reset_map_gen_vars()
	var map_to_return = MAP_CLASS.new(name, id, type)
	
	map_to_return.set_parent_mapset(parent_mapset)
	
	var maps_thrown_away = -1
	
	while (test_if_map_valid() == false):
		maps_thrown_away += 1
		reset_map_gen_vars()
		rng.randomize()
		create_floor()
		start_tree()
		create_leaf(0)
		create_rooms()
		join_rooms()
		clear_deadends()
		define_extra_room_stats()
	
	for room in rooms:
		room.parent_map = map_to_return
	
	var filled_map = map_filler.fill_map(map_to_return, total_map, rooms)
	
	print_rooms(filled_map[1])
	print('%d maps thrown away' % [maps_thrown_away])
	# map must be accepted to go further
	
	map_to_return.set_map_grid_and_dict(filled_map[0], filled_map[1])
	
	return map_to_return

func test_if_map_valid():
	if total_map == []: return false
	
	var x
	var z
	
	for room in rooms:
		var last_was_ground = false
		var exits = []
		
		# start at bottomleft
		x = room.bottomleft[0]
		z = room.bottomleft[1]
		
		# go one left
		z -= 1
		
		while (x <= room.topleft[0]):
			if total_map[x][z][0].get_obj_type() == 'Ground':
				if last_was_ground: return false
				else: 
					last_was_ground = true
					exits.append([x,z])
			else: last_was_ground = false
			x += 1
		last_was_ground = false
		# left side checked
		
		# go to topleft, then one more up
		x = room.topleft[0]
		z = room.topleft[1]
		x += 1
		
		while (z <= room.topright[1]):
			if total_map[x][z][0].get_obj_type() == 'Ground':
				if last_was_ground: return false
				else: 
					last_was_ground = true
					exits.append([x,z])
			else: last_was_ground = false
			z += 1
		last_was_ground = false
		# top side checked
		
		# go to topright, then one more right
		x = room.topright[0]
		z = room.topright[1]
		z += 1
		
		while (x >= room.bottomright[0]):
			if total_map[x][z][0].get_obj_type() == 'Ground':
				if last_was_ground: return false
				else: 
					last_was_ground = true
					exits.append([x,z])
			else: last_was_ground = false
			x -= 1
		last_was_ground = false
		# right side checked
		
		# go to bottomright, then one more down
		x = room.bottomright[0]
		z = room.bottomright[1]
		x -= 1
		
		while (z >= room.bottomleft[1]):
			if total_map[x][z][0].get_obj_type() == 'Ground':
				if last_was_ground: return false
				else: 
					last_was_ground = true
					exits.append([x,z])
			else: last_was_ground = false
			z -= 1
		last_was_ground = false
		#bottom side checked
		
		room.exits = exits
	
	return true

func reset_map_gen_vars():
	tree = {}
	leaves = []
	leaf_id = 0
	rooms = []
	total_map = []

func create_floor():
	for x in range(0, map_l):
		total_map.append([])
		for z in range(0, map_w):
			var wall = base_wall.instance()
			wall.translation = Vector3(x * GlobalVars.TILE_OFFSET, Y_OFFSET+0.3, z * GlobalVars.TILE_OFFSET)
			wall.visible = false
			
			total_map[x].append([wall])

func start_tree():
	# Reset variables.
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0
	
	# Set basis for first tree node.
	# x and z are both 1, not 0, as we dont want the algo to have access to the
	# very bottom or left edge, where a wall should be.
	# map_l and map_w are -2 for the same reason; not -1 because the indexing
	# would make that have access to the top and right edge.
	tree[leaf_id] = {"x": 1, "z": 1, "l": map_l - 2, "w": map_w - 2}
	leaf_id += 1

func create_leaf(parent_id):
	var x = tree[parent_id].x # far left node
	var z = tree[parent_id].z # far down node
	var l = tree[parent_id].l # far right node
	var w = tree[parent_id].w # far up node
	
	tree[parent_id].center = [floor(x + l/2), floor(z + w/2)]
	
	# whether the tree has space for a split?
	var can_split = false
	
	# randomly split vertical or horizontal
	# if not enough width, do horizontal, 
	# if not enough height, split vertical
	var types_of_splits = ['h', 'v']
	var split_type = types_of_splits[rng.randi() % types_of_splits.size()] # 0 = h, 1 = v
	if (min_room_factor * l < min_room_size): split_type = 'h'
	elif (min_room_factor * w < min_room_size): split_type = 'v'
	
	var leaf1 = {}
	var leaf2 = {}
	
	#try and split current leaf, if room will fit
	
	if (split_type == 'v'):
		var room_size = min_room_factor * l
		if (room_size >= min_room_size):
			var l1 = rng.randi_range(room_size, (l - room_size))
			var l2 = l - l1
			leaf1 = {x = x, z = z, l = l1, w = w, split = 'v'}
			leaf2 = {x = x+l1, z = z, l = l2, w = w, split = 'v'}
			can_split = true
	else:
		var room_size = min_room_factor * w
		if (room_size >= min_room_size):
			var w1 = rng.randi_range(room_size, (w - room_size))
			var w2 = w - w1
			leaf1 = {x = x, z = z, l = l, w = w1, split = 'h'}
			leaf2 = {x = x, z = z + w1, l = l, w = w2, split = 'h'}
			can_split = true
			
	if (can_split):
		leaf1.parent_id = parent_id
		tree[leaf_id] = leaf1
		tree[parent_id].c = leaf_id
		leaf_id += 1
		
		leaf2.parent_id = parent_id
		tree[leaf_id] = leaf2
		tree[parent_id].r = leaf_id
		leaf_id += 1
		
		leaves.append([tree[parent_id].c, tree[parent_id].r])
		
		# try and create more leaves
		create_leaf(tree[parent_id].c)
		create_leaf(tree[parent_id].r)
	
func create_rooms():
	for leaf_id_num in tree:
		var leaf = tree[leaf_id_num]
		if leaf.has("c"): continue # if node has children, don't build rooms
	
		if (rng.randi_range(0,100) < room_density):
			var room = ROOM_CLASS.new()
			room.id = leaf_id_num
			room.l = rng.randi_range(min_room_size, leaf.l) - 1
			room.w = rng.randi_range(min_room_size, leaf.w) - 1
			room.x = leaf.x + floor((leaf.l-room.l)/2) + 1
			room.z = leaf.z + floor((leaf.w-room.w)/2) + 1
			room.parent_id = leaf.parent_id
			
			room.split = leaf.split
			
			room.center = [0,0]
			room.center[0] = floor(room.x + room.l/2)
			room.center[1] = floor(room.z + room.w/2) 
			rooms.append(room)

	for i in range(rooms.size()):
		var room = rooms[i]
		
		for x in range(room.x, (room.x + room.l)):
			for z in range(room.z, (room.z + room.w)):
				var ground = base_block.instance()
				ground.translation = Vector3((x) * GlobalVars.TILE_OFFSET, Y_OFFSET+0.3, (z) * GlobalVars.TILE_OFFSET)
				ground.visible = false
				
				total_map[x][z][0] = ground
			
func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])

func connect_leaves(leaf1, leaf2):
	# connects leaves by shooting corridors right or up
	var x = min(leaf1.center[0], leaf2.center[0])
	var z = min(leaf1.center[1], leaf2.center[1])
	var l = 1
	var w = 1
	
	if (leaf1.split == 'h'): # Vertical Corridor
		x -= floor(w/2)+1
		w = abs(leaf1.center[1] - leaf2.center[1])
	else:					 # Horizontal Corridor
		z -= floor(l/2)+1
		l = abs(leaf1.center[0] - leaf2.center[0])
	
	if check_if_path_may_need_extension(x+l, z+w, leaf1.split):
		if leaf1.split == 'h': w += 1
		elif leaf1.split == 'v': l += 1

	# Ensure within map
	x = 0 if (x < 0) else x
	z = 0 if (z < 0) else z
			
	for i in range(x, x+l):
		for j in range(z, z+w):
			if (total_map[i][j][0].get_obj_type() == 'Wall'):
				var ground = base_block.instance()
				ground.translation = Vector3((i) * GlobalVars.TILE_OFFSET, Y_OFFSET+0.3, (j) * GlobalVars.TILE_OFFSET)
				ground.visible = false
				total_map[i][j][0] = ground 

func check_if_path_may_need_extension(x, z, split_type):
	if split_type == 'h':
		if total_map[x+1][z+1][0].get_obj_type() == 'Ground': return true
		if total_map[x+1][z-1][0].get_obj_type() == 'Ground': return true
	elif split_type == 'v':
		if total_map[x+1][z+1][0].get_obj_type() == 'Ground': return true
		if total_map[x-1][z+1][0].get_obj_type() == 'Ground': return true
	
	return false

func clear_deadends():
	var done = false
	
	while !done:
		done = true
	
		for x in range(0, total_map.size()-1):
			for z in range(0, total_map[0].size()-1): 
				# using 0th entry v here, is okay at this stage.
				if total_map[x][z][0].get_obj_type() != 'Ground' : continue
				
				var roof_count = check_cardinal_dirs_for_walls(x,z)
				if roof_count == 3:
					var wall = base_wall.instance()
					wall.translation = Vector3(x * GlobalVars.TILE_OFFSET, Y_OFFSET+0.3, z * GlobalVars.TILE_OFFSET)
					wall.visible = false
					
					total_map[x][z][0] = wall

					done = false

func check_cardinal_dirs_for_walls(x,z):
	var count = 0
	if total_map[x][z-1][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x][z+1][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x-1][z][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x+1][z][0].get_obj_type() == 'Wall' : count += 1
			
	return count

func define_extra_room_stats():
	for room in rooms:
		room['bottomleft'] = [room.x, room.z]
		room['bottomright'] = [room.x, (room.z + room.w)-1]
		room['topleft'] = [(room.x + room.l) - 1, room.z]
		room['topright'] = [(room.x + room.l) - 1, (room.z + room.w)-1]
		room['area'] = room.l * room.w
		
		
		room['type'] = 'Unassigned'
	
func print_rooms(_rooms_in_map):
	for room in rooms: print(room)

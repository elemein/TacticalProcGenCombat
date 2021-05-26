extends Node

# This generator uses BSP (Binary Space Partitioning) to generate a dungeon
# by folding the dungeon into leaflets multiple times to create rooms.

# I followed this link: https://abitawake.com/news/articles/procedural-generation-with-godot-create-dungeons-using-a-bsp-tree
# I had to do some modification to it as the link uses a TileMap, whereas we use a 2D Array. 

var map_w = 30
var map_h = 30
var min_room_size = 4 # -1 = Min room dimension.
var min_room_factor = 0.4

var room_density = 75 # 0-100. 100 being most dense.

var rng = RandomNumberGenerator.new()

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []

var total_map = []
	
func generate():
	rng.randomize()
	fill_roof()
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
	clear_deadends()
	return total_map

func fill_roof(): # This varies as we don't use a TileMap
	for x in range(0, map_w):
		total_map.append([])
		for z in range(0, map_h):
			total_map[x].append('.')

func start_tree():
	# Reset variables.
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0
	
	# Set basis for first tree node.
	tree[leaf_id] = {"x": 1, "y": 1, "w": map_w - 2, "h": map_h - 2}
	leaf_id += 1

func create_leaf(parent_id):
	var x = tree[parent_id].x # far left node
	var y = tree[parent_id].y # far down node
	var w = tree[parent_id].w # far right node
	var h = tree[parent_id].h # far up node
	
	# I believe this adds a "center" dict entry to tree[parent_id] containing the
	# halfway points for that node.
	# apparently used to connect the leaves later
	tree[parent_id].center = {x = floor(x + w/2), y = floor(y + h/2)}
	
	# whether the tree has space for a split?
	var can_split = false
	
	# randomly split vertical or horizontal
	# if not enough width, do horizontal, 
	# if not enough height, split vertical
	var types_of_splits = ['h', 'v']
	var split_type = types_of_splits[rng.randi() % types_of_splits.size()] # 0 = h, 1 = v
	if (min_room_factor * w < min_room_size): split_type = 'h'
	elif (min_room_factor * h < min_room_size): split_type = 'v'
	
	var leaf1 = {}
	var leaf2 = {}
	
	#try and split current leaf, if room will fit
	
	if (split_type == 'v'):
		var room_size = min_room_factor * w
		if (room_size >= min_room_size):
			var w1 = rng.randi_range(room_size, (w - room_size))
			var w2 = w - w1
			leaf1 = {x = x, y = y, w = w1, h = h, split = 'v'}
			leaf2 = {x = x+w1, y = y, w = w2, h = h, split = 'v'}
			can_split = true
	else:
		var room_size = min_room_factor * h
		if (room_size >= min_room_size):
			var h1 = rng.randi_range(room_size, (h - room_size))
			var h2 = h - h1
			leaf1 = {x = x, y = y, w = w, h = h1, split = 'h'}
			leaf2 = {x = x, y = y + h1, w = w, h = h2, split = 'h'}
			can_split = true
			
			
	if (can_split):
		leaf1.parent_id = parent_id
		tree[leaf_id] = leaf1
		tree[parent_id].l = leaf_id
		leaf_id += 1
		
		leaf2.parent_id = parent_id
		tree[leaf_id] = leaf2
		tree[parent_id].r = leaf_id
		leaf_id += 1
		
		leaves.append([tree[parent_id].l, tree[parent_id].r])
		
		# try and create more leaves
		create_leaf(tree[parent_id].l)
		create_leaf(tree[parent_id].r)
	
func create_rooms():
	
	for leaf_id in tree:
		var leaf = tree[leaf_id]
		if leaf.has("l"): continue # if node has children, don't build rooms
	
		if (rng.randi_range(0,100) < room_density):
			var room = {}
			room.id = leaf_id
			room.w = rng.randi_range(min_room_size, leaf.w) - 1
			room.h = rng.randi_range(min_room_size, leaf.h) - 1			
			room.x = leaf.x + floor((leaf.w-room.w)/2) + 1
			room.y = leaf.y + floor((leaf.h-room.h)/2) + 1
			room.split = leaf.split
			
			room.center = Vector2()
			room.center.x = floor(room.x + room.w/2)
			room.center.y = floor(room.y + room.h/2)
			rooms.append(room)

	for i in range(rooms.size()):
		var room = rooms[i]
		
		for x in range(room.x, (room.x + room.w)):
			for y in range(room.y, (room.y + room.h)):
				total_map[x-1][y-1] = '0'
			
			
func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])
			

func connect_leaves(leaf1, leaf2):
	var x = min(leaf1.center.x, leaf2.center.x)
	var y = min(leaf1.center.y, leaf2.center.y)
	var w = 1
	var h = 1
	
	if (leaf1.split == 'h'): # Vertical Corridor
		x -= 1
		h = abs(leaf1.center.y - leaf2.center.y)
	else:					 # Horizontal Corridor
		y -= 1
		w = abs(leaf1.center.x - leaf2.center.x)
		
	# Ensure within map
	x = 0 if (x < 0) else x
	y = 0 if (y < 0) else y
			
	for i in range(x, x+w):
		for j in range(y, y+h):
			if (total_map[i-1][j-1] == '.'): total_map[i-1][j-1] = '0' 
	
	
func clear_deadends():
	var done = false
	
	while !done:
		done = true
	
		for x in range(0, total_map.size()-1):
			for y in range(0, total_map[0].size()-1):
				if total_map[x][y] != '0' : continue
				
				var roof_count = check_nearby(x,y)
				if roof_count == 3:
					total_map[x][y] = '.'
					done = false
			

func check_nearby(x,y):
	var count = 0
	if total_map[x][y-1] == '.' : count += 1
	if total_map[x][y+1] == '.' : count += 1
	if total_map[x-1][y] == '.' : count += 1
	if total_map[x+1][y] == '.' : count += 1
			
	return count
			
func print_total_map():
	total_map.invert()
	for line in total_map:
		print(line)
	total_map.invert()
			
			
			
			
	
	
	

extends Node

# This generator uses BSP (Binary Space Partitioning) to generate a dungeon
# by folding the dungeon into leaflets multiple times to create rooms.

# I followed this link: https://abitawake.com/news/articles/procedural-generation-with-godot-create-dungeons-using-a-bsp-tree
# I had to do some modification to it as the link uses a TileMap, whereas we use a 2D Array. 

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2
const NUMBER_OF_ENEMIES = 10
# const AVG_NO_OF_ENEMIES_PER_ROOM = 2
const NUMBER_OF_TRAPS = 30
const NUMBER_OF_COINS = 8
const NUMBER_OF_SWORDS = 5
const NUMBER_OF_STAFFS = 5
const NUMBER_OF_NECKLACES = 5

var base_enemy = preload("res://Assets/Objects/EnemyObjects/Enemy.tscn")
var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_wall = preload("res://Assets/Objects/MapObjects/Wall.tscn")
var base_spiketrap = preload("res://Assets/Objects/MapObjects/SpikeTrap.tscn")
var base_coins = preload("res://Assets/Objects/MapObjects/Coins.tscn")
var base_sword = preload("res://Assets/Objects/MapObjects/InventoryObjects/Sword.tscn")
var base_staff = preload("res://Assets/Objects/MapObjects/InventoryObjects/MagicStaff.tscn")
var base_necklace = preload("res://Assets/Objects/MapObjects/InventoryObjects/ArcaneNecklace.tscn")

var map_w = 30
var map_h = 30
var min_room_size = 3
var min_room_factor = 0.4

var room_density = 70 # 0-100. 100 being most dense.

var rng = RandomNumberGenerator.new()

var tree = {}
var leaves = []
var leaf_id = 0
var rooms = []

var total_map = []
	
func generate():
	rng.randomize()
	create_floor()
	start_tree()
	create_leaf(0)
	create_rooms()
	join_rooms()
	clear_deadends()
	catalog_rooms()
	spawn_enemies()
	spawn_traps()
	spawn_loot()
	return [total_map, rooms]

func create_floor():
	for x in range(0, map_w):
		total_map.append([])
		for z in range(0, map_h):
			var wall = base_wall.instance()
			wall.translation = Vector3(x * TILE_OFFSET, Y_OFFSET+0.3, z * TILE_OFFSET)
			wall.visible = false
			
			total_map[x].append([wall])

func start_tree():
	# Reset variables.
	rooms = []
	tree = {}
	leaves = []
	leaf_id = 0
	
	# Set basis for first tree node.
	# x and y are both 1, not 0, as we dont want the algo to have access to the
	# very bottom or left edge, where a wall should be.
	# map_w and map_h are -2 for the same reason; not -1 because the indexing
	# would make that have access to the top and right edge.
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
			room.w = rng.randi_range(min_room_size, leaf.w)
			room.h = rng.randi_range(min_room_size, leaf.h)
			room.x = leaf.x + floor((leaf.w-room.w)/2)
			room.y = leaf.y + floor((leaf.h-room.h)/2)
			
			room.split = leaf.split
			
			room.center = Vector2()
			room.center.x = floor(room.x + room.w/2)
			room.center.y = floor(room.y + room.h/2)
			rooms.append(room)

	for i in range(rooms.size()):
		var room = rooms[i]
		
		for x in range(room.x, (room.x + room.w)):
			for y in range(room.y, (room.y + room.h)):
				var ground = base_block.instance()
				ground.translation = Vector3((x) * TILE_OFFSET, Y_OFFSET+0.3, (y) * TILE_OFFSET)
				ground.visible = false
				
				total_map[x][y][0] = ground
			
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
			if (total_map[i][j][0].get_obj_type() == 'Wall'):
				var ground = base_block.instance()
				ground.translation = Vector3((i) * TILE_OFFSET, Y_OFFSET+0.3, (j) * TILE_OFFSET)
				ground.visible = false
				total_map[i][j][0] = ground 

func clear_deadends():
	var done = false
	
	while !done:
		done = true
	
		for x in range(0, total_map.size()-1):
			for y in range(0, total_map[0].size()-1): 
				# using 0th entry v here, is okay at this stage.
				if total_map[x][y][0].get_obj_type() != 'Ground' : continue
				
				var roof_count = check_nearby(x,y)
				if roof_count == 3:
					var wall = base_wall.instance()
					wall.translation = Vector3(x * TILE_OFFSET, Y_OFFSET+0.3, y * TILE_OFFSET)
					wall.visible = false
					
					total_map[x][y][0] = wall

					done = false

func check_nearby(x,y):
	var count = 0
	if total_map[x][y-1][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x][y+1][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x-1][y][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x+1][y][0].get_obj_type() == 'Wall' : count += 1
			
	return count

func catalog_rooms():
	for room in rooms:
		room['bottomleft'] = [room.x, room.y]
		room['bottomright'] = [room.x, (room.y + room.h)-1]
		room['topleft'] = [(room.x + room.w) - 1, room.y]
		room['topright'] = [(room.x + room.w) - 1, (room.y + room.h)-1]
		room['type'] = 'Enemy'
	
	rooms[rng.randi_range(0, rooms.size()-1)]['type'] = 'Player Spawn'
	
	for room in rooms: print(room)

func get_random_available_tile_in_room(room) -> Array:
	var x
	var z
	
	var tile_clear = false
	
	while tile_clear == false:
		# room.x/y + room.w/h gives you the right/top border tile 
		# encirling the room, so we do -1 to ensure being in the room.
		x = rng.randi_range(room.x, (room.x + room.w)-1)
		z = rng.randi_range(room.y, (room.y + room.h)-1)
		
		var all_clear = true
		
		for object in total_map[x][z]:
			if object.get_obj_type() != 'Ground': 
				all_clear = false
		
		if all_clear == true: tile_clear = true
	
	return [x,z]

func spawn_enemies():
	for enemy_cnt in range(NUMBER_OF_ENEMIES):
		var room = null
		
		while room == null:
			room = rooms[rng.randi_range(0, rooms.size()-1)]
			if room['type'] == 'Player Spawn':
				room = null
		
		var rand_tile = get_random_available_tile_in_room(room)
		var x = rand_tile[0]
		var z = rand_tile[1]
				
		var enemy = base_enemy.instance()
		enemy.translation = Vector3(x * TILE_OFFSET, Y_OFFSET+0.3, z * TILE_OFFSET)
		enemy.visible = false
		enemy.set_map_pos([x,z])
		enemy.add_to_group('enemies')

		total_map[x][z].append(enemy)

func spawn_traps():
	for trap_cnt in range(NUMBER_OF_TRAPS):
		var room = rooms[rng.randi_range(0, rooms.size()-1)]

		var rand_tile = get_random_available_tile_in_room(room)
		var x = rand_tile[0]
		var z = rand_tile[1]
				
		var trap = base_spiketrap.instance()
		trap.translation = Vector3(x * TILE_OFFSET, Y_OFFSET+0.3-1, z * TILE_OFFSET)
		trap.visible = false
		trap.set_map_pos([x,z])
		trap.add_to_group('traps')

		total_map[x][z].append(trap)

func spawn_loot():
	spawn_inv_items(base_coins, NUMBER_OF_COINS)
	spawn_inv_items(base_sword, NUMBER_OF_SWORDS)
	spawn_inv_items(base_staff, NUMBER_OF_STAFFS)
	spawn_inv_items(base_necklace, NUMBER_OF_NECKLACES)

func spawn_inv_items(item_scene, no_of_items):
	for obj_cnt in range(no_of_items):
		var room = rooms[rng.randi_range(0, rooms.size()-1)]
		
		var rand_tile = get_random_available_tile_in_room(room)
		var x = rand_tile[0]
		var z = rand_tile[1]
				
		var item = item_scene.instance()
		item.translation = Vector3(x * TILE_OFFSET, 0.3, z * TILE_OFFSET)
		item.visible = false
		item.set_map_pos([x,z])
		item.add_to_group('loot')

		total_map[x][z].append(item)
	

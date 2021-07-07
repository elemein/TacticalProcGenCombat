extends Node

# This generator uses BSP (Binary Space Partitioning) to generate a dungeon
# by folding the dungeon into leaflets multiple times to create rooms.

# I followed this link: https://abitawake.com/news/articles/procedural-generation-with-godot-create-dungeons-using-a-bsp-tree
# I had to do some modification to it as the link uses a TileMap, whereas we use a 2D Array. 

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.2
const NUMBER_OF_ENEMIES = 10
# const AVG_NO_OF_ENEMIES_PER_ROOM = 2
const NUMBER_OF_TRAPS = 50
const NUMBER_OF_COINS = 5
const NUMBER_OF_SWORDS = 0
const NUMBER_OF_STAFFS = 1
const NUMBER_OF_NECKLACES = 1
const NUMBER_OF_DAGGERS = 1
const NUMBER_OF_ARMOURS = 1
const NUMBER_OF_CUIRASSES = 1

# Fun settings: 30x30
#const NUMBER_OF_ENEMIES = 10
## const AVG_NO_OF_ENEMIES_PER_ROOM = 2
#const NUMBER_OF_TRAPS = 20
#const NUMBER_OF_COINS = 5
#const NUMBER_OF_SWORDS = 1
#const NUMBER_OF_STAFFS = 1
#const NUMBER_OF_NECKLACES = 1
#const NUMBER_OF_DAGGERS = 1
#const NUMBER_OF_ARMOURS = 1

var base_enemy = preload("res://Assets/Objects/EnemyObjects/Enemy.tscn")
var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_wall = preload("res://Assets/Objects/MapObjects/Wall.tscn")
var base_spiketrap = preload("res://Assets/Objects/MapObjects/SpikeTrap.tscn")
var base_coins = preload("res://Assets/Objects/MapObjects/Coins.tscn")
var base_sword = preload("res://Assets/Objects/MapObjects/InventoryObjects/Sword.tscn")
var base_staff = preload("res://Assets/Objects/MapObjects/InventoryObjects/MagicStaff.tscn")
var base_necklace = preload("res://Assets/Objects/MapObjects/InventoryObjects/ArcaneNecklace.tscn")
var base_dagger = preload("res://Assets/Objects/MapObjects/InventoryObjects/ScabbardAndDagger.tscn")
var base_armour = preload("res://Assets/Objects/MapObjects/InventoryObjects/BodyArmour.tscn")
var base_cuirass = preload("res://Assets/Objects/MapObjects/InventoryObjects/LeatherCuirass.tscn")

var map_l = 30 # how many rows
var map_w = 30 # how long are those rows
var min_room_size = 4 # -1 is min room size.
var min_room_factor = 0.4 # Higher this is, the smaller the rooms are

var room_density = 100 # 0-100. 100 being most dense.

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
	for x in range(0, map_l):
		total_map.append([])
		for z in range(0, map_w):
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
	
	# I believe this adds a "center" dict entry to tree[parent_id] containing the
	# halfway points for that node.
	# apparently used to connect the leaves later
	tree[parent_id].center = {x = floor(x + l/2), z = floor(z + w/2)}
	
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
	for leaf_id in tree:
		var leaf = tree[leaf_id]
		if leaf.has("c"): continue # if node has children, don't build rooms
	
		if (rng.randi_range(0,100) < room_density):
			var room = {}
			room.id = leaf_id
			room.l = rng.randi_range(min_room_size, leaf.l) - 1
			room.w = rng.randi_range(min_room_size, leaf.w) - 1
			room.x = leaf.x + floor((leaf.l-room.l)/2) + 1
			room.z = leaf.z + floor((leaf.w-room.w)/2) + 1
			room.parent_id = leaf.parent_id
			
			room.split = leaf.split
			
			room.center = {"x": 0, "z": 0}
			room.center.x = floor(room.x + room.l/2)
			room.center.z = floor(room.z + room.w/2) 
			rooms.append(room)

	for i in range(rooms.size()):
		var room = rooms[i]
		
		for x in range(room.x, (room.x + room.l)):
			for z in range(room.z, (room.z + room.w)):
				var ground = base_block.instance()
				ground.translation = Vector3((x) * TILE_OFFSET, Y_OFFSET+0.3, (z) * TILE_OFFSET)
				ground.visible = false
				
				total_map[x][z][0] = ground
			
func join_rooms():
	for sister in leaves:
		var a = sister[0]
		var b = sister[1]
		connect_leaves(tree[a], tree[b])

func connect_leaves(leaf1, leaf2):
	var x = min(leaf1.center.x, leaf2.center.x)
	var z = min(leaf1.center.z, leaf2.center.z)
	var l = 1
	var w = 1
	
	if (leaf1.split == 'h'): # Vertical Corridor
		x -= 1
		w = abs(leaf1.center.z - leaf2.center.z)
	else:					 # Horizontal Corridor
		z -= 1
		l = abs(leaf1.center.x - leaf2.center.x)
	
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
				ground.translation = Vector3((i) * TILE_OFFSET, Y_OFFSET+0.3, (j) * TILE_OFFSET)
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
				
				var roof_count = check_nearby(x,z)
				if roof_count == 3:
					var wall = base_wall.instance()
					wall.translation = Vector3(x * TILE_OFFSET, Y_OFFSET+0.3, z * TILE_OFFSET)
					wall.visible = false
					
					total_map[x][z][0] = wall

					done = false

func check_nearby(x,z):
	var count = 0
	if total_map[x][z-1][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x][z+1][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x-1][z][0].get_obj_type() == 'Wall' : count += 1
	if total_map[x+1][z][0].get_obj_type() == 'Wall' : count += 1
			
	return count

func catalog_rooms():
	for room in rooms:
		room['bottomleft'] = [room.x, room.z]
		room['bottomright'] = [room.x, (room.z + room.w)-1]
		room['topleft'] = [(room.x + room.l) - 1, room.z]
		room['topright'] = [(room.x + room.l) - 1, (room.z + room.w)-1]
		room['type'] = 'Enemy'
	
	rooms[rng.randi_range(0, rooms.size()-1)]['type'] = 'Player Spawn'
	
	for room in rooms: print(room)

func get_random_available_tile_in_room(room) -> Array:
	var x
	var z
	
	var tile_clear = false
	
	while tile_clear == false:
		# room.x/z + room.w/h gives you the right/top border tile 
		# encirling the room, so we do -1 to ensure being in the room.
		x = rng.randi_range(room.x, (room.x + room.l)-1)
		z = rng.randi_range(room.z, (room.z + room.w)-1)
		
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
	spawn_inv_items(base_dagger, NUMBER_OF_DAGGERS)
	spawn_inv_items(base_armour, NUMBER_OF_ARMOURS)
	spawn_inv_items(base_cuirass, NUMBER_OF_CUIRASSES)

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

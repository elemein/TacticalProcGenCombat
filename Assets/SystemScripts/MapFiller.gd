extends Node

var rng = RandomNumberGenerator.new()

onready var world = get_node('/.')

const PATHFINDER = preload("res://Assets/SystemScripts/PathFinder.gd")
var pathfinder = PATHFINDER.new()

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")
var obj_spawner = OBJ_SPAWNER.new()

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.1
const AVG_NO_OF_ENEMIES_PER_ROOM = 1
const NUMBER_OF_TRAPS = 5
const NUMBER_OF_COINS = 5
const NUMBER_OF_SWORDS = 1
const NUMBER_OF_STAFFS = 1
const NUMBER_OF_NECKLACES = 1
const NUMBER_OF_DAGGERS = 1
const NUMBER_OF_ARMOURS = 1
const NUMBER_OF_CUIRASSES = 1

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

var base_stairs = preload("res://Assets/Objects/MapObjects/Stairs.tscn")

var map_object
var total_map
var rooms

var dist_to_spawn_dict = {}
var spawn_room
var exit_room

func _ready():
	rng.randomize()

func fill_map(passed_map_object, passed_map, passed_rooms):
	map_object = passed_map_object
	total_map = passed_map
	rooms = passed_rooms
	
	map_object.map_grid = total_map
	
	assign_spawn_room()
	
	assign_exit_room()
	
	assign_room_types()
	
	spawn_enemies()
	spawn_traps()
	spawn_loot()

	return [total_map, rooms]
	
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
	
func find_smallest_room():
	var smallest_room
	var smallest_room_area = 99999
	
	for room in rooms:
		if room.area < smallest_room_area: 
			smallest_room = room
			smallest_room_area = room['area']
	
	return smallest_room

func assign_spawn_room():
	var smallest_room = find_smallest_room()
	spawn_room = smallest_room
	spawn_room['type'] = 'Player Spawn'
	map_object.spawn_room = spawn_room
	
	var x = spawn_room.topleft[0]
	var z = spawn_room.topleft[1]
	
	var stairs = base_stairs.instance()
	stairs.translation = Vector3(x * TILE_OFFSET, 0.3, z * TILE_OFFSET)
	stairs.visible = false
	stairs.set_map_pos([x, z])
	stairs.set_parent_map(map_object)
	stairs.connects_to = map_object.map_id + 1
	map_object.add_map_object(stairs)

func assign_exit_room():
	find_room_dists_to_spawn()
	exit_room['type'] = 'Exit Room'
	
	var stairs = base_stairs.instance()
	stairs.translation = Vector3(exit_room.center.x * TILE_OFFSET, 0.3, exit_room.center.z * TILE_OFFSET)
	stairs.visible = false
	stairs.set_map_pos([exit_room.center.x, exit_room.center.z])
	stairs.set_parent_map(map_object)
	stairs.connects_to = map_object.map_id + 1
	map_object.add_map_object(stairs)

func assign_room_types():
	for room in rooms:
		if room['type'] == 'Unassigned':
			room['type'] = 'Enemy'

func find_room_dists_to_spawn():
	var furthest_dist = -99
	var furthest_room
	
	for room in rooms:
		var from = [room.center.x, room.center.z]
		var to = [spawn_room.center.x, spawn_room.center.z]
		
		var dist_from_spawn = pathfinder.solve(self, map_object, from, to)[0]
		
		room['distance_to_spawn'] = dist_from_spawn
		
		if (dist_from_spawn > furthest_dist):
			furthest_dist = dist_from_spawn
			furthest_room = room
			
	exit_room = furthest_room

func spawn_enemies():
	for room in rooms:
		if room['type'] == 'Enemy':
			var rng_mod = rng.randi_range(-1,2)
			var no_of_enemy_in_room = rng_mod + AVG_NO_OF_ENEMIES_PER_ROOM
			
			if no_of_enemy_in_room > 0:
				for enemy_cnt in range(no_of_enemy_in_room):
					var rand_tile = get_random_available_tile_in_room(room)
					var x = rand_tile[0]
					var z = rand_tile[1]
							
					var enemy = base_enemy.instance()
					enemy.translation = Vector3(x * TILE_OFFSET, Y_OFFSET+0.3, z * TILE_OFFSET)
					enemy.visible = false
					enemy.set_map_pos([x,z])
					enemy.set_parent_map(map_object)
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
		trap.set_parent_map(map_object)
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
		item.set_parent_map(map_object)
		item.add_to_group('loot')

		total_map[x][z].append(item)

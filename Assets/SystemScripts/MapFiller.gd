extends Node

var rng = RandomNumberGenerator.new()

onready var world = get_node('/.')

const PATHFINDER = preload("res://Assets/SystemScripts/PathFinder.gd")
var pathfinder = PATHFINDER.new()

const Y_OFFSET = -0.3
const AVG_NO_OF_ENEMIES_PER_ROOM = 1
const NUMBER_OF_TRAPS = 5
const NUMBER_OF_COINS = 5
const NUMBER_OF_SWORDS = 1
const NUMBER_OF_STAFFS = 1
const NUMBER_OF_NECKLACES = 1
const NUMBER_OF_DAGGERS = 1
const NUMBER_OF_ARMOURS = 1
const NUMBER_OF_CUIRASSES = 1

var base_block = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_wall = preload("res://Assets/Objects/MapObjects/Wall.tscn")
var base_spiketrap = preload("res://Assets/Objects/MapObjects/SpikeTrap.tscn")

var base_stairs = preload("res://Assets/Objects/MapObjects/Stairs.tscn")

var obj_spawner = GlobalVars.obj_spawner

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
	stairs.translation = Vector3(x * GlobalVars.TILE_OFFSET, 0.3, z * GlobalVars.TILE_OFFSET)
	stairs.visible = false
	stairs.set_map_pos([x, z])
	stairs.set_parent_map(map_object)
	stairs.connects_to = map_object.map_id + 1
	map_object.add_map_object(stairs)

func assign_exit_room():
	find_room_dists_to_spawn()
	exit_room['type'] = 'Exit Room'
	map_object.exit_room = exit_room
	
	if map_object.get_map_type() == 'Normal Floor':
		var stairs = base_stairs.instance()
		stairs.translation = Vector3(exit_room.center.x * GlobalVars.TILE_OFFSET, 0.3, exit_room.center.z * GlobalVars.TILE_OFFSET)
		stairs.visible = false
		stairs.set_map_pos([exit_room.center.x, exit_room.center.z])
		stairs.set_parent_map(map_object)
		stairs.connects_to = map_object.map_id + 1
		map_object.add_map_object(stairs)
	elif map_object.get_map_type() == 'End Floor':
		spawn_enemies_in_room(exit_room, floor(exit_room.area/3))

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

func spawn_enemies_in_room(room, enemy_cnt):
	if enemy_cnt > 0:
		for _cnt in range(enemy_cnt):
			var rand_tile = get_random_available_tile_in_room(room)
			var x = rand_tile[0]
			var z = rand_tile[1]
			
			var enemy_list = ['Imp', 'Fox']
			var chosen_enemy = enemy_list[rng.randi_range(0,1)]
			
			obj_spawner.spawn_enemy(chosen_enemy, map_object, [x, z], false)

func spawn_enemies():
	for room in rooms:
		if room['type'] == 'Enemy':
			var rng_mod = rng.randi_range(-1,2)
			var no_of_enemy_in_room = rng_mod + AVG_NO_OF_ENEMIES_PER_ROOM
			
			if no_of_enemy_in_room > 0:
				for _enemy_cnt in range(no_of_enemy_in_room):
					var rand_tile = get_random_available_tile_in_room(room)
					var x = rand_tile[0]
					var z = rand_tile[1]
					
					var enemy_list = ['Imp', 'Fox']
					var chosen_enemy = enemy_list[rng.randi_range(0,1)]
					
					obj_spawner.spawn_enemy(chosen_enemy, map_object, [x, z], false)

func spawn_traps():
	for _trap_cnt in range(NUMBER_OF_TRAPS):
		var room = rooms[rng.randi_range(0, rooms.size()-1)]

		var rand_tile = get_random_available_tile_in_room(room)
		var x = rand_tile[0]
		var z = rand_tile[1]
				
		var trap = base_spiketrap.instance()
		trap.translation = Vector3(x * GlobalVars.TILE_OFFSET, Y_OFFSET+0.3-1, z * GlobalVars.TILE_OFFSET)
		trap.visible = false
		trap.set_map_pos([x,z])
		trap.set_parent_map(map_object)
		trap.add_to_group('traps')

		total_map[x][z].append(trap)

func spawn_loot():
	spawn_gold(NUMBER_OF_COINS)
	
	spawn_inv_items('Sword', NUMBER_OF_SWORDS)
	spawn_inv_items('Magic Staff', NUMBER_OF_STAFFS)
	spawn_inv_items('Arcane Necklace', NUMBER_OF_NECKLACES)
	spawn_inv_items('Scabbard and Dagger', NUMBER_OF_DAGGERS)
	spawn_inv_items('Body Armour', NUMBER_OF_ARMOURS)
	spawn_inv_items('Leather Cuirass', NUMBER_OF_CUIRASSES)
	
func spawn_gold(no_of_items):
	for _obj_cnt in range(no_of_items):
		var room = rooms[rng.randi_range(0, rooms.size()-1)]
		var rand_tile = get_random_available_tile_in_room(room)

		obj_spawner.spawn_gold(rng.randi_range(10,30), map_object, [rand_tile[0], rand_tile[1]], false)

func spawn_inv_items(item_name, no_of_items):
	for _obj_cnt in range(no_of_items):
		var room = rooms[rng.randi_range(0, rooms.size()-1)]
		var rand_tile = get_random_available_tile_in_room(room)

		obj_spawner.spawn_item(item_name, map_object, [rand_tile[0], rand_tile[1]], false)

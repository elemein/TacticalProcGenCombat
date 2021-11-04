extends Node

var rng = RandomNumberGenerator.new()

onready var world = get_node('/.')

const PATHFINDER = preload("res://Assets/SystemScripts/PathFinder.gd")
var pathfinder = PATHFINDER.new()

const AVG_NO_OF_ENEMIES_PER_ROOM = 1
const NUMBER_OF_TRAPS = 5

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
	
	fill_rooms()

	spawn_traps()

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
			if object.get_id()['CategoryType'] != 'Ground': 
				all_clear = false
		
		if all_clear == true: tile_clear = true
	
	return [x,z]
	
func find_smallest_room():
	var smallest_room
	var smallest_room_area = INF
	
	for room in rooms:
		if room.area < smallest_room_area: 
			smallest_room = room
			smallest_room_area = room['area']
	
	return smallest_room

func assign_spawn_room():
	spawn_room = find_smallest_room()
	spawn_room['type'] = 'Player Spawn'
	map_object.spawn_room = spawn_room
	
#	# ENABLE BELOW IF YOU WANT STAIRS IN SPAWN ROOM
	if map_object.map_id < map_object.parent_mapset.floor_count: # if last floor, no stairs
		obj_spawner.spawn_map_object('BaseStairs', map_object, \
										spawn_room.topleft, false)
	# ------------------------------------------------------------
	
	rng.randomize()
	spawn_treasure_in_room(spawn_room, rng.randi_range(0,1), 
							rng.randi_range(0,1), rng.randi_range(0,1), 0)

func assign_exit_room():
	find_room_dists_to_spawn()
	exit_room['type'] = 'Exit Room'
	map_object.exit_room = exit_room
	
	if map_object.get_map_type() == 'Normal Floor':
		obj_spawner.spawn_map_object('BaseStairs', map_object, \
										exit_room.center, false)

	elif map_object.get_map_type() == 'End Floor':
		spawn_specific_enemy_in_room(exit_room, 1, 'Minotaur')

func assign_room_types():
	for room in rooms:
		if room.type == 'Unassigned':
			var rand_mod = rng.randi_range(0,100)
			
			if (rand_mod >= 0) and (rand_mod <= 70):
				room.type = 'Enemy'
			elif (rand_mod >= 71) and (rand_mod <= 90):
				room.type = 'Treasure'
			elif (rand_mod >= 91) and (rand_mod <= 100):
				room.type = 'Horde'

func fill_rooms():
	for room in rooms:
		if room.type == 'Enemy':
			var rng_mod = rng.randi_range(-1,1)
			var no_of_enemy_in_room = rng_mod + AVG_NO_OF_ENEMIES_PER_ROOM
			spawn_enemies_in_room(room, no_of_enemy_in_room)

		elif room.type == 'Treasure':
			var wep_cnt = rng.randi_range(0,1)
			var armr_cnt = rng.randi_range(0,1)
			var acc_cnt = rng.randi_range(0,1)
			var gold_cnt = rng.randi_range(1,2)
			
			spawn_treasure_in_room(room, wep_cnt, armr_cnt, acc_cnt, gold_cnt)
		
		if room.type == 'Horde':
			var enemy_cnt = (room.area/2)
			if enemy_cnt > 5: enemy_cnt = 5
			spawn_enemies_in_room(room, enemy_cnt)

func find_room_dists_to_spawn():
	var furthest_dist = -INF
	var furthest_room
	
	for room in rooms:
		var from = [room.center[0], room.center[1]]
		var to = [spawn_room.center[0], spawn_room.center[1]]
		
		var dist_from_spawn = pathfinder.solve(self, map_object, from, to)[0]
		
		room['distance_to_spawn'] = dist_from_spawn
		
		if (dist_from_spawn > furthest_dist):
			furthest_dist = dist_from_spawn
			furthest_room = room
			
	exit_room = furthest_room

func spawn_treasure_in_room(room, wep_cnt, armr_cnt, acc_cnt, gold_cnt):
	var pos_weps = ['Sword', 'Magic Staff']
	for _wep in range(0, wep_cnt):
		var rand_tile = get_random_available_tile_in_room(room)
		var chosen_wep = pos_weps[rng.randi_range(0,1)]
		obj_spawner.spawn_item(chosen_wep, map_object, rand_tile, false)
		
	var pos_armrs = ['Body Armour', 'Leather Cuirass']
	for _armr in range(0, armr_cnt):
		var rand_tile = get_random_available_tile_in_room(room)
		var chosen_armr = pos_armrs[rng.randi_range(0,1)]
		obj_spawner.spawn_item(chosen_armr, map_object, rand_tile, false)
		
	var pos_accs = ['Arcane Necklace', 'Scabbard and Dagger']
	for _acc in range(0, acc_cnt):
		var rand_tile = get_random_available_tile_in_room(room)
		var chosen_acc = pos_accs[rng.randi_range(0,1)]
		obj_spawner.spawn_item(chosen_acc, map_object, rand_tile, false)
	
	for _gold in range(0, gold_cnt):
		var rand_tile = get_random_available_tile_in_room(room)
		obj_spawner.spawn_gold(rng.randi_range(10,30), map_object, rand_tile, false)

func spawn_enemies_in_room(room, enemy_cnt):
	var enemy_list = ['Imp', 'Fox']
	
	if enemy_cnt > 0:
		for _cnt in range(enemy_cnt):
			var chosen_enemy = enemy_list[rng.randi_range(0, enemy_list.size()-1)]
			
			obj_spawner.spawn_enemy(chosen_enemy, map_object, \
								get_random_available_tile_in_room(room), false)

func spawn_specific_enemy_in_room(room, enemy_cnt, enemy_type):
	if enemy_cnt > 0:
		for _cnt in range(enemy_cnt):
			obj_spawner.spawn_enemy(enemy_type, map_object, \
							get_random_available_tile_in_room(room), false)

func spawn_traps():
	for _trap_cnt in range(NUMBER_OF_TRAPS):
		var room = rooms[rng.randi_range(0, rooms.size()-1)]

		obj_spawner.spawn_map_object('Spike Trap', map_object, \
								get_random_available_tile_in_room(room), false)

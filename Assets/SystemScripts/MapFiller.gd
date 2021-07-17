extends Node

var rng = RandomNumberGenerator.new()

const Y_OFFSET = -0.3
const TILE_OFFSET = 2.1
const AVG_NO_OF_ENEMIES_PER_ROOM = 2
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

var total_map
var rooms

func _ready():
	rng.randomize()

func fill_map(passed_map, passed_rooms):
	total_map = passed_map
	rooms = passed_rooms
	
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
	
func assign_room_types():
	for room in rooms:
		room['type'] = 'Enemy'
	
	rooms[rng.randi_range(0, rooms.size()-1)]['type'] = 'Player Spawn'

func spawn_enemies():
	for room in rooms:
		if room['type'] == 'Enemy':
			var no_of_enemy_in_room = rng.randi_range(-1,1) + AVG_NO_OF_ENEMIES_PER_ROOM
			
			if no_of_enemy_in_room > 0:
				for enemy_cnt in range(no_of_enemy_in_room):
					var rand_tile = get_random_available_tile_in_room(room)
					var x = rand_tile[0]
					var z = rand_tile[1]
							
					var enemy = base_enemy.instance()
					enemy.translation = Vector3(x * TILE_OFFSET, Y_OFFSET+0.3, z * TILE_OFFSET)
					enemy.visible = false
					enemy.set_map_pos([x,z])
					enemy.set_parent_map(total_map)
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
		trap.set_parent_map(total_map)
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
		item.set_parent_map(total_map)
		item.add_to_group('loot')

		total_map[x][z].append(item)

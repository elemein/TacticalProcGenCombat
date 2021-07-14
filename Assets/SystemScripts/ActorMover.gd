extends Node

const TILE_OFFSET = 2.0

onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

var actor
var map_pos
var direction_facing
var target_pos

# Initiliaztion functions
func set_actor(setter):
	actor = setter
	map_pos = actor.get_map_pos()
	target_pos = actor.get_translation()

func set_actor_translation():
	var interp_mod = actor.get_turn_anim_timer().time_left / actor.get_turn_anim_timer().get_wait_time()
	actor.set_translation(actor.get_translation().linear_interpolate(target_pos, 1-interp_mod))

func check_cornering(direction):
	match direction:
		'upleft':
			if map.is_tile_wall(map_pos[0]+1,map_pos[1]): return false
			if map.is_tile_wall(map_pos[0],map_pos[1]-1): return false
		'upright': 
			if map.is_tile_wall(map_pos[0]+1,map_pos[1]): return false
			if map.is_tile_wall(map_pos[0],map_pos[1]+1): return false
		'downleft': 
			if map.is_tile_wall(map_pos[0]-1,map_pos[1]): return false
			if map.is_tile_wall(map_pos[0],map_pos[1]-1): return false	
		'downright': 
			if map.is_tile_wall(map_pos[0]-1,map_pos[1]): return false
			if map.is_tile_wall(map_pos[0],map_pos[1]+1): return false
	return true

func check_move_action(move):
	match move:
		'move upleft':
			if map.tile_available(map_pos[0] + 1, map_pos[1] - 1) == true: 
				if check_cornering('upleft'): return true
		'move upright':
			if map.tile_available(map_pos[0] + 1, map_pos[1] + 1) == true: 
				if check_cornering('upright'): return true
		'move downleft':
			if map.tile_available(map_pos[0] - 1, map_pos[1] - 1) == true: 
				if check_cornering('downleft'): return true
		'move downright':
			if map.tile_available(map_pos[0] - 1, map_pos[1] + 1) == true: 
				if check_cornering('downright'): return true
		
		'move up':
			if map.tile_available(map_pos[0] + 1, map_pos[1]) == true: return true
		'move down':
			if map.tile_available(map_pos[0] - 1, map_pos[1]) == true: return true
		'move left':
			if map.tile_available(map_pos[0], map_pos[1] - 1) == true: return true
		'move right':
			if map.tile_available(map_pos[0], map_pos[1] + 1) == true: return true
				
	return false

func move_actor(amount):
	var target_tile
	var direction = actor.get_direction_facing()
	actor.set_actor_dir(direction)

	match direction:
		'upleft':
			target_tile = [map_pos[0] + amount, map_pos[1] - amount]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET
		'upright':
			target_tile = [map_pos[0] + amount, map_pos[1] + amount]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET
		'downleft':
			target_tile = [map_pos[0] - amount, map_pos[1] - amount]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET
		'downright':
			target_tile = [map_pos[0] - amount, map_pos[1] + amount]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET

		'up':
			target_tile = [map_pos[0] + amount, map_pos[1]]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = actor.get_translation().z
		'down':
			target_tile = [map_pos[0] - amount, map_pos[1]]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = actor.get_translation().z
		'left':
			target_tile = [map_pos[0], map_pos[1] - amount]
			target_pos.z = target_tile[1] * TILE_OFFSET
			target_pos.x = actor.get_translation().x
		'right':
			target_tile = [map_pos[0], map_pos[1] + amount]
			target_pos.z = target_tile[1] * TILE_OFFSET
			target_pos.x = actor.get_translation().x

	map_pos = map.move_on_map(actor, map_pos, target_tile)
	actor.set_map_pos(map_pos)
	check_tile_for_steppable_objects(map_pos[0], map_pos[1])

func check_tile_for_steppable_objects(x,z):
	var tile_objects = map.get_tile_contents(x,z)
	
	for object in tile_objects:
		match object.get_obj_type():
			'Spike Trap': object.activate_trap(tile_objects)
			'Coins': object.collect_item(tile_objects)
			'Inv Item': object.collect_item(tile_objects)

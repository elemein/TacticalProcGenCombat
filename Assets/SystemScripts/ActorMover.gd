extends Node

const TILE_OFFSET = 2.2

onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

var actor
var map_pos
var direction_facing
var target_pos
var saved_pos

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

func set_actor_direction(direction):
	match direction:
		'upleft': actor.set_model_rot("upleft", (135))
		'upright': actor.set_model_rot("upright", (45))
		'downleft': actor.set_model_rot("downleft", (225))
		'downright': actor.set_model_rot("downright", (315))
		
		'up': actor.set_model_rot("up", (90))
		'down': actor.set_model_rot("down", (270))
		'left': actor.set_model_rot("left", (180))
		'right': actor.set_model_rot("right", (0))

	direction_facing = direction

func move_actor():
	var target_tile
	var direction = actor.get_action().split(" ")[1]
	set_actor_direction(direction)

	match direction:
		'upleft':
			target_tile = [map_pos[0] + 1, map_pos[1] - 1]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET
		'upright':
			target_tile = [map_pos[0] + 1, map_pos[1] + 1]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET
		'downleft':
			target_tile = [map_pos[0] - 1, map_pos[1] - 1]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET
		'downright':
			target_tile = [map_pos[0] - 1, map_pos[1] + 1]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = target_tile[1] * TILE_OFFSET

		'up':
			target_tile = [map_pos[0] + 1, map_pos[1]]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = actor.get_translation().z
		'down':
			target_tile = [map_pos[0] - 1, map_pos[1]]
			target_pos.x = target_tile[0] * TILE_OFFSET
			target_pos.z = actor.get_translation().z
		'left':
			target_tile = [map_pos[0], map_pos[1] - 1]
			target_pos.z = target_tile[1] * TILE_OFFSET
			target_pos.x = actor.get_translation().x
		'right':
			target_tile = [map_pos[0], map_pos[1] + 1]
			target_pos.z = target_tile[1] * TILE_OFFSET
			target_pos.x = actor.get_translation().x

	map_pos = map.move_on_map(actor, map_pos, target_tile)
	check_tile_for_steppable_objects(map_pos[0], map_pos[1])
	actor.set_map_pos(map_pos)

func check_tile_for_steppable_objects(x,z):
	var tile_objects = map.get_tile_contents(x,z)
	
	for object in tile_objects:
		match object.get_obj_type():
			'Spike Trap': object.activate_trap(tile_objects)
			'Coins': object.collect_item(tile_objects)
			'Sword': object.collect_item(tile_objects)
			'Magic Staff': object.collect_item(tile_objects)

func reset_pos_vars():
	target_pos = actor.get_translation()
	saved_pos = actor.get_translation()

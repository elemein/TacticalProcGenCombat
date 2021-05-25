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

# Move actor
func set_actor_translation():
	actor.set_translation(actor.get_translation().linear_interpolate(target_pos, (1-turn_timer.time_left))) 

func check_cornering(direction): # This can definitely be done better. - SS
	match direction:
		'upleft': # check both tiles up and left to check for walls
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
		'upleft': actor.set_model_rot("upleft", (45 + 90))
		'upright': actor.set_model_rot("upright", (45))
		'downleft': actor.set_model_rot("downleft", (45 + 180))
		'downright': actor.set_model_rot("downright", (45 + 90 + 180))
		
		'up': actor.set_model_rot("up", (90))
		'down': actor.set_model_rot("down", (90 + 180))
		'left': actor.set_model_rot("left", (180))
		'right': actor.set_model_rot("right", (180 + 180))

	direction_facing = direction

func move_actor():
	var target_tile
	var proposed_action = actor.get_action()
	# Sets target positions for move and basic attack.
	if proposed_action.split(" ")[0] == 'move':
		set_actor_direction(proposed_action.split(" ")[1])

		match proposed_action.split(" ")[1]:
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
			
			'idle':
				target_pos = map_pos

		map_pos = map.move_on_map(actor, map_pos, target_tile)
		actor.set_map_pos(map_pos)

func reset_pos_vars():
	target_pos = actor.get_translation()
	saved_pos = actor.get_translation()

extends Node

var actor
var direction_facing
var target_pos
var turn_timer

onready var parent_tween = get_node("../Tween")

# Initiliaztion functions
func set_actor(setter):
	actor = setter
	target_pos = actor.get_translation()
	turn_timer = actor.get_parent_map().get_turn_timer()

func move_actor_translation():
	# ANIM TIMER FOR MOVE IS 0.35
	parent_tween.interpolate_property(actor, "translation", actor.get_translation(), target_pos, 0.35, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	parent_tween.start()

func set_actor_translation():
	var interp_mod = actor.get_turn_anim_timer().time_left / actor.get_turn_anim_timer().get_wait_time()
	actor.set_translation(actor.get_translation().linear_interpolate(target_pos, 1-interp_mod))

func check_cornering(direction):
	var map_pos = actor.get_map_pos()
	
	match direction:
		'upleft':
			if actor.parent_map.is_tile_wall(map_pos[0]+1,map_pos[1]): return false
			if actor.parent_map.is_tile_wall(map_pos[0],map_pos[1]-1): return false
		'upright': 
			if actor.parent_map.is_tile_wall(map_pos[0]+1,map_pos[1]): return false
			if actor.parent_map.is_tile_wall(map_pos[0],map_pos[1]+1): return false
		'downleft': 
			if actor.parent_map.is_tile_wall(map_pos[0]-1,map_pos[1]): return false
			if actor.parent_map.is_tile_wall(map_pos[0],map_pos[1]-1): return false	
		'downright': 
			if actor.parent_map.is_tile_wall(map_pos[0]-1,map_pos[1]): return false
			if actor.parent_map.is_tile_wall(map_pos[0],map_pos[1]+1): return false
	return true

func check_move_action(move):
	var map_pos = actor.get_map_pos()
	
	match move:
		'move upleft':
			if actor.parent_map.tile_available(map_pos[0] + 1, map_pos[1] - 1) == true: 
				if check_cornering('upleft'): return true
		'move upright':
			if actor.parent_map.tile_available(map_pos[0] + 1, map_pos[1] + 1) == true: 
				if check_cornering('upright'): return true
		'move downleft':
			if actor.parent_map.tile_available(map_pos[0] - 1, map_pos[1] - 1) == true: 
				if check_cornering('downleft'): return true
		'move downright':
			if actor.parent_map.tile_available(map_pos[0] - 1, map_pos[1] + 1) == true: 
				if check_cornering('downright'): return true
		
		'move up':
			if actor.parent_map.tile_available(map_pos[0] + 1, map_pos[1]) == true: return true
		'move down':
			if actor.parent_map.tile_available(map_pos[0] - 1, map_pos[1]) == true: return true
		'move left':
			if actor.parent_map.tile_available(map_pos[0], map_pos[1] - 1) == true: return true
		'move right':
			if actor.parent_map.tile_available(map_pos[0], map_pos[1] + 1) == true: return true
				
	return false

func move_actor(amount):
	var map_pos = actor.get_map_pos()
	var target_tile
	var direction = actor.get_direction_facing()

	match direction:
		'upleft':
			target_tile = [map_pos[0] + amount, map_pos[1] - amount]
			target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
		'upright':
			target_tile = [map_pos[0] + amount, map_pos[1] + amount]
			target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
		'downleft':
			target_tile = [map_pos[0] - amount, map_pos[1] - amount]
			target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
		'downright':
			target_tile = [map_pos[0] - amount, map_pos[1] + amount]
			target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET

		'up':
			target_tile = [map_pos[0] + amount, map_pos[1]]
			target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			target_pos.z = actor.get_translation().z
		'down':
			target_tile = [map_pos[0] - amount, map_pos[1]]
			target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			target_pos.z = actor.get_translation().z
		'left':
			target_tile = [map_pos[0], map_pos[1] - amount]
			target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
			target_pos.x = actor.get_translation().x
		'right':
			target_tile = [map_pos[0], map_pos[1] + amount]
			target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
			target_pos.x = actor.get_translation().x

	map_pos = actor.parent_map.move_on_map(actor, map_pos, target_tile)
	actor.set_map_pos(map_pos)
	move_actor_translation()
	check_tile_for_steppable_objects(map_pos[0], map_pos[1])

func check_tile_for_steppable_objects(x,z):
	var tile_objects = actor.parent_map.get_tile_contents(x,z)
	
	for object in tile_objects:
		match object.get_id()['CategoryType']:
			'Trap': object.activate_trap(tile_objects)
			'Coins': object.collect_item(tile_objects)
			'Armour': object.collect_item(tile_objects)
			'Weapon': object.collect_item(tile_objects)
			'Accessory': object.collect_item(tile_objects)
			'Interactable': object.interact_w_object(tile_objects)

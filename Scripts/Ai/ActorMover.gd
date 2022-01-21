extends Node

var actor
var direction_facing
var target_pos
var turn_timer

onready var parent_tween = get_node("../Tween")

# Initiliaztion functions
func set_actor(setter):
	self.actor = setter
	self.target_pos = self.actor.get_translation()
	self.turn_timer = self.actor.get_parent_map().get_turn_timer()

func move_actor_translation():
	# ANIM TIMER FOR MOVE IS 0.35
	var walk_time = 0.35
	self.parent_tween.interpolate_property(self.actor, "translation", actor.get_translation(), self.target_pos, walk_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	# handles animation
	self.actor.play_anim('run')
	self.parent_tween.interpolate_callback(self.actor, walk_time, "play_anim", 'idle')
	self.parent_tween.start()

func check_cornering(direction):
	var map_pos = self.actor.get_map_pos()
	
	match direction:
		'upleft':
			if self.actor.parent_map.tile_blocks_vision(map_pos[0]+1,map_pos[1]): return false
			if self.actor.parent_map.tile_blocks_vision(map_pos[0],map_pos[1]-1): return false
		'upright': 
			if self.actor.parent_map.tile_blocks_vision(map_pos[0]+1,map_pos[1]): return false
			if self.actor.parent_map.tile_blocks_vision(map_pos[0],map_pos[1]+1): return false
		'downleft': 
			if self.actor.parent_map.tile_blocks_vision(map_pos[0]-1,map_pos[1]): return false
			if self.actor.parent_map.tile_blocks_vision(map_pos[0],map_pos[1]-1): return false	
		'downright': 
			if self.actor.parent_map.tile_blocks_vision(map_pos[0]-1,map_pos[1]): return false
			if self.actor.parent_map.tile_blocks_vision(map_pos[0],map_pos[1]+1): return false
	return true

func check_move_action(move):
	var map_pos = self.actor.get_map_pos()
	
	match move:
		'move upleft':
			if self.actor.parent_map.tile_available(map_pos[0] + 1, map_pos[1] - 1) == true: 
				if check_cornering('upleft'): return true
		'move upright':
			if self.actor.parent_map.tile_available(map_pos[0] + 1, map_pos[1] + 1) == true: 
				if check_cornering('upright'): return true
		'move downleft':
			if self.actor.parent_map.tile_available(map_pos[0] - 1, map_pos[1] - 1) == true: 
				if check_cornering('downleft'): return true
		'move downright':
			if self.actor.parent_map.tile_available(map_pos[0] - 1, map_pos[1] + 1) == true: 
				if check_cornering('downright'): return true
		
		'move up':
			if self.actor.parent_map.tile_available(map_pos[0] + 1, map_pos[1]) == true: return true
		'move down':
			if self.actor.parent_map.tile_available(map_pos[0] - 1, map_pos[1]) == true: return true
		'move left':
			if self.actor.parent_map.tile_available(map_pos[0], map_pos[1] - 1) == true: return true
		'move right':
			if self.actor.parent_map.tile_available(map_pos[0], map_pos[1] + 1) == true: return true
				
	return false

func move_actor(amount):
	var map_pos = self.actor.get_map_pos()
	var target_tile
	var direction = self.actor.get_direction_facing()

	match direction:
		'upleft':
			target_tile = [map_pos[0] + amount, map_pos[1] - amount]
			self.target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			self.target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
		'upright':
			target_tile = [map_pos[0] + amount, map_pos[1] + amount]
			self.target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			self.target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
		'downleft':
			target_tile = [map_pos[0] - amount, map_pos[1] - amount]
			self.target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			self.target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
		'downright':
			target_tile = [map_pos[0] - amount, map_pos[1] + amount]
			self.target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			self.target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET

		'up':
			target_tile = [map_pos[0] + amount, map_pos[1]]
			self.target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			self.target_pos.z = self.actor.get_translation().z
		'down':
			target_tile = [map_pos[0] - amount, map_pos[1]]
			self.target_pos.x = target_tile[0] * GlobalVars.TILE_OFFSET
			self.target_pos.z = self.actor.get_translation().z
		'left':
			target_tile = [map_pos[0], map_pos[1] - amount]
			self.target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
			self.target_pos.x = self.actor.get_translation().x
		'right':
			target_tile = [map_pos[0], map_pos[1] + amount]
			self.target_pos.z = target_tile[1] * GlobalVars.TILE_OFFSET
			self.target_pos.x = self.actor.get_translation().x

	map_pos = self.actor.parent_map.move_on_map(actor, map_pos, target_tile)
	self.actor.set_map_pos(map_pos)
	move_actor_translation()
	
	if GlobalVars.peer_type == 'server':
		check_tile_for_steppable_objects(map_pos[0], map_pos[1])

func check_tile_for_steppable_objects(x,z):
	var tile_objects = self.actor.parent_map.get_tile_contents(x,z)
	
	for object in tile_objects:
		match object.get_id()['CategoryType']:
			'Trap': object.activate_trap(tile_objects)
			'Coins': object.collect_item(tile_objects)
			'Armour': object.collect_item(tile_objects)
			'Weapon': object.collect_item(tile_objects)
			'Accessory': object.collect_item(tile_objects)
			'Interactable': object.interact_w_object(tile_objects)

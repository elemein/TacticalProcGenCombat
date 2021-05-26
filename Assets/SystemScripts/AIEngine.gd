extends Node

const VISION_RANGE = 15

onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")
onready var player = get_node("/root/World/Player")

var rng = RandomNumberGenerator.new()

var ai_state = 'active' # [idle, active]

var actor

var players = []

var dist_from_player = 0
var path = []

var pathfinder_direction

func _ready():
	rng.randomize()

func set_actor(setter):
	actor = setter
	
func reset_vars():
	players = []
	dist_from_player = 0

func run_engine():
	reset_vars()
	# first, we must see where PCs are, as the AI only responds to PCs.
	players.append(player.get_map_pos())
	# if a PC is not within VISION_RANGE tiles, the AI can idle.
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		pathfinder_direction = 'idle'
		#find path to player
		
		pathfind()
		determine_direction_of_path()
		
		if dist_from_player == 1: pathfinder_direction = 'idle'
		
		match pathfinder_direction:
			'up':
				if actor.check_move_action('move up'):
					actor.set_action('move up')
				else: actor.set_action('idle')
			'down':
				if actor.check_move_action('move down'):
					actor.set_action('move down')
				else: actor.set_action('idle')
			'left':
				if actor.check_move_action('move left'):
					actor.set_action('move left')
				else: actor.set_action('idle')
			'right':
				if actor.check_move_action('move right'):
					actor.set_action('move right')
				else: actor.set_action('idle')
					
			'upleft':
				if actor.check_move_action('move upleft'):
					actor.set_action('move upleft')
				else: actor.set_action('idle')
			'upright':
				if actor.check_move_action('move upright'):
					actor.set_action('move upright')
				else: actor.set_action('idle')
			'downleft':
				if actor.check_move_action('move downleft'):
					actor.set_action('move downleft')
				else: actor.set_action('idle')
			'downright':
				if actor.check_move_action('move downright'):
					actor.set_action('move downright')
				else: actor.set_action('idle')
			'idle':
				actor.set_action('idle')
				
			

func pathfind(): # ONLY WORKS FOR SINGLE PLAYERS FOR NOW
	var path_info = map.pathfind(actor, actor.get_map_pos(), players[0])
	
	dist_from_player = path_info[0]
	path = path_info[1]
	
	if dist_from_player == 1:
		path.append([actor.get_map_pos()]) 
	
	
func determine_direction_of_path():
	var curr_pos = actor.get_map_pos()
	
	if path[0] == [curr_pos[0] + 1, curr_pos[1]]: pathfinder_direction = 'up'
	elif path[0] == [curr_pos[0] - 1, curr_pos[1]]: pathfinder_direction = 'down'
	elif path[0] == [curr_pos[0], curr_pos[1] - 1]: pathfinder_direction = 'left'
	elif path[0] == [curr_pos[0], curr_pos[1] + 1]: pathfinder_direction = 'right'
	
	elif path[0] == [curr_pos[0] + 1, curr_pos[1] - 1]: pathfinder_direction = 'upleft'
	elif path[0] == [curr_pos[0] + 1, curr_pos[1] + 1]: pathfinder_direction = 'upright'
	elif path[0] == [curr_pos[0] - 1, curr_pos[1] - 1]: pathfinder_direction = 'downleft'
	elif path[0] == [curr_pos[0] - 1, curr_pos[1] + 1]: pathfinder_direction = 'downright'

func check_if_adjacent_to_player():
	for direction in ['up', 'down', 'left', 'right', 'upleft', 'upright', 'downleft', 'downright']:
		var tile
		match direction:
			'up': tile = map.get_tile_contents(actor.get_map_pos()[0] + 1, actor.get_map_pos()[1])
			'down': tile = map.get_tile_contents(actor.get_map_pos()[0] - 1, actor.get_map_pos()[1])
			'left': tile = map.get_tile_contents(actor.get_map_pos()[0], actor.get_map_pos()[1] - 1)
			'right': tile = map.get_tile_contents(actor.get_map_pos()[0], actor.get_map_pos()[1] + 1)
			'upleft': tile = map.get_tile_contents(actor.get_map_pos()[0] + 1, actor.get_map_pos()[1] - 1)
			'upright': tile = map.get_tile_contents(actor.get_map_pos()[0] + 1, actor.get_map_pos()[1] + 1)
			'downleft': tile = map.get_tile_contents(actor.get_map_pos()[0] - 1, actor.get_map_pos()[1] - 1)
			'downright': tile = map.get_tile_contents(actor.get_map_pos()[0] - 1, actor.get_map_pos()[1] + 1)
				
		if typeof(tile) == TYPE_OBJECT:
			if tile.get_obj_type() == 'Player':
				
				return true
				
	return false

extends Node

const VISION_RANGE = 5

onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

var rng = RandomNumberGenerator.new()

var ai_state # [idle, active]

var actor

var detected_players = []

var dist_from_player = 0
var path = []

var pathfinder_direction

func _ready():
	rng.randomize()

func set_actor(setter):
	actor = setter
	
func run_engine():
	# first, we must see where PCs are, as the AI only responds to PCs.
	
	# if a PC is not within VISION_RANGE tiles, the AI can idle.
	search_area()
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		
		pathfinder_direction = 'idle'
		
		#find path to player
		pathfind()
		determine_direction_of_path()
		
		match pathfinder_direction:
			'up':
				if actor.check_move_action('move up'):
					actor.set_action('move up')
			'down':
				if actor.check_move_action('move down'):
					actor.set_action('move down')
			'left':
				if actor.check_move_action('move left'):
					actor.set_action('move left')
			'right':
				if actor.check_move_action('move right'):
					actor.set_action('move right')
					
			'upleft':
				if actor.check_move_action('move upleft'):
					actor.set_action('move upleft')
			'upright':
				if actor.check_move_action('move upright'):
					actor.set_action('move upright')
			'downleft':
				if actor.check_move_action('move downleft'):
					actor.set_action('move downleft')
			'downright':
				if actor.check_move_action('move downright'):
					actor.set_action('move downright')
			'idle':
				actor.set_action('idle')
				
			


func search_area():
	ai_state = 'idle'
	detected_players = []

	for x in range(-VISION_RANGE,VISION_RANGE):
		for z in range(-VISION_RANGE,VISION_RANGE):
			var tile = map.get_tile_contents(actor.get_map_pos()[0] + x, actor.get_map_pos()[1] + z)
			if typeof(tile) != TYPE_STRING:
				if tile.get_obj_type() == 'Player':
					detected_players.append([actor.get_map_pos()[0] + x, actor.get_map_pos()[1] + z])
					ai_state = 'active'

func pathfind(): # ONLY WORKS FOR SINGLE PLAYERS FOR NOW
	var path_info = map.pathfind(actor, actor.get_map_pos(), detected_players[0])
	dist_from_player = path_info[0]
	path = path_info[1]
	
	if dist_from_player != 1:
		path.pop_front()
	
	
func determine_direction_of_path():
	var curr_pos = actor.get_map_pos()
	
	if path[0] == [curr_pos[0] + 1, curr_pos[1]]: pathfinder_direction = 'up'
	if path[0] == [curr_pos[0] - 1, curr_pos[1]]: pathfinder_direction = 'down'
	if path[0] == [curr_pos[0], curr_pos[1] - 1]: pathfinder_direction = 'left'
	if path[0] == [curr_pos[0], curr_pos[1] + 1]: pathfinder_direction = 'right'
	
	if path[0] == [curr_pos[0] + 1, curr_pos[1] - 1]: pathfinder_direction = 'upleft'
	if path[0] == [curr_pos[0] + 1, curr_pos[1] + 1]: pathfinder_direction = 'upright'
	if path[0] == [curr_pos[0] - 1, curr_pos[1] - 1]: pathfinder_direction = 'downleft'
	if path[0] == [curr_pos[0] - 1, curr_pos[1] + 1]: pathfinder_direction = 'downright'

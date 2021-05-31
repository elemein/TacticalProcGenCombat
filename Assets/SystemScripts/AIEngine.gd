extends Node

const VISION_RANGE = 15

onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")
onready var player = get_node("/root/World/Player")

var rng = RandomNumberGenerator.new()

var ai_state = 'idle' # [idle, active]

var actor

var player_pos = []

var dist_from_player = 0
var path = []
var viewfield = []

var pathfinder_direction

func _ready():
	rng.randomize()

func set_actor(setter):
	actor = setter
	
func reset_vars():
	player_pos = []
	dist_from_player = 0
	ai_state = 'idle'

func run_engine():
	reset_vars()
	
	viewfield = actor.get_viewfield()
	
	for tile in viewfield:
		var tile_objects = map.get_tile_contents(tile[0], tile[1])
		for object in tile_objects:
			if object.get_obj_type() == 'Player': player_pos.append(tile)
	
	if player_pos.size() > 0: ai_state = 'active'
	
	# if a PC is not within VISION_RANGE tiles, the AI can idle.
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		pathfinder_direction = 'idle'
		#find path to player
		
		pathfind()
		pathfinder_direction = determine_direction_of_path()
		
		if dist_from_player == 1: 
			actor.mover.set_actor_direction(pathfinder_direction)
			match rng.randi_range(1, 2):
				1:	actor.set_action('basic attack')
				2:	actor.set_action('fireball')
		
		elif dist_from_player > 1:
			var move_command = 'move %s' % [pathfinder_direction]
			
			if actor.check_move_action(move_command):
				actor.set_action(move_command)
			else: actor.set_action('idle')
			
		else:
			actor.set_action('idle')
				
func pathfind(): # ONLY WORKS FOR SINGLE PLAYERS FOR NOW
	var path_info = map.pathfind(actor, actor.get_map_pos(), player_pos[0])
	
	dist_from_player = path_info[0]
	path = path_info[1]
	
	if dist_from_player == 1:
		path.append([actor.get_map_pos()]) 
	
	
func determine_direction_of_path():
	var curr_pos = actor.get_map_pos()
	var direction
	
	if path[0] == [curr_pos[0] + 1, curr_pos[1]]: direction = 'up'
	elif path[0] == [curr_pos[0] - 1, curr_pos[1]]: direction = 'down'
	elif path[0] == [curr_pos[0], curr_pos[1] - 1]: direction = 'left'
	elif path[0] == [curr_pos[0], curr_pos[1] + 1]: direction = 'right'
	
	elif path[0] == [curr_pos[0] + 1, curr_pos[1] - 1]: direction = 'upleft'
	elif path[0] == [curr_pos[0] + 1, curr_pos[1] + 1]: direction = 'upright'
	elif path[0] == [curr_pos[0] - 1, curr_pos[1] - 1]: direction = 'downleft'
	elif path[0] == [curr_pos[0] - 1, curr_pos[1] + 1]: direction = 'downright'

	else: return 'idle'

	return direction

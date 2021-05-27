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
		pathfinder_direction = determine_direction_of_path()
		
		if dist_from_player == 1: 
#			actor.mover.set_actor_direction(pathfinder_direction)
			actor.set_action('basic attack')
		
		elif dist_from_player > 1:
			var move_command = 'move %s' % [pathfinder_direction]
			
			if actor.check_move_action(move_command):
				actor.set_action(move_command)
			else: actor.set_action('idle')
			
		else:
			actor.set_action('idle')
				
func pathfind(): # ONLY WORKS FOR SINGLE PLAYERS FOR NOW
	var path_info = map.pathfind(actor, actor.get_map_pos(), players[0])
	
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

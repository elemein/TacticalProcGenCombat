extends Node

const VISION_RANGE = 15

const PATHFINDER = preload("res://Assets/SystemScripts/PathFinder.gd")

onready var player = get_node("/root/World/Player")

var rng = RandomNumberGenerator.new()

var ai_state = 'idle' # [idle, active]

var actor
var map
var turn_timer

var player_pos = []

var dist_from_player = 0
var path = []
var viewfield = []

var pathfinder = PATHFINDER.new()
var pathfinder_direction

func _ready():
	rng.randomize()
	add_child(pathfinder)

func set_actor(setter):
	actor = setter
	map = actor.get_parent_map()
	turn_timer = actor.get_parent_map().get_turn_timer()
	
func reset_vars():
	player_pos = []
	dist_from_player = 0
	ai_state = 'idle'

func run_engine():
	reset_vars()
	find_players_in_viewfield()
	
	if player_pos.size() > 0: ai_state = 'active'
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		pathfinder_direction = 'idle'

		pathfind()
		pathfinder_direction = determine_direction_of_path()
		
		if dist_from_player == 1: 
			actor.set_actor_dir(pathfinder_direction)
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
	var path_info = pathfinder.solve(actor, actor.get_parent_map(), actor.get_map_pos(), player_pos[0])
	
	dist_from_player = path_info[0]
	path = path_info[1]

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

func find_players_in_viewfield():
	viewfield = actor.get_viewfield()
	for tile in viewfield:
		var tile_objects = map.get_tile_contents(tile[0], tile[1])
		for object in tile_objects:
			if object.get_obj_type() == 'Player': player_pos.append(tile)

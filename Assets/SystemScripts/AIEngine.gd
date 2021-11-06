extends Node
class_name AI_Engine

const VISION_RANGE = 15

const PATHFINDER = preload("res://Assets/SystemScripts/PathFinder.gd")

var rng = RandomNumberGenerator.new()

var ai_state = 'idle' # [idle, active]

var actor
var map
var turn_timer

var player_pos = []

var dist_from_player = 0
var path = []
var viewfield = []
var players_in_viewfield = {}
var players_in_focus = []

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
	players_in_viewfield = {}
	players_in_focus = []
	dist_from_player = 0
	ai_state = 'idle'

func pathfind(): # ENEMIES WILL PATHFIND TO PLAYER WITH LOWEST DISTANCE.
	var possible_paths = {}
	
	for key in players_in_viewfield.keys():
		possible_paths[key] = pathfinder.solve(actor, actor.get_parent_map(), \
												actor.get_map_pos(), \
												players_in_viewfield[key])
	
	var lowest_path_cost = INF
	var lowest_path
	var player_in_focus
	for key in possible_paths.keys():
		if possible_paths[key][0] < lowest_path_cost:
			lowest_path_cost = possible_paths[key][0]
			lowest_path = possible_paths[key][1]
			player_in_focus = key
	
	players_in_focus.append(player_in_focus)
	dist_from_player = lowest_path_cost
	path = lowest_path

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
			if object.get_id()['CategoryType'] == 'Player': 
				players_in_viewfield[object] = tile
				player_pos.append(tile)

func get_pathfinder_direction_to_player():
	pathfinder_direction = 'idle'
	pathfind()
	pathfinder_direction = determine_direction_of_path()

func determine_ai_state(): if player_pos.size() > 0: ai_state = 'active'
# ----------------------------------------------------------------------------
# ACTIONS

func idle():
	actor.set_action('idle')

func move_toward_player():
	var move_command = 'move %s' % [pathfinder_direction]
	
	if actor.check_move_action(move_command):
		actor.set_action(move_command)
	else: actor.set_action('idle')

func basic_attack_player():
	actor.set_actor_dir(pathfinder_direction)
	actor.set_action('basic attack')

func fireball_player():
	actor.set_actor_dir(pathfinder_direction)
	actor.set_action('fireball')

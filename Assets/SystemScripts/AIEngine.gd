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

func pathfind(): # ENEMIES WILL PATHFIND TO PLAYER WITH LOWEST DISTANCE.
	var possible_paths = []
	for x in range(player_pos.size()):
		possible_paths.append(pathfinder.solve(actor, actor.get_parent_map(), actor.get_map_pos(), player_pos[x]))
	
	var lowest_path_cost = INF
	var lowest_path
	for path in possible_paths:
		if path[0] < lowest_path_cost:
			lowest_path_cost = path[0]
			lowest_path = path[1]
	
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
			if object.get_id()['CategoryType'] == 'Player': player_pos.append(tile)

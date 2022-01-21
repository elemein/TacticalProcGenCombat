extends Node
class_name AI_Engine

const VISION_RANGE = 15

const PATHFINDER = preload("res://Scripts/Ai/PathFinder.gd")

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
	self.rng.randomize()
	add_child(self.pathfinder)

func set_actor(setter):
	self.actor = setter
	self.map = self.actor.get_parent_map()
	self.turn_timer = self.actor.get_parent_map().get_turn_timer()
	
func reset_vars():
	self.player_pos = []
	self.players_in_viewfield = {}
	self.players_in_focus = []
	self.dist_from_player = 0
	self.ai_state = 'idle'

func pathfind(): # ENEMIES WILL PATHFIND TO PLAYER WITH LOWEST DISTANCE.
	var possible_paths = {}
	
	for key in self.players_in_viewfield.keys():
		possible_paths[key] = self.pathfinder.solve(self.actor, actor.get_parent_map(), \
												self.actor.get_map_pos(), \
												self.players_in_viewfield[key])
	
	var lowest_path_cost = INF
	var lowest_path
	var player_in_focus
	for key in possible_paths.keys():
		if possible_paths[key][0] < lowest_path_cost:
			lowest_path_cost = possible_paths[key][0]
			lowest_path = possible_paths[key][1]
			player_in_focus = key
	
	self.players_in_focus.append(player_in_focus)
	self.dist_from_player = lowest_path_cost
	self.path = lowest_path

func determine_direction_of_path():
	var curr_pos = self.actor.get_map_pos()
	var direction
	
	if self.path[0] == [curr_pos[0] + 1, curr_pos[1]]: direction = 'up'
	elif self.path[0] == [curr_pos[0] - 1, curr_pos[1]]: direction = 'down'
	elif self.path[0] == [curr_pos[0], curr_pos[1] - 1]: direction = 'left'
	elif self.path[0] == [curr_pos[0], curr_pos[1] + 1]: direction = 'right'
	
	elif self.path[0] == [curr_pos[0] + 1, curr_pos[1] - 1]: direction = 'upleft'
	elif self.path[0] == [curr_pos[0] + 1, curr_pos[1] + 1]: direction = 'upright'
	elif self.path[0] == [curr_pos[0] - 1, curr_pos[1] - 1]: direction = 'downleft'
	elif self.path[0] == [curr_pos[0] - 1, curr_pos[1] + 1]: direction = 'downright'

	else: return 'idle'

	return direction

func find_players_in_viewfield():
	self.viewfield = self.actor.get_viewfield()
	for tile in self.viewfield:
		var tile_objects = self.map.get_tile_contents(tile[0], tile[1])
		for object in tile_objects:
			if object.get_id()['CategoryType'] == 'Player': 
				self.players_in_viewfield[object] = tile
				self.player_pos.append(tile)

func get_pathfinder_direction_to_player():
	self.pathfinder_direction = 'idle'
	pathfind()
	self.pathfinder_direction = determine_direction_of_path()

func determine_ai_state(): if player_pos.size() > 0: ai_state = 'active'
# ----------------------------------------------------------------------------
# ACTIONS

func idle():
	self.actor.set_action('idle')

func move_toward_player():
	var move_command = 'move %s' % [self.pathfinder_direction]
	
	if self.actor.check_move_action(move_command):
		self.actor.set_action(move_command)
	else: self.actor.set_action('idle')

func basic_attack_player():
	self.actor.set_actor_dir(self.pathfinder_direction)
	self.actor.set_action('basic attack')

func fireball_player():
	self.actor.set_actor_dir(self.pathfinder_direction)
	self.actor.set_action('fireball')

func self_heal(): actor.set_action('self heal')

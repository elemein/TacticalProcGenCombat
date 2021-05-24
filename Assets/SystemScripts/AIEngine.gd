extends Node

const VISION_RANGE = 15

onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

var rng = RandomNumberGenerator.new()

var ai_state # [idle, active]

var actor

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
		match rng.randi_range(1,8):
			1:
				if actor.check_move_action('move upleft'):
					actor.set_action('move upleft')
			2:
				if actor.check_move_action('move upright'):
					actor.set_action('move upright')
			3:
				if actor.check_move_action('move downleft'):
					actor.set_action('move downleft')
			4:
				if actor.check_move_action('move downright'):
					actor.set_action('move downright')
			
			5:
				if actor.check_move_action('move up'):
					actor.set_action('move up')
			6:
				if actor.check_move_action('move down'):
					actor.set_action('move down')
			7:
				if actor.check_move_action('move left'):
					actor.set_action('move left')
			8:
				if actor.check_move_action('move right'):
					actor.set_action('move right')

func search_area():
	ai_state = 'idle'

	for x in range(-VISION_RANGE,VISION_RANGE):
		for z in range(-VISION_RANGE,VISION_RANGE):
			var tile = map.get_tile_contents(actor.get_map_pos()[0] + x, actor.get_map_pos()[1] + z)
			if typeof(tile) != TYPE_STRING:
				if tile.get_obj_type() == 'Player':
					ai_state = 'active'

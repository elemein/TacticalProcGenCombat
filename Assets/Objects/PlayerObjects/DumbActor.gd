extends ActorObj

const DIRECTION_SELECT_TIME = 0.27
const DIAGONAL_INPUT_SMOOTHING_TIME = 0.1
const INPUT_CONFIRMATION_SMOOTHING_TIME = 0.1

const INVENTORY = preload("res://Assets/GUI/Inventory/Inventory.tscn")

var start_stats = {"Max HP" : 100, "HP" : 100, "Max MP": 100, "MP": 100, \
				"HP Regen" : 1, "MP Regen": 6, "Attack Power" : 10, \
				"Crit Chance": 5, "Spell Power" : 20, "Defense" : 0, \
				"Speed": 13, "View Range" : 4}

# movement and positioning related vars
var directional_timer = Timer.new()
var input_smoothing_timer = Timer.new()

# inventory vars
var inventory_open = false

# object vars
var inventory = INVENTORY.instance()

var minimap_icon = "Player"

var identity = {'Category': 'Actor', 'CategoryType': 'Player', 
				'Identifier': 'PlagueDoc', "Max HP": start_stats['Max HP'],
				'HP': start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': start_stats['MP'], 'Facing': null, 'NetID': null, 
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity, start_stats):
	pass

func _ready():
#	directional_timer.set_one_shot(true)
#	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
#	add_child(directional_timer)
#
#	input_smoothing_timer.set_one_shot(true)
#	input_smoothing_timer.set_wait_time(DIAGONAL_INPUT_SMOOTHING_TIME)
#	add_child(input_smoothing_timer)
	
	if GlobalVars.peer_type == 'client': set_parent_map(GlobalVars.server_mapset)
	elif GlobalVars.peer_type == 'server': set_parent_map(get_parent())
	
	add_sub_nodes_as_children()

func add_sub_nodes_as_children():
	add_child(mover)
	mover.set_actor(self)
	
	add_child(inventory)
	inventory.setup_inventory(self)

func _physics_process(_delta):
	if is_dead == false:
		
#		if in_turn == true:
#			# Change position based on time tickdown.
#			if proposed_action.split(" ")[0] == 'move' or proposed_action == 'dash':
#				mover.set_actor_translation()
			
		if proposed_action != '' && in_turn == true:
			if proposed_action == 'idle':
				anim_state = "idle"
			else:
				anim_state = "walk"
		else:
			anim_state = "idle"

	handle_animations()
			

func smooth_diagonal_input():
	match direction_facing:
		'upleft':
			if (Input.is_action_just_released('w') or Input.is_action_just_released('a')):
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)
		'upright':
			if (Input.is_action_just_released('w') or Input.is_action_just_released('d')):
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)
		'downleft':
			if (Input.is_action_just_released('s') or Input.is_action_just_released('a')):
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)
		'downright':
			if (Input.is_action_just_released('s') or Input.is_action_just_released('d')):
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)

func smooth_move_confirm_input():
	var dir_char = ''

	match direction_facing:
		'up': dir_char = 'w'
		'down': dir_char = 's'
		'left': dir_char = 'a'
		'right': dir_char = 'd'
	
	if dir_char != '':
		if(Input.is_action_just_pressed(dir_char)):
			directional_timer.start(INPUT_CONFIRMATION_SMOOTHING_TIME)

func set_direction(direction):
	set_actor_dir(direction)

# Getters
func get_inventory_open() -> bool:
	return inventory_open

func get_inventory_object() -> Object:
	return inventory

func get_item_to_drop() -> Object:
	return inventory.get_item_to_drop()

#Setters
func set_inventory_open(state):
	inventory_open = state

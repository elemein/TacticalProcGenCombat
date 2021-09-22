extends ActorObj

const DIRECTION_SELECT_TIME = 0.27
const DIAGONAL_INPUT_SMOOTHING_TIME = 0.1
const INPUT_CONFIRMATION_SMOOTHING_TIME = 0.1

const INVENTORY = preload("res://Assets/GUI/Inventory/Inventory.tscn")

signal prepare_gui(stats)

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
				'MP': start_stats['MP'], 'Facing': null, 'Map ID': null, 
				'Position': [0,0], 'NetID': 1, 'Instance ID': get_instance_id()}

func _init().(identity, start_stats):
	pass

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)

	input_smoothing_timer.set_one_shot(true)
	input_smoothing_timer.set_wait_time(DIAGONAL_INPUT_SMOOTHING_TIME)
	add_child(input_smoothing_timer)

	var _result = self.connect("prepare_gui", get_node("/root/World/GUI"),"_on_Player_prepare_gui")
	_result = self.connect("status_bar_hp", get_node("/root/World/GUI"), "_on_Player_status_bar_hp")
	_result = self.connect("status_bar_mp", get_node("/root/World/GUI"), "_on_Player_status_bar_mp")	

	emit_signal("prepare_gui", start_stats)
	Signals.emit_signal("player_attack_power_updated", start_stats['Attack Power'])
	Signals.emit_signal("player_spell_power_updated", start_stats['Spell Power'])

	add_sub_nodes_as_children()
	
	GlobalVars.server_player = self

func add_sub_nodes_as_children():
	add_child(mover)
	mover.set_actor(self)
	
	add_child(inventory)
	inventory.setup_inventory(self)

func _physics_process(_delta):
	if is_dead == false:
		get_input()
		
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

func get_input():
	smooth_diagonal_input()
	smooth_move_confirm_input()
	
	if (turn_timer.get_turn_in_process() == true) or (inventory_open) or \
	(input_smoothing_timer.time_left > 0): 
		# We don't wanna collect input if turn in action or in inventory or
		# while smoothing input.
		return
	
	if Input.is_action_just_pressed('tab'): 
		if inventory_open: inventory_open = false
		elif !inventory_open: inventory_open = true
	
	var no_of_inputs = 0
	
	for input in [Input.is_action_pressed("w"), 
				Input.is_action_pressed("a"),
				Input.is_action_pressed("s"), 
				Input.is_action_pressed("d")]:
					
		if input == true: no_of_inputs += 1
	
	# Below sets direction. It checks for the directional key being used, AND
	# if the char is not already facing that direction, and then starts the 
	# timer to decide direction so that it doesnt just auto-move.
	
	if no_of_inputs > 1:
		
		if (Input.is_action_pressed("w") && Input.is_action_pressed("a") 
			&& direction_facing != 'upleft'):
			Server.request_for_player_action({"Command Type": "Look", "Value": "upleft"})
			directional_timer.start(DIRECTION_SELECT_TIME)
		if (Input.is_action_pressed("w") && Input.is_action_pressed("d") 
			&& direction_facing != 'upright'): 
			Server.request_for_player_action({"Command Type": "Look", "Value": "upright"})
			directional_timer.start(DIRECTION_SELECT_TIME)
		if (Input.is_action_pressed("s") && Input.is_action_pressed("a") 
			&& direction_facing != 'downleft'): 
			Server.request_for_player_action({"Command Type": "Look", "Value": "downleft"})
			directional_timer.start(DIRECTION_SELECT_TIME)
		if (Input.is_action_pressed("s") && Input.is_action_pressed("d") 
			&& direction_facing != 'downright'): 
			Server.request_for_player_action({"Command Type": "Look", "Value": "downright"})
			directional_timer.start(DIRECTION_SELECT_TIME)
	
	if no_of_inputs == 1:
		if Input.is_action_pressed("w") && direction_facing != 'up': 
			Server.request_for_player_action({"Command Type": "Look", "Value": "up"})
			directional_timer.start(DIRECTION_SELECT_TIME)
		if Input.is_action_pressed("s") && direction_facing != 'down': 
			Server.request_for_player_action({"Command Type": "Look", "Value": "down"})
			directional_timer.start(DIRECTION_SELECT_TIME)
		if Input.is_action_pressed("a") && direction_facing != 'left': 
			Server.request_for_player_action({"Command Type": "Look", "Value": "left"})
			directional_timer.start(DIRECTION_SELECT_TIME)
		if Input.is_action_pressed("d") && direction_facing != 'right': 
			Server.request_for_player_action({"Command Type": "Look", "Value": "right"})
			directional_timer.start(DIRECTION_SELECT_TIME)

	# As the move buttons are used to change direction, these need to abide
	# to the directional timer.
	if directional_timer.time_left == 0:
		if no_of_inputs > 1:
			if Input.is_action_pressed("w") && Input.is_action_pressed("a"): 
				if check_move_action('move upleft'):
					set_action('move upleft')
			if Input.is_action_pressed("w") && Input.is_action_pressed("d"): 
				if check_move_action('move upright'):
					set_action('move upright')
			if Input.is_action_pressed("s") && Input.is_action_pressed("a"): 
				if check_move_action('move downleft'):
					set_action('move downleft')
			if Input.is_action_pressed("s") && Input.is_action_pressed("d"): 
				if check_move_action('move downright'):
					set_action('move downright')
		
		if no_of_inputs == 1:
			if Input.is_action_pressed("w"): 
				if check_move_action('move up'):
					set_action('move up')
			if Input.is_action_pressed("s"): 
				if check_move_action('move down'):
					set_action('move down')
			if Input.is_action_pressed("a"):
				if check_move_action('move left'):
					set_action('move left')
			if Input.is_action_pressed("d"): 
				if check_move_action('move right'):
					set_action('move right')
	
	# X to skip your turn.
	if Input.is_action_pressed("x"): 
		Server.request_for_player_action({"Command Type": "Idle"})
	
	# Basic attacks only need one press.
	if 'BasicAttackAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("space"): 
			Server.request_for_player_action({"Command Type": "Basic Attack", "Value": get_direction_facing()})
	
	# Skills will need two presses to confirm.
	if 'FireballAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("e"): 
			Server.request_for_player_action({"Command Type": "Fireball"})
	if 'DashAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("r"): 
			Server.request_for_player_action({"Command Type": "Dash"})
	if 'SelfHealAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("t"): 
			Server.request_for_player_action({"Command Type": "Self Heal"})

func set_direction(direction):
	set_actor_dir(direction)
	directional_timer.start(DIRECTION_SELECT_TIME) 

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

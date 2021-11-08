extends Node

const DIRECTION_SELECT_TIME = 0.27
const DIAGONAL_INPUT_SMOOTHING_TIME = 0.15
const INPUT_CONFIRMATION_SMOOTHING_TIME = 0.1

# movement and positioning related vars
var directional_timer = Timer.new()
var input_smoothing_timer = Timer.new()

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)

	input_smoothing_timer.set_one_shot(true)
	input_smoothing_timer.set_wait_time(DIAGONAL_INPUT_SMOOTHING_TIME)
	add_child(input_smoothing_timer)

func _physics_process(_delta):
	if MultiplayerTestenv.get_client().get_client_obj().get_is_dead() == false and \
		MultiplayerTestenv.get_client().get_client_state() == 'ingame': 
		get_input()

func smooth_input():
	var direction_facing = MultiplayerTestenv.get_client().get_client_obj().get_direction_facing()
	
	var dir_char = ''
	match direction_facing:
		'up': dir_char = 'w'
		'down': dir_char = 's'
		'left': dir_char = 'a'
		'right': dir_char = 'd'
	
	if dir_char != '':
		if(Input.is_action_just_pressed(dir_char)):
			directional_timer.start(INPUT_CONFIRMATION_SMOOTHING_TIME)

func count_inputs():
	var no_of_inputs = 0
	
	for input in [Input.is_action_pressed("w"), 
				Input.is_action_pressed("a"),
				Input.is_action_pressed("s"), 
				Input.is_action_pressed("d")]:
					
		if input == true: no_of_inputs += 1
	
	return no_of_inputs

func get_possible_direction(no_of_inputs):
	var character = MultiplayerTestenv.get_client().get_client_obj()
	var direction_facing = character.get_direction_facing()
	
	if input_smoothing_timer.time_left == 0:
		if no_of_inputs > 1:
			if (Input.is_action_pressed("w") && Input.is_action_pressed("a") 
				&& direction_facing != 'upleft'):
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "upleft"})
				directional_timer.start(DIRECTION_SELECT_TIME)
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)
			if (Input.is_action_pressed("w") && Input.is_action_pressed("d") 
				&& direction_facing != 'upright'): 
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "upright"})
				directional_timer.start(DIRECTION_SELECT_TIME)
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)
			if (Input.is_action_pressed("s") && Input.is_action_pressed("a") 
				&& direction_facing != 'downleft'): 
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "downleft"})
				directional_timer.start(DIRECTION_SELECT_TIME)
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)
			if (Input.is_action_pressed("s") && Input.is_action_pressed("d") 
				&& direction_facing != 'downright'): 
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "downright"})
				directional_timer.start(DIRECTION_SELECT_TIME)
				input_smoothing_timer.start(DIAGONAL_INPUT_SMOOTHING_TIME)
		
		if no_of_inputs == 1:
			if Input.is_action_pressed("w") && direction_facing != 'up': 
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "up"})
				directional_timer.start(DIRECTION_SELECT_TIME)
			if Input.is_action_pressed("s") && direction_facing != 'down': 
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "down"})
				directional_timer.start(DIRECTION_SELECT_TIME)
			if Input.is_action_pressed("a") && direction_facing != 'left': 
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "left"})
				directional_timer.start(DIRECTION_SELECT_TIME)
			if Input.is_action_pressed("d") && direction_facing != 'right': 
				MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Look", "Value": "right"})
				directional_timer.start(DIRECTION_SELECT_TIME)

func confirm_direction(no_of_inputs):
	var character = MultiplayerTestenv.get_client().get_client_obj()
	var direction_facing = character.get_direction_facing()
	
	if directional_timer.time_left == 0 and input_smoothing_timer.time_left == 0:
		if no_of_inputs > 1:
			if Input.is_action_pressed("w") && Input.is_action_pressed("a"): 
				if character.check_move_action('move upleft'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "upleft"})
			if Input.is_action_pressed("w") && Input.is_action_pressed("d"): 
				if character.check_move_action('move upright'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "upright"})
			if Input.is_action_pressed("s") && Input.is_action_pressed("a"): 
				if character.check_move_action('move downleft'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "downleft"})
			if Input.is_action_pressed("s") && Input.is_action_pressed("d"): 
				if character.check_move_action('move downright'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "downright"})
		
		if no_of_inputs == 1:
			if Input.is_action_pressed("w"): 
				if character.check_move_action('move up'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "up"})
			if Input.is_action_pressed("s"): 
				if character.check_move_action('move down'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "down"})
			if Input.is_action_pressed("a"):
				if character.check_move_action('move left'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "left"})
			if Input.is_action_pressed("d"): 
				if character.check_move_action('move right'):
					MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Move", "Value": "right"})

func check_for_action():
	var character = MultiplayerTestenv.get_client().get_client_obj()
	
	# X to skip your turn.
	if Input.is_action_pressed("x"): 
		MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Idle"})
	
	# Basic attacks only need one press.
	if 'BasicAttackAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("space"): 
			MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Basic Attack", "Value": character.get_direction_facing()})
	
	# Skills will need two presses to confirm.
	if 'FireballAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("e"): 
			MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Fireball"})
	if 'DashAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("r"): 
			MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Dash"})
	if 'SelfHealAbility' in PlayerInfo.abilities:
		if Input.is_action_pressed("t"): 
			MultiplayerTestenv.get_client().request_for_player_action({"Command Type": "Self Heal"})

func get_input():
	smooth_input()
	
	var no_of_inputs = count_inputs()
	get_possible_direction(no_of_inputs)
	confirm_direction(no_of_inputs)
	
	check_for_action()

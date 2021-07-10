extends ActorObj

const DIRECTION_SELECT_TIME = 0.27
const DIAGONAL_INPUT_SMOOTHING_TIME = 0.1

const INVENTORY = preload("res://Assets/GUI/Inventory/Inventory.tscn")

var start_stats = {"Max HP" : 100, "HP" : 100, "Max MP": 100, "MP": 100, \
				"HP Regen" : 1, "MP Regen": 6, "Attack Power" : 10, \
				"Spell Power" : 20, "Defense" : 0, "Speed": 13, "View Range" : 4}

# movement and positioning related vars
var directional_timer = Timer.new()
var input_smoothing_timer = Timer.new()

# inventory vars
var inventory_open = false

# object vars

var inventory = INVENTORY.instance()

func _init().("Player", start_stats):
	pass

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)
	
	input_smoothing_timer.set_one_shot(true)
	input_smoothing_timer.set_wait_time(DIAGONAL_INPUT_SMOOTHING_TIME)
	add_child(input_smoothing_timer)
	
	turn_timer.add_to_timer_group(self)
	
	map_pos = map.place_player_on_map(self)
	translation.x = map_pos[0] * TILE_OFFSET
	translation.z = map_pos[1] * TILE_OFFSET
	
	target_pos = translation
	saved_pos = translation
	
	add_sub_nodes_as_children()
	
	map.print_map_grid()
	
	viewfield = view_finder.find_view_field(map_pos[0], map_pos[1])
	map.hide_non_visible_from_player()

func add_sub_nodes_as_children():
	add_child(mover)
	mover.set_actor(self)
	
	add_child(inventory)
	inventory.setup_inventory(self)

func _physics_process(_delta):
	if is_dead: 
		play_death_anim()
		if death_anim_timer.time_left > 0: mover.set_actor_translation()
		
	if is_dead == false:
		get_input()
		
		if in_turn == true:
			# Change position based on time tickdown.
			if proposed_action.split(" ")[0] == 'move' or proposed_action == 'dash':
				mover.set_actor_translation()
			
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
	match direction_facing:
		'up':
			if (Input.is_action_just_pressed('w')):
				directional_timer.start(0.1)
		'down':
			if (Input.is_action_just_pressed('s')):
				directional_timer.start(0.1)
		'left':
			if (Input.is_action_just_pressed('a')):
				directional_timer.start(0.1)
		'right':
			if (Input.is_action_just_pressed('d')):
				directional_timer.start(0.1)

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
			set_direction('upleft')
		if (Input.is_action_pressed("w") && Input.is_action_pressed("d") 
			&& direction_facing != 'upright'): 
			set_direction('upright')
		if (Input.is_action_pressed("s") && Input.is_action_pressed("a") 
			&& direction_facing != 'downleft'): 
			set_direction('downleft')
		if (Input.is_action_pressed("s") && Input.is_action_pressed("d") 
			&& direction_facing != 'downright'): 
			set_direction('downright')
	
	if no_of_inputs == 1:
		if Input.is_action_pressed("w") && direction_facing != 'up': set_direction('up')
		if Input.is_action_pressed("s") && direction_facing != 'down': set_direction('down')
		if Input.is_action_pressed("a") && direction_facing != 'left': set_direction('left')
		if Input.is_action_pressed("d") && direction_facing != 'right': set_direction('right')

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
	if Input.is_action_pressed("x"): set_action('idle')
	
	# Basic attacks only need one press.
	if Input.is_action_pressed("space"): set_action('basic attack')
	
	# Skills will need two presses to confirm.
	if Input.is_action_pressed("e"): set_action('fireball')
	if Input.is_action_pressed("r"): set_action('dash')
	if Input.is_action_pressed("t"): set_action('self heal')

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

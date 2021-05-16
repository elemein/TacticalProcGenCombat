extends KinematicBody

const MOVE_SPEED = 2.2
const DIRECTION_SELECT_TIME = 0.3

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

# Used to store the action for the next turn.
var proposed_action = ""

var ready_status = false
var attacked = false

var direction_facing = "down"
var directional_timer = Timer.new()

var anim_state = "idle"

var saved_pos = Vector3()
var target_pos = Vector3()

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)

func get_input():
	if turn_timer.time_left > 0: # We don't wanna collect input if turn in action.
		return
	
	# Below sets direction. It checks for the directional key being used, AND
	# if the char is not already facing that direction, and then starts the 
	# timer to decide direction so that it doesnt just auto-move.
	if Input.is_action_pressed("w") && direction_facing != 'up': set_direction('up')
	if Input.is_action_pressed("s") && direction_facing != 'down': set_direction('down')
	if Input.is_action_pressed("a") && direction_facing != 'left': set_direction('left')
	if Input.is_action_pressed("d") && direction_facing != 'right': set_direction('right')

	# As the move buttons are used to change direction, these need to abide
	# to the directional timer.
	if directional_timer.time_left == 0:
		if Input.is_action_pressed("w"): set_action('move up')
		if Input.is_action_pressed("s"): set_action('move down')
		if Input.is_action_pressed("a"): set_action('move left')
		if Input.is_action_pressed("d"): set_action('move right')
	
	# Basic attacks only need one press.
	if Input.is_action_pressed("space"): set_action('basic attack')
	
	# Skills will need two taps to confirm.
	pass

func set_direction(direction):
	match direction:
		'up':
			direction_facing = "up"
			model.rotation_degrees.y = 90
		'down':
			direction_facing = "down"
			model.rotation_degrees.y = 90 + 180
		'left':
			direction_facing = "left"
			model.rotation_degrees.y = 180
		'right':
			direction_facing = "right"
			model.rotation_degrees.y = 180 + 180

	directional_timer.start(DIRECTION_SELECT_TIME) 
	
func set_action(action):
	proposed_action = action
	gui.set_action(proposed_action)
	ready_status = true
	
func process_turn():
	ready_status = false
	
	if proposed_action.split(" ")[0] == 'move' || proposed_action == 'basic attack':
		match direction_facing:
			'up':
				target_pos.x = translation.x + MOVE_SPEED
			'down':
				target_pos.x = translation.x + -MOVE_SPEED
			'left':
				target_pos.z = translation.z + -MOVE_SPEED
			'right':
				target_pos.z = translation.z + MOVE_SPEED
		
func end_turn():
	# Clear action.
	target_pos = translation
	saved_pos = translation
	proposed_action = ''
	attacked = false

func _physics_process(_delta):
	get_input()

	# Change position based on time tickdown.
	if proposed_action.split(" ")[0] == 'move':
		translation = translation.linear_interpolate(target_pos, (1-turn_timer.time_left)) 
	
	if proposed_action == "basic attack":
		if turn_timer.time_left > 0.5: # Move char towards attack cell.
			translation = translation.linear_interpolate(target_pos, (1-(turn_timer.time_left - 0.5)))
			if attacked == false:
				map.get_tree().call_group('enemies', 'attacked_by_player')
				attacked = true
		else: # Move char back.
			translation = translation.linear_interpolate(saved_pos, (0.5-turn_timer.time_left))
	
	if proposed_action != '' and turn_timer.time_left > 0.5:
		anim_state = "walk"
	else:
		anim_state = "idle"

	handle_animations()

func handle_animations():
	match anim_state:
		'idle':
			play_anim("idle")
		'walk':
			play_anim("walk")

func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

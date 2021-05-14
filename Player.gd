extends KinematicBody

const MOVE_SPEED = 2.2
const DIRECTION_SELECT_TIME = 0.3

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")

# Used to store the action for the next turn.
var proposed_action = ""

var ready_status = false

var direction_facing = "down"
var directional_timer = Timer.new()
var still_deciding_direction = false

var anim_state = "idle"

var saved_pos = Vector3()
var target_pos = Vector3()

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	directional_timer.connect("timeout", self, "on_direction_timer_complete")
	add_child(directional_timer)
		
func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

func get_input():
	if turn_timer.time_left > 0: # We don't wanna collect input if turn in action.
		return
	
	# Below sets direction. It checks for the directional key being used, AND
	# if the char is not already facing that direction, and then starts the 
	# timer to decide direction.
	if Input.is_action_pressed("w") && direction_facing != 'up':
		model.rotation_degrees.y = 90
		direction_facing = "up"
		still_deciding_direction = true
		directional_timer.start(DIRECTION_SELECT_TIME) 
	if Input.is_action_pressed("s") && direction_facing != 'down':
		model.rotation_degrees.y = 90 + 180
		direction_facing = "down"
		still_deciding_direction = true
		directional_timer.start(DIRECTION_SELECT_TIME)
	if Input.is_action_pressed("a") && direction_facing != 'left':
		model.rotation_degrees.y = 180
		direction_facing = "left"
		still_deciding_direction = true
		directional_timer.start(DIRECTION_SELECT_TIME)
	if Input.is_action_pressed("d") && direction_facing != 'right':
		model.rotation_degrees.y = 180 + 180
		direction_facing = "right"
		still_deciding_direction = true
		directional_timer.start(DIRECTION_SELECT_TIME)

	# As the move buttons are used to change direction, these need to abide
	# to the directional timer.
	if still_deciding_direction == false:
		if Input.is_action_pressed("w"):
			proposed_action = "move up"
			gui.propose_action(proposed_action)
			ready_status = true
		if Input.is_action_pressed("s"):
			proposed_action = "move down"
			gui.propose_action(proposed_action)
			ready_status = true
		if Input.is_action_pressed("a"):
			proposed_action = "move left"
			gui.propose_action(proposed_action)
			ready_status = true
		if Input.is_action_pressed("d"):
			proposed_action = "move right"
			gui.propose_action(proposed_action)
			ready_status = true
	
	# Basic attacks only need one press.
	if Input.is_action_pressed("space"):
		proposed_action = "basic attack"
		gui.propose_action(proposed_action)
		ready_status = true
	
	# Skills will need two taps to confirm.
	pass

func on_direction_timer_complete():
	still_deciding_direction = false	
		
func process_turn():
	
	ready_status = false
	target_pos = translation # Reset this.
	
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
	saved_pos = translation
	proposed_action = ''

func _physics_process(_delta):
	
	# Change position based on time tickdown.
	if proposed_action.split(" ")[0] == 'move':
		translation = translation.linear_interpolate(target_pos, (1-turn_timer.time_left)) 
	
	if proposed_action == "basic attack":
		if turn_timer.time_left > 0.5: # Move char towards attack cell.
			translation = translation.linear_interpolate(target_pos, (1-(turn_timer.time_left - 0.5))) 
		else: # Move char back.
			translation = translation.linear_interpolate(saved_pos, (0.5-turn_timer.time_left))
	
	if proposed_action != '':
		anim_state = "walk"
	else:
		anim_state = "idle"
	
	get_input()
	
	handle_animations()

func handle_animations():
	if anim_state == "idle":
		play_anim("idle")
	else:
		play_anim("walk")

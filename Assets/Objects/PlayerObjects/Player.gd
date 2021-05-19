extends KinematicBody

const MOVE_SPEED = 2.2
const DIRECTION_SELECT_TIME = 0.225

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

var effects_fire = preload("res://Assets/Objects/Effects/Fire/Fire.tscn")

# vars to handle turn state
var proposed_action = ""
var ready_status = false
var in_turn = false

# movement and positioning related vars
var direction_facing = "down"
var directional_timer = Timer.new()
var saved_pos = Vector3()
var target_pos = Vector3()
var map_pos = []

# vars for animation
var anim_state = "idle"
var effect = null

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)
	
	map_pos = map.place_on_map(self, translation)

func _physics_process(_delta):
	get_input()
	
	if in_turn == true:
		# Change position based on time tickdown.
		if proposed_action.split(" ")[0] == 'move':
			translation = translation.linear_interpolate(target_pos, (1-turn_timer.time_left)) 
		
		if proposed_action == "basic attack":
			if turn_timer.time_left > 0.5: # Move char towards attack cell.
				translation = translation.linear_interpolate(target_pos, (1-(turn_timer.time_left - 0.5))) 
			else: # Move char back.
				translation = translation.linear_interpolate(saved_pos, (0.5-turn_timer.time_left))
		
		if proposed_action == 'fireball':
			if turn_timer.time_left > 0.1: # Move fireball towards attack cell.
				effect.translation = effect.translation.linear_interpolate(target_pos, (1-(turn_timer.time_left - 0.1))) 
			else: # Delete fireball.
				if effect != null:
					remove_child(get_node("/root/World/Player/Fire"))
					effect = null
			
		
	if proposed_action != '':
		anim_state = "walk"
	else:
		anim_state = "idle"

	handle_animations()

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
	
	# Basic attacks only need one press.
	if Input.is_action_pressed("space"): set_action('basic attack')
	
	# Skills will need two presses to confirm.
	if Input.is_action_pressed("e"): set_action('fireball')
	
func set_action(action):
	proposed_action = action
	gui.set_action(proposed_action)
	ready_status = true
	
func process_turn():	
	# Sets target positions for move and basic attack.
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
	elif proposed_action == 'fireball':
		set_fireball_target_pos()

	# If position will actually be changing, update to map.
	if proposed_action.split(" ")[0] == 'move':
		map_pos = map.move_on_map(self, translation, target_pos)
	
	in_turn = true

func end_turn():
	target_pos = translation
	saved_pos = translation
	proposed_action = ''
	in_turn = false
	ready_status = false

# Movement related functions.
func check_move_action(move):
	match move:
		'move up':
			if map.tile_available(map_pos[0] + 1, map_pos[1]) == true: return true
		'move down':
			if map.tile_available(map_pos[0] - 1, map_pos[1]) == true: return true
		'move left':
			if map.tile_available(map_pos[0], map_pos[1] - 1) == true: return true
		'move right':
			if map.tile_available(map_pos[0], map_pos[1] + 1) == true: return true

	# if none of the above returned true
	return false

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

# Ability related functions.
func set_fireball_target_pos():
		effect = effects_fire.instance()
		add_child(effect)
		
		match direction_facing:
			
			'up':
				effect.rotation_degrees.y = 90
				target_pos.x = effect.translation.x + (3*MOVE_SPEED)
				target_pos.z = 0
			'down':
				effect.rotation_degrees.y = -90
				target_pos.x = effect.translation.x - (3*MOVE_SPEED)
				target_pos.z = 0
			'left':
				effect.rotation_degrees.y = 180
				target_pos.z = effect.translation.x - (3*MOVE_SPEED)
				target_pos.x = 0
			'right':
				effect.rotation_degrees.y = 0
				target_pos.z = effect.translation.x + (3*MOVE_SPEED)
				target_pos.x = 0

# Animations related functions.
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


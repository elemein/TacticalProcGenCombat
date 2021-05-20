extends KinematicBody

const TILE_OFFSET = 2.2
const DIRECTION_SELECT_TIME = 0.225

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

var effects_fire = preload("res://Assets/Objects/Effects/Fire/Fire.tscn")

# gameplay vars
var object_type = 'Player'
var hp = 100
var mp = 100
var attack_power = 10

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
	
	turn_timer.add_to_timer_group(self)
	
	map_pos = map.place_on_map(self)
	translation.x = map_pos[0] * TILE_OFFSET
	translation.z = map_pos[1] * TILE_OFFSET
	
	target_pos = translation
	saved_pos = translation

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
			
		
	if proposed_action != '' && in_turn == true:
		anim_state = "walk"
	else:
		anim_state = "idle"

	handle_animations()

func get_input():
	if turn_timer.time_left > 0: # We don't wanna collect input if turn in action.
		return
	
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
		if (Input.is_action_pressed("w") &&Input.is_action_pressed("a") 
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
	
	# Basic attacks only need one press.
	if Input.is_action_pressed("space"): set_action('basic attack')
	
	# Skills will need two presses to confirm.
	if Input.is_action_pressed("e"): set_action('fireball')
	
func set_action(action):
	proposed_action = action
	gui.set_action(proposed_action)
	ready_status = true
	
func process_turn():	
	var target_tile
	# Sets target positions for move and basic attack.
	if proposed_action.split(" ")[0] == 'move':
		match direction_facing:
			'upleft':
				target_tile = [map_pos[0] + 1, map_pos[1] - 1]
				target_pos.x = target_tile[0] * TILE_OFFSET
				target_pos.z = target_tile[1] * TILE_OFFSET
			'upright':
				target_tile = [map_pos[0] + 1, map_pos[1] + 1]
				target_pos.x = target_tile[0] * TILE_OFFSET
				target_pos.z = target_tile[1] * TILE_OFFSET
			'downleft':
				target_tile = [map_pos[0] - 1, map_pos[1] - 1]
				target_pos.x = target_tile[0] * TILE_OFFSET
				target_pos.z = target_tile[1] * TILE_OFFSET
			'downright':
				target_tile = [map_pos[0] - 1, map_pos[1] + 1]
				target_pos.x = target_tile[0] * TILE_OFFSET
				target_pos.z = target_tile[1] * TILE_OFFSET
			
			'up':
				target_tile = [map_pos[0] + 1, map_pos[1]]
				target_pos.x = target_tile[0] * TILE_OFFSET
			'down':
				target_tile = [map_pos[0] - 1, map_pos[1]]
				target_pos.x = target_tile[0] * TILE_OFFSET
			'left':
				target_tile = [map_pos[0], map_pos[1] - 1]
				target_pos.z = target_tile[1] * TILE_OFFSET
			'right':
				target_tile = [map_pos[0], map_pos[1] + 1]
				target_pos.z = target_tile[1] * TILE_OFFSET
	
	elif proposed_action == 'basic attack':
		match direction_facing:
			'upleft':
				target_tile = [map_pos[0] + 1, map_pos[1] - 1]
				target_pos.x = target_tile[0] * TILE_OFFSET
			'upright':
				target_tile = [map_pos[0] + 1, map_pos[1] + 1]
				target_pos.x = target_tile[0] * TILE_OFFSET
			'downleft':
				target_tile = [map_pos[0] - 1, map_pos[1] - 1]
				target_pos.z = target_tile[1] * TILE_OFFSET
			'downright':
				target_tile = [map_pos[0] - 1, map_pos[1] + 1]
				target_pos.z = target_tile[1] * TILE_OFFSET
			
			'up':
				target_tile = [map_pos[0] + 1, map_pos[1]]
				target_pos.x = target_tile[0] * TILE_OFFSET
			'down':
				target_tile = [map_pos[0] - 1, map_pos[1]]
				target_pos.x = target_tile[0] * TILE_OFFSET
			'left':
				target_tile = [map_pos[0], map_pos[1] - 1]
				target_pos.z = target_tile[1] * TILE_OFFSET
			'right':
				target_tile = [map_pos[0], map_pos[1] + 1]
				target_pos.z = target_tile[1] * TILE_OFFSET
		
		var attacked_obj = map.get_tile_contents(target_tile[0], target_tile[1])
		
		if typeof(attacked_obj) != TYPE_STRING: #If not attacking a blank space.
			if attacked_obj.get_obj_type() == 'Enemy':
				attacked_obj.take_damage(attack_power)
	
	elif proposed_action == 'fireball':
		set_fireball_target_pos()

	# If position will actually be changing, update to map.
	if proposed_action.split(" ")[0] == 'move':
		map_pos = map.move_on_map(self, map_pos, target_tile)
	
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
		'move upleft':
			if map.tile_available(map_pos[0] + 1, map_pos[1] - 1) == true: return true
		'move upright':
			if map.tile_available(map_pos[0] + 1, map_pos[1] + 1) == true: return true
		'move downleft':
			if map.tile_available(map_pos[0] - 1, map_pos[1] - 1) == true: return true
		'move downright':
			if map.tile_available(map_pos[0] - 1, map_pos[1] + 1) == true: return true
		
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
		'upleft':
			direction_facing = "upleft"
			model.rotation_degrees.y = 45 + 90
		'upright':
			direction_facing = "upright"
			model.rotation_degrees.y = 45 
		'downleft':
			direction_facing = "downleft"
			model.rotation_degrees.y = 45 + 180
		'downright':
			direction_facing = "downright"
			model.rotation_degrees.y = 45 + 90 + 180
		
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
			'upleft':
				effect.rotation_degrees.y = 45
				target_pos.x = effect.translation.x + (3*TILE_OFFSET)
				target_pos.z = 0
			'upright':
				effect.rotation_degrees.y = 90 + 45
				target_pos.x = effect.translation.x - (3*TILE_OFFSET)
				target_pos.z = 0
			'downleft':
				effect.rotation_degrees.y = 180 - 45
				target_pos.z = effect.translation.x - (3*TILE_OFFSET)
				target_pos.x = 0
			'downright':
				effect.rotation_degrees.y = 180 + 45
				target_pos.z = effect.translation.x + (3*TILE_OFFSET)
				target_pos.x = 0
			
			
			'up':
				effect.rotation_degrees.y = 90
				target_pos.x = effect.translation.x + (3*TILE_OFFSET)
				target_pos.z = 0
			'down':
				effect.rotation_degrees.y = -90
				target_pos.x = effect.translation.x - (3*TILE_OFFSET)
				target_pos.z = 0
			'left':
				effect.rotation_degrees.y = 180
				target_pos.z = effect.translation.x - (3*TILE_OFFSET)
				target_pos.x = 0
			'right':
				effect.rotation_degrees.y = 0
				target_pos.z = effect.translation.x + (3*TILE_OFFSET)
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

func get_obj_type():
	return object_type

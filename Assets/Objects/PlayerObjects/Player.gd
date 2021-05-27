extends KinematicBody

const TILE_OFFSET = 2.2
const DIRECTION_SELECT_TIME = 0.225

const DEATH_ANIM_TIME = 1

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

# Spell signals
signal spell_cast_fireball
signal spell_cast_basic_attack

# Mover signals
signal mover_check_move_action(move)
signal mover_move_actor
signal mover_set_actor(actor)
signal mover_set_actor_direction(direction)
signal mover_set_actor_translation

# Sound effects
onready var audio_hit = $Audio/Hit

# gameplay vars
var object_type = 'Player'
var hp = 100
var mp = 100
var max_hp = 100
var max_mp = 100
var regen_mp = 10
var attack_power = 10
var spell_power = 20

# vars to handle turn state
var proposed_action = ""
var ready_status = false
var in_turn = false

# movement and positioning related vars
var direction_facing = "up"
var directional_timer = Timer.new()
var map_pos = []

# vars for animation
var anim_state = "idle"
var effect = null

#death vars
var is_dead = false
var death_anim_timer = Timer.new()
var death_anim_info = []

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)
	
	turn_timer.add_to_timer_group(self)
	
	map_pos = map.place_on_map(self)
	translation.x = map_pos[0] * TILE_OFFSET
	translation.z = map_pos[1] * TILE_OFFSET

	emit_signal('mover_set_actor', self)
#	mover.set_actor(self)
#	add_child(mover)

func _physics_process(_delta):
	if is_dead:
		if death_anim_timer.time_left > 0.75:
			model.translation = (model.translation.linear_interpolate(death_anim_info[0], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		if death_anim_timer.time_left < 0.75 && death_anim_timer.time_left != 0:
			model.translation = (model.translation.linear_interpolate(death_anim_info[1], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
			model.rotation_degrees = (model.rotation_degrees.linear_interpolate(death_anim_info[2], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		if death_anim_timer.time_left == 0:
			return 'dead'
	
	else:
		get_input()
		
		if in_turn == true:
			# Change position based on time tickdown.
			if proposed_action.split(" ")[0] == 'move':
#				mover.set_actor_translation()
				emit_signal("mover_set_actor_translation")
				pass
			
		if proposed_action != '' && in_turn == true:
			if proposed_action == 'idle':
				anim_state = "idle"
			else:
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
	
	# X to skip your turn.
	if Input.is_action_pressed("x"): set_action('idle')
	
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
	if proposed_action.split(" ")[0] == 'move':
#		mover.move_actor()
		emit_signal('mover_move_actor')
		pass
	
	elif proposed_action == 'idle':
		pass
	
	elif proposed_action == 'basic attack':
		emit_signal("spell_cast_basic_attack")
	
	elif proposed_action == 'fireball':
		emit_signal("spell_cast_fireball")

	in_turn = true

	mp += regen_mp
	$HealthManaBar3D/Viewport/HealthManaBar2D.update_mana_bar(mp, max_mp)

func end_turn():
	proposed_action = ''
	in_turn = false
	ready_status = false

# Movement related functions.
func check_move_action(move):
#	return mover.check_move_action(move)
	emit_signal('mover_check_move_action', move)
	pass

func check_cornering(direction): # This can definitely be done better. - SS
	match direction:
		'upleft': # check both tiles up and left to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]+1,map_pos[1])
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]-1)
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
			
		'upright': # check both tiles up and right to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]+1,map_pos[1])
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]+1)
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
			
		'downleft': # check both tiles down and left to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]-1,map_pos[1])
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]-1)
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
			
		'downright': # check both tiles down and right to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]-1,map_pos[1])
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]+1)
			if typeof(adjacent_tile) == TYPE_STRING:
				if adjacent_tile == '.':
					return false
	return true

func set_direction(direction):
#	mover.set_actor_direction(direction)
	emit_signal("mover_set_actor_direction", direction)
	directional_timer.start(DIRECTION_SELECT_TIME) 

func take_damage(damage):
	hp -= damage
	print("%s has %s HP" % [self, hp])
	
	# Player audio node is empty, so this doesnt work.
	# Play a random audio effect upon getting hit
#	var num_audio_effects = audio_hit.get_children().size()
#	audio_hit.get_children()[randi() % num_audio_effects].play()
	
	# Update the health bar
	$HealthManaBar3D.update_health_bar(hp, max_hp)

	if hp <= 0:
		die()

func die():
	death_anim_timer.set_one_shot(true)
	death_anim_timer.set_wait_time(DEATH_ANIM_TIME)
	add_child(death_anim_timer)
	is_dead = true
	turn_timer.remove_from_timer_group(self)

#	remove_child(mover)
	proposed_action = 'idle'
	
	var rise = Vector3(model.translation.x, 2, model.translation.z)
	var fall = Vector3(model.translation.x, 0.2, model.translation.z)
	var fall_rot = Vector3(-90, model.rotation_degrees.y, model.rotation_degrees.z)
	
	death_anim_info = [rise, fall, fall_rot]
	
	death_anim_timer.start()


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



# Getters
func get_translation():
	return translation

func get_obj_type():
	return object_type

func get_map_pos():
	return map_pos

func get_action():
	return proposed_action

func get_hp():
	return hp

func get_mp():
	return mp

func get_max_hp():
	return max_hp

func get_max_mp():
	return max_mp

func get_regen_mp():
	return regen_mp

func get_attack_power():
	return attack_power

func get_spell_power():
	return spell_power


#Setters
func set_model_rot(dir_facing, rotation_deg):
	direction_facing = dir_facing
	model.rotation_degrees.y = rotation_deg

func set_translation(new_translation):
	translation = new_translation

func set_map_pos(new_pos):
	map_pos = new_pos

func set_hp(new_hp):
	hp = new_hp

func set_mp(new_mp):
	mp = new_mp

func set_max_hp(new_max_hp):
	max_hp = new_max_hp

func set_max_mp(new_max_mp):
	max_mp = new_max_mp

func set_regen_mp(new_regen_mp):
	regen_mp = new_regen_mp

func set_attack_power(new_attack_power):
	attack_power = new_attack_power

func set_spell_power(new_spell_power):
	spell_power = new_spell_power

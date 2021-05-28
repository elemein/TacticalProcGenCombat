extends KinematicBody

const TILE_OFFSET = 2.2
const DIRECTION_SELECT_TIME = 0.225

const DEATH_ANIM_TIME = 1

const ACTOR_MOVER = preload("res://Assets/SystemScripts/ActorMover.gd")

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

# Sound effects
onready var miss_basick_attack = $Audio/miss_basic_attack
onready var fireball_throw = $Audio/fireball_throw
onready var out_of_mana = $Audio/out_of_mana
onready var audio_hit = $Audio/Hit

var effects_fire = preload("res://Assets/Objects/Effects/Fire/Fire.tscn")

# gameplay vars
var object_type = 'Player'
var max_hp = 100
var hp = 100
var mp = 100
var max_mp = 100
var speed = 15
var attack_power = 10
var spell_power = 20

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

#death vars
var is_dead = false
var death_anim_timer = Timer.new()
var death_anim_info = []

# object vars
var mover = ACTOR_MOVER.new()

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)
	
	turn_timer.add_to_timer_group(self)
	
	map_pos = map.place_on_random_avail_tile(self)
	translation.x = map_pos[0] * TILE_OFFSET
	translation.z = map_pos[1] * TILE_OFFSET
	
	target_pos = translation
	saved_pos = translation
	
	mover.set_actor(self)
	add_child(mover)
	
	map.print_map_grid()

func _physics_process(_delta):
	if is_dead:
		if death_anim_timer.time_left > 0.75:
			model.translation = (model.translation.linear_interpolate(death_anim_info[0], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		if death_anim_timer.time_left < 0.75 && death_anim_timer.time_left != 0:
			model.translation = (model.translation.linear_interpolate(death_anim_info[1], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
			model.rotation_degrees = (model.rotation_degrees.linear_interpolate(death_anim_info[2], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		if death_anim_timer.time_left == 0:
			return 'dead'
	
	if is_dead == false:
		get_input()
		
		if in_turn == true:
			# Change position based on time tickdown.
			if proposed_action.split(" ")[0] == 'move':
				mover.set_actor_translation()
			
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
	if Input.is_action_pressed("e"): 
		if mp >= 20:
			set_action('fireball')
		else:
			out_of_mana.play()
	
func set_action(action):
	proposed_action = action
	gui.set_action(proposed_action)
	ready_status = true
	
func get_target_tiles(num):
	# Get the contents for the number of tiles desired
	
	var target_tiles = []
	
	for tile_num in num:
		match direction_facing:
			'upleft':
				target_tiles.append([map_pos[0] + 1 + tile_num, map_pos[1] - 1 - tile_num])
			'upright':
				target_tiles.append([map_pos[0] + 1 + tile_num, map_pos[1] + 1 + tile_num])
			'downleft':
				target_tiles.append([map_pos[0] - 1 - tile_num, map_pos[1] - 1 - tile_num])
			'downright':
				target_tiles.append([map_pos[0] - 1 - tile_num, map_pos[1] + 1 + tile_num])
			
			'up':
				target_tiles.append([map_pos[0] + 1 + tile_num, map_pos[1]])
			'down':
				target_tiles.append([map_pos[0] - 1 - tile_num, map_pos[1]])
			'left':
				target_tiles.append([map_pos[0], map_pos[1] - 1 - tile_num])
			'right':
				target_tiles.append([map_pos[0], map_pos[1] + 1 + tile_num])
	return target_tiles
	
func process_turn():	
	# Sets target positions for move and basic attack.
	if proposed_action.split(" ")[0] == 'move':
		mover.move_actor()
	
	elif proposed_action == 'idle':
		target_pos = map_pos
	
	elif proposed_action == 'basic attack':
		var target_tile = get_target_tiles(1)[0]
		target_pos.x = target_tile[0] * TILE_OFFSET
		target_pos.z = target_tile[1] * TILE_OFFSET
		
		var attacked_obj = map.get_tile_contents(target_tile[0], target_tile[1])
		
		if typeof(attacked_obj) != TYPE_STRING: #If not attacking a blank space.
			if attacked_obj.get_obj_type() == 'Enemy':
				attacked_obj.take_damage(attack_power)
		else:
			miss_basick_attack.play()
	
	elif proposed_action == 'fireball':
		set_fireball_target_pos()
		fireball_throw.play()
		for target_tile in get_target_tiles(3):
			var attacked_obj = map.get_tile_contents(target_tile[0], target_tile[1])
			if typeof(attacked_obj) != TYPE_STRING: #If not attacking a blank space.
				if attacked_obj.get_obj_type() == 'Enemy':
					attacked_obj.take_damage(spell_power)
		mp -= 20
		$HealthManaBar3D.update_mana_bar(mp, max_mp)

	in_turn = true

func end_turn():
	target_pos = translation
	saved_pos = translation
	proposed_action = ''
	in_turn = false
	ready_status = false

# Movement related functions.
func check_move_action(move):
	return mover.check_move_action(move)

func check_cornering(direction): # This can definitely be done better. - SS
	match direction:
		'upleft': # check both tiles up and left to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]+1,map_pos[1])
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]-1)
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
			
		'upright': # check both tiles up and right to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]+1,map_pos[1])
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]+1)
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
			
		'downleft': # check both tiles down and left to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]-1,map_pos[1])
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]-1)
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
			
		'downright': # check both tiles down and right to check for walls
			var adjacent_tile = map.get_tile_contents(map_pos[0]-1,map_pos[1])
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
			adjacent_tile = map.get_tile_contents(map_pos[0],map_pos[1]+1)
			if adjacent_tile.get_obj_type() == 'Wall':
				return false
	return true

func set_direction(direction):
	mover.set_actor_direction(direction)
	directional_timer.start(DIRECTION_SELECT_TIME) 

# Ability related functions.
func set_fireball_target_pos():
		effect = effects_fire.instance()
		add_child(effect)
		
		target_pos.y = 0.3
		
		match direction_facing:
			'upleft':
				effect.rotation_degrees.y = 90 + 45
				target_pos.x = effect.translation.x + (3*TILE_OFFSET)
				target_pos.z = effect.translation.z - (3*TILE_OFFSET)
			'upright':
				effect.rotation_degrees.y = 45
				target_pos.x = effect.translation.x + (3*TILE_OFFSET)
				target_pos.z = effect.translation.z + (3*TILE_OFFSET)
			'downleft':
				effect.rotation_degrees.y = 180 + 45
				target_pos.x = effect.translation.z - (3*TILE_OFFSET)
				target_pos.z = effect.translation.x - (3*TILE_OFFSET)
			'downright':
				effect.rotation_degrees.y = 270 + 45
				target_pos.x = effect.translation.z - (3*TILE_OFFSET)
				target_pos.z = effect.translation.x + (3*TILE_OFFSET)
			
			'up':
				effect.rotation_degrees.y = 90
				target_pos.x = effect.translation.x + (3*TILE_OFFSET)
				target_pos.z = 0
			'down':
				effect.rotation_degrees.y = 270
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

	remove_child(mover)
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
	
func get_speed():
	return speed

#Setters
func set_model_rot(dir_facing, rotation_deg):
	direction_facing = dir_facing
	model.rotation_degrees.y = rotation_deg

func set_translation(new_translation):
	translation = new_translation

func set_map_pos(new_pos):
	map_pos = new_pos

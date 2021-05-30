extends KinematicBody

const TILE_OFFSET = 2.2

const DEATH_ANIM_TIME = 1

const AI_ENGINE = preload("res://Assets/SystemScripts/AIEngine.gd")
const ACTOR_MOVER = preload("res://Assets/SystemScripts/ActorMover.gd")
const VIEW_FINDER = preload("res://Assets/SystemScripts/ViewFinder.gd")

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var map = get_node("/root/World/Map")

# Audio effects
onready var miss_basick_attack = $Audio/Hit/basic_attack_2
onready var audio_hit = $Audio/Hit/basic_attack_2

var rng = RandomNumberGenerator.new()

# Spell signals
signal spell_cast_fireball
signal spell_cast_basic_attack

# Status bar signals
signal status_bar_hp(hp, max_hp)
signal status_bar_mp(mp, max_mp)

# gameplay vars
var object_type = 'Enemy'
var hp = 100 setget set_hp
var mp = 100 setget set_mp
var max_hp = 100
var max_mp = 100
var regen_hp = 2
var regen_mp = 10
var speed = 15
var attack_power = 10
var spell_power = 20

# vars to handle turn state
var proposed_action = ""
var ready_status = false
var in_turn = false

# movement and positioning related vars
var direction_facing = "down"
var map_pos = []

var target_pos = Vector3()
var saved_pos = Vector3()

# vars for animation
var anim_state = "idle"
var effect = null

# view var
var viewfield = []

#death vars
var is_dead = false
var death_anim_timer = Timer.new()
var death_anim_info = []

# object vars
var ai_engine = AI_ENGINE.new()
var mover = ACTOR_MOVER.new()
var view_finder = VIEW_FINDER.new()

func _ready():
	rng.randomize()
	speed = rng.randi_range(5,15)

func setup_actor():
	turn_timer.add_to_timer_group(self)
	map_pos = map.place_on_random_avail_tile(self)
	translation.x = map_pos[0] * TILE_OFFSET
	translation.z = map_pos[1] * TILE_OFFSET
	
	ai_engine.set_actor(self)
	add_child(ai_engine)
	
	mover.set_actor(self)
	add_child(mover)
	add_child(view_finder)
	
	viewfield = view_finder.find_view_field(map_pos[0], map_pos[1])

func _physics_process(_delta):
	if is_dead:
		if death_anim_timer.time_left > 0.75:
			model.translation = (model.translation.linear_interpolate(death_anim_info[0], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		if death_anim_timer.time_left < 0.75 && death_anim_timer.time_left != 0:
			model.translation = (model.translation.linear_interpolate(death_anim_info[1], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
			model.rotation_degrees = (model.rotation_degrees.linear_interpolate(death_anim_info[2], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		if death_anim_timer.time_left == 0:
			return 'dead'
	
	if turn_timer.time_left == 0: # We don't wanna decide a turn if timer isn't 0.
		if ready_status == false:
			decide_next_action()
	
	if in_turn == true:
		if proposed_action.split(" ")[0] == 'move':
			mover.set_actor_translation()

	if proposed_action == "basic attack":
		if turn_timer.time_left > 0.5: # Move char towards attack cell.
			translation = translation.linear_interpolate(target_pos, (1-(turn_timer.time_left - 0.5))) 
		else: # Move char back.
			translation = translation.linear_interpolate(saved_pos, (0.5-turn_timer.time_left))
			
	if proposed_action != '' && in_turn == true:
		if proposed_action == 'idle':
			anim_state = "idle"
		else:
			anim_state = "walk"
	else:
		anim_state = "idle"

	handle_animations()

func decide_next_action():
	ai_engine.run_engine()

func set_action(action):
	proposed_action = action
	ready_status = true

func process_turn():
	if proposed_action.split(" ")[0] == 'move':
		mover.move_actor()

	elif proposed_action == 'basic attack':
		emit_signal("spell_cast_basic_attack")
	
	elif proposed_action == 'fireball':
		emit_signal("spell_cast_fireball")
		
	# Apply any regen effects
	self.hp += regen_hp
	self.mp += regen_mp

	in_turn = true

func end_turn():
	mover.reset_pos_vars()
	target_pos = translation
	saved_pos = translation
	proposed_action = ''
	in_turn = false
	ready_status = false
	
	viewfield = view_finder.find_view_field(map_pos[0], map_pos[1])

func take_damage(damage):
	if not is_dead:
		hp -= damage
		print("%s has %s HP" % [self, hp])
		
		# Play a random audio effect upon getting hit
		var num_audio_effects = audio_hit.get_children().size()
		audio_hit.play()
		
		# Update the health bar
		emit_signal("status_bar_hp", hp, max_hp)
		
		if hp <= 0:
			die()

func die():
	death_anim_timer.set_one_shot(true)
	death_anim_timer.set_wait_time(DEATH_ANIM_TIME)
	add_child(death_anim_timer)
	is_dead = true
	turn_timer.remove_from_timer_group(self)

	remove_child(mover)
	remove_child(ai_engine)
	proposed_action = 'idle'
	
	var rise = Vector3(model.translation.x, 2, model.translation.z)
	var fall = Vector3(model.translation.x, 0.2, model.translation.z)
	var fall_rot = Vector3(-90, model.rotation_degrees.y, model.rotation_degrees.z)
	
	death_anim_info = [rise, fall, fall_rot]
	
	death_anim_timer.start()
	$HealthManaBar3D.visible = false

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
	

# Movement related functions.
func check_move_action(move):
	return mover.check_move_action(move)

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
	
func get_is_dead():
	return is_dead

func get_speed():
	return speed

func get_viewfield():
	return viewfield

# Setters
func set_model_rot(dir_facing, rotation_deg):
	direction_facing = dir_facing
	model.rotation_degrees.y = rotation_deg

func set_translation(new_translation):
	translation = new_translation

func set_map_pos(new_pos):
	map_pos = new_pos

func set_hp(new_hp):
	hp = new_hp
	if hp > max_hp:
		hp = max_hp
	emit_signal("status_bar_hp", hp, max_hp)
	
func set_mp(new_mp):
	mp = new_mp
	if mp > max_mp:
		mp = max_mp
	emit_signal("status_bar_mp", mp, max_mp)

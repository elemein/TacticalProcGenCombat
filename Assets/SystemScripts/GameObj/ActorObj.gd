extends GameObj
class_name ActorObj

const DEATH_ANIM_TIME = 1

const ACTOR_MOVER = preload("res://Assets/SystemScripts/ActorMover.gd")
const VIEW_FINDER = preload("res://Assets/SystemScripts/ViewFinder.gd")

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI/Action")
onready var turn_timer = get_node("/root/World/TurnTimer")

# Sound effects
onready var audio_hit = $Audio/Hit

# Spell signals
signal spell_cast_fireball
signal spell_cast_self_heal
signal spell_cast_basic_attack
signal spell_cast_dash
signal action_drop_item
signal action_equip_item
signal action_unequip_item

# Status bar signals
signal status_bar_hp(hp, max_hp)
signal status_bar_mp(mp, max_mp)

var mover = ACTOR_MOVER.new()
var view_finder = VIEW_FINDER.new()

#death vars
var death_anim_timer = Timer.new()
var death_anim_info = []
var is_dead = false

var viewfield = []
var proposed_action = ""

var turn_anim_timer = Timer.new()
var anim_timer_waittime = 1

# movement and positioning related vars
var direction_facing = "down"
var target_pos = Vector3()
var saved_pos = Vector3()

# turn_state vars
var ready_status = false
var in_turn = false

# vars for animation
var anim_state = "idle"
var effect = null

var stat_dict = {"Max HP" : 0, "HP" : 0, "Max MP": 0, "MP": 0, \
				"HP Regen" : 0, "MP Regen": 0, "Attack Power" : 0, \
				"Spell Power" : 0, "Defense" : 0, "Speed": 0, "View Range" : 0}

func _init(obj_type, actor_stats).(obj_type):
	stat_dict = actor_stats

	turn_anim_timer.set_one_shot(true)
	turn_anim_timer.set_wait_time(1)
	add_child(turn_anim_timer)
	
	add_child(view_finder)
	view_finder.set_actor(self)

func set_action(action):
	proposed_action = action
	ready_status = true
	
	if object_type == 'Player': gui.set_action(proposed_action)

func process_turn():	
	if proposed_action.split(" ")[0] == 'move': turn_anim_timer.set_wait_time(0.35)
	elif proposed_action == 'idle': turn_anim_timer.set_wait_time(0.00001)
	elif proposed_action == 'basic attack': turn_anim_timer.set_wait_time(0.8)
	elif proposed_action == 'fireball': turn_anim_timer.set_wait_time(0.5)
	elif proposed_action == 'self_heal': turn_anim_timer.set_wait_time(0.7)
	elif proposed_action == 'dash': turn_anim_timer.set_wait_time(0.6)
	elif proposed_action in ['drop item', 'equip item', 'unequip item']: turn_anim_timer.set_wait_time(0.5)
	turn_anim_timer.start()

	# Sets target positions for move and basic attack.
	if proposed_action.split(" ")[0] == 'move':
		set_actor_dir(proposed_action.split(" ")[1])
		if check_move_action(proposed_action) == true:
			mover.move_actor(1)
	
	elif proposed_action == 'idle':
		target_pos = map_pos
	
	elif proposed_action == 'basic attack':
		emit_signal("spell_cast_basic_attack")
	
	elif proposed_action == 'fireball':
		emit_signal("spell_cast_fireball")
	elif proposed_action == 'dash':
		emit_signal("spell_cast_dash")
	elif proposed_action == 'self heal':
		emit_signal("spell_cast_self_heal")
		
	elif proposed_action == 'drop item':
		emit_signal("action_drop_item")
	elif proposed_action == 'equip item':
		emit_signal("action_equip_item")
	elif proposed_action == 'unequip item':
		emit_signal("action_unequip_item")
		
	# Apply any regen effects
	set_hp(stat_dict['HP'] + stat_dict['HP Regen'])
	set_mp(stat_dict['MP'] + stat_dict['MP Regen'])

	in_turn = true

func end_turn():
	target_pos = translation
	saved_pos = translation
	proposed_action = ''
	in_turn = false
	ready_status = false
	
	viewfield = view_finder.find_view_field(map_pos[0], map_pos[1])

# Movement related functions.
func check_move_action(move):
	return mover.check_move_action(move)

func manual_move_char(amount):
	mover.move_actor(amount)

# Animations related functions.
func handle_animations():
	match anim_state:
		'idle':
			play_anim("idle")
		'walk':
			if get_obj_type() == 'Player':
				play_anim("run")
			if get_obj_type() == 'Enemy':
				play_anim("walk")

func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

func take_damage(damage):
	if not is_dead:
		var damage_multiplier = 100 / (100+float(stat_dict['Defense']))
		damage = floor(damage * damage_multiplier)
		damage = floor(damage)
		stat_dict['HP'] -= damage
		print("%s has %s HP" % [self, stat_dict['HP']])
		
		# Play a random audio effect upon getting hit
		var num_audio_effects = audio_hit.get_children().size()
		var hit_sound = audio_hit.get_children()[randi() % num_audio_effects]
		hit_sound.translation = self.translation
		hit_sound.play()
		
		# Update the health bar
		emit_signal("status_bar_hp", stat_dict['HP'], stat_dict['Max HP'])

		if stat_dict['HP'] <= 0:
			die()

func die():
	death_anim_timer.set_one_shot(true)
	death_anim_timer.set_wait_time(DEATH_ANIM_TIME)
	add_child(death_anim_timer)
	is_dead = true
	turn_timer.remove_from_timer_group(self)
	
	proposed_action = 'idle'
	
	var rise = Vector3(model.translation.x, 2, model.translation.z)
	var fall = Vector3(model.translation.x, 0.2, model.translation.z)
	var fall_rot = Vector3(-90, model.rotation_degrees.y, model.rotation_degrees.z)
	
	death_anim_info = [rise, fall, fall_rot]
	
	death_anim_timer.start()
	$HealthManaBar3D.visible = false
	
	if self.object_type == 'Player':
		get_tree().change_scene('res://Assets/GUI/DeathScreen/DeathScreen.tscn')
	else:
		parent_map.current_number_of_enemies -= 1
		if parent_map.current_number_of_enemies == 0:
			get_tree().change_scene('res://Assets/GUI/VictoryScreen/VictoryScreen.tscn')

func play_death_anim():
	if death_anim_timer.time_left > 0.75:
		model.translation = (model.translation.linear_interpolate(death_anim_info[0], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
	if death_anim_timer.time_left < 0.75 && death_anim_timer.time_left != 0:
		model.translation = (model.translation.linear_interpolate(death_anim_info[1], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		model.rotation_degrees = (model.rotation_degrees.linear_interpolate(death_anim_info[2], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 

# Getters
func get_hp(): return stat_dict['HP']

func get_mp(): return stat_dict['MP']

func get_speed(): return stat_dict['Speed']

func get_viewrange(): return stat_dict['View Range']

func get_attack_power() -> int: return stat_dict['Attack Power']

func get_spell_power() -> int: return stat_dict['Spell Power']

func get_defense() -> int: return stat_dict['Defense']

func get_is_dead() -> bool: return is_dead

func get_stat_dict() -> Dictionary: return stat_dict

func get_viewfield() -> Array: return viewfield

func get_action() -> String: return proposed_action

func get_direction_facing() -> String: return direction_facing

func get_turn_anim_timer() -> Object: return turn_anim_timer

# Setters
func set_stat_dict(changed_dict): stat_dict = changed_dict

func set_actor_dir(dir_facing):
	direction_facing = dir_facing

	match direction_facing:
		'upleft': model.rotation_degrees.y = 135
		'upright': model.rotation_degrees.y = 45
		'downleft': model.rotation_degrees.y = 225
		'downright': model.rotation_degrees.y = 315
		
		'up': model.rotation_degrees.y = 90
		'down': model.rotation_degrees.y = 270
		'left': model.rotation_degrees.y = 180
		'right': model.rotation_degrees.y = 0

func set_hp(new_hp):
	stat_dict['HP'] = stat_dict['Max HP'] if (new_hp > stat_dict['Max HP']) else new_hp
	emit_signal("status_bar_hp", stat_dict['HP'], stat_dict['Max HP'])
	
func set_mp(new_mp):
	stat_dict['MP'] = stat_dict['Max MP'] if (new_mp > stat_dict['Max MP']) else new_mp
	emit_signal("status_bar_mp", stat_dict['MP'], stat_dict['Max MP'])
	
func set_attack_power(new_value):
	stat_dict['Attack Power'] = new_value

func set_spell_power(new_value):
	stat_dict['Spell Power'] = new_value

func set_defense(new_value):
	stat_dict['Defense'] = new_value

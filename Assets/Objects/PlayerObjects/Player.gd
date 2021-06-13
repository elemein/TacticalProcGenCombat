extends ActorObj

const DEATH_ANIM_TIME = 1
const DIRECTION_SELECT_TIME = 0.27

const ACTOR_MOVER = preload("res://Assets/SystemScripts/ActorMover.gd")
const VIEW_FINDER = preload("res://Assets/SystemScripts/ViewFinder.gd")
const INVENTORY = preload("res://Assets/Objects/UIObjects/Inventory.tscn")

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")

# Sound effects
onready var miss_basic_attack = $Audio/miss_basic_attack
onready var fireball_throw = $Audio/fireball_throw
onready var out_of_mana = $Audio/out_of_mana
onready var audio_hit = $Audio/Hit

var effects_fire = preload("res://Assets/Objects/Effects/Fire/Fire.tscn")

# Spell signals
signal spell_cast_fireball
signal spell_cast_basic_attack
signal spell_cast_dash
signal action_drop_item
signal action_equip_item
signal action_unequip_item

# Status bar signals
signal status_bar_hp(hp, max_hp)
signal status_bar_mp(mp, max_mp)

# unsorted vars
var turn_anim_timer = Timer.new()
var anim_timer_waittime = 1

# gameplay vars
var hp = 100 setget set_hp
var mp = 100 setget set_mp
var max_hp = 100
var max_mp = 100
var defense = 0
var regen_hp = 1
var regen_mp = 7
var speed = 15
var attack_power = 10
var spell_power = 20
var view_range = 4

# vars to handle turn state
var proposed_action = ""
var ready_status = false
var in_turn = false

# movement and positioning related vars
var direction_facing = "down"
var directional_timer = Timer.new()
var saved_pos = Vector3()
var target_pos = Vector3()

# vars for animation
var anim_state = "idle"
var effect = null

# view var
var viewfield = []

# inventory vars
var inventory_open = false

#death vars
var is_dead = false
var death_anim_timer = Timer.new()
var death_anim_info = []

# object vars
var mover = ACTOR_MOVER.new()
var view_finder = VIEW_FINDER.new()
var inventory = INVENTORY.instance()

func _init().("Player"):
	pass

func _ready():
	directional_timer.set_one_shot(true)
	directional_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(directional_timer)
	
	turn_anim_timer.set_one_shot(true)
	turn_anim_timer.set_wait_time(DIRECTION_SELECT_TIME)
	add_child(turn_anim_timer)
	
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
	
	add_child(view_finder)
	view_finder.set_actor(self)
	
	add_child(inventory)
	inventory.setup_inventory(self)

func _physics_process(_delta):
	if is_dead: play_death_anim()
		
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

func play_death_anim():
	mover.set_actor_translation()
	if death_anim_timer.time_left > 0.75:
		model.translation = (model.translation.linear_interpolate(death_anim_info[0], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
	if death_anim_timer.time_left < 0.75 && death_anim_timer.time_left != 0:
		model.translation = (model.translation.linear_interpolate(death_anim_info[1], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
		model.rotation_degrees = (model.rotation_degrees.linear_interpolate(death_anim_info[2], (DEATH_ANIM_TIME-death_anim_timer.time_left))) 
	if death_anim_timer.time_left == 0:
		return 'dead'
			
	
func get_input():
	if turn_timer.get_turn_in_process() == true or inventory_open: 
		# We don't wanna collect input if turn in action or in inventory.
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
	if Input.is_action_pressed("r"): set_action('dash')
	
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
	
	if proposed_action.split(" ")[0] == 'move': turn_anim_timer.set_wait_time(0.35)
	elif proposed_action == 'idle': turn_anim_timer.set_wait_time(0.00001)
	elif proposed_action == 'basic attack': turn_anim_timer.set_wait_time(0.8)
	elif proposed_action == 'fireball': turn_anim_timer.set_wait_time(0.5)
	elif proposed_action == 'dash': turn_anim_timer.set_wait_time(0.8)
	elif proposed_action in ['drop item', 'equip item', 'unequip item']: turn_anim_timer.set_wait_time(0.5)

	turn_anim_timer.start()

	# Sets target positions for move and basic attack.
	if proposed_action.split(" ")[0] == 'move':
		if check_move_action(proposed_action):
			mover.move_actor(1)
	
	elif proposed_action == 'idle':
		target_pos = map_pos
	
	elif proposed_action == 'basic attack':
		emit_signal("spell_cast_basic_attack")
	
	elif proposed_action == 'fireball':
		emit_signal("spell_cast_fireball")
	elif proposed_action == 'dash':
		emit_signal("spell_cast_dash")
		
	elif proposed_action == 'drop item':
		emit_signal("action_drop_item")
	elif proposed_action == 'equip item':
		emit_signal("action_equip_item")
	elif proposed_action == 'unequip item':
		emit_signal("action_unequip_item")
		
	# Apply any regen effects
	self.hp += regen_hp
	self.mp += regen_mp

	in_turn = true

func end_turn():
	target_pos = translation
	saved_pos = translation
	proposed_action = ''
	in_turn = false
	ready_status = false
	gui.clear_action()
	
	viewfield = view_finder.find_view_field(map_pos[0], map_pos[1])

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
	if not is_dead:
		var damage_multiplier = 100 / (100+float(defense))
		damage = floor(damage * damage_multiplier)
		damage = floor(damage)
		hp -= damage
		print("%s has %s HP" % [self, hp])
		
		# Player audio node is empty, so this doesnt work.
		# Play a random audio effect upon getting hit
		var num_audio_effects = audio_hit.get_children().size()
		audio_hit.get_children()[randi() % num_audio_effects].play()
		
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
	
	proposed_action = 'idle'
	
	var rise = Vector3(model.translation.x, 2, model.translation.z)
	var fall = Vector3(model.translation.x, 0.2, model.translation.z)
	var fall_rot = Vector3(-90, model.rotation_degrees.y, model.rotation_degrees.z)
	
	death_anim_info = [rise, fall, fall_rot]
	
	death_anim_timer.start()
	$HealthManaBar3D.visible = false

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

func manual_move_char(amount):
	mover.move_actor(amount)

# Getters
func get_action():
	return proposed_action
	
func get_hp():
	return hp
	
func get_is_dead():
	return is_dead

func get_speed():
	return speed

func get_viewrange():
	return view_range

func get_viewfield():
	return viewfield

func get_attack_power() -> int:
	return attack_power

func get_spell_power() -> int:
	return spell_power

func get_defense() -> int:
	return defense

func get_inventory_open() -> bool:
	return inventory_open

func get_inventory_object() -> Object:
	return inventory

func get_item_to_drop() -> Object:
	return inventory.get_item_to_drop()

func get_turn_anim_timer() -> Object:
	return turn_anim_timer

func get_direction_facing() -> String:
	return direction_facing

#Setters
func set_model_rot(dir_facing, rotation_deg):
	direction_facing = dir_facing
	model.rotation_degrees.y = rotation_deg

func set_hp(new_hp):
	hp = max_hp if (new_hp > max_hp) else new_hp
	emit_signal("status_bar_hp", hp, max_hp)
	
func set_mp(new_mp):
	mp = max_mp if (new_mp > max_mp) else new_mp
	emit_signal("status_bar_mp", mp, max_mp)
	
func set_attack_power(new_value):
	attack_power = new_value

func set_spell_power(new_value):
	spell_power = new_value

func set_defense(new_value):
	defense = new_value

func set_inventory_open(state):
	inventory_open = state

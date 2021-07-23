extends Node
class_name BaseAbility

# Get required nodes
onready var world = get_node('/root/World/')

# Signals
signal set_ready_status

# Sound effects
onready var UseSpell = null
onready var out_of_mana = $out_of_mana

# Misc variables
var target_spell_pos = Vector3()
var target_actor_pos = Vector3()
var saved_actor_pos = Vector3()
var tile_offset = null
var effect = null
var parent = null
var direction_facing = null
var map_pos = null
var map = null
var damage = 0

# Movement Variables - These need to be changed if the actor is moving as apart of the spell
var moving = false
var moving_back = false  # if the actor will move back to it's starting postion

# Spell variables - These need to be updated for each spell
var spell_power = 0
var spell_cost = 0
var spell_length = 0
var spell_name = 'spell name'
var spell_heal_user = false

# Visual assets - This needs to be updated for each spell if it has an effect
var visual_effect = null
var effect_start_height = 0
var effect_end_height = 0

func _ready():
	tile_offset = world.MAP_GEN.TILE_OFFSET
	
# Move the parent every frame
func _physics_process(_delta):
	if effect != null:
		if parent.get_turn_anim_timer().time_left > 0:
			var interp_mod = parent.get_turn_anim_timer().time_left / parent.get_turn_anim_timer().get_wait_time()
			effect.translation = effect.translation.linear_interpolate(target_spell_pos, 1-interp_mod) 
		else:
			get_node(spell_name).queue_free()
			remove_child(get_node(spell_name))
			effect = null
	if moving and moving_back and parent:
		var interp_mod = parent.get_turn_anim_timer().time_left / parent.get_turn_anim_timer().get_wait_time()
		if interp_mod > 0.5:
			parent.translation = parent.translation.linear_interpolate(target_actor_pos, 1-interp_mod)
		elif parent.in_turn:
			parent.translation = parent.translation.linear_interpolate(saved_actor_pos, 1-interp_mod)
		else:
			parent = null

# Main functionality of the spell
func use():
	if parent == null:
		parent = find_parent('Actions').get_parent()
	map = parent.get_parent_map()
	if moving and not moving_back and not move_check():
		parent = null
		return
	if parent:
		set_ready_status()
		play_audio()
		if visual_effect != null:
			create_spell_instance()
			set_target_spell_pos()
		if moving:
			set_target_actor_pos()
		if moving and not moving_back:
			parent.manual_move_char(2)
		set_power()
		do_damage()
		if spell_heal_user:
			heal_user()
		
func move_check() -> bool:
	set_target_actor_pos()
	for target_tile in get_target_tiles():
		for object in target_tile:
			if object.object_type == 'Wall':
				return false
	return true
			
func set_ready_status():
	emit_signal("set_ready_status")
	
func heal_user():
	parent.set_hp(parent.get_hp() + spell_power)
			
func play_audio():
	UseSpell = find_node('UseSpell')
	if UseSpell != null and not UseSpell.is_playing():
		UseSpell.translation = parent.translation
		UseSpell.play()

func set_power():
	damage = parent.get_spell_power() + spell_power

# Check if out of mana
func mana_check() -> bool:
	parent = find_parent('Actions').get_parent()
	if parent.get_mp() and parent.get_mp() < spell_cost:
		if not out_of_mana.is_playing():
			out_of_mana.translation = parent.translation
			out_of_mana.play()
		return false
		
	# Update mana
	elif parent.get_mp():
		parent.set_mp(parent.get_mp() - spell_cost)
	return true

# Spawn in the spell
func create_spell_instance():
	effect = visual_effect.instance()
	effect.name = spell_name
	add_child(effect)
	effect.translation.x = parent.translation.x
	effect.translation.z = parent.translation.z
	effect.translation.y = parent.translation.y + effect_start_height

# Set the destination tile
func set_target_spell_pos():
	direction_facing = parent.direction_facing

	target_spell_pos = Vector3(0, 0.3, 0)

	match direction_facing:
		'upleft':
			effect.rotation_degrees.y = 90 + 45
			target_spell_pos.x = effect.translation.x + (spell_length*tile_offset)
			target_spell_pos.z = effect.translation.z - (spell_length*tile_offset)
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
		'upright':
			effect.rotation_degrees.y = 90 - 45
			target_spell_pos.x = effect.translation.x + (spell_length*tile_offset)
			target_spell_pos.z = effect.translation.z + (spell_length*tile_offset)
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
		'downleft':
			effect.rotation_degrees.y = 270 - 45
			target_spell_pos.x = effect.translation.x - (spell_length*tile_offset)
			target_spell_pos.z = effect.translation.z - (spell_length*tile_offset)
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
		'downright':
			effect.rotation_degrees.y = 270 + 45
			target_spell_pos.x = effect.translation.x - (spell_length*tile_offset)
			target_spell_pos.z = effect.translation.z + (spell_length*tile_offset)
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
					
		'up':
			effect.rotation_degrees.y = 90
			target_spell_pos.x = effect.translation.x + (spell_length*tile_offset)
			target_spell_pos.z = effect.translation.z
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
		'down':
			effect.rotation_degrees.y = 270
			target_spell_pos.x = effect.translation.x - (spell_length*tile_offset)
			target_spell_pos.z = effect.translation.z
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
		'left':
			effect.rotation_degrees.y = 180
			target_spell_pos.x = effect.translation.x
			target_spell_pos.z = effect.translation.z - (spell_length*tile_offset)
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
		'right':
			effect.rotation_degrees.y = 0
			target_spell_pos.x = effect.translation.x
			target_spell_pos.z = effect.translation.z + (spell_length*tile_offset)
			target_spell_pos.y = effect.translation.y + (effect_end_height - effect_start_height)
			
# Set the destination tile
func set_target_actor_pos():

	direction_facing = parent.direction_facing
	saved_actor_pos = parent.translation

	match direction_facing:
		'upleft':
			target_actor_pos.x = saved_actor_pos.x + (spell_length*tile_offset)
			target_actor_pos.z = saved_actor_pos.z - (spell_length*tile_offset)
		'upright':
			target_actor_pos.x = saved_actor_pos.x + (spell_length*tile_offset)
			target_actor_pos.z = saved_actor_pos.z + (spell_length*tile_offset)
		'downleft':
			target_actor_pos.x = saved_actor_pos.x - (spell_length*tile_offset)
			target_actor_pos.z = saved_actor_pos.z - (spell_length*tile_offset)
		'downright':
			target_actor_pos.x = saved_actor_pos.x - (spell_length*tile_offset)
			target_actor_pos.z = saved_actor_pos.z + (spell_length*tile_offset)
		
		'up':
			target_actor_pos.x = saved_actor_pos.x + (spell_length*tile_offset)
			target_actor_pos.z = saved_actor_pos.z
		'down':
			target_actor_pos.x = saved_actor_pos.x - (spell_length*tile_offset)
			target_actor_pos.z = saved_actor_pos.z
		'left':
			target_actor_pos.x = saved_actor_pos.x
			target_actor_pos.z = saved_actor_pos.z - (spell_length*tile_offset)
		'right':
			target_actor_pos.x = saved_actor_pos.x
			target_actor_pos.z = saved_actor_pos.z + (spell_length*tile_offset)

# Get information for all of the tiles that will get hit by the spell
func get_target_tiles() -> Array:
	var target_tiles = []
	var target_tile_contents = []
	map_pos = parent.map_pos

	for tile_num in spell_length:
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
	
	for target_tile in target_tiles:
		target_tile_contents.append(map.get_tile_contents(target_tile[0], target_tile[1]))
	return target_tile_contents

# Actually inflict damage on the target tiles
func do_damage():
	for objects_on_tile in get_target_tiles():
		if typeof(objects_on_tile) != TYPE_STRING:
			for object in objects_on_tile:
				if object.get_obj_type() in ['Enemy', 'Player']:
					object.take_damage(damage)

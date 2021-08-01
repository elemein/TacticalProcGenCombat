extends Node
class_name BaseAbility

# Sound effects
onready var UseSpell = null
onready var out_of_mana = $out_of_mana

# Misc variables
var target_spell_pos = Vector3()
var target_actor_pos = Vector3()
var saved_actor_pos = Vector3()
var tile_offset = GlobalVars.TILE_OFFSET
var effect = null
var parent = null
var direction_facing = null
var map_pos = null
var map = null
var spell_final_power = 0
var spell_final_attack_power = 0
var anim_time = 0

# Movement Variables - These need to be changed if the actor is moving as apart of the spell
var moving = false
var moving_back = false  # if the actor will move back to it's starting postion

# Spell variables - These need to be updated for each spell
var attack_power = 0
var spell_power = 0
var spell_cost = 0
var spell_length = 0
var spell_name = 'spell name'
var spell_description = 'spell description'
var scales_off_atk_or_spl = null

# Visual assets - This needs to be updated for each spell if it has an effect
var visual_effect = null
var effect_start_height = 0
var effect_end_height = 0

# Move the parent every frame
func _physics_process(_delta): pass
#	if moving and moving_back and parent:
#		var interp_mod = parent.get_turn_anim_timer().time_left / parent.get_turn_anim_timer().get_wait_time()
#		if interp_mod > 0.5:
#			parent.translation = parent.translation.linear_interpolate(target_actor_pos, 1-interp_mod)
#		elif parent.in_turn:
#			parent.translation = parent.translation.linear_interpolate(saved_actor_pos, 1-interp_mod)
#		else:
#			parent = null
		
func move_check() -> bool:
	set_target_actor_pos()
	for target_tile in get_target_tiles():
		for object in target_tile:
			if object.object_type in GlobalVars.NON_TRAVERSABLES:
				return false
	return true
			
func heal_user():
	parent.set_hp(parent.get_hp() + spell_final_power)
			
func play_audio():
	UseSpell = find_node('UseSpell')
	if UseSpell != null and not UseSpell.is_playing():
		UseSpell.translation = parent.translation
		UseSpell.play()

func set_power():
	spell_final_power = parent.get_spell_power() + spell_power

func set_attack_power():
	spell_final_attack_power = parent.get_attack_power() + attack_power

# Check if out of mana
func mana_check() -> bool:
	parent = find_parent('Actions').get_parent()
	if parent.get_mp() and parent.get_mp() < spell_cost:
		if not out_of_mana.is_playing():
			out_of_mana.translation = parent.translation
			out_of_mana.play()
		return false
	return true

# Spawn in the spell
func create_spell_instance():
	effect = visual_effect.instance()
	effect.name = spell_name
	add_child(effect)
	effect.translation = parent.translation + Vector3(0, effect_start_height, 0)

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
					if scales_off_atk_or_spl == 'spl':
						object.take_damage(spell_final_power)
					elif scales_off_atk_or_spl == 'atk':
						object.take_damage(spell_final_attack_power)

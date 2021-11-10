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
var rng = RandomNumberGenerator.new()

# Spell variables - These need to be updated for each spell
var attack_power = 0
var spell_power = 0
var spell_cost = 0
var spell_length = 0
var spell_name = 'spell name'
var spell_description = 'spell description'

# Visual assets - This needs to be updated for each spell if it has an effect
var visual_effect = null
var effect_start_height = 0
var effect_end_height = 0

func _ready():
	parent = find_parent("Actions").get_parent()

func move_check():
	var dash_length = 0
	
	set_target_actor_pos()
	var target_tiles = get_target_tiles()
	for target_tile in target_tiles:
		
		var tile_clear = true
		
		for object in target_tile:
			if object.get_relation_rules()['Non-Traversable'] == true:
				tile_clear = false
		
		if tile_clear == true: dash_length += 1
		
	return dash_length
			
func heal_user():
	MultiplayerTestenv.get_server().update_actor_stat(parent.get_id(), {"Stat": "HP", "Modifier": spell_final_power})
	MultiplayerTestenv.get_server().actor_notif_event(parent.get_id(), ("+" + str(spell_final_power)), 'heal')

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
	if parent.get_mp() and parent.get_mp() < spell_cost:
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

	target_spell_pos = Vector3(0, 0, 0)

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
func do_damage(amount, variance, attacker):
	var is_crit = rng.randi_range(0,100) < parent.get_crit_chance()
	
	var damage_percentage = (100 - rng.randf_range(0, variance)) / 100
	var damage_amount = floor(amount * damage_percentage)
	
	if is_crit == true: damage_amount = amount * 2
	
	var damaged_objects = []
	
	for objects_on_tile in get_target_tiles():
		if typeof(objects_on_tile) != TYPE_STRING:
			for object in objects_on_tile:
				if object.get_id()['CategoryType'] in ['Enemy', 'Player']:
					damaged_objects.append(object)

	var damage_instance = {"Amount": damage_amount, "Crit": is_crit, \
						"Attacker": attacker}

	for object in damaged_objects:
		object.take_damage(damage_instance)

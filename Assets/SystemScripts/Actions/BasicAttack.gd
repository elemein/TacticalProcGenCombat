extends Node

# Get required nodes
onready var map = get_node("/root/World/Map")
onready var turn_timer = get_node("/root/World/TurnTimer")

# Sound effects
onready var UseSpell = $UseSpell
onready var out_of_mana = $out_of_mana

# Misc variables
var target_pos = Vector3()
var saved_pos = Vector3()
var tile_offset = null
var effect = null
var parent = null
var direction_facing = null
var map_pos = null

# Spell variables
var spell_power = 10
var spell_cost = 0
var spell_length = 1

func _ready():
	tile_offset = map.TILE_OFFSET
	
# Move the parent every frame
func _physics_process(_delta):
	if parent:
		if turn_timer.time_left > 0.5:
			parent.translation = parent.translation.linear_interpolate(target_pos, (1-(turn_timer.time_left - 0.5))) 
		elif parent.in_turn:
			parent.translation = parent.translation.linear_interpolate(saved_pos, (0.5-turn_timer.time_left))
		else:
			parent = null

# Main functionality of the spell
func use():
	parent = find_parent('Actions').get_parent()
	if parent:
		if mana_check():
			UseSpell.play()
			set_target_pos()
			do_damage()

# Check if out of mana
func mana_check() -> bool:
	if parent.get('mp') and parent.mp < spell_cost:
		out_of_mana.play()
		return false
		
	# Update mana
	elif parent.get('mp'):
		parent.mp -= spell_cost

	return true

# Set the destination tile
func set_target_pos():

	direction_facing = parent.direction_facing
	saved_pos = parent.translation

	match direction_facing:
		'upleft':
			target_pos.x = saved_pos.x + (spell_length*tile_offset)
			target_pos.z = saved_pos.z - (spell_length*tile_offset)
		'upright':
			target_pos.x = saved_pos.x + (spell_length*tile_offset)
			target_pos.z = saved_pos.z + (spell_length*tile_offset)
		'downleft':
			target_pos.x = saved_pos.x - (spell_length*tile_offset)
			target_pos.z = saved_pos.z - (spell_length*tile_offset)
		'downright':
			target_pos.x = saved_pos.x - (spell_length*tile_offset)
			target_pos.z = saved_pos.z + (spell_length*tile_offset)
		
		'up':
			target_pos.x = saved_pos.x + (spell_length*tile_offset)
			target_pos.z = saved_pos.z
		'down':
			target_pos.x = saved_pos.x - (spell_length*tile_offset)
			target_pos.z = saved_pos.z
		'left':
			target_pos.x = saved_pos.x
			target_pos.z = saved_pos.z - (spell_length*tile_offset)
		'right':
			target_pos.x = saved_pos.x
			target_pos.z = saved_pos.z + (spell_length*tile_offset)

# Get information for all of the tiles that will get hit by the spell
func get_target_tiles() -> Array:

	var target_tiles = []
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
	return target_tiles

# Actually inflict damage on the target tiles
func do_damage():
	for target_tile in get_target_tiles():
		var attacked_obj = map.get_tile_contents(target_tile[0], target_tile[1])
		if not attacked_obj.get('object_type') in ['Ground', 'Wall']:
			attacked_obj.take_damage(spell_power)

func _on_Actions_spell_cast_basic_attack():
	use()

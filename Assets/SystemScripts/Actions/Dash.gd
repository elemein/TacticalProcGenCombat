extends Node

# Get required nodes
onready var map = get_node("/root/World/Map")
onready var turn_timer = get_node("/root/World/TurnTimer")

# Sound effects
onready var UseSpell = $UseSpell
onready var out_of_mana = $out_of_mana

# Misc variables
var target_pos = Vector3()
var tile_offset = null
var parent = null
var direction_facing = null
var dashing = false
var end_tile = []

# Spell variables
var spell_cost = 20
var spell_length = 2

func _ready():
	tile_offset = map.TILE_OFFSET
	
# Move the parent every frame
func _physics_process(_delta):
	if dashing:
		if parent.get_turn_anim_timer().time_left > 0:
			var interp_mod = parent.get_turn_anim_timer().time_left / parent.get_turn_anim_timer().get_wait_time()
			parent.translation = parent.translation.linear_interpolate(target_pos, 1-interp_mod) 
		else:
			dashing = false

func _on_Actions_spell_cast_dash():
	use()
# Main functionality of the spell
func use():
	parent = find_parent('Actions').get_parent()
	if parent:
		if mana_check():
			direction_facing = parent.get_direction_facing()
			if check_if_dashable():
				set_target_pos()
				parent.set_map_pos(end_tile)
				dashing = true

# Check if out of mana
func mana_check() -> bool:
	if parent.get('mp') and parent.get('mp') < spell_cost:
		out_of_mana.play()
		return false
		
	# Update mana
	elif parent.get('mp'):
		parent.mp -= spell_cost
	return true

# Set the destination tile
func set_target_pos():
	target_pos = Vector3(0, 0.3, 0)

	match direction_facing:
		'upleft':
			target_pos.x = parent.translation.x + (spell_length*tile_offset)
			target_pos.z = parent.translation.z - (spell_length*tile_offset)
		'upright':
			target_pos.x = parent.translation.x + (spell_length*tile_offset)
			target_pos.z = parent.translation.z + (spell_length*tile_offset)
		'downleft':
			target_pos.x = parent.translation.x - (spell_length*tile_offset)
			target_pos.z = parent.translation.z - (spell_length*tile_offset)
		'downright':
			target_pos.x = parent.translation.x - (spell_length*tile_offset)
			target_pos.z = parent.translation.z + (spell_length*tile_offset)
		
		'up':
			target_pos.x = parent.translation.x + (spell_length*tile_offset)
			target_pos.z = parent.translation.z
		'down':
			target_pos.x = parent.translation.x - (spell_length*tile_offset)
			target_pos.z = parent.translation.z
		'left':
			target_pos.x = parent.translation.x
			target_pos.z = parent.translation.z - (spell_length*tile_offset)
		'right':
			target_pos.x = parent.translation.x
			target_pos.z = parent.translation.z + (spell_length*tile_offset)

func check_if_dashable():
	var start_tile = parent.get_map_pos()
	var dash_valid = check_if_dir_clear(start_tile)
	
	if !dash_valid: return false
	
	match direction_facing: # check secondary tile
		'upleft':
			dash_valid = check_if_dir_clear([start_tile[0]+1, start_tile[0]-1])
			end_tile = [start_tile[0]+2, start_tile[0]-2]
		'upright': 
			dash_valid = check_if_dir_clear([start_tile[0]+1, start_tile[0]+1])
			end_tile = [start_tile[0]+2, start_tile[0]+2]
		'downleft': 
			dash_valid = check_if_dir_clear([start_tile[0]-1, start_tile[0]-1])
			end_tile = [start_tile[0]-2, start_tile[0]-2]
		'downright': 
			dash_valid = check_if_dir_clear([start_tile[0]-1, start_tile[0]+1])
			end_tile = [start_tile[0]-2, start_tile[0]+2]
		'up':
			dash_valid = check_if_dir_clear([start_tile[0]+1, start_tile[0]])
			end_tile = [start_tile[0]+2, start_tile[0]]
		'down':
			dash_valid = check_if_dir_clear([start_tile[0]-1, start_tile[0]])
			end_tile = [start_tile[0]-2, start_tile[0]]
		'left':
			dash_valid = check_if_dir_clear([start_tile[0], start_tile[0]-1])
			end_tile = [start_tile[0]-2, start_tile[0]]
		'right':
			dash_valid = check_if_dir_clear([start_tile[0], start_tile[0]+1])
			end_tile = [start_tile[0]+2, start_tile[0]]
	
	if dash_valid: return true
	
func check_if_dir_clear(curr_tile) -> bool:
	var dir_clear = true
	
	match direction_facing:
		'upleft':
			if map.is_tile_wall(curr_tile[0]+1,curr_tile[1]): dir_clear = false
			if map.is_tile_wall(curr_tile[0],curr_tile[1]-1): dir_clear = false
			if !map.tile_available(curr_tile[0]+1, curr_tile[1]-1): dir_clear = false
		'upright': 
			if map.is_tile_wall(curr_tile[0]+1,curr_tile[1]): dir_clear = false
			if map.is_tile_wall(curr_tile[0],curr_tile[1]+1): dir_clear = false
			if !map.tile_available(curr_tile[0]+1, curr_tile[1]+1): dir_clear = false
		'downleft': 
			if map.is_tile_wall(curr_tile[0]-1,curr_tile[1]): dir_clear = false
			if map.is_tile_wall(curr_tile[0],curr_tile[1]-1): dir_clear = false
			if !map.tile_available(curr_tile[0]-1, curr_tile[1]-1): dir_clear = false
		'downright': 
			if map.is_tile_wall(curr_tile[0]-1,curr_tile[1]): dir_clear = false
			if map.is_tile_wall(curr_tile[0],curr_tile[1]+1): dir_clear = false
			if !map.tile_available(curr_tile[0]-1, curr_tile[1]+1): dir_clear = false
		
		'up':
			if !map.tile_available(curr_tile[0]+1, curr_tile[1]): dir_clear = false
		'down':
			if !map.tile_available(curr_tile[0]-1, curr_tile[1]): dir_clear = false	
		'left':
			if !map.tile_available(curr_tile[0], curr_tile[1]-1): dir_clear = false
		'right':
			if !map.tile_available(curr_tile[0], curr_tile[1]+1): dir_clear = false
			
	return dir_clear

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
var start_tile = []

# Spell variables
var spell_cost = 20
var spell_length = 2

func _ready():
	tile_offset = map.TILE_OFFSET

func _on_Actions_spell_cast_dash():
	use()
# Main functionality of the spell
func use():
	parent = find_parent('Actions').get_parent()
	if parent:
		if mana_check():
			direction_facing = parent.get_direction_facing()
			start_tile = parent.get_map_pos()
			if check_if_dashable():
				parent.manual_move_char(2)

# Check if out of mana
func mana_check() -> bool:
	if parent.get('mp') and parent.get('mp') < spell_cost:
		out_of_mana.play()
		return false
		
	# Update mana
	elif parent.get('mp'):
		parent.mp -= spell_cost
	return true

func check_if_dashable():
	var dash_valid = check_if_dir_clear(start_tile)
	
	if !dash_valid: return false
	
	match direction_facing: # check secondary tile
		'upleft':
			dash_valid = check_if_dir_clear([start_tile[0]+1, start_tile[1]-1])
			end_tile = [start_tile[0]+2, start_tile[1]-2]
		'upright': 
			dash_valid = check_if_dir_clear([start_tile[0]+1, start_tile[1]+1])
			end_tile = [start_tile[0]+2, start_tile[1]+2]
		'downleft': 
			dash_valid = check_if_dir_clear([start_tile[0]-1, start_tile[1]-1])
			end_tile = [start_tile[0]-2, start_tile[1]-2]
		'downright': 
			dash_valid = check_if_dir_clear([start_tile[0]-1, start_tile[1]+1])
			end_tile = [start_tile[0]-2, start_tile[1]+2]
		'up':
			dash_valid = check_if_dir_clear([start_tile[0]+1, start_tile[1]])
			end_tile = [start_tile[0]+2, start_tile[1]]
		'down':
			dash_valid = check_if_dir_clear([start_tile[0]-1, start_tile[1]])
			end_tile = [start_tile[0]-2, start_tile[1]]
		'left':
			dash_valid = check_if_dir_clear([start_tile[0], start_tile[1]-1])
			end_tile = [start_tile[0], start_tile[1]-2]
		'right':
			dash_valid = check_if_dir_clear([start_tile[0], start_tile[1]+1])
			end_tile = [start_tile[0], start_tile[1]+2]
	
	if dash_valid: 
		return true
	
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

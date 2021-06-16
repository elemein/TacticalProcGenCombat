extends Node

# Get required nodes
onready var map = get_node("/root/World/Map")
onready var turn_timer = get_node("/root/World/TurnTimer")

# Sound effects
onready var UseSpell = $UseSpell
onready var out_of_mana = $out_of_mana

# Visual assets
var effects_fire = preload("res://Assets/Objects/Effects/Fire/Fire.tscn")

# Misc variables
var target_pos = Vector3()
var tile_offset = null
var effect = null
var parent = null
var direction_facing = null
var map_pos = null

# Spell variables
var spell_power = 20
var spell_cost = 25
var spell_length = 3

func _ready():
	tile_offset = map.TILE_OFFSET
	
# Move the parent every frame
func _physics_process(_delta):
	if effect != null:
		if parent.get_turn_anim_timer().time_left > 0:
			var interp_mod = parent.get_turn_anim_timer().time_left / parent.get_turn_anim_timer().get_wait_time()
			effect.translation = effect.translation.linear_interpolate(target_pos, 1-interp_mod) 
		else:
			get_node('Fire').queue_free()
			remove_child(get_node('Fire'))
			effect = null

# Main functionality of the spell
func use():
	parent = find_parent('Actions').get_parent()
	if parent:
		if mana_check():
			UseSpell.play()
			create_spell_instance()
			set_target_pos()
			set_power()
			do_damage()

func set_power():
	spell_power = parent.get_spell_power()

# Check if out of mana
func mana_check() -> bool:
	if parent.get_mp() and parent.get_mp() < spell_cost:
		out_of_mana.play()
		return false
		
	# Update mana
	elif parent.get_mp():
		parent.set_mp(parent.get_mp() - spell_cost)
	return true

# Spawn in the spell
func create_spell_instance():
	effect = effects_fire.instance()
	add_child(effect)
	effect.translation.x = parent.translation.x
	effect.translation.z = parent.translation.z

# Set the destination tile
func set_target_pos():
	direction_facing = parent.direction_facing

	target_pos = Vector3(0, 0.3, 0)

	match direction_facing:
		'upleft':
			effect.rotation_degrees.y = 90 + 45
			target_pos.x = effect.translation.x + (spell_length*tile_offset)
			target_pos.z = effect.translation.z - (spell_length*tile_offset)
		'upright':
			effect.rotation_degrees.y = 90 - 45
			target_pos.x = effect.translation.x + (spell_length*tile_offset)
			target_pos.z = effect.translation.z + (spell_length*tile_offset)
		'downleft':
			effect.rotation_degrees.y = 180 + 45
			target_pos.x = effect.translation.x - (spell_length*tile_offset)
			target_pos.z = effect.translation.z - (spell_length*tile_offset)
		'downright':
			effect.rotation_degrees.y = 315
			target_pos.x = effect.translation.x - (spell_length*tile_offset)
			target_pos.z = effect.translation.z + (spell_length*tile_offset)
		
		'up':
			effect.rotation_degrees.y = 90
			target_pos.x = effect.translation.x + (spell_length*tile_offset)
			target_pos.z = effect.translation.z
		'down':
			effect.rotation_degrees.y = 270
			target_pos.x = effect.translation.x - (spell_length*tile_offset)
			target_pos.z = effect.translation.z
		'left':
			effect.rotation_degrees.y = 180
			target_pos.x = effect.translation.x
			target_pos.z = effect.translation.z - (spell_length*tile_offset)
		'right':
			effect.rotation_degrees.y = 0
			target_pos.x = effect.translation.x
			target_pos.z = effect.translation.z + (spell_length*tile_offset)

# Get information for all of the tiles that will get hit by the spell
func get_target_tiles() -> Array:
	var target_tiles = []
	map_pos = parent.map_pos

	for tile_num in spell_length:
		match direction_facing:
			'upleft':
				if typeof(map.get_tile_contents(map_pos[0] + 1 + tile_num, map_pos[1] - 1 - tile_num)) != TYPE_STRING:
					target_tiles.append([map_pos[0] + 1 + tile_num, map_pos[1] - 1 - tile_num])
			'upright':
				if typeof(map.get_tile_contents(map_pos[0] + 1 + tile_num, map_pos[1] + 1 + tile_num)) != TYPE_STRING:
					target_tiles.append([map_pos[0] + 1 + tile_num, map_pos[1] + 1 + tile_num])
			'downleft':
				if typeof(map.get_tile_contents(map_pos[0] - 1 - tile_num, map_pos[1] - 1 - tile_num)) != TYPE_STRING:
					target_tiles.append([map_pos[0] - 1 - tile_num, map_pos[1] - 1 - tile_num])
			'downright':
				if typeof(map.get_tile_contents(map_pos[0] - 1 - tile_num, map_pos[1] + 1 + tile_num)) != TYPE_STRING:
					target_tiles.append([map_pos[0] - 1 - tile_num, map_pos[1] + 1 + tile_num])
			
			'up':
				if typeof(map.get_tile_contents(map_pos[0] + 1 + tile_num, map_pos[1])) != TYPE_STRING:
					target_tiles.append([map_pos[0] + 1 + tile_num, map_pos[1]])
			'down':
				if typeof(map.get_tile_contents(map_pos[0] - 1 - tile_num, map_pos[1])) != TYPE_STRING:
					target_tiles.append([map_pos[0] - 1 - tile_num, map_pos[1]])
			'left':
				if typeof(map.get_tile_contents(map_pos[0], map_pos[1] - 1 - tile_num)) != TYPE_STRING:
					target_tiles.append([map_pos[0], map_pos[1] - 1 - tile_num])
			'right':
				if typeof(map.get_tile_contents(map_pos[0], map_pos[1] + 1 + tile_num)) != TYPE_STRING:
					target_tiles.append([map_pos[0], map_pos[1] + 1 + tile_num])
	return target_tiles

# Actually inflict damage on the target tiles
func do_damage():
	for target_tile in get_target_tiles():
		var objects_on_tile = map.get_tile_contents(target_tile[0], target_tile[1])

		for object in objects_on_tile:
			if object.get_obj_type() in ['Enemy', 'Player']:
				object.take_damage(spell_power)

func _on_Actions_spell_cast_fireball():
	use()

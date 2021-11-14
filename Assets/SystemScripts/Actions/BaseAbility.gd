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
	self.parent = find_parent("Actions").get_parent()

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
	Server.update_actor_stat(self.parent.get_id(), {"Stat": "HP", "Modifier": self.spell_final_power})
	Server.actor_notif_event(self.parent.get_id(), ("+" + str(self.spell_final_power)), 'heal')

func play_audio():
	self.UseSpell = find_node('UseSpell')
	if self.UseSpell != null and not UseSpell.is_playing():
		self.UseSpell.translation = self.parent.translation
		self.UseSpell.play()

func set_power():
	self.spell_final_power = self.parent.get_spell_power() + spell_power

func set_attack_power():
	self.spell_final_attack_power = self.parent.get_attack_power() + attack_power

# Check if out of mana
func mana_check() -> bool:
	if self.parent.get_mp() and parent.get_mp() < self.spell_cost:
		return false
	return true

# Spawn in the spell
func create_spell_instance():
	self.effect = self.visual_effect.instance()
	self.effect.name = self.spell_name
	add_child(self.effect)
	self.effect.translation = self.parent.translation + Vector3(0, self.effect_start_height, 0)

# Set the destination tile
func set_target_spell_pos():
	self.direction_facing = self.parent.direction_facing

	self.target_spell_pos = Vector3(0, 0, 0)

	match self.direction_facing:
		'upleft':
			self.effect.rotation_degrees.y = 90 + 45
			self.target_spell_pos.x = self.effect.translation.x + (self.spell_length*self.tile_offset)
			self.target_spell_pos.z = self.effect.translation.z - (self.spell_length*self.tile_offset)
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
		'upright':
			self.effect.rotation_degrees.y = 90 - 45
			self.target_spell_pos.x = self.effect.translation.x + (self.spell_length*self.tile_offset)
			self.target_spell_pos.z = self.effect.translation.z + (self.spell_length*self.tile_offset)
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
		'downleft':
			self.effect.rotation_degrees.y = 270 - 45
			self.target_spell_pos.x = self.effect.translation.x - (self.spell_length*self.tile_offset)
			self.target_spell_pos.z = self.effect.translation.z - (self.spell_length*self.tile_offset)
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
		'downright':
			self.effect.rotation_degrees.y = 270 + 45
			self.target_spell_pos.x = self.effect.translation.x - (self.spell_length*self.tile_offset)
			self.target_spell_pos.z = self.effect.translation.z + (self.spell_length*self.tile_offset)
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
					
		'up':
			self.effect.rotation_degrees.y = 90
			self.target_spell_pos.x = self.effect.translation.x + (self.spell_length*self.tile_offset)
			self.target_spell_pos.z = self.effect.translation.z
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
		'down':
			self.effect.rotation_degrees.y = 270
			self.target_spell_pos.x = self.effect.translation.x - (self.spell_length*self.tile_offset)
			self.target_spell_pos.z = self.effect.translation.z
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
		'left':
			self.effect.rotation_degrees.y = 180
			self.target_spell_pos.x = self.effect.translation.x
			self.target_spell_pos.z = self.effect.translation.z - (self.spell_length*self.tile_offset)
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
		'right':
			self.effect.rotation_degrees.y = 0
			self.target_spell_pos.x = self.effect.translation.x
			self.target_spell_pos.z = self.effect.translation.z + (self.spell_length*self.tile_offset)
			self.target_spell_pos.y = self.effect.translation.y + (self.effect_end_height - self.effect_start_height)
			
# Set the destination tile
func set_target_actor_pos():
	self.direction_facing = self.parent.direction_facing
	self.saved_actor_pos = self.parent.translation

	match self.direction_facing:
		'upleft':
			self.target_actor_pos.x = self.saved_actor_pos.x + (self.spell_length*self.tile_offset)
			self.target_actor_pos.z = self.saved_actor_pos.z - (self.spell_length*self.tile_offset)
		'upright':
			self.target_actor_pos.x = self.saved_actor_pos.x + (self.spell_length*self.tile_offset)
			self.target_actor_pos.z = self.saved_actor_pos.z + (self.spell_length*self.tile_offset)
		'downleft':
			self.target_actor_pos.x = self.saved_actor_pos.x - (self.spell_length*self.tile_offset)
			self.target_actor_pos.z = self.saved_actor_pos.z - (self.spell_length*self.tile_offset)
		'downright':
			self.target_actor_pos.x = self.saved_actor_pos.x - (self.spell_length*self.tile_offset)
			self.target_actor_pos.z = self.saved_actor_pos.z + (self.spell_length*self.tile_offset)
		
		'up':
			self.target_actor_pos.x = self.saved_actor_pos.x + (self.spell_length*self.tile_offset)
			self.target_actor_pos.z = self.saved_actor_pos.z
		'down':
			self.target_actor_pos.x = self.saved_actor_pos.x - (self.spell_length*self.tile_offset)
			self.target_actor_pos.z = self.saved_actor_pos.z
		'left':
			self.target_actor_pos.x = self.saved_actor_pos.x
			self.target_actor_pos.z = self.saved_actor_pos.z - (self.spell_length*self.tile_offset)
		'right':
			self.target_actor_pos.x = self.saved_actor_pos.x
			self.target_actor_pos.z = self.saved_actor_pos.z + (self.spell_length*self.tile_offset)

# Get information for all of the tiles that will get hit by the spell
func get_target_tiles() -> Array:
	var target_tiles = []
	var target_tile_contents = []
	self.map_pos = self.parent.map_pos

	for tile_num in self.spell_length:
		match self.direction_facing:
			'upleft':
				target_tiles.append([self.map_pos[0] + 1 + tile_num, map_pos[1] - 1 - tile_num])
			'upright':
				target_tiles.append([self.map_pos[0] + 1 + tile_num, map_pos[1] + 1 + tile_num])
			'downleft':
				target_tiles.append([self.map_pos[0] - 1 - tile_num, map_pos[1] - 1 - tile_num])
			'downright':
				target_tiles.append([self.map_pos[0] - 1 - tile_num, map_pos[1] + 1 + tile_num])
			
			'up':
				target_tiles.append([self.map_pos[0] + 1 + tile_num, map_pos[1]])
			'down':
				target_tiles.append([self.map_pos[0] - 1 - tile_num, map_pos[1]])
			'left':
				target_tiles.append([self.map_pos[0], map_pos[1] - 1 - tile_num])
			'right':
				target_tiles.append([self.map_pos[0], map_pos[1] + 1 + tile_num])
	
	for target_tile in target_tiles:
		target_tile_contents.append(self.map.get_tile_contents(target_tile[0], target_tile[1]))
	return target_tile_contents

# Actually inflict damage on the target tiles
func do_damage(amount, variance, attacker):
	var is_crit = self.rng.randi_range(0,100) < self.parent.get_crit_chance()
	
	var damage_percentage = (100 - self.rng.randf_range(0, variance)) / 100
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

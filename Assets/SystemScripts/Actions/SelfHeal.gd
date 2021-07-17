extends Node

const TILE_OFFSET = 2.1

# Get required nodes
onready var turn_timer = get_node("/root/World/TurnTimer")

# Sound effects
onready var UseSpell = $UseSpell
onready var out_of_mana = $out_of_mana

# Visual assets
var effects_heal = preload("res://Assets/Objects/Effects/Heal/Heal.tscn")

# Misc variables
var target_pos = Vector3()
var tile_offset = null
var effect = null
var parent = null
var direction_facing = null
var map_pos = null
var map

# Spell variables
var spell_power = 0
var spell_cost = 40

func _ready():
	tile_offset = TILE_OFFSET
	
# Move the parent every frame
func _physics_process(_delta):
	if effect != null:
		if parent.get_turn_anim_timer().time_left > 0:
			var interp_mod = parent.get_turn_anim_timer().time_left / parent.get_turn_anim_timer().get_wait_time()
			effect.translation = effect.translation.linear_interpolate(target_pos, 1-interp_mod) 
		else:
			get_node('Heal').queue_free()
			remove_child(get_node('Heal'))
			effect = null

# Main functionality of the spell
func use():
	parent = find_parent('Actions').get_parent()
	map = parent.get_parent_map()
	if parent:
		if mana_check():
			UseSpell.play()
			create_spell_instance()
			target_pos = parent.get_translation()
			set_power()
			heal_user()

func set_power():
	spell_power = parent.get_spell_power()

func heal_user():
	parent.set_hp(parent.get_hp() + spell_power)

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
	effect = effects_heal.instance()
	add_child(effect)
	effect.translation = parent.get_translation()
	effect.translation.y += 8

func _on_Actions_spell_cast_self_heal():
	use()

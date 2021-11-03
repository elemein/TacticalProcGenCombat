extends MarginContainer


onready var actions = find_parent('StatusBar').find_node('Actions')

onready var icon = find_node('Icon')
onready var button = find_node('Button')
onready var cost = find_node('Cost')
onready var power = find_node('Power')

var icon_path_beg = "res://Assets/GUI/StatusBar/"
var icon_path_end = "_x76.png"
var icon_path = null

var base_spell_cost = 0
var base_spell_power = 0
var spell_cost = 0
var spell_power = 0
var spell_button = ''
var spell_description = ''
var uses_any_power = true
var uses_attack_power = false

func _ready():
	var _result = Signals.connect("player_attack_power_updated", self, "update_attack_power")
	_result = Signals.connect("player_spell_power_updated", self, "update_spell_power")

func set_info(ability_name):
	name = ability_name
	match name:
		'BasicAttackAbility':
			icon_path = icon_path_beg + 'Basic_Attack' + icon_path_end
			base_spell_cost = actions.find_node('BasicAttack').spell_cost
			base_spell_power = actions.find_node('BasicAttack').attack_power
			spell_description = actions.find_node('BasicAttack').spell_description
			spell_button = 'Space'
			uses_attack_power = true
		'FireballAbility':
			icon_path = icon_path_beg + 'Fireball' + icon_path_end
			base_spell_cost = actions.find_node('Fireball').spell_cost
			base_spell_power = actions.find_node('Fireball').spell_power
			spell_description = actions.find_node('Fireball').spell_description
			spell_button = 'E'
		'DashAbility':
			icon_path = icon_path_beg + 'Dash' + icon_path_end
			base_spell_cost = actions.find_node('Dash').spell_cost
			base_spell_power = actions.find_node('Dash').spell_power
			spell_description = actions.find_node('Dash').spell_description
			spell_button = 'R'
			uses_any_power = false
		'SelfHealAbility':
			icon_path = icon_path_beg + 'Self_Heal' + icon_path_end
			base_spell_cost = actions.find_node('SelfHeal').spell_cost
			base_spell_power = actions.find_node('SelfHeal').spell_power
			spell_description = actions.find_node('SelfHeal').spell_description
			spell_button = 'T'
			
	if icon_path != null:
		icon.texture = load(icon_path)
		
	button.text = spell_button
	cost.text = str(base_spell_cost + spell_cost)
	power.text = str(base_spell_power + spell_power)
	
func update_attack_power(val):
	if not uses_any_power:
		power.text = '-'
		return
	if uses_attack_power:
		spell_power = val
		power.text = str(base_spell_power + spell_power)

func update_spell_power(val):
	if not uses_any_power:
		power.text = '-'
		return
	if not uses_attack_power:
		spell_power = val
		power.text = str(base_spell_power + spell_power)

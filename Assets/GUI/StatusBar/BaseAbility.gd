extends MarginContainer


onready var actions = find_parent('StatusBar').find_node('Actions')

onready var icon = find_node('Icon')
onready var button = find_node('Button')
onready var cost = find_node('Cost')
onready var power = find_node('Power')

var icon_path_beg = "res://Assets/GUI/StatusBar/"
var icon_path_end = "_x76.png"
var icon_path = null

var spell_cost = 0
var spell_power = 0
var spell_button = ''


func set_info(ability_name):
	name = ability_name
	match name:
		'BasicAttackAbility':
			icon_path = icon_path_beg + 'Basic_Attack' + icon_path_end
			spell_cost = actions.find_node('BasicAttack').spell_cost
			spell_power = actions.find_node('BasicAttack').attack_power
			spell_button = 'Space'
		'FireballAbility':
			icon_path = icon_path_beg + 'Fireball' + icon_path_end
			spell_cost = actions.find_node('Fireball').spell_cost
			spell_power = actions.find_node('Fireball').spell_power
			spell_button = 'E'
		'DashAbility':
			icon_path = icon_path_beg + 'Dash' + icon_path_end
			spell_cost = actions.find_node('Dash').spell_cost
			spell_power = actions.find_node('Dash').spell_power
			spell_button = 'R'
		'SelfHealAbility':
			icon_path = icon_path_beg + 'Self_Heal' + icon_path_end
			spell_cost = actions.find_node('SelfHeal').spell_cost
			spell_power = actions.find_node('SelfHeal').spell_power
			spell_button = 'T'
			
	if icon_path != null:
		icon.texture = load(icon_path)
		
	button.text = spell_button
	cost.text = str(spell_cost)
	power.text = str(spell_power)

extends MarginContainer


onready var actions = find_parent('StatusBar').find_node('Actions')

onready var icon = find_node('Icon')
onready var button = find_node('Button')
onready var cost = find_node('Cost')
onready var power = find_node('Power')

var icon_path_beg = "res://Gui/Objects/Icons/Abilities/"
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
			self.icon_path = self.icon_path_beg + 'Basic_Attack' + self.icon_path_end
			self.base_spell_cost = self.actions.find_node('BasicAttack').spell_cost
			self.base_spell_power = self.actions.find_node('BasicAttack').attack_power
			self.spell_description = self.actions.find_node('BasicAttack').spell_description
			self.spell_button = 'Space'
			self.uses_attack_power = true
		'FireballAbility':
			self.icon_path = self.icon_path_beg + 'Fireball' + self.icon_path_end
			self.base_spell_cost = self.actions.find_node('Fireball').spell_cost
			self.base_spell_power = self.actions.find_node('Fireball').spell_power
			self.spell_description = self.actions.find_node('Fireball').spell_description
			self.spell_button = 'E'
		'DashAbility':
			self.icon_path = self.icon_path_beg + 'Dash' + self.icon_path_end
			self.base_spell_cost = self.actions.find_node('Dash').spell_cost
			self.base_spell_power = self.actions.find_node('Dash').spell_power
			self.spell_description = self.actions.find_node('Dash').spell_description
			self.spell_button = 'R'
			self.uses_any_power = false
		'SelfHealAbility':
			self.icon_path = self.icon_path_beg + 'Self_Heal' + self.icon_path_end
			self.base_spell_cost = self.actions.find_node('SelfHeal').spell_cost
			self.base_spell_power = self.actions.find_node('SelfHeal').spell_power
			self.spell_description = self.actions.find_node('SelfHeal').spell_description
			self.spell_button = 'T'
			
	if self.icon_path != null:
		self.icon.texture = load(self.icon_path)
		
	self.button.text = self.spell_button
	self.cost.text = str(self.base_spell_cost + self.spell_cost)
	self.power.text = str(self.base_spell_power + self.spell_power)
	
func update_attack_power(val):
	if not self.uses_any_power:
		self.cost.text = '-'
		return
	if self.uses_attack_power:
		self.spell_power = val
		self.cost.text = str(self.base_spell_power + self.spell_power)

func update_spell_power(val):
	if not self.uses_any_power:
		self.cost.text = '-'
		return
	if not self.uses_attack_power:
		self.spell_power = val
		self.cost.text = str(self.base_spell_power + self.spell_power)

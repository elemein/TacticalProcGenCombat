extends TextureButton


onready var ability_description = find_parent('AbilityInfo')
onready var actions = find_parent('Node').find_node('Actions')

onready var hovered_border = find_node('Hovered')
onready var locked_in_border = find_node('LockedIn')
onready var disabled_border = find_node('Disabled')

var icon_path_beg = "res://Gui/Objects/Icons/Abilities/"
var icon_path_end = "_x76.png"
var icon_path = null

var ability_text = ''
var ability_names = {'BasicAttackAbility': 'BasicAttack', 
					 'FireballAbility': 'Fireball',
					 'DashAbility': 'Dash',
					 'SelfHealAbility': 'SelfHeal'}


func _ready():
	self.ability_description = self.ability_description.find_node('AbilityDescription')
	match name:
		'BasicAttackAbility':
			self.icon_path = self.icon_path_beg + 'Basic_Attack' + self.icon_path_end
		'FireballAbility':
			self.icon_path = self.icon_path_beg + 'Fireball' + self.icon_path_end
		'DashAbility':
			self.icon_path = self.icon_path_beg + 'Dash' + self.icon_path_end
		'SelfHealAbility':
			self.icon_path = self.icon_path_beg + 'Self_Heal' + self.icon_path_end
			
	if self.icon_path != null:
		texture_normal = load(self.icon_path)

func set_disabled(disabled_status):
	if not disabled_status:
		disabled = false
		self.disabled_border.visible = false
	else:
		disabled = true
		self.disabled_border.visible = true

func _on_TextureButton_mouse_entered():
	if not is_pressed() and not disabled:
		self.hovered_border.visible = true
	self.ability_description.text = self.actions.find_node(self.ability_names[name]).spell_description

func _on_TextureButton_mouse_exited():
	self.hovered_border.visible = false

func _on_TextureButton_pressed():
	self.locked_in_border.visible = not self.locked_in_border.visible

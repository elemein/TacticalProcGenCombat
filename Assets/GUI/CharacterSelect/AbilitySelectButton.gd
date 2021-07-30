extends TextureButton


onready var ability_description = find_parent('AbilityInfo')
onready var actions = find_parent('Node').find_node('Actions')

onready var hovered_border = find_node('Hovered')
onready var locked_in_border = find_node('LockedIn')
onready var disabled_border = find_node('Disabled')

var icon_path_beg = "res://Assets/GUI/StatusBar/"
var icon_path_end = "_x76.png"
var icon_path = null

var ability_text = ''
var ability_names = {'BasicAttackAbility': 'BasicAttack', 
					 'FireballAbility': 'Fireball',
					 'DashAbility': 'Dash',
					 'SelfHealAbility': 'SelfHeal'}


func _ready():
	ability_description = ability_description.find_node('AbilityDescription')
	match name:
		'BasicAttackAbility':
			icon_path = icon_path_beg + 'Basic_Attack' + icon_path_end
		'FireballAbility':
			icon_path = icon_path_beg + 'Fireball' + icon_path_end
		'DashAbility':
			icon_path = icon_path_beg + 'Dash' + icon_path_end
		'SelfHealAbility':
			icon_path = icon_path_beg + 'Self_Heal' + icon_path_end
			
	if icon_path != null:
		texture_normal = load(icon_path)

func set_disabled(disabled_status):
	if not disabled_status:
		disabled = false
		disabled_border.visible = false
	else:
		disabled = true
		disabled_border.visible = true

func _on_TextureButton_mouse_entered():
	if not is_pressed() and not disabled:
		hovered_border.visible = true
	ability_description.text = actions.find_node(ability_names[name]).spell_description

func _on_TextureButton_mouse_exited():
	hovered_border.visible = false

func _on_TextureButton_pressed():
	locked_in_border.visible = not locked_in_border.visible

extends Control


onready var ability_1 = find_node('Ability1')
onready var ability_2 = find_node('Ability2')
onready var ability_3 = find_node('Ability3')

onready var ability_info = find_node('AbilityInfo')
onready var status_bar_container = find_node('StatusBarContainer')

onready var health_bar = find_node('Health').find_node('ProgressBar2D')
onready var health_text = find_node('Health').find_node('StatIndicator')
onready var mana_bar = find_node('Mana').find_node('ProgressBar2D')
onready var mana_text = find_node('Mana').find_node('StatIndicator')

var ability_info_size = null


func _ready():
	ability_1.set_info(PlayerInfo.abilities[0])
	ability_2.set_info(PlayerInfo.abilities[1])
	ability_3.set_info(PlayerInfo.abilities[2])
	
	var _result = ability_1.connect("mouse_entered", self, "update_ability_info_panel", [ ability_1 ])
	_result = ability_2.connect("mouse_entered", self, "update_ability_info_panel", [ ability_2 ])
	_result = ability_3.connect("mouse_entered", self, "update_ability_info_panel", [ ability_3 ])
	_result = ability_1.connect("mouse_exited", self, "_on_mouse_exited")
	_result = ability_2.connect("mouse_exited", self, "_on_mouse_exited")
	_result = ability_3.connect("mouse_exited", self, "_on_mouse_exited")
	ability_info.visible = false
	ability_info_size = ability_info.get_size()
	
	yield(get_tree(), "idle_frame")
	_on_GUI_set_status_bars(GlobalVars.get_self_obj().start_stats)


func _on_GUI_set_status_bars(stats):
	health_bar.value = stats['HP']
	health_bar.max_value = stats['Max HP']
	health_text.text = str(stats['HP']) + '/' + str(stats['Max HP'])
	
	mana_bar.value = stats['MP']
	mana_bar.max_value = stats['Max MP']
	mana_text.text = str(stats['MP']) + '/' + str(stats['Max MP'])


func _on_GUI_update_health_bar(hp, max_hp):
	health_bar.value = hp
	health_bar.max_value = max_hp
	health_text.text = str(hp) + '/' + str(max_hp)


func _on_GUI_update_mana_bar(mp, max_mp):
	mana_bar.value = mp
	mana_bar.max_value = max_mp
	mana_text.text = str(mp) + '/' + str(max_mp)
	
	
func update_ability_info_panel(ability_box):
	ability_info.text = ability_box.spell_description
	ability_info.visible = true
	var new_x = ability_box.get_position().x - int(ability_box.get_size().x / 2)
	var new_y = ability_box.get_position().y + status_bar_container.rect_position.y - ability_info_size.y - 10
	ability_info.set_position(Vector2(new_x, new_y))
	
func _on_mouse_exited():
	ability_info.visible = false

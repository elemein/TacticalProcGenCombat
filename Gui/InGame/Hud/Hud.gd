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
	self.ability_1.set_info(PlayerInfo.abilities[0])
	self.ability_2.set_info(PlayerInfo.abilities[1])
	self.ability_3.set_info(PlayerInfo.abilities[2])
	
	var _result = self.ability_1.connect("mouse_entered", self, "update_ability_info_panel", [ self.ability_1 ])
	_result = self.ability_2.connect("mouse_entered", self, "update_ability_info_panel", [ self.ability_2 ])
	_result = self.ability_3.connect("mouse_entered", self, "update_ability_info_panel", [ self.ability_3 ])
	_result = self.ability_1.connect("mouse_exited", self, "_on_mouse_exited")
	_result = self.ability_2.connect("mouse_exited", self, "_on_mouse_exited")
	_result = self.ability_3.connect("mouse_exited", self, "_on_mouse_exited")
	self.ability_info.visible = false
	self.ability_info_size = self.ability_info.get_size()
	
	yield(get_tree(), "idle_frame")
	_on_GUI_set_status_bars(GlobalVars.get_self_obj().start_stats)


func _on_GUI_set_status_bars(stats):
	self.health_bar.value = stats['HP']
	self.health_bar.max_value = stats['Max HP']
	self.health_text.text = str(stats['HP']) + '/' + str(stats['Max HP'])
	
	self.mana_bar.value = stats['MP']
	self.mana_bar.max_value = stats['Max MP']
	self.mana_text.text = str(stats['MP']) + '/' + str(stats['Max MP'])


func _on_GUI_update_health_bar(hp, max_hp):
	self.health_bar.value = hp
	self.health_bar.max_value = max_hp
	self.health_text.text = str(hp) + '/' + str(max_hp)


func _on_GUI_update_mana_bar(mp, max_mp):
	self.mana_bar.value = mp
	self.mana_bar.max_value = max_mp
	self.mana_text.text = str(mp) + '/' + str(max_mp)
	
	
func update_ability_info_panel(ability_box):
	self.ability_info.text = ability_box.spell_description
	self.ability_info.visible = true
	var new_x = ability_box.get_position().x - int(ability_box.get_size().x / 2)
	var new_y = ability_box.get_position().y + self.status_bar_container.rect_position.y - self.ability_info_size.y - 10
	self.ability_info.set_position(Vector2(new_x, new_y))
	
func _on_mouse_exited():
	self.ability_info.visible = false

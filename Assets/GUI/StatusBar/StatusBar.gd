extends Control


onready var ability_1 = find_node('Ability1')
onready var ability_2 = find_node('Ability2')
onready var ability_3 = find_node('Ability3')

signal set_health_bar(hp_current, hp_max)
signal set_mana_bar(mp_current, mp_max)


func _ready():
	ability_1.set_info(PlayerInfo.abilities[0])
	ability_2.set_info(PlayerInfo.abilities[1])
	ability_3.set_info(PlayerInfo.abilities[2])


func _on_GUI_set_status_bars(stats):
	emit_signal("set_health_bar", stats['HP'], stats['Max HP'])
	emit_signal("set_mana_bar", stats['MP'], stats['Max MP'])


func _on_GUI_update_health_bar(hp, max_hp):
	emit_signal("set_health_bar", hp, max_hp)


func _on_GUI_update_mana_bar(mp, max_mp):
	emit_signal("set_mana_bar", mp, max_mp)

extends Control

signal set_health_bar(hp_current, hp_max)
signal set_mana_bar(mp_current, mp_max)


func _on_GUI_set_status_bars(stats):
	emit_signal("set_health_bar", stats['HP'], stats['Max HP'])
	emit_signal("set_mana_bar", stats['MP'], stats['Max MP'])


func _on_GUI_update_health_bar(hp, max_hp):
	emit_signal("set_health_bar", hp, max_hp)


func _on_GUI_update_mana_bar(mp, max_mp):
	emit_signal("set_mana_bar", mp, max_mp)

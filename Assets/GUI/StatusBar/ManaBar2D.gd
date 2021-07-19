extends MarginContainer

signal set_mana_bar(mp_current, mp_max)


func _on_StatusBar_set_mana_bar(mp_current, mp_max):
	emit_signal("set_mana_bar", mp_current, mp_max)

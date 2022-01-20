extends Control

signal set_status_bars(stats)
signal update_health_bar(hp, max_hp)
signal update_mana_bar(mp, max_hp)

func _on_Player_prepare_gui(stats):
	emit_signal("set_status_bars", stats)


func _on_Player_status_bar_mp(mp, max_mp):
	emit_signal("update_mana_bar", mp, max_mp)


func _on_Player_status_bar_hp(hp, max_hp):
	emit_signal("update_health_bar", hp, max_hp)

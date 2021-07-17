extends MarginContainer

signal set_health_bar(hp_current, hp_max)


func _on_StatusBar_set_health_bar(hp_current, hp_max):
	emit_signal("set_health_bar", hp_current, hp_max)

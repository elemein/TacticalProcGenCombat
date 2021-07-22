extends TextureProgress

signal update_text(string)

func set_text():
	emit_signal("update_text", str(value) + "/" + str(max_value))


func _on_HealthBar2D_set_health_bar(hp_current, hp_max):
	value = hp_current
	max_value = hp_max
	set_text()

		
func _on_ManaBar2D_set_mana_bar(mp_current, mp_max):
	value = mp_current
	max_value = mp_max
	set_text()

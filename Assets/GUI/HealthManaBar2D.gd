extends Control

onready var health_bar = $HealthBar
onready var mana_bar = $ManaBar

signal set_health_current(amount)
signal set_health_max(amount)
signal set_mana_current(amount)
signal set_mana_max(amount)


func _ready():
	# Get and set the max health
	if get_parent() and get_parent().get("max_hp"):
		emit_signal("set_health_max", get_parent().max_hp)
		
	# Get and set the max mana
	if get_parent() and get_parent().get("max_mp"):
		emit_signal("set_mana_max", get_parent().max_mp)

func update_health_bar(amount, full):
	emit_signal("set_health_current", amount)
	emit_signal("set_health_max", full)
	
func update_mana_bar(amount, full):
	emit_signal("set_mana_current", amount)
	emit_signal("set_mana_max", full)


func _on_HealthBar3D_status_bar_hp(hp, max_hp):
	update_health_bar(hp, max_hp)

func _on_HealthBar3D_status_bar_mp(mp, max_mp):
	update_mana_bar(mp, max_mp)

extends Control

onready var health_bar = $HealthBar
onready var mana_bar = $ManaBar

func _ready():
	# Get and set the max health
	if get_parent() and get_parent().get("max_hp"):
		health_bar.max_value = get_parent().max_hp
		
	# Get and set the max mana
	if get_parent() and get_parent().get("max_mp"):
		mana_bar.max_value = get_parent().max_mp

func update_health_bar(amount, full):
	health_bar.value = amount
	health_bar.max_value = full
	
func update_mana_bar(amount, full):
	mana_bar.value = amount
	mana_bar.max_value = full

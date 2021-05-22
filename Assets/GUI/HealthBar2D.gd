extends Control

onready var health_bar = $HealthBar

var bar = preload("res://Assets/GUI/health.png")

func _ready():
	if get_parent() and get_parent().get("max_hp"):
		health_bar.max_value = get_parent().max_hp
	health_bar.texture_progress = bar

func update_bar(amount, full):
	health_bar.value = amount
	health_bar.max_value = full

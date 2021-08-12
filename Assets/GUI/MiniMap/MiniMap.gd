extends MarginContainer


export (NodePath) var player
export var zoom = 1.5

onready var player_marker = find_node('Player')
onready var fox_marker = find_node('Fox')
onready var imp_marker = find_node('Imp')
onready var minotaur_marker = find_node('Minotaur')

onready var icons = {"fox": fox_marker, "imp": imp_marker, "minotaur": minotaur_marker}

var markers = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	if len(PlayerInfo.abilities) == 0:
		PlayerInfo.abilities = ["BasicAttackAbility", "FireballAbility", "SelfHealAbility"]
		get_tree().change_scene("res://World.tscn")
		queue_free()
	print('testing')

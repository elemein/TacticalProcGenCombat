extends MarginContainer


export (NodePath) var player
export var zoom = 1.5

onready var player_marker = find_node('Player')
onready var fox_marker = $Fox
onready var imp_marker = $Imp
onready var minotaur_marker = find_node('Minotaur')

onready var icons = {"fox": fox_marker, "imp": imp_marker, "minotaur": minotaur_marker}

var grid_scale
var markers = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	if len(PlayerInfo.abilities) == 0:
		PlayerInfo.abilities = ["BasicAttackAbility", "FireballAbility", "SelfHealAbility"]
		var _result = get_tree().change_scene("res://World.tscn")
		self.queue_free()
	else:
		yield(get_tree(), "idle_frame")
		player = get_tree().get_nodes_in_group('player')[0]
		player_marker.rect_position = self.rect_size / 2
		grid_scale = self.rect_size / (get_viewport_rect().size * zoom)
		
		for enemy in get_tree().get_nodes_in_group('enemies'):
			var new_marker = icons[enemy.minimap_icon].duplicate()
			self.add_child(new_marker)
			new_marker.show()
			markers[enemy] = new_marker
			
func _process(_delta):
	if !player:
		return
#	player_marker.rect_rotation = player.rotation + PI / 2
	for enemy in markers:
		# 
		# JUST CALC WITH THE X AND Z TRANSLATIONS
		#
		var obj_pos = (enemy.translation - player.translation) * grid_scale + self.rect_size / 2
		markers[enemy].pos = obj_pos
		

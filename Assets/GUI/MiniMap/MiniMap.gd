extends MarginContainer


export (NodePath) var player
export var zoom = 1.5

onready var grid = find_node('GridContainer')

onready var player_marker = find_node('Player')
onready var fox_marker = find_node('Fox')
onready var imp_marker = find_node('Imp')
onready var minotaur_marker = find_node('Minotaur')
onready var blank_marker = find_node('Blank')
onready var tile_marker = find_node('Tile')
onready var stair_marker = find_node('Stairs')

onready var icons = {"Fox": fox_marker, "Imp": imp_marker, "Minotaur": minotaur_marker, "Wall": blank_marker, "Ground": tile_marker, "Player": player_marker, "Stairs": stair_marker}

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
		
		
		# CAN PROB DELETE THIS
#		for enemy in get_tree().get_nodes_in_group('enemies'):
#			var new_marker = icons[enemy.minimap_icon].duplicate()
#			self.add_child(new_marker)
#			new_marker.show()
#			markers[enemy] = new_marker
			
func add_tile_to_grid(marker):
	if marker != null:
		var new_marker = icons[marker].duplicate()
		grid.add_child(new_marker)
		new_marker.show()
			
func _process(_delta):
	if player == null:
		return
#	player_marker.rect_rotation = player.rotation + PI / 2
	var map_grid = player.get_parent_map().map_grid
	for row_cnt in range(map_grid.size()):
		for tile_cnt in range(map_grid[row_cnt].size()):
			var minimap_icon = "Blank"
			for thing in map_grid[tile_cnt][row_cnt]:
				match thing.minimap_icon:
					"Player":
						minimap_icon = thing.minimap_icon
					"Fox", "Imp", "Minotaur":
						if not minimap_icon in ["Player", "Stairs"]:
							minimap_icon = thing.minimap_icon
					"Stairs":
						if not minimap_icon in ["Player"]:
							minimap_icon = thing.minimap_icon
					"Ground":
						if not minimap_icon in ["Player", "Stairs", "Fox", "Imp", "Minotaur"]:
							minimap_icon = thing.minimap_icon
					"Wall":
						if minimap_icon == "Blank":
							minimap_icon = thing.minimap_icon
					null:
						pass
				
			add_tile_to_grid(minimap_icon)
			
	pass
#
#	var tmp = 1
#	for enemy in markers:
#		# 
#		# JUST CALC WITH THE X AND Z TRANSLATIONS
#		#
#		var enemy_pos = Vector2(enemy.translation.x, enemy.translation.z)
#		var player_pos = Vector2(player.translation.x, player.translation.z)
#		var obj_pos = (enemy_pos - player_pos) 
#		markers[enemy].rect_position = obj_pos

extends MarginContainer


export (NodePath) var player = null
export var zoom = 1.5

onready var grid = find_node('GridContainer')
onready var base_tile = find_node('BaseTile')

onready var player_icon = preload("res://Assets/GUI/MiniMap/Player.png")
onready var fox_icon = preload("res://Assets/GUI/MiniMap/EnemyFox.png")
onready var imp_icon = preload("res://Assets/GUI/MiniMap/EnemyImp.png")
onready var minotaur_icon = preload("res://Assets/GUI/MiniMap/EnemyMinotaur.png")
onready var stairs_icon = preload("res://Assets/GUI/MiniMap/Stairs.png")
onready var tile_icon = preload("res://Assets/GUI/MiniMap/Tile.png")
onready var blank_icon = preload("res://Assets/GUI/MiniMap/Blank.png")
onready var seen_icon = preload("res://Assets/GUI/MiniMap/Seen.png")
onready var co_op_player = preload("res://Assets/GUI/MiniMap/CoOpPlayer.png")

var markers = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if len(PlayerInfo.abilities) == 0:
		PlayerInfo.abilities = ["BasicAttackAbility", "FireballAbility", "SelfHealAbility"]
		var _result = get_tree().change_scene("res://World.tscn")
		self.queue_free()
	else:
		yield(get_tree(), "idle_frame")
		player = GlobalVars.self_instanceObj

		var map_grid = player.get_parent_map().map_grid
		for row_cnt in range(map_grid.size()):
			var row = []
			for _tile_cnt in range(map_grid[row_cnt].size()):
				var new_tile = base_tile.duplicate()
				grid.add_child(new_tile)
				new_tile.show()
				row.append(new_tile)
			markers.append(row)
			
func _process(_delta):
	if player == null:
		return
#	player_marker.rect_rotation = player.rotation + PI / 2

#	var map_grid = player.get_parent_map().map_grid
#	for row_cnt in range(map_grid.size()):
#		for tile_cnt in range(map_grid[row_cnt].size()):
#			var minimap_icon = blank_icon
#			var tile = markers[abs(map_grid.size() - row_cnt) - 1][tile_cnt]
#			for thing in map_grid[row_cnt][tile_cnt]:
#				match thing.minimap_icon:
#					"Player":
#						if player == thing:
#							minimap_icon = player_icon
#						else:
#							minimap_icon = co_op_player
#					"Fox":
#						if not minimap_icon in ["Player", "Stairs"] and not thing.is_dead:
#							if thing.visible:
#								minimap_icon = fox_icon
#							elif thing.was_visible:
#								minimap_icon = seen_icon
#					"Imp":
#						if not minimap_icon in ["Player", "Stairs"] and not thing.is_dead:
#							if thing.visible:
#								minimap_icon = imp_icon
#							elif thing.was_visible:
#								minimap_icon = seen_icon
#					"Minotaur":
#						if not minimap_icon in ["Player", "Stairs"] and not thing.is_dead:
#							if thing.visible:
#								minimap_icon = minotaur_icon
#							elif thing.was_visible:
#								minimap_icon = seen_icon
#					"Stairs":
#						if not minimap_icon in ["Player", "Stairs"]:
#							if thing.visible or thing.was_visible:
#								minimap_icon = stairs_icon
#					"Ground":
#						if not minimap_icon in ["Player", "Stairs", "Fox", "Imp", "Minotaur"]:
#							if thing.visible:
#								minimap_icon = tile_icon
#							elif thing.was_visible:
#								minimap_icon = seen_icon
#					null:
#						pass
#					_:
#						pass
#			tile.texture = minimap_icon

extends MarginContainer


export (NodePath) var player
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

var markers = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if len(PlayerInfo.abilities) == 0:
		PlayerInfo.abilities = ["BasicAttackAbility", "FireballAbility", "SelfHealAbility"]
		var _result = get_tree().change_scene("res://World.tscn")
		self.queue_free()
	else:
		yield(get_tree(), "idle_frame")
		player = get_tree().get_nodes_in_group('player')[0]
				
		var map_grid = player.get_parent_map().map_grid
		for row_cnt in range(map_grid.size()):
			var row = []
			for tile_cnt in range(map_grid[row_cnt].size()):
				var new_tile = base_tile.duplicate()
				grid.add_child(new_tile)
				new_tile.show()
				row.append(new_tile)
			markers.append(row)
			
func _process(_delta):
	if player == null:
		return
#	player_marker.rect_rotation = player.rotation + PI / 2
	var map_grid = player.get_parent_map().map_grid
	for row_cnt in range(map_grid.size()):
		for tile_cnt in range(map_grid[row_cnt].size()):
			var minimap_icon = "Blank"
			var tile = markers[abs(map_grid.size() - row_cnt) - 1][tile_cnt]
			for thing in map_grid[row_cnt][tile_cnt]:
				match thing.minimap_icon:
					"Player":
						minimap_icon = player_icon
					"Fox":
						if not minimap_icon in ["Player", "Stairs"] and not thing.is_dead:
							minimap_icon = fox_icon
					"Imp":
						if not minimap_icon in ["Player", "Stairs"] and not thing.is_dead:
							minimap_icon = imp_icon
					"Minotaur":
						if not minimap_icon in ["Player", "Stairs"] and not thing.is_dead:
							minimap_icon = minotaur_icon
					"Stairs":
						if not minimap_icon in ["Player"]:
							minimap_icon = stairs_icon
					"Ground":
						if not minimap_icon in ["Player", "Stairs", "Fox", "Imp", "Minotaur"]:
							minimap_icon = tile_icon
					"Wall":
						if minimap_icon == "Blank":
							minimap_icon = blank_icon
					null:
						pass
					_:
						pass
			tile.texture = minimap_icon

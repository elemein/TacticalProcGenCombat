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
	
	var map_grid = player.get_parent_map().map_grid
	for row_cnt in range(map_grid.size()):
		for tile_cnt in range(map_grid[row_cnt].size()):
			var minimap_icon = blank_icon
			var tile = markers[abs(map_grid.size() - row_cnt) - 1][tile_cnt]
			for thing in map_grid[row_cnt][tile_cnt]:
				match thing.get_id()['CategoryType']:
					"Player":
						if player == thing:
							minimap_icon = player_icon
						else:
							minimap_icon = co_op_player
						break
					"Enemy":
						if thing.visible:
							match thing.get_id()['Identifier']:
								"Imp":
									minimap_icon = imp_icon
								"Fox":
									minimap_icon = fox_icon
								"Minotaur":
									minimap_icon = minotaur_icon
						elif thing.was_visible and not thing.is_dead:
							minimap_icon = seen_icon
						break
					"Ground":
						if thing.was_visible or thing.visible:
							match thing.get_id()['Identifier']:
								"BaseGround":
									minimap_icon = tile_icon
			tile.texture = minimap_icon


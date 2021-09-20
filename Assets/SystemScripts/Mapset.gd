extends Node
class_name Mapset

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")
onready var blank_node = preload("res://Assets/SystemScripts/blank_node.tscn")
var map_generator = MAP_GEN.new()

var dungeon_name = ''
var floors = {}
var floor_count = 0

func _init(d_name, flr_count):
	dungeon_name = d_name
	self.set_name(dungeon_name)
	floor_count = flr_count

func _ready():
	for flr_no in range(1, floor_count+1):
		var floor_name = 'Dungeon Floor %d' % [flr_no]
		var map_type = 'Normal Floor' if flr_no < floor_count else 'End Floor'
		floors[floor_name] = map_generator.generate(self, floor_name, flr_no, map_type)
		var floor_object = floors[floor_name]
		add_child(floor_object)
		floor_object.name = 'Floor%d' % [flr_no]
		organize_map_assets(floor_object)

func organize_map_assets(floor_object):
	var organization_nodes = {'All': []}
	
	# Generate Organization Nodes
	var organize_types = ['Terrain', 'Objects', 'Enemies', 'Players', 'Logic']
	for type in organize_types:
		var new_node = blank_node.instance()
		new_node.name = type
		organization_nodes[type] = new_node
		organization_nodes['All'].append(new_node)
		floor_object.add_child(new_node)
	
	var types = []
	for asset in floor_object.get_children():
		if not asset in organization_nodes['All']:
			var thing_type = asset.name
			
			# Ignore duplicated instances
			if thing_type[0] == '@':
				thing_type = thing_type.substr(1, thing_type.find_last('@') - 1)
				
			asset.get_parent().remove_child(asset)
			match thing_type:
				'Sword', 'ArcaneNecklace', 'Coins', 'Spike Trap', 'LeatherCuirass', 'ScabbardAndDagger', 'MagicStaff', 'BodyArmour':
					organization_nodes['Objects'].add_child(asset)
				'BaseStairs', 'BaseWall', 'BaseBlock', 'Stairs':
					organization_nodes['Terrain'].add_child(asset)
				'Enemy':
					organization_nodes['Enemies'].add_child(asset)
				'TurnTimer':
					organization_nodes['Logic'].add_child(asset)
				_:
					if not thing_type in types:
						types.append(thing_type)
	print('Map objects not categorized: ' + str(types))


# Getters
func get_mapset_name() -> String: return dungeon_name

func get_floors() -> Dictionary: return floors

extends Node
class_name Mapset

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")
var blank_node = preload("res://Assets/SystemScripts/blank_node.tscn")
var map_generator = MAP_GEN.new()

var dungeon_name = ''
var floors = {}
var floor_count = 0
var create_instance = true

func _init(d_name, flr_count):
	if [d_name, flr_count] == [null, null]:
		create_instance = false
	else:
		dungeon_name = d_name
		self.set_name(dungeon_name)
		floor_count = flr_count

func _ready():
	if create_instance:
		for flr_no in range(1, floor_count+1):
			var floor_name = 'Dungeon Floor %d' % [flr_no]
			var map_type = 'Normal Floor' if flr_no < floor_count else 'End Floor'
			floors[floor_name] = map_generator.generate(self, floor_name, flr_no, map_type)
	organize_map_nodes(floors, null)

func organize_map_nodes(floors, floor_num):
	for flr_no in range(1, floors.size()+1):
		if floor_num != null:
			flr_no = floor_num
		var floor_name = 'Dungeon Floor %d' % [flr_no]
		var floor_object = floors[floor_name]
		add_child(floor_object)
		floor_object.name = 'Floor%d' % [flr_no]
		organize_map_floor(floor_object)

func organize_map_floor(floor_object):
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
			asset.get_parent().remove_child(asset)
			if asset.name == 'TurnTimer':
				organization_nodes['Logic'].add_child(asset)
			else:
				match asset.object_identity['Category']:
					'Inv Item':
						organization_nodes['Objects'].add_child(asset)
						asset.name = '%s%d' % [asset.object_identity['Identifier'], asset.object_identity['Instance ID']]
					'MapObject':
						organization_nodes['Terrain'].add_child(asset)
						asset.name = '%s%d' % [asset.object_identity['Identifier'], asset.object_identity['Instance ID']]
					'Actor':
						match asset.object_identity['CategoryType']:
							'Enemy':
								organization_nodes['Enemies'].add_child(asset)
								asset.name = '%s%d' % [asset.object_identity['Identifier'], asset.object_identity['Instance ID']]
							'Player':
								organization_nodes['Players'].add_child(asset)
								asset.name = 'Player%d' % asset.object_identity['NetID']
	print('Map objects not categorized: ' + str(types))

# Getters
func get_mapset_name() -> String: return dungeon_name

func get_floors() -> Dictionary: return floors

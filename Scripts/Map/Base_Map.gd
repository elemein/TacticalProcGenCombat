extends Node
class_name Base_Map

var map_name : String = ''
var map_server_id : int
var map_grid : Array = []

func remove_from_map_grid_but_keep_node(object):
	var tile : Array = object.get_map_pos()
	self.map_grid[tile[0]][tile[1]].erase(object)

func remove_from_map_tree(object):
	remove_child(object)

func organize_object(obj):
	match obj.get_id()['Category']:
		'Actor':
			match obj.get_id()['CategoryType']:
				'Player':
					if obj.get_parent() != get_node("Players"):
						obj.get_parent().remove_child(obj)
						if get_node("Players") != null: get_node("Players").add_child(obj)

func organize_map_floor():
	var organization_nodes : Dictionary = {'All': []}
	
	# Generate Organization Nodes
	var organize_types : Array = ['Terrain', 'Objects', 'Characters', 'Players', 'Logic']
	var type_nodes_exist : bool = true
	for type in organize_types:
		if get_node_or_null(type) == null: type_nodes_exist = false
	
	if type_nodes_exist == false:
		for type in organize_types:
			var new_node : Node = Node.new()
			new_node.name = type
			organization_nodes[type] = new_node
			organization_nodes['All'].append(new_node)
			self.add_child(new_node)
	
	var types : Array = []
	for asset in self.get_children():
		if not asset.name in organize_types:
			asset.get_parent().remove_child(asset)
			if asset.name == 'TurnTimer':
				organization_nodes['Logic'].add_child(asset)
			else:
				if GlobalVars.peer_type == 'server':
					asset.update_id('Map ID', self.get_map_server_id())
				
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
								organization_nodes['Characters'].add_child(asset)
								asset.name = '%s%d' % [asset.object_identity['Identifier'], asset.object_identity['Instance ID']]
							'Player':
								organization_nodes['Players'].add_child(asset)
								asset.name = 'Player%d' % asset.object_identity['NetID']
	print('Map objects not categorized: ' + str(types))

func tile_in_bounds(x,z):
	return (x >= 0 && z >= 0 && x < self.map_grid.size() && z < map_grid[x].size())

func get_tile_contents(x,z):
	if !tile_in_bounds(x,z): return 'Out of Bounds'
	
	return self.map_grid[x][z]

func get_map_name() -> String: return map_name

func get_map_server_id(): return map_server_id

# A player version of Map.gd.

extends Node

var map_name = ''
var parent_mapset 

var blank_node = preload("res://Assets/SystemScripts/blank_node.tscn")

var PSIDE_TURN_TIMER = preload("res://Assets/SystemScripts/PSideTurnTimer.gd")
var turn_timer = PSIDE_TURN_TIMER.new()
var map_grid
var map_server_id
var rooms = []

# Getters
func get_map_name() -> String: return map_name

func get_turn_timer(): return turn_timer

func set_map_grid(new_grid): map_grid = new_grid

func get_tile_contents(x,z):
	if !tile_in_bounds(x,z): return 'Out of Bounds'
	
	return map_grid[x][z]

func tile_in_bounds(x,z):
	return (x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size())

func tile_available(x,z):
	if tile_in_bounds(x,z): 
		for object in map_grid[x][z]:
			if object.get_relation_rules()['Non-Traversable'] == true: return false
			
			if (object.get_id()['CategoryType'] == 'Enemy') or \
				(object.get_id()['CategoryType'] == 'Player'):
				if object.get_is_dead() == true: continue
				else: return false
		return true
	return false

func tile_blocks_vision(x,z):
	if tile_in_bounds(x,z): 
		for object in map_grid[x][z]:
			if object.get_relation_rules()['Blocks Vision'] == true: return true
	return false

func move_on_map(object, old_pos, new_pos):
	map_grid[new_pos[0]][new_pos[1]].append(object)
	map_grid[old_pos[0]][old_pos[1]].erase(object)
	
	return [new_pos[0], new_pos[1]]

func set_map_server_id(server_id): map_server_id = server_id

func get_map_server_id(): return map_server_id

func remove_map_object(object):
	var tile = object.get_map_pos()
	
	map_grid[tile[0]][tile[1]].erase(object)
	object.get_parent().remove_child(object)

func add_map_object(object, tile):
	object.set_parent_map(self)

	object.set_map_pos_and_translation(tile)
	map_grid[tile[0]][tile[1]].append(object)
	add_child(object)

func remove_from_map_grid_but_keep_node(object):
	var tile = object.get_map_pos()
	map_grid[tile[0]][tile[1]].erase(object)
	
func remove_from_map_tree(object):
	remove_child(object)

func organize_map_floor():
	var organization_nodes = {'All': []}
	
	# Generate Organization Nodes
	var organize_types = ['Terrain', 'Objects', 'Enemies', 'Players', 'Logic']
	for type in organize_types:
		var new_node = blank_node.instance()
		new_node.name = type
		organization_nodes[type] = new_node
		organization_nodes['All'].append(new_node)
		self.add_child(new_node)
	
	var types = []
	for asset in self.get_children():
		if not asset in organization_nodes['All']:
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
								organization_nodes['Enemies'].add_child(asset)
								asset.name = '%s%d' % [asset.object_identity['Identifier'], asset.object_identity['Instance ID']]
							'Player':
								organization_nodes['Players'].add_child(asset)
								asset.name = 'Player%d' % asset.object_identity['NetID']
	print('Map objects not categorized: ' + str(types))

extends Base_Map

var parent_mapset 

var PSIDE_TURN_TIMER : GDScript = preload("res://Scripts/Objects/Characters/Player/PSideTurnTimer.gd")
var turn_timer : Node = self.PSIDE_TURN_TIMER.new()
var rooms : Array = []

# Getters
func get_turn_timer(): return turn_timer

func set_map_grid(new_grid): map_grid = new_grid

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

func remove_map_object(object):
	var tile : Array = object.get_map_pos()
	
	map_grid[tile[0]][tile[1]].erase(object)
	object.get_parent().remove_child(object)

func add_map_object(object, tile):
	object.set_parent_map(self)

	object.set_map_pos_and_translation(tile)
	map_grid[tile[0]][tile[1]].append(object)
	add_child(object)
	
#	organize_object(object)

func clear_play_map():
	for child in get_children():
		remove_child(child)
		
		if not child.get('object_identity') == null and child.get_id()['Identifier'] == 'PlagueDoc':
			Server.player_list.erase(child)
			
		child.queue_free()

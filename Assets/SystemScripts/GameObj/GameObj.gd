extends MeshInstance
class_name GameObj

var object_identity
var parent_mapset
var parent_map = 'None'
var turn_timer
var map_pos = []

var obj_relation_rules = {"Blocks Vision": false, "Non-Traversable": false, \
						"Monopolizes Space": false}

func _init(obj_id, obj_relate_rules):
	self.object_identity = obj_id
	self.obj_relation_rules = obj_relate_rules

# Getters
func get_id(): return object_identity

func get_relation_rules(): return obj_relation_rules

func get_parent_mapset(): return parent_mapset

func get_parent_map(): return parent_map

func get_map_pos(): return map_pos

func get_translation(): return translation

# Updaters
func update_id(key, new_val): object_identity[key] = new_val

# Setters
func set_id(changed_id): object_identity = changed_id

func set_parent_map(map):
	if self.object_identity['CategoryType'] == 'Player': 
		PlayerInfo.current_map = map
	
	self.object_identity['Map ID'] = map.get_map_server_id()
	
	self.parent_map = map
	
	if GlobalVars.get_self_netid() == 1:
	# This is only done on server, as only the server has access to parent mapset.
		self.parent_mapset = map.get_parent_mapset()
		
	self.turn_timer = map.get_turn_timer()
	if GlobalVars.peer_type == 'server': self.parent_mapset = map.get_parent_mapset()

func set_map_pos(new_pos): 
	self.object_identity['Position'] = new_pos
	self.map_pos = new_pos

func set_translation_w_map_pos(new_pos):
	translation = Vector3(new_pos[0] * GlobalVars.TILE_OFFSET, 0, new_pos[1] * GlobalVars.TILE_OFFSET)

func set_map_pos_and_translation(new_pos):	
	set_map_pos(new_pos)
	set_translation_w_map_pos(new_pos)

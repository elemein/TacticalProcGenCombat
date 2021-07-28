extends MeshInstance
class_name GameObj

var object_type 
var parent_mapset
var parent_map = 'None'
var turn_timer
var map_pos = []

func _init(obj_type):
	object_type = obj_type

# Getters
func get_obj_type(): return object_type

func get_parent_mapset(): return parent_mapset

func get_parent_map(): return parent_map

func get_map_pos(): return map_pos

func get_translation(): return translation

# Setters
func set_parent_map(map): 
	parent_map = map
	turn_timer = map.get_turn_timer()
	parent_mapset = map.get_parent_mapset()

func set_map_pos(new_pos): map_pos = new_pos

func set_translation(new_translation): translation = new_translation 

func set_map_pos_and_translation(new_pos):	
	set_map_pos(new_pos)
	set_translation_w_map_pos(new_pos)

func set_translation_w_map_pos(new_pos):
	translation = Vector3(new_pos[0] * GlobalVars.TILE_OFFSET, 0.3, new_pos[1] * GlobalVars.TILE_OFFSET)

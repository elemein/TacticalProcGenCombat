extends MeshInstance
class_name GameObj

const TILE_OFFSET = 2.1

var object_type 
var parent_map = []
var turn_timer
var map_pos = []

func _init(obj_type):
	object_type = obj_type

# Getters
func get_obj_type(): return object_type

func get_parent_map(): return parent_map

func get_map_pos(): return map_pos

func get_translation(): return translation

# Setters
func set_parent_map(map): 
	parent_map = map
	turn_timer = map.get_turn_timer()

func set_map_pos(new_pos): map_pos = new_pos

func set_translation(new_translation): translation = new_translation 

func set_map_pos_and_translation(new_pos):
	map_pos = new_pos
	set_translation_w_map_pos(map_pos)

func set_translation_w_map_pos(new_pos):
	translation = Vector3(new_pos[0] * TILE_OFFSET, 0.3, new_pos[1] * TILE_OFFSET)

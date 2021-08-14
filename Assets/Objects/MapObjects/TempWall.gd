extends GameObj

onready var TweenNode = get_node("Tween")
onready var rest_pos = translation

var anim_playing = false
var anim_played = false
var to_remove = false

# vars for minimap
var minimap_icon = null

func _init().('TempWall'): pass

func _ready():
	TweenNode.connect("tween_completed", self, "_on_wall_slam_down_complete")
	TweenNode.interpolate_property(self, "translation", 
	rest_pos + Vector3(0, 10, 0), rest_pos, 0.5, 
	Tween.TRANS_QUINT, Tween.EASE_IN)
	TweenNode.start()
	anim_playing = true

func _on_wall_slam_down_complete(_tween_object, _tween_node_path):
	GlobalVars.camera.shake(50)
	anim_playing = false
	anim_played = true
	TweenNode.disconnect("tween_completed", self, "_on_wall_slam_down_complete")

func remove_self():
	TweenNode.connect("tween_completed", self, "_on_wall_raise_up_complete")
	TweenNode.interpolate_property(self, "translation", rest_pos, 
		rest_pos + Vector3(0, 5, 0), 0.5, 
		Tween.TRANS_BACK, Tween.EASE_IN)
	
	to_remove = true
	TweenNode.start()
	parent_map.remove_from_map_grid_but_keep_node(self)
	
func _on_wall_raise_up_complete(_tween_object, _tween_node_path):
	parent_map.remove_from_map_tree(self)

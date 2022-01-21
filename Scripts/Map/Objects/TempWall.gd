extends GameObj

onready var TweenNode = get_node("Tween")
onready var rest_pos = translation

var anim_playing = false
var anim_played = false
var to_remove = false

# vars for minimap
var minimap_icon = null

var identity = {"Category": "MapObject", "CategoryType": "TempWall", 
				"Identifier": "TempWall", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

var relation_rules = {"Blocks Vision": true, "Non-Traversable": true, \
						"Monopolizes Space": true}

func _init().(identity, relation_rules): pass

func _ready():
	self.TweenNode.connect("tween_completed", self, "_on_wall_slam_down_complete")
	self.TweenNode.interpolate_property(self, "translation", 
	self.rest_pos + Vector3(0, 10, 0), rest_pos, 0.5, 
	Tween.TRANS_QUINT, Tween.EASE_IN)
	self.TweenNode.start()
	self.anim_playing = true

func _on_wall_slam_down_complete(_tween_object, _tween_node_path):
	GlobalVars.camera.shake(50)
	self.anim_playing = false
	self.anim_played = true
	self.TweenNode.disconnect("tween_completed", self, "_on_wall_slam_down_complete")

func remove_self():
	self.TweenNode.connect("tween_completed", self, "_on_wall_raise_up_complete")
	self.TweenNode.interpolate_property(self, "translation", self.rest_pos, 
		self.rest_pos + Vector3(0, 5, 0), 0.5, 
		Tween.TRANS_BACK, Tween.EASE_IN)
	
	self.to_remove = true
	self.TweenNode.start()
	parent_map.remove_from_map_grid_but_keep_node(self)
	
func _on_wall_raise_up_complete(_tween_object, _tween_node_path):
	parent_map.remove_from_map_tree(self)

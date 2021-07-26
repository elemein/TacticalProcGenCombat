extends GameObj

onready var TweenNode = get_node("Tween")
onready var rest_pos = translation

var anim_playing = false
var anim_played = false
var to_remove = false

func _init().('TempWall'): pass

func _ready():
	print("IM A TEMPWALL")

func _physics_process(_delta):
	if (anim_played == false) and (anim_playing == false):
		TweenNode.interpolate_property(self, "translation", 
			rest_pos + Vector3(0, 10, 0), rest_pos, 0.5, 
			Tween.TRANS_QUINT, Tween.EASE_IN)
		TweenNode.start()
		anim_playing = true
	
	if (anim_playing == true) and (TweenNode.is_active() == false):
		GlobalVars.camera.shake(50)
		anim_playing = false
		anim_played = true
		
	if (to_remove == true) and (TweenNode.is_active() == false):
		parent_map.remove_from_map_tree(self)

func remove_self():
	TweenNode.interpolate_property(self, "translation", rest_pos, 
		rest_pos + Vector3(0, 5, 0), 0.5, 
		Tween.TRANS_BACK, Tween.EASE_IN)
	
	to_remove = true
	TweenNode.start()
	parent_map.remove_from_map_grid_but_keep_node(self)

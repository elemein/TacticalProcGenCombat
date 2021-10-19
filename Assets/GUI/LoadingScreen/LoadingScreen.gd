extends Node

onready var background = get_node("moon_multi_exposure_unsplash_license")
onready var label = get_node("LoadingLabel")
onready var tween = get_node("Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	tween.interpolate_property(background, "modulate", 
	  Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.0, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

extends Node


onready var texture_rect = find_node('TextureRect')


# Called when the node enters the scene tree for the first time.
func _ready():
	texture_rect.texture.get_data().resize(800, 450)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends Sprite3D


onready var model = find_node('Character')


# Called when the node enters the scene tree for the first time.
func _ready():
	var animation_player = model.find_node('AnimationPlayer')
	animation_player.get_animation('idle').set_loop(true)
	animation_player.play('idle')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

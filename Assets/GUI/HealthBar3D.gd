extends Sprite3D

onready var health_bar = $Viewport/HealthBar2D

func _ready():
	texture = $Viewport.get_texture()

func update(value, full):
	health_bar.update_bar(value, full)

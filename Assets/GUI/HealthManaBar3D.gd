extends Sprite3D

onready var bars = $Viewport/HealthManaBar2D

func _ready():
	texture = $Viewport.get_texture()

func update_health_bar(value, full):
	bars.update_health_bar(value, full)
	
func update_mana_bar(value, full):
	bars.update_mana_bar(value, full)
	

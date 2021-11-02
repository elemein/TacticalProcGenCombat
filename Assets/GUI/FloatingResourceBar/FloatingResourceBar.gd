extends Sprite3D

#signal status_bar_hp(hp, max_hp)
#signal status_bar_mp(mp, max_mp)
onready var health_bar = find_node('HealthManaBar2D').find_node('HealthBar')
onready var mana_bar = find_node('HealthManaBar2D').find_node('ManaBar')

func _ready():
	texture = $Viewport.get_texture()

func _on_status_bar_hp(hp, max_hp):
	health_bar.value = hp
	health_bar.max_value = max_hp
#	emit_signal("status_bar_hp", hp, max_hp)


func _on_status_bar_mp(mp, max_mp):
#	emit_signal("status_bar_mp", mp, max_mp)
	mana_bar.value = mp
	mana_bar.max_value = max_mp

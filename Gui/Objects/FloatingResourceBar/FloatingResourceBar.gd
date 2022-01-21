extends Sprite3D

#signal status_bar_hp(hp, max_hp)
#signal status_bar_mp(mp, max_mp)
onready var health_bar = find_node('HealthManaBar2D').find_node('HealthBar')
onready var mana_bar = find_node('HealthManaBar2D').find_node('ManaBar')

func _ready():
	texture = $Viewport.get_texture()

func _on_status_bar_hp(hp, max_hp):
	self.health_bar.value = hp
	self.health_bar.max_value = max_hp


func _on_status_bar_mp(mp, max_mp):
	self.mana_bar.value = mp
	self.mana_bar.max_value = max_mp

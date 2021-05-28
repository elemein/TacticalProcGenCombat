extends Sprite3D

signal status_bar_hp(hp, max_hp)
signal status_bar_mp(mp, max_mp)

func _ready():
	texture = $Viewport.get_texture()

func _on_status_bar_hp(hp, max_hp):
	emit_signal("status_bar_hp", hp, max_hp)


func _on_status_bar_mp(mp, max_mp):
	emit_signal("status_bar_mp", mp, max_mp)

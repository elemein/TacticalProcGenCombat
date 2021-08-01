extends BaseAbility

onready var effect_tween = $Tween

var damage_variance = 30

func _ready():
	spell_name = 'Fireball'
	anim_time = 0.4
	spell_cost = 25
	spell_length = 3
	spell_power = 20
	effect_start_height = 1
	effect_end_height = 1
	spell_description = str("""Fireball
	Cost: {cost}\tPower: {power}
	
	Throw a fireball {length} tiles in front of you.
	""").format({'cost': spell_cost, 'power': spell_power, 'length': spell_length})
	visual_effect = preload('res://Assets/Objects/Effects/Fire/Fire.tscn')

func _on_Actions_spell_cast_fireball():
	use()

func use():
	map = parent.get_parent_map()
	
	# Update mana
	parent.set_mp(parent.get_mp() - spell_cost)

	play_audio()
	
	create_spell_instance()
	
	set_target_spell_pos()
	
	effect_tween.connect("tween_completed", self, "_on_tween_complete")
	effect_tween.interpolate_property(effect, "translation", effect.translation, target_spell_pos, anim_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
	effect_tween.start()

	set_power()
	do_damage(spell_final_power, damage_variance)

func _on_tween_complete(_tween_object, _tween_node_path):
	effect_tween.disconnect("tween_completed", self, "_on_tween_complete")
	get_node(spell_name).queue_free()
	remove_child(get_node(spell_name))
	effect = null

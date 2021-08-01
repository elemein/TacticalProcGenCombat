extends BaseAbility

onready var effect_tween = $Tween

func _ready():
	spell_power = 15
	spell_cost = 40
	spell_name = 'SelfHeal'
	anim_time = 0.6
	spell_description = str("""Self Heal
	Cost: {cost}\tPower: {power}
	
	Heal yourself.
	""").format({'cost': spell_cost, 'power': spell_power})
	effect_start_height = 13
	effect_end_height = 0
	visual_effect = preload("res://Assets/Objects/Effects/Heal/Heal.tscn")

func _on_Actions_spell_cast_self_heal():
	use()

func use():
	map = parent.get_parent_map()
	
	# Update mana
	parent.set_mp(parent.get_mp() - spell_cost)
	
	play_audio()
	
	create_spell_instance()
	
	set_target_spell_pos()
	
	effect_tween.connect("tween_completed", self, "_on_tween_complete")
	effect_tween.interpolate_property(effect, "translation", effect.translation, target_spell_pos, anim_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	effect_tween.start()
	
	set_power()

	heal_user()

func _on_tween_complete(_tween_object, _tween_node_path):
	get_node(spell_name).queue_free()
	remove_child(get_node(spell_name))
	effect = null

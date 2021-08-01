extends BaseAbility

onready var effect_tween = $Tween

func _ready():
	attack_power = 10
	spell_cost = 0
	spell_length = 1
	moving = true
	moving_back = true
	scales_off_atk_or_spl = 'atk'
	anim_time = 0.6
	spell_description = str("""Basic Attack
	Cost: {cost}\tPower: {power}
	
	Attack {length} tile in front of you.
	""").format({'cost': spell_cost, 'power': attack_power, 'length': spell_length})

func _on_Actions_spell_cast_basic_attack():
	use()

func use():
	if parent == null: parent = find_parent('Actions').get_parent()
	map = parent.get_parent_map()
	
	parent.set_mp(parent.get_mp() - spell_cost)
	play_audio()

	set_target_actor_pos()
	
	# Move towards
	effect_tween.connect("tween_completed", self, "_on_tween_complete")
	effect_tween.interpolate_property(parent, "translation", saved_actor_pos, target_actor_pos, anim_time/2, Tween.TRANS_SINE, Tween.EASE_OUT)
	effect_tween.start()

	set_attack_power()

	do_damage()

# Move back
func _on_tween_complete(_tween_object, _tween_node_path):
	effect_tween.disconnect("tween_completed", self, "_on_tween_complete")
	effect_tween.interpolate_property(parent, "translation", target_actor_pos, saved_actor_pos, anim_time/2, Tween.TRANS_SINE, Tween.EASE_OUT)
	effect_tween.start()

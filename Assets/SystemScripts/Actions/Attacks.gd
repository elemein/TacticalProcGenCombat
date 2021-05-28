extends Node

onready var helper = $HelperFunction

func _ready():
	for attack in self.get_children():
		if attack.get('name') != 'HelperFunction':
			attack.connect('set_target_pos', $Attacks/HelperFunction, 'set_target_pos')

func set_target_pos(direction_facing, parent, effects_fire, target_pos, spell_length):
	helper.set_target_pos(direction_facing, parent, effects_fire, target_pos, spell_length)

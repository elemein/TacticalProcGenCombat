extends Node


onready var character = find_node('Character')
onready var ability_box = find_node('AbilityBox')
onready var lock_in = find_node('LockIn')
onready var left_turn = find_node('Left')
onready var right_turn = find_node('Right')

var max_abilities = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	var animation_player = character.find_node('AnimationPlayer')
	animation_player.get_animation('idle').set_loop(true)
	animation_player.play('idle')
	
	for ability_button in ability_box.get_children():
		ability_button.connect('pressed', self, '_on_ability_selected')
	lock_in.connect("pressed", self, '_on_LockIn_pressed')
	left_turn.connect("pressed", self, '_on_Left_button_down')
	right_turn.connect("pressed", self, '_on_Right_button_down')
	

func _on_ability_selected():
	# Check is the max number of abilities are selected
	var selected_abilities = 0
	for ability_button in ability_box.get_children():
		if ability_button.is_pressed():
			selected_abilities += 1
			
	# If at max, disable the rest
	if selected_abilities >= max_abilities:
		for ability_button in ability_box.get_children():
			if not ability_button.is_pressed():
				ability_button.set_disabled(true)
		lock_in.disabled = false
	
	# Otherwise ensure they are all enabled
	else:
		for ability_button in ability_box.get_children():
			ability_button.set_disabled(false)
		lock_in.disabled = true

func _on_Left_button_down():
	character.rotate_y(deg2rad(-15))


func _on_Right_button_down():
	character.rotate_y(deg2rad(15))


func _on_LockIn_pressed():
	for ability_button in ability_box.get_children():
		if ability_button.is_pressed():
			PlayerInfo.abilities.append(ability_button.name)

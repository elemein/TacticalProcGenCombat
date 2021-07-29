extends VBoxContainer


onready var model = find_node('Character')
onready var ability_box = find_node('AbilityBox')

var max_abilities = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	var animation_player = model.find_node('AnimationPlayer')
	animation_player.get_animation('idle').set_loop(true)
	animation_player.play('idle')
	
	for ability_button in ability_box.get_children():
		ability_button.connect('pressed', self, '_on_ability_selected')

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
	
	# Otherwise ensure they are all enabled
	else:
		for ability_button in ability_box.get_children():
			ability_button.set_disabled(false)

func _on_Left_button_down():
	model.rotate_y(deg2rad(-15))


func _on_Right_button_down():
	model.rotate_y(deg2rad(15))

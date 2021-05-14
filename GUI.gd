extends MarginContainer

var blank_action = preload("res://Assets/GUI/Blank_Action.png")
var movement_arrow = preload("res://Assets/GUI/Arrow.png")
var basic_attack = preload("res://Assets/GUI/Basic_Attack.png")

onready var action_holder = get_node("/root/World/GUI/Proposed Action")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var timer_label = get_node("/root/World/Label")
onready var player = get_node("/root/World/Player")

func clear_action():
	action_holder.set_texture(blank_action)

func set_action(proposed_action):
	if proposed_action == "move up":
		action_holder.set_texture(movement_arrow)
		action_holder.rotation_degrees = -90
	if proposed_action == "move down":
		action_holder.set_texture(movement_arrow)
		action_holder.rotation_degrees = 90
	if proposed_action == "move right":
		action_holder.set_texture(movement_arrow)
		action_holder.rotation_degrees = 0
	if proposed_action == "move left":
		action_holder.set_texture(movement_arrow)
		action_holder.rotation_degrees = 180
	if proposed_action == "basic attack":
		action_holder.set_texture(basic_attack)
		action_holder.rotation_degrees = 0

func _physics_process(_delta):
	# We want to continuously display the time left on the turn timer.
	timer_label.text = str(turn_timer.time_left)
	
	if turn_timer.time_left == 0 and player.ready_status == false:
		clear_action()

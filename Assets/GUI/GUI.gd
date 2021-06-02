extends MarginContainer

var blank_action = preload("res://Assets/GUI/Blank_Action.png")
var movement_arrow = preload("res://Assets/GUI/Arrow.png")
var basic_attack = preload("res://Assets/GUI/Basic_Attack.png")
var fireball = preload("res://Assets/GUI/Fireball.png")

onready var action_holder = get_node("/root/World/GUI/Proposed Action")
onready var turn_timer = get_node("/root/World/TurnTimer")
onready var timer_label = get_node("/root/World/TimerReadout")
onready var player = get_node("/root/World/Player")

func _ready():
	clear_action()

func set_action(proposed_action):
	var direction = proposed_action.split(" ")[1] if proposed_action.split(" ")[0] == 'move' else ''
	if proposed_action.split(" ")[0] == 'move': proposed_action = 'move'
	
	match proposed_action:
		'move':
			action_holder.set_texture(movement_arrow)
			match direction:
				'upleft': action_holder.rotation_degrees = 180 + 45
				'upright': action_holder.rotation_degrees = 180 + 90 + 45
				'downleft': action_holder.rotation_degrees = 90 + 45
				'downright': action_holder.rotation_degrees = 45	
				
				'up': action_holder.rotation_degrees = -90
				'down': action_holder.rotation_degrees = 90
				'left': action_holder.rotation_degrees = 180
				'right': action_holder.rotation_degrees = 0
	
		'basic attack': action_holder.set_texture(basic_attack)
		'fireball': action_holder.set_texture(fireball)

func _physics_process(_delta):
	# We want to continuously display the time left on the turn timer.
	timer_label.text = str(turn_timer.time_left)

func clear_action():
	action_holder.rotation_degrees = 0
	action_holder.set_texture(blank_action)

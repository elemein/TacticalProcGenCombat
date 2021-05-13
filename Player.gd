extends KinematicBody

const MOVE_SPEED = 2.2

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")

# Used to store the action for the next turn.
var proposed_action = ""

var ready_status = false
var is_timer_zero = false

var anim_state = "idle"

var target_pos = Vector3()

var t = 0 

func _ready():
	pass
		
func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

func get_input():
	if is_timer_zero != true: # We don't wanna collect input if turn in action.
		return
	
	if Input.is_action_just_pressed("w"):
		proposed_action = "move up"
		gui.propose_action(proposed_action)
		ready_status = true
	if Input.is_action_just_pressed("s"):
		proposed_action = "move down"
		gui.propose_action(proposed_action)
		ready_status = true
	if Input.is_action_just_pressed("a"):
		proposed_action = "move left"
		gui.propose_action(proposed_action)
		ready_status = true
	if Input.is_action_just_pressed("d"):
		proposed_action = "move right"
		gui.propose_action(proposed_action)
		ready_status = true
	
func process_turn():
	
	# IF ACTION IS MOVE
	if proposed_action == "move up":
		target_pos.x = translation.x + MOVE_SPEED
		model.rotation_degrees.y = 90
	if proposed_action == "move down":
		target_pos.x = translation.x + -MOVE_SPEED
		model.rotation_degrees.y = 90 + 180
	if proposed_action == "move left":
		target_pos.z = translation.z + -MOVE_SPEED
		model.rotation_degrees.y = 180
	if proposed_action == "move right":
		target_pos.z = translation.z + MOVE_SPEED
		model.rotation_degrees.y = 180 + 180
	
	# CLEAR ACTION
	proposed_action = ""
	
func _physics_process(_delta):
	# Update local variable.
	is_timer_zero = turn_timer.is_timer_zero
	
	# Change position based on time tickdown.
	translation = translation.linear_interpolate(target_pos, (1-turn_timer.time_left)) 
	
	if translation != target_pos:
		anim_state = "walk"
	else:
		anim_state = "idle"
	
	get_input()
	
	handle_animations()

func handle_animations():
	if anim_state == "idle":
		play_anim("idle")
	else:
		play_anim("walk")

extends Timer

onready var player = get_node("/root/World/Player")

var turn_counter = 1
var is_timer_zero = false

# Use this to hold all of the actors in the world; players, enemies, etc.
var actors = []

# Called when the node enters the scene tree for the first time.
func _ready():
	actors.append(player)

func process_turn():
	start()
	
	for actor in actors:
		actor.process_turn()
	
	reset_ready_statuses()
	turn_counter += 1

func reset_ready_statuses():
	for actor in actors:
		actor.ready_status = false

func _physics_process(_delta):
	if time_left > 0: # We dont wanna process anything while turn is in action.
		is_timer_zero = false
	else:
		is_timer_zero = true
	
	var all_ready = true
	
	for actor in actors:
		if actor.ready_status == false:
			all_ready = false

	if all_ready:
		process_turn()

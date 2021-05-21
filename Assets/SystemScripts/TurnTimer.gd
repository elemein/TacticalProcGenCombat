extends Timer

const RESET_TIME = 0.1
const MOVING_TIME = 0.35
const ACTION_TIME = 0.95

onready var player = get_node("/root/World/Player")
onready var map = get_node("/root/World/Map")

var turn_counter = 1

# Use this to hold all of the actors in the world; players, enemies, etc.
var actors = []

func add_to_timer_group(actor):
	actors.append(actor)

func process_turn():
	wait_time = RESET_TIME # Reset this. 0 is NOT valid for some reason, so 0.1.
	
	for actor in actors: # Checks if everyone is just moving to shorten the time.
		if (actor.proposed_action.split(" ")[0] == 'move' 
			or actor.proposed_action.split(" ")[0] == 'idle'):
			if !(wait_time > MOVING_TIME) or wait_time == RESET_TIME:
				wait_time = MOVING_TIME
		else:
			wait_time = ACTION_TIME
		
	start() #This starts the timer.
	
	for actor in actors:
		if actor.proposed_action.split(" ")[0] == 'move':
			if actor.check_move_action(actor.proposed_action) == true:
				actor.process_turn()
		else:
			actor.process_turn()
	
func end_turn():
	for actor in actors:
		actor.end_turn()
	turn_counter += 1
	map.print_map_grid()

func _physics_process(_delta):
	var all_ready = false
	
	if time_left == 0: all_ready = true
	
	for actor in actors:
		if actor.ready_status == false: all_ready = false

	if all_ready: process_turn()

func _on_TurnTimer_timeout():
	end_turn()

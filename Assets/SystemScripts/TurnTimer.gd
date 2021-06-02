extends Timer

const RESET_TIME = 0.1
const MOVING_TIME = 0.35
const ACTION_TIME = 0.95

onready var player = get_node("/root/World/Player")
onready var map = get_node("/root/World/Map")

var rng = RandomNumberGenerator.new()

var turn_counter = 1

# Use this to hold all of the actors in the world; players, enemies, etc.
var actors = []

func _ready():
	rng.randomize()

func add_to_timer_group(actor):
	actors.append(actor)

func remove_from_timer_group(actor):
	actors.erase(actor)

func process_turn():
	wait_time = RESET_TIME # Reset this. 0 is NOT valid for some reason, so 0.1.
	
	sort_actors_by_speed()
	
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

func sort_actors_by_speed():
	# randomize order of those with same speed stat
	var speed_entries = {}
	var highest_speed = 0
	
	# make a dict of the actors by their speed in the speed_entries dict
	for actor in actors:
		if actor.get_speed() > highest_speed: highest_speed = actor.get_speed()
		
		if speed_entries.has(actor.get_speed()):
			speed_entries[actor.get_speed()].append(actor)
		else: speed_entries[actor.get_speed()] = [actor]
	
	actors = [] # reset
	
	# descend down the keys by highest speed, take a random actor from that group,
	# insert into actors, remove it from highest speed.
	while highest_speed > 0:
		if speed_entries.has(highest_speed):
			var group_size = speed_entries[highest_speed].size()
			if group_size > 0:
				rng.randomize()
				var random_index = rng.randi_range(0, group_size-1)
				var actor = speed_entries[highest_speed][random_index]
				actors.append(actor)
				speed_entries[highest_speed].erase(actor)
			elif group_size == 0:
				highest_speed -= 1
				
		else:
			highest_speed -= 1
		
		
func end_turn():
	for actor in actors:
		actor.end_turn()
	turn_counter += 1
	map.print_map_grid()
	
	map.hide_non_visible_from_player()

func _physics_process(_delta):
	var all_ready = false
	var players_alive = 0
	
	if time_left == 0: all_ready = true
	
	for actor in actors:
		if actor.ready_status == false: all_ready = false
		
	for actor in actors:
		if actor.object_type == 'Player':
			if actor.is_dead == false: players_alive += 1
	if players_alive == 0:
		all_ready = false

	if all_ready: process_turn()

func _on_TurnTimer_timeout():
	end_turn()

func get_actors():
	return actors

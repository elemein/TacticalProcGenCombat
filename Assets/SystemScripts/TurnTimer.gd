extends Timer

const RESET_TIME = 0.1
const MOVING_TIME = 0.35
const ACTION_TIME = 0.95

onready var world = get_parent()
onready var gui = get_node("/root/World/GUI/Action")
onready var turn_delay_timer = $TurnDelayTimer

var rng = RandomNumberGenerator.new()

var map
var turn_in_process = false
var in_delay = false
var turn_counter = 1
var actor_idx = 0

# Use this to hold all of the actors in the world; players, enemies, etc.
var actors = []

func _ready():
	rng.randomize()
	wait_time = RESET_TIME

func set_map(new_map):
	map = new_map

func add_to_timer_group(actor):
	actors.append(actor)

func remove_from_timer_group(actor):
	actors.erase(actor)

func process_turn():
	sort_actors_by_speed()
	
	actor_idx = 0
	turn_delay_timer.start(0.0001)

func _on_Turn_Delay_Timer_timeout():
	if actor_idx <= actors.size()-1 and turn_delay_timer.time_left == 0:
		var actor = actors[actor_idx]
		
		if actor.get_action().split(" ")[0] == 'move': turn_delay_timer.set_wait_time(0.15)
		elif actor.get_action() == 'idle': turn_delay_timer.set_wait_time(0.000001)
		elif actor.get_action() == 'basic attack': turn_delay_timer.set_wait_time(0.5)
		elif actor.get_action() == 'fireball': turn_delay_timer.set_wait_time(0.3)
		elif actor.get_action() == 'self heal': turn_delay_timer.set_wait_time(0.3)
		elif actor.get_action() == 'dash': turn_delay_timer.set_wait_time(0.175)
		elif actor.get_action() in ['drop item', 'equip item', 'unequip item']: turn_delay_timer.set_wait_time(0.2)
			
		actor.process_turn()
		
		actor_idx += 1
		turn_delay_timer.start()

func wait_for_actor_anims_and_delay_timer_to_end():
	var all_done = true
	
	for actor in actors:
		if actor.get_turn_anim_timer().time_left != 0:
			all_done = false
			
	if turn_delay_timer.time_left > 0: all_done = false
	
	if all_done == true: end_turn()
	
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
	gui.clear_action()
	for actor in actors:
		actor.end_turn()
	turn_in_process = false
	turn_counter += 1
	map.print_map_grid()
	
	map.check_for_map_events()
	
	for actor in actors:
		if actor.get_id()['CategoryType'] == 'Enemy':
			actor.find_viewfield()
			
	Server.resolve_all_viewfields(map)

func _physics_process(_delta):
	if turn_in_process:
		wait_for_actor_anims_and_delay_timer_to_end()
	
	if !turn_in_process:
		if check_if_actors_ready(): 
			turn_in_process = true
			process_turn()

func check_if_actors_ready() -> bool:
	var all_ready = true
	var players_alive = 0

	for actor in actors:
		if actor.ready_status == false: all_ready = false

	for actor in actors:
		if actor.get_id()['CategoryType'] == 'Player':
			if actor.is_dead == false: players_alive += 1
	if players_alive == 0:
		all_ready = false
	
	return all_ready

func get_actors():
	return actors

func get_turn_in_process() -> bool:
	return turn_in_process

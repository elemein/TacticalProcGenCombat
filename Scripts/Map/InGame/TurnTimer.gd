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
	self.rng.randomize()
	wait_time = RESET_TIME

func set_map(new_map):
	self.map = new_map

func add_to_timer_group(actor):
	self.actors.append(actor)

func remove_from_timer_group(actor):
	self.actors.erase(actor)

func process_turn():
	sort_actors_by_speed()
	
	self.actor_idx = 0
	self.turn_delay_timer.start(0.0001)

func _on_Turn_Delay_Timer_timeout():
	if self.actor_idx <= self.actors.size()-1 and self.turn_delay_timer.time_left == 0:
		var actor = self.actors[self.actor_idx]
		
		if actor.get_action().split(" ")[0] == 'move': self.turn_delay_timer.set_wait_time(0.15)
		elif actor.get_action() == 'idle': self.turn_delay_timer.set_wait_time(0.000001)
		elif actor.get_action() == 'basic attack': self.turn_delay_timer.set_wait_time(0.5)
		elif actor.get_action() == 'fireball': self.turn_delay_timer.set_wait_time(0.3)
		elif actor.get_action() == 'self heal': self.turn_delay_timer.set_wait_time(0.3)
		elif actor.get_action() == 'dash': self.turn_delay_timer.set_wait_time(0.175)
		elif actor.get_action() in ['drop item', 'equip item', 'unequip item']: self.turn_delay_timer.set_wait_time(0.2)
			
		actor.process_turn()
		
		self.actor_idx += 1
		self.turn_delay_timer.start()

func wait_for_actor_anims_and_delay_timer_to_end():
	var all_done = true
	
	for actor in self.actors:
		if actor.get_turn_anim_timer().time_left != 0:
			all_done = false
			
	if self.turn_delay_timer.time_left > 0: all_done = false
	
	if all_done == true: end_turn()
	
func sort_actors_by_speed():
	# randomize order of those with same speed stat
	var speed_entries = {}
	var highest_speed = 0
	
	# make a dict of the actors by their speed in the speed_entries dict
	for actor in self.actors:
		if actor.get_speed() > highest_speed: highest_speed = actor.get_speed()
		
		if speed_entries.has(actor.get_speed()):
			speed_entries[actor.get_speed()].append(actor)
		else: speed_entries[actor.get_speed()] = [actor]
	
	self.actors = [] # reset
	
	# descend down the keys by highest speed, take a random actor from that group,
	# insert into actors, remove it from highest speed.
	while highest_speed > 0:
		if speed_entries.has(highest_speed):
			var group_size = speed_entries[highest_speed].size()
			if group_size > 0:
				self.rng.randomize()
				var random_index = self.rng.randi_range(0, group_size-1)
				var actor = speed_entries[highest_speed][random_index]
				self.actors.append(actor)
				speed_entries[highest_speed].erase(actor)
			elif group_size == 0:
				highest_speed -= 1
		else:
			highest_speed -= 1

func end_turn():
	for actor in self.actors:
		actor.end_turn()
	Server.update_round_for_players_in_map(map)
	self.turn_in_process = false
	self.turn_counter += 1
	self.map.print_map_grid()
	
	self.map.check_for_map_events()
	
	for actor in self.actors:
		if actor.get_id()['CategoryType'] == 'Enemy':
			actor.find_viewfield()
			
	Server.resolve_all_viewfields(self.map)

func _physics_process(_delta):
	if self.turn_in_process:
		wait_for_actor_anims_and_delay_timer_to_end()
	
	if !self.turn_in_process:
		if check_if_actors_ready(): 
			self.turn_in_process = true
			process_turn()

func check_if_actors_ready() -> bool:
	var all_ready = true
	var players_alive = 0

	for actor in self.actors:
		if actor.ready_status == false: all_ready = false

	for actor in self.actors:
		if actor.get_id()['CategoryType'] == 'Player':
			if actor.is_dead == false: players_alive += 1
	if players_alive == 0:
		all_ready = false
	
	return all_ready

func get_actors():
	return self.actors

func get_turn_in_process() -> bool:
	return self.turn_in_process

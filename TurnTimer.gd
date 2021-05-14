extends Timer

onready var player = get_node("/root/World/Player")

var turn_counter = 1

# Use this to hold all of the actors in the world; players, enemies, etc.
var actors = []

# Called when the node enters the scene tree for the first time.
func _ready():
	actors.append(player)

func process_turn():
	turn_counter += 1
	
	start() #This starts the timer on self.
	
	for actor in actors:
		actor.process_turn()
	
func end_turn():
	for actor in actors:
		actor.end_turn()

func _physics_process(_delta):
	var all_ready = true
	
	for actor in actors:
		if actor.ready_status == false:
			all_ready = false

	if all_ready:
		process_turn()


func _on_TurnTimer_timeout():
	end_turn()

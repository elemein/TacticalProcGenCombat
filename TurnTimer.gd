extends Timer

onready var player = get_node("/root/World/Player")
onready var enemy = get_node("/root/World/Enemy")

var turn_counter = 1

# Use this to hold all of the actors in the world; players, enemies, etc.
var actors = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	actors['player'] = [player]
	actors['enemies'] = [enemy]

func process_turn():
	turn_counter += 1
	
	start() #This starts the timer on self.
	
	for category in actors:
		if category == 'player':
			for actor in actors[category]:
				actor.process_turn()
		elif category == 'enemy':
			for actor in actors[category]:
#				actor.process_turn()
				pass
	
func end_turn():
	for category in actors:
		for actor in actors[category]:
			actor.end_turn()

func _physics_process(_delta):
	var all_ready = true
	
	for category in actors:
		for actor in actors[category]:
			if actor.ready_status == false:
				all_ready = false

	if all_ready:
		process_turn()


func _on_TurnTimer_timeout():
	end_turn()

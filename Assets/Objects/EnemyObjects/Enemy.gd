extends KinematicBody

onready var model = $Graphics
onready var map = get_node("/root/World/Map")

onready var ready_status = true


var MAX_HEALTH = 100
var health

func _ready():
	health = MAX_HEALTH
	#print(health)
	# this is a test
	
func attacked_by_player():
	health -= 10
	#print(health)
	
func end_turn():
	pass
	
func process_turn():
	pass

func _physics_process(_delta):
	pass

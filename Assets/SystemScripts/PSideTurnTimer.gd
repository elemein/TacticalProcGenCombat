extends Node

var turn_timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	pass
	
func get_turn_in_process() -> bool:
	if turn_timer.get_time_left() > 0: return true
	else: return false

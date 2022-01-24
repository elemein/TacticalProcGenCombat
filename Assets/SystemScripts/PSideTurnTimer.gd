extends Node

var turn_timer = Timer.new()

func get_turn_in_process() -> bool:
	if turn_timer.get_time_left() > 0: return true
	else: return false

func get_turn_timer(): return turn_timer

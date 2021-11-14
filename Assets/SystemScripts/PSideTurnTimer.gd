extends Node

var turn_timer = Timer.new()

func get_turn_in_process() -> bool:
	if self.turn_timer.get_time_left() > 0: return true
	else: return false

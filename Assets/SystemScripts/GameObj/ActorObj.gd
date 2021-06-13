extends GameObj
class_name ActorObj

var is_dead = false

var stat_dict = {"Max HP" : 0, "HP" : 0, "Max MP": 0, "MP": 0, \
				"HP Regen" : 0, "MP Regen": 0, "Attack Power" : 0, \
				"Spell Power" : 0, "Defense" : 0, "Speed": 0, "View Range" : 0}

func _init(obj_type).(obj_type):
	pass


func get_is_dead(): return is_dead

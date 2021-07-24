extends Node
class_name Room

var id
var l
var w
var x
var z

var area

var type
var exits
var distance_to_spawn

var parent_id
var split

var center
var bottomleft
var bottomright
var topleft
var topright

func pos_in_room(pos):
	var pos_x = pos[0]
	var pos_z = pos[1]
	
	if (pos_x >= x) and (pos_x <= x + (l-1)):
		if  (pos_z >= z) and (pos_z <= z + (w-1)):
			print("Player is inside me! I'm %s" % [self])

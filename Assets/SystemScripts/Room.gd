extends Node
class_name Room

var parent_map

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

var cleared = false

var obj_spawner = GlobalVars.obj_spawner

func pos_in_room(pos):
	var pos_x = pos[0]
	var pos_z = pos[1]
	
	if (pos_x >= x) and (pos_x <= x + (l-1)):
		if  (pos_z >= z) and (pos_z <= z + (w-1)):
			print("Player is inside me! I'm %s" % [self])
			if type == 'Enemy':
				block_exits()

func block_exits():
	if cleared == false:
		for exit in exits:
			obj_spawner.spawn_map_object('TempWall', parent_map, [exit[0], exit[1]], true)

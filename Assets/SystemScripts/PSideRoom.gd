extends Node
class_name PSideRoom

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

var enemy_count = 0

var room_cleared = false
var exits_blocked = false

var obj_spawner = GlobalVars.plyr_obj_spawner

func pos_in_room(pos):
	var pos_x = pos[0]
	var pos_z = pos[1]
	
	if (pos_x >= x) and (pos_x <= x + (l-1)):
		if (pos_z >= z) and (pos_z <= z + (w-1)):
			print("Player is inside me! I'm %s" % [self])
			
			if room_cleared == false:
				if type in ['Enemy', 'Exit Room']:
					if exits_blocked == false:
						count_enemies_in_room()
						if enemy_count > 0:
							block_exits()
			
			return true
	#else
	return false

func count_enemies_in_room():
	var temp_count = 0
	
	for pos_x in range(x, x+l):
		for pos_z in range(z, z+w):
			var objects_on_tile = parent_map.get_tile_contents(pos_x, pos_z)
			
			for obj in objects_on_tile:
				if obj.get_id()['CategoryType'] == 'Enemy':
					if obj.get_is_dead() == false:
						temp_count += 1
	enemy_count = temp_count
	print("Enemies detected in room: " + str(enemy_count))

func block_exits():
	for exit in exits:
		var tempwall = obj_spawner.spawn_map_object('TempWall', parent_map, [exit[0], exit[1]], true)
		
		# below rotates the wall 90 degrees if it runs horizontally
		if parent_map.is_tile_wall(exit[0], exit[1]-1) and \
			parent_map.is_tile_wall(exit[0], exit[1]+1):
			tempwall.rotation_degrees.y = 90
	
	exits_blocked = true

func unblock_exits():
	if exits_blocked == true:
		exits_blocked = false
		print("Exits unblocked!")
	
	for exit in exits:
		var objects_on_tile = parent_map.get_tile_contents(exit[0], exit[1])
		
		for obj in objects_on_tile:
			if obj.get_id()['CategoryType'] == 'TempWall':
				obj.remove_self()
	
func log_enemy_death(_dead_enemy):
	count_enemies_in_room()
	
	if enemy_count <= 0: 
		room_cleared = true

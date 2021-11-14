extends Node
class_name DungeonRoom

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

var obj_spawner = GlobalVars.obj_spawner

func pos_in_room(pos):
	var pos_x = pos[0]
	var pos_z = pos[1]
	
	if (pos_x >= x) and (pos_x <= x + (self.l-1)):
		if (pos_z >= z) and (pos_z <= z + (self.w-1)):
			print("Player is inside me! I'm %s" % [self])
			return true
	#else
	return false

func check_if_locking(map_player_list):
	count_enemies_in_room()
	if self.room_cleared == true: return
	if !(self.type in ['Enemy', 'Exit Room']): return
	if self.exits_blocked == true: return
	if self.enemy_count <= 0: return
	if map_player_list.size() == 0: return
	
	var all_players_in_room = true
	for player in map_player_list:
		if all_players_in_room == true:
			all_players_in_room = pos_in_room(player.get_id()['Position'])
	
	if all_players_in_room: Server.map_object_event(self.parent_map.get_map_server_id(), {"Scope": "Room", "Room ID": id, "Action": "Block Exits"})

func count_enemies_in_room():
	var temp_count = 0
	
	for pos_x in range(x, x+self.l):
		for pos_z in range(z, z+self.w):
			var objects_on_tile = self.parent_map.get_tile_contents(pos_x, pos_z)
			
			for obj in objects_on_tile:
				if obj.get_id()['CategoryType'] == 'Enemy':
					if obj.get_is_dead() == false:
						temp_count += 1
	self.enemy_count = temp_count
#	print("Enemies detected in room: " + str(enemy_count))

func block_exits():
	for exit in self.exits:
		var tempwall = self.obj_spawner.spawn_map_object('TempWall', self.parent_map, [exit[0], exit[1]], true)
		
		# below rotates the wall 90 degrees if it runs horizontally
		if self.parent_map.tile_blocks_vision(exit[0], exit[1]-1) and \
			self.parent_map.tile_blocks_vision(exit[0], exit[1]+1):
			tempwall.rotation_degrees.y = 90
	
	self.exits_blocked = true

func unblock_exits():
	if self.exits_blocked == true:
		self.exits_blocked = false
		print("Exits unblocked!")
	
	for exit in self.exits:
		var objects_on_tile = self.parent_map.get_tile_contents(exit[0], exit[1])
		
		for obj in objects_on_tile:
			if obj.get_id()['CategoryType'] == 'TempWall':
				obj.remove_self()
	
func log_enemy_death(_dead_enemy):
	count_enemies_in_room()
	
	if self.enemy_count <= 0: 
		self.room_cleared = true
		Server.map_object_event(self.parent_map.get_map_server_id(), {"Scope": "Room", "Room ID": id, "Action": "Unblock Exits"})
		
		if self.type == 'Exit Room':
			Server.map_object_event(self.parent_map.get_map_server_id(), {"Scope": "Map", "Action": "Victory"})

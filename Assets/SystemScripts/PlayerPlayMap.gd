extends Node

var dungeon_name = ''

var PSIDE_TURN_TIMER = preload("res://Assets/SystemScripts/PSideTurnTimer.gd")
var turn_timer = PSIDE_TURN_TIMER.new()
var map_grid
var map_server_id

func _init():
	pass

func _ready():
	pass

# Getters
func get_mapset_name() -> String: return dungeon_name

func get_turn_timer(): return turn_timer

func set_map_grid(new_grid): map_grid = new_grid

func get_tile_contents(x,z):
	if !tile_in_bounds(x,z): 
		return 'Out of Bounds'
	
	return map_grid[x][z]

func tile_in_bounds(x,z):
	return (x >= 0 && z >= 0 && x < map_grid.size() && z < map_grid[x].size())
	
func move_on_map(object, old_pos, new_pos):
	map_grid[new_pos[0]][new_pos[1]].append(object)
	map_grid[old_pos[0]][old_pos[1]].erase(object)
	
	return [new_pos[0], new_pos[1]]

func set_map_server_id(server_id): map_server_id = server_id

func get_map_server_id(): return map_server_id

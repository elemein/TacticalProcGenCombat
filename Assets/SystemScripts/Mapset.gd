extends Node
class_name Mapset

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")

var map_generator = MAP_GEN.new()

var dungeon_name = ''
var floors = {}
var floor_count = 0
var create_instance = true

func _init(d_name, flr_count):
	if [d_name, flr_count] == [null, null]:
		create_instance = false
	else:
		dungeon_name = d_name
		self.set_name(dungeon_name)
		floor_count = flr_count

func _ready():
	if create_instance:
		for flr_no in range(1, floor_count+1):
			var floor_name = 'Dungeon Floor %d' % [flr_no]
			var map_type = 'Normal Floor' if flr_no < floor_count else 'End Floor'
			var new_floor = map_generator.generate(self, floor_name, flr_no, map_type)
			
			add_map_to_mapset(new_floor)
			
	organize_child_map_nodes()

func organize_child_map_nodes():
	for key in floors:
		floors[key].organize_map_floor()

# Getters
func get_mapset_name() -> String: return dungeon_name

func get_floors() -> Dictionary: return floors

# Setters
func add_map_to_mapset(map):
	floors[map.get_map_name()] = map
	add_child(map)

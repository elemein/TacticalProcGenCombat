extends Node
class_name Mapset

const MAP_GEN = preload("res://Assets/SystemScripts/MapGenerator.gd")
var map_generator = MAP_GEN.new()

var dungeon_name = ''
var floors = {}
var floor_count = 0

func _init(d_name, flr_count):
	dungeon_name = d_name
	self.set_name(dungeon_name)
	floor_count = flr_count

func _ready():
	for flr_no in range(1, floor_count+1):
		floors['Dungeon Floor %d' % [flr_no]] = map_generator.generate(self, 'Dungeon Floor %d' % [flr_no], flr_no)
		add_child(floors['Dungeon Floor %d' % [flr_no]])

func get_mapset_name() -> String: return dungeon_name

func get_floors() -> Dictionary: return floors

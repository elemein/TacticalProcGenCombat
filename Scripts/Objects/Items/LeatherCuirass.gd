extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Armour' , 
				"Identifier": 'Leather Cuirass', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/LeatherCuirass_x76.png")

var defense_bonus = 10
var attack_power_bonus = 5
var spell_power_bonus = 5
	
func get_stats():
	return [[10, "def"], [5, "atk pwr"], [5, "spl pwr"]]

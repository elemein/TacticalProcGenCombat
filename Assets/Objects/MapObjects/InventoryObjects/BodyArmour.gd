extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Armour' , 
				"Identifier": 'Body Armour', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/BodyArmour_x76.png")

var defense_bonus = 30
	
func get_stats():
	return [[30, "def"]]

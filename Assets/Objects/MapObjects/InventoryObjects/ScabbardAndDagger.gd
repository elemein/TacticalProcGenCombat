extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Accessory' , 
				"Identifier": 'Scabbard and Dagger', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/ScabbardAndDagger_x76.png")

var attack_power_bonus = 5
	
func get_stats():
	return [[self.attack_power_bonus, "atk pwr"]]

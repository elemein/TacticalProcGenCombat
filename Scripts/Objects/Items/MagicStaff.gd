extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Weapon' , 
				"Identifier": 'Magic Staff', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/MagicStaff_x76.png")

var spell_power_bonus = 10
	
func get_stats():
	return [[self.spell_power_bonus, "spl pwr"]]

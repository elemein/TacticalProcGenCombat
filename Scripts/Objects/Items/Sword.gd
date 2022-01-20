extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Weapon' , 
				"Identifier": 'Sword', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	inventory_icon = preload("res://Resources/Objects/Items/Sword_x76.png")

var attack_power_bonus = 20
	
func get_stats():
	return [[self.attack_power_bonus, "atk pwr"]]

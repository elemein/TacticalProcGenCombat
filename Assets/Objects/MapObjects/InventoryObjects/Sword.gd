extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Weapon' , 
				"Identifier": 'Sword', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	pass
	
func _ready():
	inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/sword_x76.png")

var attack_power_bonus = 20
	
func get_stats():
	return [[attack_power_bonus, "atk pwr"]]

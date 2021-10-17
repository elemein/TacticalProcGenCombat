extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Accessory' , 
				"Identifier": 'Arcane Necklace', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	pass

func _ready():
	inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/ArcaneNecklace_x76.png")

var spell_power_bonus = 5
	
func get_stats():
	return [[5, "spl pwr"]]

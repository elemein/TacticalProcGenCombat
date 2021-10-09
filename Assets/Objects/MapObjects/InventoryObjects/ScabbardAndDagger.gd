extends InvObject

var identity = {"Category": "Inv Item", "CategoryType": 'Accessory' , 
				"Identifier": 'Scabbard and Dagger', "Value": 50, 
				"Equippable": true, "Usable": false, "Consumable": false,
				'Map ID': null, 'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity):
	pass
	
func _ready():
	inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/ScabbardAndDagger_x76.png")

var attack_power_bonus = 5

func equip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() + attack_power_bonus)
	item_owner.inventory[self]['equipped'] = true

func unequip_object():
	item_owner.set_attack_power(item_owner.get_attack_power() - attack_power_bonus)
	item_owner.inventory[self]['equipped'] = false
	
func get_stats():
	return [[attack_power_bonus, "atk pwr"]]

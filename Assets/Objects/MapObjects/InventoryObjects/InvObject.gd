extends GameObj
class_name InvObject

var inv_item_type = "" 
var inv_item_name = ""
var item_owner
var value 
var equippable
var usable

var minimap_icon = null
var inventory_icon = preload("res://Assets/Objects/MapObjects/InventoryObjects/placeholder_x76.png")

func _init(identity).(identity):
	pass

func get_gold_value():
	return value

func get_usable(): return object_identity['Usable']

func get_equippable(): return object_identity['Equippable']

func get_inv_item_type(): return object_identity['CategoryType']

func get_inv_item_name(): return object_identity['Identifier']

func collect_item(tile_objects):
	for object in tile_objects:
		if object.get_id()['CategoryType'] == 'Player':
			if len(object.inventory) < 8:
				item_owner = object
				object.inventory[self] = {'equipped': false, 'description': self.get_id()['Identifier']}
				Server.object_action_event(object_identity, {"Command Type": "Remove From Map"})
			
func equip_item():
	for stat_type in ['spell_power_bonus', 'defense_bonus', 'attack_power_bonus']:
		if self.get(stat_type):
			match stat_type:
				'spell_power_bonus':
					item_owner.set_spell_power(item_owner.get_spell_power() + self.get(stat_type))
				'defense_bonus':
					item_owner.set_defense(item_owner.get_defense() + self.get(stat_type))
				'attack_power_bonus':
					item_owner.set_attack_power(item_owner.get_attack_power() + self.get(stat_type))
	item_owner.inventory[self]['equipped'] = true
	
func unequip_item():
	for stat_type in ['spell_power_bonus', 'defense_bonus', 'attack_power_bonus']:
		if self.get(stat_type):
			match stat_type:
				'spell_power_bonus':
					item_owner.set_spell_power(item_owner.get_spell_power() - self.get(stat_type))
				'defense_bonus':
					item_owner.set_defense(item_owner.get_defense() - self.get(stat_type))
				'attack_power_bonus':
					item_owner.set_attack_power(item_owner.get_attack_power() - self.get(stat_type))
	item_owner.inventory[self]['equipped'] = false
	
func drop_item():
	unequip_item()
	set_parent_map(item_owner.get_parent_map())
	set_map_pos_and_translation(item_owner.get_map_pos())
	PlayerInfo.current_map.add_map_object(self)
	item_owner.inventory.erase(self)
	Server.object_action_event(object_identity, {"Command Type": "Spawn On Map"})

extends Node

const TILE_OFFSET = 2.2

onready var map = get_node("/root/World/Map")

var base_spiketrap = preload("res://Assets/Objects/MapObjects/SpikeTrap.tscn")

# Gold
var base_coins = preload("res://Assets/Objects/MapObjects/Coins.tscn")

# Inv Objects
var base_sword = preload("res://Assets/Objects/MapObjects/InventoryObjects/Sword.tscn")
var base_staff = preload("res://Assets/Objects/MapObjects/InventoryObjects/MagicStaff.tscn")
var base_necklace = preload("res://Assets/Objects/MapObjects/InventoryObjects/ArcaneNecklace.tscn")
var base_dagger = preload("res://Assets/Objects/MapObjects/InventoryObjects/ScabbardAndDagger.tscn")
var base_armour = preload("res://Assets/Objects/MapObjects/InventoryObjects/BodyArmour.tscn")

func spawn_item(item_name, map_pos):
	var item_scene
	
	match item_name:
		'Sword': item_scene = base_sword
		'Magic Staff': item_scene = base_staff
		'Arcane Necklace': item_scene = base_necklace
		'Scabbard and Dagger': item_scene = base_dagger
		'Body Armour': item_scene = base_armour
			
	var item = item_scene.instance()
	item.translation = Vector3(map_pos[0] * TILE_OFFSET, 0.3, map_pos[1] * TILE_OFFSET)
	item.visible = true
	item.set_map_pos([map_pos[0], map_pos[1]])
	item.add_to_group('loot')
	map.add_map_object(item)
	
func spawn_gold(value, map_pos):
	var coins = base_coins.instance()
	coins.translation = Vector3(map_pos[0] * TILE_OFFSET, 0.6, map_pos[1] * TILE_OFFSET)
	coins.visible = true
	coins.set_map_pos([map_pos[0],map_pos[1]])
	coins.add_to_group('loot')
	coins.set_gold_value(value)
	map.add_map_object(coins)

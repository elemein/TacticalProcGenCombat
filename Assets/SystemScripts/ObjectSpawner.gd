extends Node

# Gold
var base_coins = preload("res://Assets/Objects/MapObjects/Coins.tscn")

# Inv Objects
var base_sword = preload("res://Assets/Objects/MapObjects/InventoryObjects/Sword.tscn")
var base_staff = preload("res://Assets/Objects/MapObjects/InventoryObjects/MagicStaff.tscn")
var base_necklace = preload("res://Assets/Objects/MapObjects/InventoryObjects/ArcaneNecklace.tscn")
var base_dagger = preload("res://Assets/Objects/MapObjects/InventoryObjects/ScabbardAndDagger.tscn")
var base_armour = preload("res://Assets/Objects/MapObjects/InventoryObjects/BodyArmour.tscn")
var base_cuirass = preload("res://Assets/Objects/MapObjects/InventoryObjects/LeatherCuirass.tscn")

# Map Objects
var base_stairs = preload("res://Assets/Objects/MapObjects/Stairs.tscn")
var base_spiketrap = preload("res://Assets/Objects/MapObjects/SpikeTrap.tscn")

# Enemies
var base_imp = preload("res://Assets/Objects/EnemyObjects/Imp.tscn")
var base_fox = preload("res://Assets/Objects/EnemyObjects/Fox.tscn")

func spawn_item(item_name, map, map_pos, visibility):
	var item_scene
	
	match item_name:
		'Sword': item_scene = base_sword
		'Magic Staff': item_scene = base_staff
		'Arcane Necklace': item_scene = base_necklace
		'Scabbard and Dagger': item_scene = base_dagger
		'Body Armour': item_scene = base_armour
		'Leather Cuirass': item_scene = base_cuirass
			
	var item = item_scene.instance()
	item.translation = Vector3(map_pos[0] * GlobalVars.TILE_OFFSET, 0.3, map_pos[1] * GlobalVars.TILE_OFFSET)
	item.visible = visibility
	item.set_map_pos([map_pos[0], map_pos[1]])
	item.set_parent_map(map)
	item.add_to_group('loot')
	map.add_map_object(item)

func spawn_enemy(enemy_name, map, map_pos, visibility):
	var enemy_scene
	
	match enemy_name:
		'Fox': enemy_scene = base_fox
		'Imp': enemy_scene = base_imp
	
	var enemy = enemy_scene.instance()
	enemy.translation = Vector3(map_pos[0] * GlobalVars.TILE_OFFSET, 0.3, map_pos[1] * GlobalVars.TILE_OFFSET)
	enemy.visible = visibility
	enemy.set_map_pos([map_pos[0], map_pos[1]])
	enemy.set_parent_map(map)
	enemy.add_to_group('enemies')
	map.add_map_object(enemy)

func spawn_gold(value, map, map_pos, visibility):
	var coins = base_coins.instance()
	coins.translation = Vector3(map_pos[0] * GlobalVars.TILE_OFFSET, 0.6, map_pos[1] * GlobalVars.TILE_OFFSET)
	coins.visible = visibility
	coins.set_map_pos([map_pos[0],map_pos[1]])
	coins.set_parent_map(map)
	coins.add_to_group('loot')
	coins.set_gold_value(value)
	map.add_map_object(coins)

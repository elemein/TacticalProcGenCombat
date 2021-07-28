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
var base_tempwall = preload("res://Assets/Objects/MapObjects/TempWall.tscn")
var base_stairs = preload("res://Assets/Objects/MapObjects/Stairs.tscn")

# Traps
var base_spiketrap = preload("res://Assets/Objects/MapObjects/SpikeTrap.tscn")

# Enemies
var base_imp = preload("res://Assets/Objects/EnemyObjects/Imp.tscn")
var base_fox = preload("res://Assets/Objects/EnemyObjects/Fox.tscn")
var base_minotaur = preload("res://Assets/Objects/EnemyObjects/Minotaur.tscn")

func create_object(object_scene, map, map_pos, visibility) -> Object:
	var object = object_scene.instance()
	object.translation = Vector3(map_pos[0] * GlobalVars.TILE_OFFSET, 0.3, map_pos[1] * GlobalVars.TILE_OFFSET)
	object.visible = visibility
	object.set_map_pos([map_pos[0], map_pos[1]])
	object.set_parent_map(map)
	map.add_map_object(object)
	
	return object

func spawn_item(item_name, map, map_pos, visibility):
	var item_scene
	
	match item_name:
		'Sword': item_scene = base_sword
		'Magic Staff': item_scene = base_staff
		'Arcane Necklace': item_scene = base_necklace
		'Scabbard and Dagger': item_scene = base_dagger
		'Body Armour': item_scene = base_armour
		'Leather Cuirass': item_scene = base_cuirass
			
	var item = create_object(item_scene, map, map_pos, visibility)
	item.add_to_group('loot')
	
	return item

func spawn_enemy(enemy_name, map, map_pos, visibility):
	var enemy_scene
	
	match enemy_name:
		'Fox': enemy_scene = base_fox
		'Imp': enemy_scene = base_imp
		'Minotaur': enemy_scene = base_minotaur
	
	var enemy = create_object(enemy_scene, map, map_pos, visibility)
	enemy.add_to_group('enemies')
	
	return enemy

func spawn_gold(value, map, map_pos, visibility):
	var coins = create_object(base_coins, map, map_pos, visibility)

	coins.add_to_group('loot')
	coins.set_gold_value(value)
	
	return coins

func spawn_map_object(object_name, map, map_pos, visibility):
	var object_scene
	
	match object_name:
		'TempWall': object_scene = base_tempwall
		'Stairs': object_scene = base_stairs
			
	var object = create_object(object_scene, map, map_pos, visibility)
	
	return object

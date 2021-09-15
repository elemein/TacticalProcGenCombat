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
var base_ground = preload("res://Assets/Objects/MapObjects/BaseBlock.tscn")
var base_wall = preload("res://Assets/Objects/MapObjects/Wall.tscn")
var base_tempwall = preload("res://Assets/Objects/MapObjects/TempWall.tscn")
var base_stairs = preload("res://Assets/Objects/MapObjects/Stairs.tscn")

# Traps
var base_spiketrap = preload("res://Assets/Objects/MapObjects/SpikeTrap.tscn")

# Enemies
var base_imp = preload("res://Assets/Objects/EnemyObjects/Imp.tscn")
var base_fox = preload("res://Assets/Objects/EnemyObjects/Fox.tscn")
var base_minotaur = preload("res://Assets/Objects/EnemyObjects/Minotaur.tscn")

# Actors
var base_player = preload("res://Assets/Objects/PlayerObjects/Player.tscn")
var base_pside_player = preload("res://Assets/Objects/PlayerObjects/PSidePlayer.tscn")
var base_dumb_actor = preload("res://Assets/Objects/PlayerObjects/DumbActor.tscn")

func create_object(object_scene, map_pos) -> Object:
	var object = object_scene.instance()
	object.translation = Vector3(map_pos[0] * GlobalVars.TILE_OFFSET, 0.3, map_pos[1] * GlobalVars.TILE_OFFSET)
	object.visible = true
	object.set_map_pos([map_pos[0], map_pos[1]])
	
	return object

func spawn_item(item_name, map_pos):
	var item_scene
	
	match item_name:
		'Sword': item_scene = base_sword
		'Magic Staff': item_scene = base_staff
		'Arcane Necklace': item_scene = base_necklace
		'Scabbard and Dagger': item_scene = base_dagger
		'Body Armour': item_scene = base_armour
		'Leather Cuirass': item_scene = base_cuirass
			
	var item = create_object(item_scene, map_pos)
	item.add_to_group('loot')
	
	return item

func spawn_actor(actor_name, map_pos):
	var actor_scene
	
	match actor_name:
		'PSidePlayer': actor_scene = base_pside_player
		'PlagueDoc': actor_scene = base_dumb_actor
	
	var actor = create_object(actor_scene, map_pos)
	actor.add_to_group('player')
	
	return actor

func spawn_enemy(enemy_name, map_pos):
	var enemy_scene
	
	match enemy_name:
		'Fox': enemy_scene = base_fox
		'Imp': enemy_scene = base_imp
		'Minotaur': enemy_scene = base_minotaur
	
	var enemy = create_object(enemy_scene, map_pos)
	enemy.add_to_group('enemies')
	
	return enemy

func spawn_gold(value, map_pos, visibility):
	var coins = create_object(base_coins, map_pos)

	coins.add_to_group('loot')
	coins.set_gold_value(value)
	
	return coins

func spawn_map_object(object_name, map_pos):
	var object_scene
	
	match object_name:
		'TempWall': object_scene = base_tempwall
		'Stairs': object_scene = base_stairs
		'BaseGround': object_scene = base_ground
		'BaseWall': object_scene = base_wall
			
	var object = create_object(object_scene, map_pos)
	
	return object
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
var base_dumb_actor = preload("res://Assets/Objects/PlayerObjects/DumbActor.tscn")

# Graphics
var plague_doc_graphics = preload("res://Assets/ObjectGraphicScenesForDumbActor/PlagueDocGraphics.tscn")
var imp_graphics = preload("res://Assets/ObjectGraphicScenesForDumbActor/ImpGraphicsScene.tscn")
var fox_graphics = preload("res://Assets/ObjectGraphicScenesForDumbActor/FoxGraphicsScene.tscn")
var minotaur_graphics = preload("res://Assets/ObjectGraphicScenesForDumbActor/MinotaurGraphicsScene.tscn")

# Lantern
var lantern_light_effect = preload("res://Assets/Objects/Effects/Lantern/LanternLight.tscn")

func create_object(object_scene, map, map_pos, visibility) -> Object:
	var object = object_scene.instance()
	object.visible = visibility
	
	# If the map/map_pos = 'Inventory' (i.e. a string), do not designate a map.
	if typeof(map) == TYPE_STRING: return object
	
	map.add_map_object(object, map_pos)
	
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

func spawn_dumb_actor(actor_name, map, map_pos, visibility):
	var actor = create_object(base_dumb_actor, map, map_pos, visibility)
	
	#Replacing the placeholder graphics with intended:
	match actor_name:
		'PlagueDoc':
			actor.set_graphics(plague_doc_graphics.instance())
			actor.add_to_group('player')
		'Fox':
			actor.set_graphics(fox_graphics.instance())
			actor.add_to_group('enemies')
		'Imp':
			actor.set_graphics(imp_graphics.instance())
			actor.add_to_group('enemies')
		'Minotaur':
			actor.set_graphics(minotaur_graphics.instance())
			actor.add_to_group('enemies')
	
	return actor

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
		'BaseStairs': object_scene = base_stairs
		'BaseGround': object_scene = base_ground
		'BaseWall': object_scene = base_wall
		'Spike Trap': object_scene = base_spiketrap
			
	var object = create_object(object_scene, map, map_pos, visibility)
	
	return object

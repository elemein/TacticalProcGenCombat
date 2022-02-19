extends Node

# Gold
var base_coins : PackedScene = preload("res://Objects/Map/Coins.tscn")

# Inv Objects
var base_sword : PackedScene = preload("res://Objects/Items/Weapon/Sword.tscn")
var base_staff : PackedScene = preload("res://Objects/Items/Weapon/MagicStaff.tscn")
var base_necklace : PackedScene = preload("res://Objects/Items/Accessory/ArcaneNecklace.tscn")
var base_dagger : PackedScene = preload("res://Objects/Items/Accessory/ScabbardAndDagger.tscn")
var base_armour : PackedScene = preload("res://Objects/Items/Armour/BodyArmour.tscn")
var base_cuirass : PackedScene = preload("res://Objects/Items/Armour/LeatherCuirass.tscn")

# Map Objects
var base_ground : PackedScene = preload("res://Objects/Map/BaseBlock.tscn")
var base_wall : PackedScene = preload("res://Objects/Map/Wall.tscn")
var base_tempwall : PackedScene = preload("res://Objects/Map/TempWall.tscn")
var base_stairs : PackedScene = preload("res://Objects/Map/Stairs.tscn")

# Traps
var base_spiketrap : PackedScene = preload("res://Objects/Map/SpikeTrap.tscn")

# Characters
var base_imp : PackedScene = preload("res://Objects/Characters/Enemies/Imp.tscn")
var base_fox : PackedScene = preload("res://Objects/Characters/Enemies/Fox.tscn")
var base_minotaur : PackedScene = preload("res://Objects/Characters/Enemies/Minotaur.tscn")

# Actors
var base_plaguedoc : PackedScene = preload("res://Objects/Characters/Players/PlagueDoc.tscn")
var base_dumb_actor : PackedScene = preload("res://Objects/Characters/DumbActor.tscn")

# Graphics
var plague_doc_graphics : PackedScene = preload("res://Objects/Characters/Players/PlagueDocGraphics.tscn")
var imp_graphics : PackedScene = preload("res://Objects/Characters/Enemies/ImpGraphicsScene.tscn")
var fox_graphics : PackedScene = preload("res://Objects/Characters/Enemies/FoxGraphicsScene.tscn")
var minotaur_graphics : PackedScene = preload("res://Objects/Characters/Enemies/MinotaurGraphicsScene.tscn")

# Lantern
var lantern_light_effect : PackedScene = preload("res://Resources/3dEffects/Lantern/LanternLight.tscn")

func create_object(object_scene, map, map_pos, visibility) -> Object:
	var object : PackedScene = object_scene.instance()
	object.visible = visibility

	# If the map/map_pos = 'Inventory' (i.e. a string), do not designate a map.
	if typeof(map) == TYPE_STRING: return object

	map.add_map_object(object, map_pos)

	return object

func spawn_item(item_name, map, map_pos, visibility):
	var item_scene : PackedScene

	match item_name:
		'Sword': item_scene = self.base_sword
		'Magic Staff': item_scene = self.base_staff
		'Arcane Necklace': item_scene = self.base_necklace
		'Scabbard and Dagger': item_scene = self.base_dagger
		'Body Armour': item_scene = self.base_armour
		'Leather Cuirass': item_scene = self.base_cuirass

	var item : PackedScene = create_object(item_scene, map, map_pos, visibility)
	item.add_to_group('loot')

	return item

func spawn_dumb_actor(actor_name, map, map_pos, visibility):
	var actor : PackedScene = create_object(self.base_dumb_actor, map, map_pos, visibility)

	#Replacing the placeholder graphics with intended:
	match actor_name:
		'PlagueDoc':
			actor.set_graphics(self.plague_doc_graphics.instance())
			actor.add_to_group('player')
		'Fox':
			actor.set_graphics(self.fox_graphics.instance())
			actor.add_to_group('enemies')
		'Imp':
			actor.set_graphics(self.imp_graphics.instance())
			actor.add_to_group('enemies')
		'Minotaur':
			actor.set_graphics(self.minotaur_graphics.instance())
			actor.add_to_group('enemies')

	return actor

func spawn_enemy(enemy_name, map, map_pos, visibility):
	var enemy_scene : PackedScene

	match enemy_name:
		'Fox': enemy_scene = self.base_fox
		'Imp': enemy_scene = self.base_imp
		'Minotaur': enemy_scene = self.base_minotaur

	var enemy : PackedScene = create_object(enemy_scene, map, map_pos, visibility)
	enemy.add_to_group('enemies')

	return enemy

func spawn_gold(value, map, map_pos, visibility):
	var coins : PackedScene = create_object(self.base_coins, map, map_pos, visibility)

	coins.add_to_group('loot')
	coins.set_gold_value(value)

	return coins

func spawn_map_object(object_name, map, map_pos, visibility):
	var object_scene : PackedScene

	match object_name:
		'TempWall': object_scene = self.base_tempwall
		'BaseStairs': object_scene = self.base_stairs
		'BaseGround': object_scene = self.base_ground
		'BaseWall': object_scene = self.base_wall
		'Spike Trap': object_scene = self.base_spiketrap

	var object : PackedScene = create_object(object_scene, map, map_pos, visibility)

	return object

# To be used when spawning something from an existing identity, like when
# player unpacks a map from server.
# Not for when spawning a new object that does not exist yet.
func spawn_obj_with_identity(object_identity):
	pass

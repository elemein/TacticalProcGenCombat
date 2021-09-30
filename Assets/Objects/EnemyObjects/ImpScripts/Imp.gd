extends ActorObj

const IMP_AI = preload("res://Assets/Objects/EnemyObjects/ImpScripts/ImpAI.gd")
const INVENTORY = preload("res://Assets/GUI/Inventory/Inventory.tscn")

var rng = RandomNumberGenerator.new()

var start_stats = {"Max HP" : 75, "HP" : 80, "Max MP": 40, "MP": 40, \
				"HP Regen" : 1, "MP Regen": 10, "Attack Power" : 5, \
				"Crit Chance": 5, "Spell Power" : 15, "Defense" : 0, \
				 "Speed": rng.randi_range(5,15), "View Range" : 4}

var loot_to_drop = []
var loot_dropped = false

# object vars
var ai_engine = IMP_AI.new()
var obj_spawner = GlobalVars.obj_spawner

var inventory = INVENTORY.instance()

var minimap_icon = 'Imp'

var identity = {"Category": "Actor", "CategoryType": "Enemy", 
				"Identifier": "Imp", "Max HP": start_stats['Max HP'],
				'HP': start_stats['Max HP'], 'Max MP': start_stats['Max MP'],
				'MP': start_stats['MP'], 'Map ID': null, 'Position': [0,0] , 
				'Facing': 'right', 'Instance ID': get_instance_id()}

func _init().(identity, start_stats):
	pass

func _ready():
	rng.randomize()
	stat_dict['Speed'] = rng.randi_range(5,15)

func setup_actor():
	object_identity['Map ID'] = get_parent_map().get_map_server_id()
	turn_timer.add_to_timer_group(self)
	translation.x = map_pos[0] * GlobalVars.TILE_OFFSET
	translation.z = map_pos[1] * GlobalVars.TILE_OFFSET
	
	ai_engine.set_actor(self)
	add_child(ai_engine)
	
	add_child(mover)
	mover.set_actor(self)
	
	add_child(inventory)
	inventory.setup_inventory(self)
	
	add_loot_to_inventory()

func _physics_process(_delta):
	if is_dead:
		if loot_dropped == false: drop_loot()

	else:
		if turn_timer.get_turn_in_process() == false: # We don't wanna decide a turn if timer isn't 0.
			if ready_status == false:
				decide_next_action()

func decide_next_action():
	ai_engine.run_engine()

func add_loot_to_inventory():
	var loot_seed = rng.randi_range(1, 100)
	
	if loot_seed <= 49: # Gold Spawn 
		inventory.add_to_gold(rng.randi_range(1,50))
		loot_to_drop.append('Gold') 
		
	elif (50 <= loot_seed) and (loot_seed <= 59): loot_to_drop.append("Sword")
	elif (60 <= loot_seed) and (loot_seed <= 69): loot_to_drop.append("Magic Staff")
	elif (70 <= loot_seed) and (loot_seed <= 79): loot_to_drop.append("Arcane Necklace")
	elif (80 <= loot_seed) and (loot_seed <= 89): loot_to_drop.append("Scabbard and Dagger")
	elif (90 <= loot_seed) and (loot_seed <= 94): loot_to_drop.append("Body Armour")
	elif (95 <= loot_seed) and (loot_seed <= 100): loot_to_drop.append("Leather Cuirass")
	
func drop_loot():
	if loot_to_drop[0] == 'Gold':
		var gold = obj_spawner.spawn_gold(inventory.get_gold_total(), parent_map, map_pos, true)
		Server.object_action_event(gold.get_id(), {"Command Type": "Spawn On Map"})
		inventory.subtract_from_gold(inventory.get_gold_total())
	else:
		var loot = obj_spawner.spawn_item(loot_to_drop[0], parent_map, map_pos, true)
		Server.object_action_event(loot.get_id(), {"Command Type": "Spawn On Map"})
	
	# drop items
	loot_dropped = true

func set_direction(direction):
	set_actor_dir(direction)

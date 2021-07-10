extends ActorObj

const AI_ENGINE = preload("res://Assets/SystemScripts/AIEngine.gd")
const INVENTORY = preload("res://Assets/GUI/Inventory/Inventory.tscn")

const OBJ_SPAWNER = preload("res://Assets/SystemScripts/ObjectSpawner.gd")

var base_coins = preload("res://Assets/Objects/MapObjects/Coins.tscn")

var rng = RandomNumberGenerator.new()

var start_stats = {"Max HP" : 100, "HP" : 100, "Max MP": 100, "MP": 100, \
				"HP Regen" : 1, "MP Regen": 7, "Attack Power" : 10, \
				"Spell Power" : 20, "Defense" : 0, \
				 "Speed": rng.randi_range(5,15), "View Range" : 4}

var loot_to_drop = []
var loot_dropped = false

# object vars
var ai_engine = AI_ENGINE.new()
var obj_spawner = OBJ_SPAWNER.new()

var inventory = INVENTORY.instance()

func _init().("Enemy", start_stats):
	pass

func _ready():
	rng.randomize()
	stat_dict['Speed'] = rng.randi_range(5,15)

func setup_actor():
	turn_timer.add_to_timer_group(self)
	translation.x = map_pos[0] * TILE_OFFSET
	translation.z = map_pos[1] * TILE_OFFSET
	
	ai_engine.set_actor(self)
	add_child(ai_engine)
	
	add_child(mover)
	mover.set_actor(self)
	
	add_child(inventory)
	inventory.setup_inventory(self)
	
	add_child(obj_spawner)
	
	viewfield = view_finder.find_view_field(map_pos[0], map_pos[1])
	
	add_loot_to_inventory()

func _physics_process(_delta):
	if is_dead:
		play_death_anim()
		if loot_dropped == false: drop_loot()

	else:
		if turn_timer.get_turn_in_process() == false: # We don't wanna decide a turn if timer isn't 0.
			if ready_status == false:
				decide_next_action()
		
		if in_turn == true:
			if proposed_action.split(" ")[0] == 'move':
				mover.set_actor_translation()
				
		if proposed_action != '' && in_turn == true:
			if proposed_action == 'idle':
				anim_state = "idle"
			else:
				anim_state = "walk"
		else:
			anim_state = "idle"

		handle_animations()

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
		obj_spawner.spawn_gold(inventory.get_gold_total(), map_pos)
		inventory.subtract_from_gold(inventory.get_gold_total())
	else:
		obj_spawner.spawn_item(loot_to_drop[0], map_pos)
	
	# drop items
	loot_dropped = true

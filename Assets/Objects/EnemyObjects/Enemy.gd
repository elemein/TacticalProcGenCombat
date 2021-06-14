extends ActorObj

const AI_ENGINE = preload("res://Assets/SystemScripts/AIEngine.gd")
const INVENTORY = preload("res://Assets/Objects/UIObjects/Inventory.tscn")

var base_coins = preload("res://Assets/Objects/MapObjects/Coins.tscn")

var rng = RandomNumberGenerator.new()

var start_stats = {"Max HP" : 100, "HP" : 100, "Max MP": 100, "MP": 100, \
				"HP Regen" : 1, "MP Regen": 7, "Attack Power" : 10, \
				"Spell Power" : 20, "Defense" : 0, \
				 "Speed": rng.randi_range(5,15), "View Range" : 4}

var loot_dropped = false

# object vars
var ai_engine = AI_ENGINE.new()
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

func set_action(action):
	proposed_action = action
	ready_status = true

func add_loot_to_inventory():
	inventory.add_to_gold(rng.randi_range(1,50))
	
func drop_loot():
	# drop gold
	var coins = base_coins.instance()
	coins.translation = Vector3(map_pos[0] * TILE_OFFSET, 0.6, map_pos[1] * TILE_OFFSET)
	coins.visible = true
	coins.set_map_pos([map_pos[0],map_pos[1]])
	coins.add_to_group('loot')
	coins.set_gold_value(inventory.get_gold_total())
	map.add_map_object(coins)
	
	inventory.subtract_from_gold(inventory.get_gold_total())
	
	# drop items
	loot_dropped = true

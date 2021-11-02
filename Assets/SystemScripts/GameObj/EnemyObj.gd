extends ActorObj
class_name EnemyObj

var rng = RandomNumberGenerator.new()

var ai_engine

var drop_table
var loot_to_drop = []
var loot_dropped = false

var obj_spawner = GlobalVars.obj_spawner

func _init(ai_eng_const, start_drop_table, obj_id, actor_stats).(obj_id, actor_stats):
	ai_engine = ai_eng_const.new()
	drop_table = start_drop_table
	rng.randomize()

func _physics_process(_delta):
	if is_dead:
		if loot_dropped == false: drop_loot()

	else:
		if turn_timer.get_turn_in_process() == false: # We don't wanna decide a turn if timer isn't 0.
			if ready_status == false:
				decide_next_action()

func setup_actor():
	object_identity['Map ID'] = get_parent_map().get_map_server_id()
	turn_timer.add_to_timer_group(self)
	translation.x = map_pos[0] * GlobalVars.TILE_OFFSET
	translation.z = map_pos[1] * GlobalVars.TILE_OFFSET
	
	ai_engine.set_actor(self)
	add_child(ai_engine)
	
	add_child(mover)
	mover.set_actor(self)
	
	add_loot_to_inventory()

func decide_next_action():
	ai_engine.run_engine()

func add_loot_to_inventory():
	var loot_seed = rng.randi_range(1, 100)
	
	for drop_chance in drop_table.keys():
		if loot_seed <= int(drop_chance):
			loot_to_drop.append(drop_table[drop_chance])
			
			if drop_table[drop_chance] == 'Gold': gold += rng.randi_range(1,50)
			
			break

func drop_loot():
	for item in loot_to_drop:
		match item:
			'Gold':
				var gold_obj = obj_spawner.spawn_gold(gold, parent_map, map_pos, true)
				Server.object_action_event(gold_obj.get_id(), {"Command Type": "Spawn On Map"})
				gold = 0
			
			_:
				var loot = obj_spawner.spawn_item(item, parent_map, map_pos, true)
				Server.object_action_event(loot.get_id(), {"Command Type": "Spawn On Map"})

	# drop items
	loot_dropped = true

func set_direction(direction):
	set_actor_dir(direction)

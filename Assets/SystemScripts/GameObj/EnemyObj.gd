extends ActorObj
class_name EnemyObj

var rng = RandomNumberGenerator.new()

var ai_engine

var drop_table
var loot_to_drop = []
var loot_dropped = false

var obj_spawner = GlobalVars.obj_spawner

func _init(ai_eng_const, start_drop_table, obj_id, relation_rules, actor_stats).(obj_id, relation_rules, actor_stats):
	self.ai_engine = ai_eng_const.new()
	self.drop_table = start_drop_table
	self.rng.randomize()

func _physics_process(_delta):
	if is_dead:
		if self.loot_dropped == false: drop_loot()

	else:
		if turn_timer.get_turn_in_process() == false: # We don't wanna decide a turn if timer isn't 0.
			if ready_status == false:
				decide_next_action()

func setup_actor():
	object_identity['Map ID'] = get_parent_map().get_map_server_id()
	translation.x = map_pos[0] * GlobalVars.TILE_OFFSET
	translation.z = map_pos[1] * GlobalVars.TILE_OFFSET
	
	self.ai_engine.set_actor(self)
	add_child(self.ai_engine)
	
	add_loot_to_inventory()

func decide_next_action():
	self.ai_engine.run_engine()

func add_loot_to_inventory():
	var loot_seed = self.rng.randi_range(1, 100)
	
	for drop_chance in self.drop_table.keys():
		if loot_seed <= int(drop_chance):
			self.loot_to_drop.append(self.drop_table[drop_chance])
			
			if self.drop_table[drop_chance] == 'Gold': gold += self.rng.randi_range(1,50)
			
			break

func drop_loot():
	for item in self.loot_to_drop:
		match item:
			'Gold':
				var gold_obj = self.obj_spawner.spawn_gold(gold, parent_map, map_pos, true)
				Server.object_action_event(gold_obj.get_id(), {"Command Type": "Spawn On Map"})
				gold = 0
			
			_:
				var loot = self.obj_spawner.spawn_item(item, parent_map, map_pos, true)
				Server.object_action_event(loot.get_id(), {"Command Type": "Spawn On Map"})

	# drop items
	self.loot_dropped = true

extends AI_Engine

func run_engine():
	reset_vars()
	find_players_in_viewfield()
	
	if player_pos.size() > 0: ai_state = 'active'
	
	if ai_state == 'idle':
		actor.set_action('idle')
	elif ai_state == 'active':
		pathfinder_direction = 'idle'

		pathfind()
		pathfinder_direction = determine_direction_of_path()
		
		if actor.get_mp() >= 25:
			if (dist_from_player in [1,2]):
				if player_is_in_fireball_range(players_in_focus[0].get_map_pos()):
					fireball_player()
				else: move_toward_player()
			elif dist_from_player > 2: move_toward_player()
			else: idle()
		
		else:
			if dist_from_player == 1: basic_attack_player()
			elif dist_from_player > 2: move_toward_player()
			else: idle()

func fireball_player():
	actor.set_actor_dir(pathfinder_direction)
	actor.set_action('fireball')

func move_toward_player():
	var move_command = 'move %s' % [pathfinder_direction]
	
	if actor.check_move_action(move_command):
		actor.set_action(move_command)
	else: actor.set_action('idle')

func basic_attack_player():
	actor.set_actor_dir(pathfinder_direction)
	actor.set_action('basic attack')

func idle():
	actor.set_action('idle')

func player_is_in_fireball_range(target_pos) -> bool:
	var self_pos = actor.get_map_pos()
	
	if target_pos[0] == self_pos[0]: return true
	elif target_pos[1] == self_pos[1]: return true
	
	# have to do janky shit below because apparently comparing arrays doesnt work..?
	
	# downleft
	elif (target_pos[0] == self_pos[0]-1) and (target_pos[1] == self_pos[1]-1): 
		return true
	elif (target_pos[0] == self_pos[0]-2) and (target_pos[1] == self_pos[1]-2): 
		return true
	
	#downright
	elif (target_pos[0] == self_pos[0]-1) and (target_pos[1] == self_pos[1]+1): 
		return true
	elif (target_pos[0] == self_pos[0]-2) and (target_pos[1] == self_pos[1]+2): 
		return true
	
	#upleft
	elif (target_pos[0] == self_pos[0]+1) and (target_pos[1] == self_pos[1]-1): 
		return true
	elif (target_pos[0] == self_pos[0]+2) and (target_pos[1] == self_pos[1]-2): 
		return true

	#upright
	elif (target_pos[0] == self_pos[0]+1) and (target_pos[1] == self_pos[1]+1): 
		return true
	elif (target_pos[0] == self_pos[0]+2) and (target_pos[1] == self_pos[1]+2): 
		return true
	
	else: return false

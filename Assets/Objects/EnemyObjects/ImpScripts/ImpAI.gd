extends AI_Engine

func run_engine():
	reset_vars()
	find_players_in_viewfield()
	determine_ai_state()
	
	if ai_state == 'idle': idle()
	elif ai_state == 'active':
		get_pathfinder_direction_to_player()
		
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

func player_is_in_fireball_range(target_pos) -> bool:
	var self_pos = actor.get_map_pos()
	
	if target_pos[0] == self_pos[0]: return true
	elif target_pos[1] == self_pos[1]: return true
	
	# have to do janky shit below because apparently comparing arrays doesnt work..?
	
	#downleft
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

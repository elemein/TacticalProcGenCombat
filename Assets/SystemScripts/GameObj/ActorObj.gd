extends GameObj
class_name ActorObj

const ACTOR_MOVER = preload("res://Assets/SystemScripts/ActorMover.gd")
const VIEW_FINDER = preload("res://Assets/SystemScripts/ViewFinder.gd")

const ACTOR_NOTIF_LABEL = preload("res://Assets/GUI/ActorNotifLabel/ActorNotifLabel.tscn")

onready var model = $Graphics
onready var anim : AnimationPlayer = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI/Action")
onready var actions = $Actions
onready var tween = $Tween

# Sound effects
onready var audio_hit = $Audio/Hit

# Spell signals
signal spell_cast_fireball
signal spell_cast_self_heal
signal spell_cast_basic_attack
signal spell_cast_dash
signal action_drop_item
signal action_equip_item
signal action_unequip_item

# Status bar signals
signal status_bar_hp(hp, max_hp)
signal status_bar_mp(mp, max_mp)

var mover = ACTOR_MOVER.new()
var view_finder = VIEW_FINDER.new()

var is_dead = false

var viewfield = []
var proposed_action = ""

var turn_anim_timer = Timer.new()
var anim_timer_waittime = 1

# movement and positioning related vars
var direction_facing = "down"

# turn_state vars
var ready_status = false
var in_turn = false

# vars for animation
var anim_state = "idle"
var effect = null

# vars for minimap
var was_visible = false

var stat_dict = {"Max HP" : 0, "HP" : 0, "Max MP": 0, "MP": 0, \
				"HP Regen" : 0, "MP Regen": 0, "Attack Power" : 0, \
				"Crit Chance" : 0, "Spell Power" : 0, "Defense" : 0, \
				"Speed": 0, "View Range" : 0}
var inventory : Dictionary = {}
var selected_item : InvObject = null
var __server_inventory : Dictionary = {}
var gold : int = 0

func _ready():
	add_child(self.mover)
	self.mover.set_actor(self)

func _init(obj_id, relation_rules, actor_stats).(obj_id, relation_rules):
	self.stat_dict = actor_stats

	self.turn_anim_timer.set_one_shot(true)
	self.turn_anim_timer.set_wait_time(1)
	add_child(self.turn_anim_timer)
	
	add_child(self.view_finder)
	self.view_finder.set_actor(self)

func set_action(action):
	self.proposed_action = action

	match action:
		'fireball':
			if $Actions/Attacks/Fireball.mana_check():
				self.ready_status = true
			else: return
		'basic attack':
			if $Actions/Attacks/BasicAttack.mana_check():
				self.ready_status = true
			else: return
		'dash':
			if $Actions/Dash.mana_check():
				self.ready_status = true
			else: return
		'self heal':
			if $Actions/SelfHeal.mana_check():
				self.ready_status = true
			else: return

	self.ready_status = true
	
	Server.update_all_actor_stats(self)

#	if object_identity['CategoryType'] == 'Player': gui.set_action(proposed_action)

func process_turn():
	if visible:
		self.was_visible = true
	if self.proposed_action.split(" ")[0] == 'move': self.turn_anim_timer.set_wait_time(0.35)
	elif self.proposed_action == 'idle': self.turn_anim_timer.set_wait_time(0.00001)
	elif self.proposed_action == 'basic attack': 
		self.turn_anim_timer.set_wait_time($Actions/Attacks/BasicAttack.anim_time)
		Server.object_action_event(object_identity, {"Command Type": "Basic Attack", "Value": get_direction_facing()})
	elif self.proposed_action == 'fireball': self.turn_anim_timer.set_wait_time($Actions/Attacks/Fireball.anim_time)
	elif self.proposed_action == 'self heal': self.turn_anim_timer.set_wait_time($Actions/SelfHeal.anim_time)
	elif self.proposed_action == 'dash': self.turn_anim_timer.set_wait_time(0.6)
	elif self.proposed_action in ['drop item', 'equip item', 'unequip item']: self.turn_anim_timer.set_wait_time(0.5)
	self.turn_anim_timer.start()

	# Sets target positions for move and basic attack.
	if self.proposed_action.split(" ")[0] == 'move':
#		set_actor_dir(proposed_action.split(" ")[1])
		if check_move_action(self.proposed_action) == true:
			print([object_identity, {"Command Type": "Move", "Value": self.proposed_action.split(" ")[1]}])
			Server.object_action_event(object_identity, {"Command Type": "Move", "Value": self.proposed_action.split(" ")[1]})
	
	elif self.proposed_action == 'idle': 
		Server.object_action_event(object_identity, {"Command Type": "Idle"})
	
	elif self.proposed_action == 'fireball':
		Server.object_action_event(object_identity, {"Command Type": "Fireball"})
	elif self.proposed_action == 'dash':
		Server.object_action_event(object_identity, {"Command Type": "Dash"})
	elif self.proposed_action == 'self heal':
		Server.object_action_event(object_identity, {"Command Type": "Self Heal"})
		
	elif self.proposed_action == 'drop item':
		drop_item(self.selected_item)
	elif self.proposed_action == 'equip item':
		equip_item(self.selected_item)
	elif self.proposed_action == 'unequip item':
		unequip_item(self.selected_item)

	turn_regen()

	self.in_turn = true
	
	# Send the state of the game to the player after every turn
	for remote_player in Server.player_list:
		if remote_player.get_id()['NetID'] != 1:
			Server.send_inventory_to_requester(remote_player.get_id())
			Server.update_all_actor_stats(remote_player)

func turn_regen():
	# Apply any regen effects
	if object_identity['HP'] < object_identity['Max HP']:
		Server.update_actor_stat(object_identity, {"Stat": "HP", "Modifier": self.stat_dict['HP Regen']})
		if object_identity['HP'] > object_identity['Max HP']:
			var difference = object_identity['HP'] - object_identity['Max HP']
			Server.update_actor_stat(object_identity, {"Stat": "HP", "Modifier": -difference})

	if object_identity['MP'] < object_identity['Max MP']:
		Server.update_actor_stat(object_identity, {"Stat": "MP", "Modifier": self.stat_dict['MP Regen']})
		if object_identity['MP'] > object_identity['Max MP']:
			var difference = object_identity['MP'] - object_identity['Max MP']
			Server.update_actor_stat(object_identity, {"Stat": "MP", "Modifier": -difference})

func perform_action(action):
	match action['Command Type']:
		'Basic Attack': emit_signal("spell_cast_basic_attack")
		
		'Fireball': emit_signal("spell_cast_fireball")
		
		'Dash': emit_signal("spell_cast_dash")
		
		'Self Heal': emit_signal("spell_cast_self_heal")

func end_turn():
	self.proposed_action = ''
	self.in_turn = false
	self.ready_status = false
	
	# Send the state of the game to the player after round end
	for remote_player in Server.player_list:
		Server.update_all_actor_stats(self)

# View related functions.
func find_viewfield():
	self.viewfield = self.view_finder.find_view_field(map_pos[0], map_pos[1])

func resolve_viewfield_to_screen():
	self.view_finder.resolve_viewfield()

func find_and_render_viewfield():
	find_viewfield()
	resolve_viewfield_to_screen()

# Movement related functions.
func check_move_action(move):
	return self.mover.check_move_action(move)

func move_actor_in_facing_dir(amount):
	self.mover.move_actor(amount)

func play_anim(name, forced=false):
	if self.anim.current_animation == name and not forced: return
	else: self.anim.play(name)

func display_notif(notif_text, notif_type):
	var new_notif = ACTOR_NOTIF_LABEL.instance()
	add_child(new_notif)
	new_notif.create_notif(notif_text, notif_type)

func take_damage(damage_instance):
	var damage = damage_instance['Amount']
	var is_crit = damage_instance['Crit']
	var attacker = damage_instance['Attacker']
	
	if not self.is_dead:
		var damage_multiplier = 100 / (100+float(self.stat_dict['Defense']))
		damage = floor(damage * damage_multiplier)
		damage = floor(damage)
		
		Server.update_actor_stat(object_identity, {"Stat": "HP", "Modifier": -damage})
		
		if is_crit: 
			Server.actor_notif_event(object_identity, ("-" + str(damage)) + "!", 'crit damage')
		else: 
			Server.actor_notif_event(object_identity, ("-" + str(damage)), 'damage')
		
		print("%s has %s HP" % [self.get_id()['Identifier'], self.stat_dict['HP']])
		
		# Play a random audio effect upon getting hit
		var num_audio_effects = self.audio_hit.get_children().size()
		var hit_sound = self.audio_hit.get_children()[randi() % num_audio_effects]
		hit_sound.translation = self.translation
		hit_sound.play()
		
		# Update the health bar
		emit_signal("status_bar_hp", self.stat_dict['HP'], stat_dict['Max HP'])

		if self.stat_dict['HP'] <= 0:
			Server.object_action_event(object_identity, {"Command Type": "Die"})

func die():
	self.is_dead = true
	
	if GlobalVars.peer_type == 'server': turn_timer.remove_from_timer_group(self)
	
	self.proposed_action = 'idle'
	
	$HealthManaBar3D.visible = false

	play_death_anim()
	
	if object_identity['Instance ID'] == GlobalVars.get_self_instance_id():
		self.tween.interpolate_callback(self, 2, 'move_to_death_screen')
	else:
		if GlobalVars.peer_type == 'server': parent_map.log_enemy_death(self)

func move_to_death_screen():
	if GlobalVars.get_self_netid() != 1:
		Server.peer.disconnect_peer(1, true)
	get_tree().change_scene('res://Assets/GUI/DeathScreen/DeathScreen.tscn')

func play_death_anim():
	var peak = Vector3(self.model.translation.x, 2, model.translation.z)
	var ground = Vector3(self.model.translation.x, model.translation.y + 0.2, model.translation.z)
	var fall_rot = Vector3(-90, self.model.rotation_degrees.y, model.rotation_degrees.z)
	
	# Move up and down, to simulate impact.
	self.tween.interpolate_property(self.model, "translation", ground, peak, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	self.tween.interpolate_property(self.model, "translation", peak, ground, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN, 0.5)
	
	# Cause fall over.
	self.tween.interpolate_property(self.model, "rotation_degrees", model.rotation_degrees, fall_rot, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	self.tween.start()

# Getters
func get_hp(): return stat_dict['HP']

func get_mp(): return stat_dict['MP']

func get_speed(): return stat_dict['Speed']

func get_viewrange(): return stat_dict['View Range']

func get_attack_power() -> int: return stat_dict['Attack Power']

func get_spell_power() -> int: return stat_dict['Spell Power']

func get_defense() -> int: return stat_dict['Defense']

func get_crit_chance() -> int: return stat_dict['Crit Chance']

func get_is_dead() -> bool: return is_dead

func get_stat_dict() -> Dictionary: return stat_dict

func get_viewfield() -> Array: return viewfield

func get_action() -> String: return proposed_action

func get_direction_facing() -> String: return direction_facing

func get_turn_anim_timer() -> Object: return turn_anim_timer

# Setters
func set_stat_dict(changed_dict): stat_dict = changed_dict

func set_actor_dir(dir_facing):
	self.direction_facing = dir_facing

func set_direction(direction):
	set_actor_dir(direction)

	match self.direction_facing:
		'upleft': self.model.rotation_degrees.y = 135
		'upright': self.model.rotation_degrees.y = 45
		'downleft': self.model.rotation_degrees.y = 225
		'downright': self.model.rotation_degrees.y = 315
		
		'up': self.model.rotation_degrees.y = 90
		'down': self.model.rotation_degrees.y = 270
		'left': self.model.rotation_degrees.y = 180
		'right': self.model.rotation_degrees.y = 0

func set_hp(new_hp):
	self.stat_dict['HP'] = stat_dict['Max HP'] if (new_hp > stat_dict['Max HP']) else new_hp
	object_identity['HP'] = self.stat_dict['HP']
	emit_signal("status_bar_hp", self.stat_dict['HP'], stat_dict['Max HP'])
	
func set_mp(new_mp):
	self.stat_dict['MP'] = stat_dict['Max MP'] if (new_mp > stat_dict['Max MP']) else new_mp
	object_identity['MP'] = self.stat_dict['MP']
	emit_signal("status_bar_mp", self.stat_dict['MP'], stat_dict['Max MP'])
	
func set_attack_power(new_value):
	self.stat_dict['Attack Power'] = new_value
	Signals.emit_signal("player_attack_power_updated", new_value)

func set_spell_power(new_value):
	self.stat_dict['Spell Power'] = new_value
	Signals.emit_signal("player_spell_power_updated", new_value)

func set_defense(new_value):
	self.stat_dict['Defense'] = new_value

func set_graphics(graphics_node):
	remove_child($Graphics)
	add_child(graphics_node)
	self.model = graphics_node
	self.anim = graphics_node.find_node("AnimationPlayer")
	

func drop_item(item : InvObject):
	item.drop_item()
	
func equip_item(item : InvObject):
	# Unequip different item from same category
	for existing_item in self.inventory:
		if self.inventory[existing_item]['equipped'] \
		and existing_item.get_id()['CategoryType'] == item.get_id()['CategoryType']:
			self.inventory[existing_item]['equipped'] = false
			existing_item.unequip_item()
	
	item.equip_item()

func unequip_item(item : InvObject):
	item.unequip_item()

func build_inv_from_server(inventory):
	for item in self.inventory:
		if not item.object_id in self.__server_inventory:
			if GlobalVars.peer_type == 'client':
				
				# Create the item
				var new_item = GlobalVars.obj_spawner.\
				spawn_item(self.inventory[item]['description'], 'Inventory', 'Inventory', false)
				self.__server_inventory[item.object_id] = new_item
				
				# Add to the player's inventory
				GlobalVars.get_self_obj().inventory[new_item] = {'equipped': inventory[item]['equipped'], 'description': new_item['identity']['Identifier'], 'server_id': item.object_id, 'item': new_item}
				new_item.item_owner = GlobalVars.get_self_obj()
		else:
			GlobalVars.get_self_obj().inventory[self.__server_inventory[item.object_id]]['equipped'] = inventory[item]['equipped']
			
	# Remove items no longer in inventory
	var server_item_ids = []
	for server_item_id in self.inventory:
		server_item_ids.append(server_item_id.object_id)
	for item in GlobalVars.get_self_obj().inventory:
		var server_id = GlobalVars.get_self_obj().inventory[item]['server_id']
		if not server_id in server_item_ids:
			GlobalVars.get_self_obj().inventory.erase(item)
			self.__server_inventory.erase(server_id)

func connect_to_status_bars():
	var _result = self.connect("status_bar_hp", get_node("/root/World/GUI"), "_on_Player_status_bar_hp")
	_result = self.connect("status_bar_mp", get_node("/root/World/GUI"), "_on_Player_status_bar_mp")

	Signals.emit_signal("player_attack_power_updated", self.stat_dict['Attack Power'])
	Signals.emit_signal("player_spell_power_updated", self.stat_dict['Spell Power'])

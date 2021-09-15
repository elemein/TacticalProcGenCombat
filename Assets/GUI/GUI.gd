extends MarginContainer

var blank_action = preload("res://Assets/GUI/ActionIcon/Blank_Action.png")
var movement_arrow = preload("res://Assets/GUI/ActionIcon/Arrow.png")
var basic_attack = preload("res://Assets/GUI/ActionIcon/Basic_Attack.png")
var fireball = preload("res://Assets/GUI/ActionIcon/Fireball.png")
var drop_item = preload("res://Assets/GUI/ActionIcon/Drop_Item.png")
var equip_item = preload("res://Assets/GUI/ActionIcon/Equip_Item.png")
var unequip_item = preload("res://Assets/GUI/ActionIcon/Unequip_Item.png")
var dash = preload("res://Assets/GUI/ActionIcon/Dash.png")
var self_heal = preload("res://Assets/GUI/ActionIcon/Self_Heal.png")

onready var action_holder = get_node("/root/World/GUI/Action/Proposed Action")

func _ready():
	clear_action()

func set_action(proposed_action):
	var direction = proposed_action.split(" ")[1] if proposed_action.split(" ")[0] == 'move' else ''
	if proposed_action.split(" ")[0] == 'move': proposed_action = 'move'
	
	match proposed_action:
		'move':
			action_holder.set_texture(movement_arrow)
			match direction:
				'upleft': action_holder.rotation_degrees = 180 + 45
				'upright': action_holder.rotation_degrees = 180 + 90 + 45
				'downleft': action_holder.rotation_degrees = 90 + 45
				'downright': action_holder.rotation_degrees = 45	
				
				'up': action_holder.rotation_degrees = -90
				'down': action_holder.rotation_degrees = 90
				'left': action_holder.rotation_degrees = 180
				'right': action_holder.rotation_degrees = 0
	
		'basic attack': set_texture_unrotated(basic_attack)
		'fireball': set_texture_unrotated(fireball)
		'dash': set_texture_unrotated(dash)
		'self heal': set_texture_unrotated(self_heal)
		'drop item': set_texture_unrotated(drop_item)
		'equip item': set_texture_unrotated(equip_item)
		'unequip item': set_texture_unrotated(unequip_item)

func set_texture_unrotated(action):
	action_holder.rotation_degrees = 0
	action_holder.set_texture(action)

func _physics_process(_delta):
	pass

func clear_action():
	action_holder.rotation_degrees = 0
	action_holder.set_texture(blank_action)

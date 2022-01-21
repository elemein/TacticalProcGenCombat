extends MarginContainer

var base_action = preload("res://Gui/Objects/Icons/base_x76.png")
var movement_arrow = preload("res://Gui/Objects/Icons/Abilities/Arrow_x200.png")
var basic_attack = preload("res://Gui/Objects/Icons/Abilities/Basic_Attack_x200.png")
var fireball = preload("res://Gui/Objects/Icons/Abilities/Fireball_x200.png")
var drop_item = preload("res://Gui/Objects/Icons/Abilities/Drop_Item_x200.png")
var equip_item = preload("res://Gui/Objects/Icons/Abilities/Equip_Item_x200.png")
var unequip_item = preload("res://Gui/Objects/Icons/Abilities/Unequip_Item_x200.png")
var dash = preload("res://Gui/Objects/Icons/Abilities/Dash_x200.png")
var self_heal = preload("res://Gui/Objects/Icons/Abilities/Self_Heal_x200.png")

onready var action_holder = get_node("/root/World/GUI/Action/Proposed Action")

func _ready():
	clear_action()

func set_action(proposed_action):
	var direction = proposed_action.split(" ")[1] if proposed_action.split(" ")[0] == 'move' else ''
	if proposed_action.split(" ")[0] == 'move': proposed_action = 'move'
	
	match proposed_action:
		'move':
			self.action_holder.set_texture(self.movement_arrow)
			match direction:
				'upleft': self.action_holder.rotation_degrees = 180 + 45
				'upright': self.action_holder.rotation_degrees = 180 + 90 + 45
				'downleft': self.action_holder.rotation_degrees = 90 + 45
				'downright': self.action_holder.rotation_degrees = 45	
				
				'up': self.action_holder.rotation_degrees = -90
				'down': self.action_holder.rotation_degrees = 90
				'left': self.action_holder.rotation_degrees = 180
				'right': self.action_holder.rotation_degrees = 0
	
		'basic attack': set_texture_unrotated(self.basic_attack)
		'fireball': set_texture_unrotated(self.fireball)
		'dash': set_texture_unrotated(self.dash)
		'self heal': set_texture_unrotated(self.self_heal)
		'drop item': set_texture_unrotated(self.drop_item)
		'equip item': set_texture_unrotated(self.equip_item)
		'unequip item': set_texture_unrotated(self.unequip_item)

func set_texture_unrotated(action):
	self.action_holder.rotation_degrees = 0
	self.action_holder.set_texture(action)

func clear_action():
	self.action_holder.rotation_degrees = 0
	self.action_holder.set_texture(self.base_action)

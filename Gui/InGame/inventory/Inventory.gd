extends Control


# UI nodes
onready var inventory_tabs = find_node('TabContainer')
onready var active_inventory_tab = self.inventory_tabs.find_node('All')
onready var option_menu = ItemList.new()

# Icons
onready var item_placeholder_icon = preload("res://Assets/GUI/NewInventory/ItemPlaceholder.png")
onready var item_blank = preload("res://Assets/GUI/NewInventory/blank_x76.png")

# Icon nodes
onready var accessory_icon = find_node('Accessory').find_node('Icon')
onready var armour_icon = find_node('Armour').find_node('Icon')
onready var weapon_icon = find_node('Weapon').find_node('Icon')

# Label nodes
onready var item_stats_label = find_node('Stats').find_node('Item').find_node('Label')
onready var player_stats_label = find_node('Stats').find_node('Player').find_node('Label')

# Misc
var all_inventory_tabs = []
var window_offset = Vector2()
var local_item = null
var item_categories = ['Accessory', 'Armour', 'Weapon']
var item_tab_dict = {}
var icon_types = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	if len(PlayerInfo.abilities) == 0:
		PlayerInfo.abilities = ["BasicAttackAbility", "FireballAbility", "SelfHealAbility"]
		var _result = get_tree().change_scene("res://World.tscn")
		self.queue_free()
	else:
		yield(Signals, "world_loaded")
		visible = false
		
		# Setup option menu when selecting and item
		add_child(self.option_menu)
		self.option_menu.name = "self.option_menu"
		self.option_menu.size_flags_horizontal = 0
		self.option_menu.size_flags_vertical = 0
		self.option_menu.rect_min_size = Vector2(65, 45)
		self.option_menu.connect("item_selected", self, "option_action")
		self.option_menu.visible = false
		self.option_menu.allow_reselect = true
		
		self.all_inventory_tabs.append(self.active_inventory_tab)
		
		# Setup tab container
		for category in self.item_categories:
			var new_tab = self.active_inventory_tab.duplicate()
			new_tab.name = category
			self.inventory_tabs.add_child(new_tab)
			self.all_inventory_tabs.append(new_tab)
			
		self.icon_types = {
			'Accessory': self.accessory_icon,
			'Armour': self.armour_icon,
			'Weapon': self.weapon_icon,
		}
			
		update_player_stats()
		setup_item_slots()
			
func setup_item_slots():
	yield(get_tree(), "idle_frame")
	self.item_tab_dict = {}
	for child in self.inventory_tabs.get_children():
		self.item_tab_dict[child] = {}
		var item_slots = child.get_children()[0].get_children()
		for cnt in item_slots.size():
			self.item_tab_dict[child][cnt] = {
				'Label': item_slots[cnt].get_node('Margin').get_node('Vbox').get_node('Label'),
				'Icon': item_slots[cnt].get_node('Margin').get_node('Vbox').get_node('Icon'),
				'Parent': item_slots[cnt],
				'ID': cnt,
				'Hovered': item_slots[cnt].get_node('Hovered'),
				'Equipped': item_slots[cnt].get_node('Equipped'),
			}

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			self.window_offset = get_viewport_rect().size / 2 - rect_size / 2
			match event.scancode:
				16777218:
					visible = not visible
					self.option_menu.visible = false

			yield(get_tree(), "idle_frame")
			rect_position = self.window_offset
			
	# Hide option menu if clicking outside of the inventory
	elif event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == 1:
			if event.global_position < self.active_inventory_tab.rect_global_position or \
			event.global_position > self.active_inventory_tab.rect_global_position + self.active_inventory_tab.rect_size:
				self.option_menu.visible = false
			
func _process(_delta):
	if not GlobalVars.get_client_state() == 'loading' and GlobalVars.get_self_obj() != null:
		# Set the items for the current inventory tab
		for item_index in 8:
			var item_node = self.item_tab_dict[self.active_inventory_tab][item_index]
			
			if GlobalVars.get_self_obj().inventory.keys().size() > item_index:
				var player_item = GlobalVars.get_self_obj().inventory.keys()[item_index]
				
				if self.active_inventory_tab.name in ['All', player_item.get_id()['CategoryType']]:
					item_node['Label'].text = player_item.get_id()['Identifier'].replace(' ', '\n')
					item_node['Icon'].texture = player_item.inventory_icon
					if GlobalVars.get_self_obj().inventory[player_item]['equipped']:
						item_node['Equipped'].visible = true
					else:
						item_node['Equipped'].visible = false
				else:
					item_node['Label'].text = ''
					item_node['Icon'].texture = self.item_blank
					item_node['Equipped'].visible = false
			else:
					item_node['Label'].text = ''
					item_node['Icon'].texture = self.item_blank
					item_node['Equipped'].visible = false

		# Set blank icons and names for any empty spot
		for placeholder_item in self.item_tab_dict[self.active_inventory_tab].values():
			if placeholder_item['Icon'].texture == self.item_placeholder_icon:
				placeholder_item['Label'].text = ''
				placeholder_item['Icon'].texture = self.item_blank
				
		# Set the equipped items icon for whatever was last selected
		var empty_categories = self.item_categories.duplicate()
		for category in self.item_categories:
			for item in GlobalVars.get_self_obj().inventory:
				if item.get_id()['CategoryType'] == category and GlobalVars.get_self_obj().inventory[item]['equipped']:
					self.icon_types[category].texture = item.inventory_icon
					empty_categories.erase(category)
					
		for empty_slot in empty_categories:
			self.icon_types[empty_slot].texture = self.item_placeholder_icon
		
		update_player_stats()
		
func item_selected(num):
	var player_item
	var index = -1
	for item in GlobalVars.get_self_obj().inventory:
		index += 1
		if index == num:
			self.local_item = item
			player_item = GlobalVars.get_self_obj().inventory[self.local_item]
		
	set_option_menu(player_item['equipped'])
	self.option_menu.rect_position = get_viewport().get_mouse_position() - self.window_offset
	self.option_menu.visible = true
	
func update_item_stats(num):
	self.item_stats_label.text = ''
	var item_stats = {
		'attack_power_bonus': 'Attack Power', 
		'spell_power_bonus': 'Spell Power', 
		'defense_bonus': 'Defense',
	}
	
	if GlobalVars.get_self_obj().inventory.keys().size() > num:
		var hovered_item = GlobalVars.get_self_obj().inventory.keys()[num]
		for stat in item_stats:
			if not hovered_item.get(stat) == null:
				self.item_stats_label.text += item_stats[stat] + ' +' + str(hovered_item.get(stat)) + '\n'
		self.item_stats_label.text = self.item_stats_label.text.strip_edges()
	
func update_player_stats():
	self.player_stats_label.text = ''
	for stat in GlobalVars.get_self_obj().stat_dict:
		self.player_stats_label.text += stat + ' ' + str(GlobalVars.get_self_obj().stat_dict[stat]) + '\n'
	self.player_stats_label.text = self.player_stats_label.text.strip_edges()
	
func option_action(index):
	var server_item_id = GlobalVars.get_self_obj().inventory[self.local_item].get('server_id')
	if not server_item_id:
		server_item_id = self.local_item.get_id()['Instance ID']
	if not GlobalVars.get_self_obj().in_turn:
		match index:
			0:  # equip item
				var player_inventory = GlobalVars.get_self_obj().inventory
				if not player_inventory[self.local_item]['equipped']:
					set_option_menu(true)
					Server.request_for_player_action({"Command Type": "Equip Item", "Value": server_item_id})
					visible = false

				# unequip item
				else:
					set_option_menu(false)
					Server.request_for_player_action({"Command Type": "Unequip Item", "Value": server_item_id})
					visible = false

			1:  # drop item
				Server.request_for_player_action({"Command Type": "Drop Item", "Value": server_item_id})
				self.option_menu.visible = false
				
func set_option_menu(equipped : bool):
	self.option_menu.clear()
	if equipped:
		self.option_menu.add_item('Unequip')
	else:
		self.option_menu.add_item('Equip')
	self.option_menu.add_item('Drop')

##################################################
#####          WARNING!!!!!!                 #####
#####          SIGNALS BELOW                 #####
##################################################


### Determine when to show the equipped border ###
func clicked(event, num):
	if event is InputEventMouseButton \
	and event.is_pressed() \
	and event.button_index == 1:
		if self.item_tab_dict[self.active_inventory_tab][num]['Icon'].texture != self.item_blank:
			item_selected(num)
		else:
			self.option_menu.visible = false

func _on_Item1_gui_input(event):
	clicked(event, 0)

func _on_Item2_gui_input(event):
	clicked(event, 1)

func _on_Item3_gui_input(event):
	clicked(event, 2)

func _on_Item4_gui_input(event):
	clicked(event, 3)

func _on_Item5_gui_input(event):
	clicked(event, 4)

func _on_Item6_gui_input(event):
	clicked(event, 5)

func _on_Item7_gui_input(event):
	clicked(event, 6)

func _on_Item8_gui_input(event):
	clicked(event, 7)

func _on_TabContainer_tab_selected(tab):
	self.option_menu.visible = false
	self.active_inventory_tab = self.all_inventory_tabs[tab]
	
func _on_TabContainer_gui_input(event):
	if event is InputEventMouseButton \
	and event.is_pressed() \
	and event.button_index == 1:
		self.option_menu.visible = false

### Determine when to show an item as hovered by the coursor ###
func hovered(num):
	# Remove any previous hovers
	for item_slot in self.item_tab_dict[self.active_inventory_tab]:
		self.item_tab_dict[self.active_inventory_tab][item_slot]['Hovered'].visible = false
	
	if not self.item_tab_dict[self.active_inventory_tab][num]['Equipped'].visible \
	and self.item_tab_dict[self.active_inventory_tab][num]['Icon'].texture != self.item_blank:
		self.item_tab_dict[self.active_inventory_tab][num]['Hovered'].visible = true
	update_item_stats(num)

func _on_Item1_mouse_entered():
	hovered(0)

func _on_Item2_mouse_entered():
	hovered(1)

func _on_Item3_mouse_entered():
	hovered(2)

func _on_Item4_mouse_entered():
	hovered(3)

func _on_Item5_mouse_entered():
	hovered(4)

func _on_Item6_mouse_entered():
	hovered(5)

func _on_Item7_mouse_entered():
	hovered(6)

func _on_Item8_mouse_entered():
	hovered(7)
	
### Determine when to hide the hovered border ###
func mouse_exited(num):
	if not self.option_menu.visible:
		self.item_tab_dict[self.active_inventory_tab][num]['Hovered'].visible = false

func _on_Item1_mouse_exited():
	mouse_exited(0)

func _on_Item2_mouse_exited():
	mouse_exited(1)

func _on_Item3_mouse_exited():
	mouse_exited(2)

func _on_Item4_mouse_exited():
	mouse_exited(3)

func _on_Item5_mouse_exited():
	mouse_exited(4)

func _on_Item6_mouse_exited():
	mouse_exited(5)

func _on_Item7_mouse_exited():
	mouse_exited(6)

func _on_Item8_mouse_exited():
	mouse_exited(7)

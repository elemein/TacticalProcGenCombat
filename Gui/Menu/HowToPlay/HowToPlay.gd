extends Node

onready var tab_container : TabContainer = find_node('TabContainer')

var num_of_tabs


func _ready():
	self.num_of_tabs = len(self.tab_container.get_children())

func _on_Prev_pressed():
	if self.tab_container.current_tab == 0:
		self.tab_container.current_tab = self.num_of_tabs - 1
	else:
		self.tab_container.current_tab -= 1

func _on_Next_pressed():
	if self.tab_container.current_tab == self.num_of_tabs - 1:
		self.tab_container.current_tab = 0
	else:
		self.tab_container.current_tab += 1

func _on_MainMenu_pressed():
	get_tree().change_scene("res://Assets/GUI/TitleScreen/MainTitleScreen.tscn")


extends Node

onready var tab_container : TabContainer = find_node('TabContainer')

var num_of_tabs


func _ready():
	num_of_tabs = len(tab_container.get_children())

func _on_Prev_pressed():
	if tab_container.current_tab == 0:
		tab_container.current_tab = num_of_tabs - 1
	else:
		tab_container.current_tab -= 1

func _on_Next_pressed():
	if tab_container.current_tab == num_of_tabs - 1:
		tab_container.current_tab = 0
	else:
		tab_container.current_tab += 1

func _on_MainMenu_pressed():
	get_tree().change_scene("res://Assets/GUI/TitleScreen/MainTitleScreen.tscn")


extends MarginContainer

onready var equipped = $ObjectInfo/Equipped
onready var object_name = $ObjectInfo/ObjectName
onready var object_type = $ObjectInfo/ObjectType

func set_object_text(name):
	print(object_name.text)
	object_name.text = name
	
func set_object_type(type):
	object_type.text = type

func set_equipped(equip_state):
	if equip_state: equipped.text = 'E'
	else: equipped.text = ''

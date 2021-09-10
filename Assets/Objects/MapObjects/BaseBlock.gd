extends GameObj

# vars for minimap
var was_visible = false
var minimap_icon = "Ground"
var identity = {"Category": "MapObject", "CategoryType": "Ground", 
				"Identifier": "BaseGround", 'Map ID': null, 
				'Position': [0,0], 'Instance ID': get_instance_id()}

func _init().(identity): pass

func _process(_delta):
	if visible:
		was_visible = true

extends GameObj

# vars for minimap
var was_visible = false
var minimap_icon = "Ground"

func _init().('Ground'): pass

func _process(_delta):
	if visible:
		was_visible = true

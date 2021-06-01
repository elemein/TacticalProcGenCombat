extends MeshInstance

onready var map = get_node("/root/World/Map")

var object_type = 'Spike Trap'
var map_pos = []
var trap_damage = 33
var sprung_pos = Vector3()

var sprung = false

var trap_anim_timer = Timer.new()

func _physics_process(_delta):
	if sprung:
		translation = translation.linear_interpolate(sprung_pos, (1-trap_anim_timer.time_left))
		
		if trap_anim_timer.time_left == 0:
			map.remove_map_object(self)

func get_obj_type():
	return object_type

func get_map_pos():
	return map_pos

func set_map_pos(new_pos):
	map_pos = new_pos
	
	# Also set up the timer.
	trap_anim_timer.set_one_shot(true)
	trap_anim_timer.set_wait_time(1)
	add_child(trap_anim_timer)
	sprung_pos = Vector3(translation.x, translation.y + 1.5, translation.z)

func activate_trap(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			sprung = true
			visible = true
			trap_anim_timer.start()
			object.take_damage(trap_damage)

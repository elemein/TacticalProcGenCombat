extends GameObj

var trap_damage = 33
var sprung_pos = Vector3()

var sprung = false

var trap_anim_timer = Timer.new()

func _init().('Spike Trap'):
	trap_anim_timer.set_one_shot(true)
	trap_anim_timer.set_wait_time(2)
	add_child(trap_anim_timer)

func _physics_process(_delta):
	if sprung:
		var intrp_mod = trap_anim_timer.time_left / trap_anim_timer.get_wait_time()
		translation = translation.linear_interpolate(sprung_pos, (1-intrp_mod))
		
		if trap_anim_timer.time_left == 0:
			map.remove_map_object(self)

func activate_trap(tile_objects):
	for object in tile_objects:
		if object.get_obj_type() == 'Player':
			sprung = true
			visible = true
			object.take_damage(trap_damage)
			sprung_pos = Vector3(translation.x, translation.y + 0.75, translation.z)
			trap_anim_timer.start()

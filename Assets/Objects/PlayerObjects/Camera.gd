extends Camera

onready var shakeTimer = get_node("Timer")
onready var tween = get_node("Tween")

var shake_amount = 0
var default_v_offset = v_offset # for 3d there are two offsets, experiment
var default_h_offset = h_offset # for 3d there are two offsets, experiment

func _ready():
	GlobalVars.camera = self
	set_process(false)
	
func _process(delta):
	v_offset = rand_range(-shake_amount, shake_amount) * delta + default_v_offset
	h_offset = rand_range(-shake_amount, shake_amount) * delta + default_h_offset
	
func shake(new_shake, shake_time = 0.3, shake_limit = 100):
	shake_amount += new_shake
	if shake_amount > shake_limit: shake_amount = shake_limit
	
	shakeTimer.wait_time = shake_time
	
	tween.stop_all()
	set_process(true)
	shakeTimer.start()
	
func _on_Timer_timeout():
	shake_amount = 0
	set_process(false)
	
	tween.interpolate_property(self, "v_offset", v_offset, default_v_offset,
	0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	
	tween.interpolate_property(self, "h_offset", h_offset, default_h_offset,
	0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

	tween.start()

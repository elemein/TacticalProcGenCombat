extends OmniLight

var max_range = 17
var min_range = 6
var max_energy = 1.6
var min_energy = 0.6
var growing = false

var change_rate = 0.012 # lower is slower

# GLOW EFFECT SETTINGS:
#var max_range = 17
#var min_range = 6
#var max_energy = 1.6
#var min_energy = 0.6
#var growing = false
#
#var change_rate = 0.012 # lower is slower

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	var light_timer = Timer.new()
	light_timer.connect("timeout", self, "_on_timer_timeout")
	add_child(light_timer)
	light_timer.set_wait_time(0.0333)
	light_timer.start()

func _process(_delta):
	pass

func _on_timer_timeout():
	glow_effect()

func flicker_effect(): #works like dogshit
	omni_range += -((max_range - min_range) * change_rate)
	light_energy += -((max_energy - min_energy) * change_rate)

	var flicker = rng.randi_range(0,100)
	var flicker_chance = 20

	if (flicker < flicker_chance):
		print(flicker)
		print("flicker")
		omni_range += rng.randi_range(2,5)
		omni_range = max_range if omni_range > max_range else omni_range

		light_energy += (rng.randi_range(5,45) * 0.01)
		light_energy = max_energy if light_energy > max_range else light_energy

func glow_effect():
	if (growing == false):
		if (omni_range > min_range) and (light_energy > min_energy):
			omni_range += -((max_range - min_range) * change_rate)
			light_energy += -((max_energy - min_energy) * change_rate)
		else: 
			growing = true
	
	if (growing == true):
		if (omni_range < max_range) and (light_energy < max_energy):
			omni_range += ((max_range - min_range) * change_rate)
			light_energy += ((max_energy - min_energy) * change_rate)
		else: 
			growing = false

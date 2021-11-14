extends OmniLight

onready var noise = OpenSimplexNoise.new()
var value = 0.0
const MAX_VALUE = 100000000

var max_range = 17
var min_range = 6
var max_energy = 1.6
var min_energy = 0.6
var growing = false
var timer_refresh_rate = 0.0333

var change_rate = 0.012 # lower is slower

#PERLIN EFFECT SETTINGS:
#var max_range = 17
#var min_range = 6
#var max_energy = 1.3
#var min_energy = 0.1
#var growing = false
#var timer_refresh_rate = 0.02

# GLOW EFFECT SETTINGS:
#var max_range = 17
#var min_range = 6
#var max_energy = 1.6
#var min_energy = 0.6
#var growing = false
#var timer_refresh_rate = 0.0333
#
#var change_rate = 0.012 # lower is slower

var rng = RandomNumberGenerator.new()

func _ready():
	self.rng.randomize()
	
	self.value = self.rng.randi() % MAX_VALUE
	self.noise.period = 32

	var light_timer = Timer.new()
	light_timer.connect("timeout", self, "_on_timer_timeout")
	add_child(light_timer)
	light_timer.set_wait_time(self.timer_refresh_rate)
	light_timer.start()

func _on_timer_timeout():
	glow_effect()

func perlin_flicker_effect():
	self.value += 1
	if (self.value > MAX_VALUE): value = 0.0
	var perlin_val = (self.noise.get_noise_1d(self.value) + 1)/2
	
	var energy_variance = self.max_energy - self.min_energy
	
	light_energy = self.min_energy + (perlin_val * energy_variance)
	
	omni_range = 14

func flicker_effect(): #works like dogshit
	omni_range += -((self.max_range - self.min_range) * self.change_rate)
	light_energy += -((self.max_energy - self.min_energy) * self.change_rate)

	var flicker = self.rng.randi_range(0,100)
	var flicker_chance = 20

	if (flicker < flicker_chance):
		omni_range += self.rng.randi_range(2,5)
		omni_range = self.max_range if omni_range > max_range else omni_range

		light_energy += (self.rng.randi_range(5,45) * 0.01)
		light_energy = self.max_energy if light_energy > self.max_range else light_energy

func glow_effect():
	if (self.growing == false):
		if (omni_range > self.min_range) and (light_energy > self.min_energy):
			omni_range += -((self.max_range - self.min_range) * self.change_rate)
			light_energy += -((self.max_energy - self.min_energy) * self.change_rate)
		else: 
			self.growing = true
	
	if (self.growing == true):
		if (omni_range < self.max_range) and (light_energy < self.max_energy):
			omni_range += ((self.max_range - self.min_range) * self.change_rate)
			light_energy += ((self.max_energy - self.min_energy) * self.change_rate)
		else: 
			self.growing = false

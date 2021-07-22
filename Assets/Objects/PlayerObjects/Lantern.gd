extends OmniLight

var max_range = 15
var min_range = 6
var max_energy = 1.25
var min_energy = 0.6
var growing = false

var change_rate = 0.003 # lower is slower

func _ready():
	pass

func _process(_delta):
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

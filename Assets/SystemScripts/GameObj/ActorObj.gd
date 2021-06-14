extends GameObj
class_name ActorObj

const DEATH_ANIM_TIME = 1

const VIEW_FINDER = preload("res://Assets/SystemScripts/ViewFinder.gd")

onready var model = $Graphics
onready var anim = $Graphics/AnimationPlayer
onready var gui = get_node("/root/World/GUI")
onready var turn_timer = get_node("/root/World/TurnTimer")

var view_finder = VIEW_FINDER.new()

#death vars
var death_anim_timer = Timer.new()
var death_anim_info = []
var is_dead = false

var viewfield = []
var proposed_action = ""

# movement and positioning related vars
var direction_facing = "down"
var target_pos = Vector3()
var saved_pos = Vector3()

# turn_state vars
var ready_status = false
var in_turn = false

# vars for animation
var anim_state = "idle"
var effect = null

var stat_dict = {"Max HP" : 0, "HP" : 0, "Max MP": 0, "MP": 0, \
				"HP Regen" : 0, "MP Regen": 0, "Attack Power" : 0, \
				"Spell Power" : 0, "Defense" : 0, "Speed": 0, "View Range" : 0}

func _init(obj_type, actor_stats).(obj_type):
	stat_dict = actor_stats
	
	add_child(view_finder)
	view_finder.set_actor(self)

# Animations related functions.
func handle_animations():
	match anim_state:
		'idle':
			play_anim("idle")
		'walk':
			play_anim("walk")

func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

func die():
	death_anim_timer.set_one_shot(true)
	death_anim_timer.set_wait_time(DEATH_ANIM_TIME)
	add_child(death_anim_timer)
	is_dead = true
	turn_timer.remove_from_timer_group(self)
	
	proposed_action = 'idle'
	
	var rise = Vector3(model.translation.x, 2, model.translation.z)
	var fall = Vector3(model.translation.x, 0.2, model.translation.z)
	var fall_rot = Vector3(-90, model.rotation_degrees.y, model.rotation_degrees.z)
	
	death_anim_info = [rise, fall, fall_rot]
	
	death_anim_timer.start()
	$HealthManaBar3D.visible = false

# Getters
func get_is_dead() -> bool: return is_dead

func get_stat_dict() -> Dictionary: return stat_dict

func get_viewfield() -> Array: return viewfield

func get_action() -> String: return proposed_action

func get_direction_facing() -> String: return direction_facing

# Setters
func set_stat_dict(changed_dict): stat_dict = changed_dict

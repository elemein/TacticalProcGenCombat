extends KinematicBody

const MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

const H_LOOK_SENS = 0.01
const V_LOOK_SENS = 0.2

onready var cam = $CamBase
onready var anim = $Graphics/AnimationPlayer

var y_velo = 0

func _ready():
	anim.get_animation("walk").set_loop(true)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation.y -= event.relative.x * H_LOOK_SENS
		
func _physics_process(_delta):
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_backwards"):
		move_vec.z += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1	
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	move_vec = move_vec.normalized()
	
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	# Not explained well in vid: move_and_slide basically sets the body of the
	# body to collide against other collision bodies.
	move_and_slide(move_vec, Vector3(0, 1, 0))
	
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	
	if grounded and Input.is_action_just_pressed("jump"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
	
	if just_jumped:
		play_anim("jump")
	elif grounded:
		if move_vec.x ==0 and move_vec.z == 0:
			play_anim("idle")
		else:
			play_anim("walk")
	
func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

	
	
	
	

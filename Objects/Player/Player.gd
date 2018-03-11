extends KinematicBody

# Member variables
var g = -9.8
var vel = Vector3()
const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCEL= 10
const DEACCEL= 10
const MAX_SLOPE_ANGLE = 30

var view_sensitivity = 0.3
var mouse_aim = true

var running = false
func _ready():
	get_tree().set_pause(false)
	set_process_input(true)

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

func _input(event):
	if (mouse_aim):
		if (event is InputEventMouseMotion):
			var yaw = rad2deg(get_node(".").get_rotation().y);
			var pitch = rad2deg(get_node(".").get_rotation().x);
			
			yaw = fmod(yaw - event.get_relative().x * view_sensitivity, 360);
			pitch = max(min(pitch - event.get_relative().y * view_sensitivity, 90), -90);
			
			get_node(".").set_rotation(Vector3(deg2rad(pitch), deg2rad(yaw), 0));

#debug
func getallnodes(node):
	for N in node.get_children():
		if N.get_child_count() > 0:
			if (N.has_method("get_aabb")):
				print(N.get_aabb())
			getallnodes(N)
		else:
		# Do something
			if (N.has_method("get_aabb")):
				print(N.get_aabb())

func _process(delta):
	var dir = Vector3() # Where does the player intend to walk to
	var cam_xform = $"./Camera".get_global_transform()
	
	if (Input.is_action_pressed("forward")):
		dir += -cam_xform.basis[2]
	if (Input.is_action_pressed("backward")):
		dir += cam_xform.basis[2]
	if (Input.is_action_pressed("left")):
		dir += -cam_xform.basis[0]
	if (Input.is_action_pressed("right")):
		dir += cam_xform.basis[0]

	if (Input.is_action_just_released("mousegrab")):
		mouse_aim = !mouse_aim

	if (Input.is_action_pressed("running")):
		running = true
	else:
		running = false

    # Firing the weapons
	if Input.is_action_pressed("fire"):
		get_node("weapon").get_child(0).fire_bullet()

	if (Input.is_action_just_released("debug")):
		var allobjects = get_node("/root")
		getallnodes(allobjects)
	
	dir.y = 0
	dir = dir.normalized()
	
	vel.y += delta*g
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir*MAX_SPEED
	var accel
	if (dir.dot(hvel) > 0):
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	
	vel.x = hvel.x
	vel.z = hvel.z
	
	if (running):
		vel.x *= 1.15
		vel.y *= 1.025
		vel.z *= 1.15
	vel = move_and_slide(vel,Vector3(0,1,0))
	
	if (is_on_floor() and Input.is_action_pressed("jump")):
		vel.y = JUMP_SPEED
extends Spatial

export(float) var area_percent = 0.1
export(int) var acc = 5
export(int) var dec = 10
export(int) var MAX_SPEED = 100
export(int) var ang_acc = 3
export(int) var ang_dec = 8
export(int) var MAX_ANG_SPEED = 50
export(float) var MOUSE_SENSITIVITY = 0.001
export(bool) var invert_rotation_keys = false
export(bool) var edge_scrolling = false

var speed = 0
var dir = Vector3(0,0,0)
var pos = Vector2(0,0)
var crsr = Vector2(0,0)
var ang_dir = Vector3.ZERO
var ang_speed = 0
var mouse_in
var is_panning = false
onready var last_mouse_pos = get_viewport().get_mouse_position()

func _input(event):
	if event is InputEventMouseMotion: 
		crsr = event.position
		
	if event.is_action_pressed("camera_look_around"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("camera_pan_around"):
		is_panning = true
		last_mouse_pos = get_viewport().get_mouse_position()
	elif event.is_action_released("camera_pan_around"):
		is_panning = false
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.rotate_y(event.relative.x * MOUSE_SENSITIVITY)
	

func _process(delta):
	var pos = get_viewport().get_visible_rect()
	
	
	var new_dir := Vector3.ZERO
#	print(pos)
#	print(pos.has_point(crsr))
#	print(crsr)
	if mouse_in and edge_scrolling:
		if (crsr.x < int(pos.size.x*area_percent)):
			new_dir.x -= 1
		if (crsr.x > (pos.size.x-(pos.size.x*area_percent))):
			new_dir.x += 1
		if (crsr.y < int(pos.size.y*area_percent)):
			new_dir.z -= 1
		if (crsr.y > (pos.size.y-(pos.size.y*area_percent))):
			new_dir.z += 1
	
	if OS.is_window_focused():
		if Input.is_action_pressed("camera_move_left"):
			new_dir.x -= 1
		if Input.is_action_pressed("camera_move_right"):
			new_dir.x += 1
		if Input.is_action_pressed("camera_move_forward"):
			new_dir.z -= 1
		if Input.is_action_pressed("camera_move_backward"):
			new_dir.z += 1

	if new_dir.length() > 1:
		new_dir = new_dir.normalized()
	
	if new_dir and OS.is_window_focused():
		dir = new_dir
		speed += acc * delta
	else:
		speed -= dec * delta
	speed = clamp(speed,0,MAX_SPEED)
	translate_object_local(dir*delta*speed)
	
	# angles
	var new_ang_dir := Vector3.ZERO
	if Input.is_action_pressed("camera_rotate_left"):
		new_ang_dir.y += 1
	elif Input.is_action_pressed("camera_rotate_right"):
		new_ang_dir.y += -1
	
	if new_ang_dir.length() > 1:
		new_ang_dir = new_ang_dir.normalized()
	
	if new_ang_dir and OS.is_window_focused():
		ang_dir = new_ang_dir
		ang_speed += ang_acc * delta
	else:
		ang_speed -= ang_dec * delta
	
	ang_speed = clamp(ang_speed, 0, MAX_ANG_SPEED)
	if ang_dir:
		rotate(ang_dir, ang_speed*delta)
	
	if Input.is_action_pressed("camera_pan_around"):
		var current_mouse_pos = get_viewport().get_mouse_position()
		var mouse_speed = last_mouse_pos - current_mouse_pos
		translation += (global_transform.basis.z * mouse_speed.y + global_transform.basis.x * mouse_speed.x) * delta * 2
		last_mouse_pos = current_mouse_pos
		

func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in = true
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in = false

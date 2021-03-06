extends Spatial

export(int) var ang_acc = 1
export(int) var ang_dec = 5
export(int) var MAX_ANG_SPEED = 50
export(float) var low = -0.2
export(float) var high = 0.8
export(float) var MOUSE_SENSITIVITY = 0.001
export(bool) var invert_tilting = false

var dir = Vector3()
var speed = 0

func _ready():
	set_process(true)

func _input(event):
	if event.is_action_released("camera_look_around"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		

	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.x = clamp(rotation.x, -0.2, 0.8)
		rotate_x(event.relative.y * MOUSE_SENSITIVITY)

func _process(delta: float) -> void:
	var new_dir:= Vector3.ZERO
	
	if Input.is_action_pressed("camera_rotate_up"):
		new_dir.x += 1
	elif Input.is_action_pressed("camera_rotate_down"):
		new_dir.x += -1
	if new_dir.length() > 1:
		new_dir = new_dir.normalized()
	if new_dir and OS.is_window_focused():
		dir = new_dir
		speed += ang_acc * delta
	else:
		speed -= ang_dec * delta
	
	speed = clamp(speed, 0, MAX_ANG_SPEED)
	rotation.x = clamp(rotation.x, low, high)
	if dir:
		rotate(-dir, speed*delta)
	rotation.x = clamp(rotation.x, low, high)


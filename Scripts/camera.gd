extends Camera

export(float) var zoom_factor = 0.09
export(int) var max_zoom =  10
export(int) var min_zoom = -18
export(bool) var invert_zooming = true
export(bool) var invert_rotation = false
export(bool) var zoom_to_cursor = true

var previous_loc = Vector3.ZERO
var zoom = 0

func _input(event):
	if event is InputEventScreenPinch:
		if event.relative < 0: # zoom in
#			print(event.relative / 64)
			zoom -= round(event.relative / 64) * (1 if invert_zooming else -1)
		elif event.relative > 0: # zoom out
			zoom += round(event.relative / 64) * (-1 if invert_zooming else 1)
		previous_loc = transform.origin
		zoom = clamp(zoom, min_zoom, max_zoom)

func _process(delta: float) -> void:
	if get_parent().get_parent().is_panning:
		return
	if Input.is_action_pressed("camera_zoom_in"):
		zoom -= 1
	elif Input.is_action_pressed("camera_zoom_out"):
		zoom += 1
	previous_loc = transform.origin
	var pointing_at = _get_3D_mouse_pos()
	zoom = clamp(zoom, min_zoom, max_zoom)
	if previous_loc.z != lerp(translation.z, zoom, zoom_factor):
		translation.z = lerp(translation.z, zoom, zoom_factor)
	
	if zoom_to_cursor and pointing_at:
		realign_camera(pointing_at)
	
func _get_3D_mouse_pos():
	var mouse_pointer = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pointer)
	var to = from + project_ray_normal(mouse_pointer) * 1000
	return get_world().direct_space_state.intersect_ray(from, to).get('position')

func realign_camera(pointing_at):
	var new_point = _get_3D_mouse_pos()
#	print(new_point)
	if new_point:
		get_parent().get_parent().translation += pointing_at - new_point

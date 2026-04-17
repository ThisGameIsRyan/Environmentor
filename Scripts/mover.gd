class_name Mover extends Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var move_axis: Vector3 = Vector3.ZERO
var screen_point: Vector2 = Vector2.ZERO
var screen_vector: Vector2 = Vector2.ZERO

var start_world_intersection_point: Vector3 = Vector3.ZERO
var start_world_position: Vector3 = Vector3.ZERO
var start_intersection_point: Vector2 = Vector2.ZERO

var last_move_offset: Vector3 = Vector3.ZERO

func _ready():
	SignalManager.update_object_position.connect(_on_update_object_position)
	SignalManager.update_tools.connect(_on_update_tools)

func intersection_point_2d() -> Vector2:
	var mouse_position = get_viewport().get_mouse_position()
	var difference = mouse_position - screen_point

	var perpendicular_vector = screen_vector.rotated(PI / 2)
	var determinant = screen_vector.x * -perpendicular_vector.y - screen_vector.y * -perpendicular_vector.x

	var t = (difference.x * -perpendicular_vector.y - difference.y * -perpendicular_vector.x) / determinant
	var intersection = screen_point + t * screen_vector

	return intersection

func get_movement_plane(target: StaticBody3D) -> Plane:
	var camera_forward = - camera.global_transform.basis.z
	var plane_normal = camera_forward - camera_forward.project(move_axis)
	
	if plane_normal.length_squared() < 0.001:
		plane_normal = move_axis
	
	return Plane(plane_normal.normalized(), target.global_transform.origin)

func screen_to_world(screen_position: Vector2, target: StaticBody3D) -> Vector3:
	var plane = get_movement_plane(target)
	var ray_origin = camera.project_ray_origin(screen_position)
	var ray_direction = camera.project_ray_normal(screen_position)
	var world_point = plane.intersects_ray(ray_origin, ray_direction)
	return world_point if world_point != null else target.global_transform.origin

# ---------- Signals ----------

func _on_update_object_position(target: StaticBody3D, target_axis: Vector3, first: bool):
	if first:
		move_axis = target_axis.normalized()
		screen_point = camera.unproject_position(target.transform.origin)
		screen_vector = camera.unproject_position((move_axis * 10) + target.transform.origin).direction_to(screen_point)
		start_intersection_point = intersection_point_2d()
		start_world_intersection_point = screen_to_world(start_intersection_point, target)
		start_world_position = target.global_position
		last_move_offset = Vector3.ZERO
		return
	var current_intersection_2d = intersection_point_2d()
	var current_intersection_3d = screen_to_world(current_intersection_2d, target)

	var offset = current_intersection_3d - start_world_intersection_point
	var movement = move_axis.dot(offset)

	if Input.is_action_pressed("Coarse"):
		movement = snapped(movement, 1)
	if Input.is_action_pressed("Fine"):
		start_world_position += (last_move_offset - (move_axis * movement)) * 0.5
	
	last_move_offset = move_axis * movement
	target.global_position = start_world_position + move_axis * movement

func _on_update_tools(target: StaticBody3D):
	global_rotation = target.global_rotation
	global_position = target.global_position

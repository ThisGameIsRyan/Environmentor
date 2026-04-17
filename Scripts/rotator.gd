class_name Rotator extends Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var rotate_axis: Vector3 = Vector3.ZERO

var start_mouse_position: Vector2 = Vector2.ZERO
var start_rotation: float = 0
var start_basis: Basis = Basis.IDENTITY

var last_target_rotation: float = 0

func _ready():
	SignalManager.update_object_rotation.connect(_on_update_object_rotation)
	SignalManager.update_tools.connect(_on_update_tools)

# ---------- Signals ----------

func _on_update_object_rotation(target: StaticBody3D, target_axis: Vector3, first: bool):
	if first:
		rotate_axis = target_axis
		start_mouse_position = get_viewport().get_mouse_position()
		start_basis = target.transform.basis
		var start_rotation_vector = camera.unproject_position(target.transform.origin).direction_to(start_mouse_position)
		start_rotation = atan2(start_rotation_vector.y, start_rotation_vector.x)
		last_target_rotation = 0
		return
	
	var mouse_position = get_viewport().get_mouse_position()
	var rotation_vector = camera.unproject_position(target.transform.origin).direction_to(mouse_position)
	var raw_angle = atan2(rotation_vector.y, rotation_vector.x) - start_rotation
	var target_rotation = last_target_rotation + angle_difference(last_target_rotation, raw_angle)

	if Input.is_action_pressed("Coarse"):
		target_rotation = snapped(target_rotation, PI / 4)
	if Input.is_action_pressed("Fine"):
		start_rotation -= (last_target_rotation - target_rotation) * 0.5
		target_rotation = atan2(rotation_vector.y, rotation_vector.x) - start_rotation

	last_target_rotation = target_rotation

	if rotate_axis.dot(camera.global_position - target.transform.origin) >= 0:
		target.transform.basis = start_basis.rotated(rotate_axis.normalized(), -target_rotation)
	else:
		target.transform.basis = start_basis.rotated(rotate_axis.normalized(), target_rotation)

func _on_update_tools(target: StaticBody3D):
	global_rotation = target.global_rotation
	global_position = target.global_position

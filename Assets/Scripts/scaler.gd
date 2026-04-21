# Convert to Unity
class_name Scaler extends Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var start_mouse_distance: float = 0
var start_scale: Vector3 = Vector3.ONE

func _ready():
	SignalManager.update_object_scale.connect(_on_update_object_position)
	SignalManager.update_tools.connect(_on_update_tools)

# Signals

func _on_update_object_position(target: StaticBody3D, target_axis: Vector3, first: bool):
	if first:
		start_scale = target.scale
		var start_mouse_position = get_viewport().get_mouse_position()
		start_mouse_distance = camera.unproject_position(target.transform.origin).distance_to(start_mouse_position)
		return
	
	var mouse_position = get_viewport().get_mouse_position()
	var mouse_distance = camera.unproject_position(target.transform.origin).distance_to(mouse_position)
	var target_scale = start_scale + target_axis * start_scale * (mouse_distance / start_mouse_distance) - start_scale * target_axis

	if Input.is_action_pressed("Fine"):
		target_scale = start_scale * (mouse_distance / start_mouse_distance)
	if Input.is_action_pressed("Coarse"):
		target_scale = snapped(target_scale, Vector3(0.5, 0.5, 0.5))

	target.scale = target_scale

func _on_update_tools(target: StaticBody3D):
	global_rotation = target.global_rotation
	global_position = target.global_position

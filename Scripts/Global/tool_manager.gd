extends Node3D

@export var mover_enabled: bool = true
@export var rotator_enabled: bool = true
@export var scaler_enabled: bool = false

const mover_scene = preload("uid://lef520va1iuy")
const rotator_scene = preload("uid://cxp4niroa1yt7")
const scaler_scene = preload("uid://dpdlgefqmcim3")

var mover_node: Mover
var rotator_node: Rotator
var scaler_node: Scaler

var selected_mover: bool = false
var selected_rotator: bool = false
var selected_scaler: bool = false

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var target_axis: Vector3 = Vector3.ZERO
var target: Node3D

var undo_transform_array: Array = []
var undo_target_array: Array = []
var undo_index: int = -1

func _ready():
	SignalManager.zoom_changed.connect(_on_zoom_changed)
	SignalManager.tool_button_toggled.connect(_on_tool_button_toggled)
	SignalManager.undo_button_pressed.connect(_on_undo_button_pressed)
	SignalManager.redo_button_pressed.connect(_on_redo_button_pressed)

	# Add tools to node
	mover_node = mover_scene.instantiate()
	add_child(mover_node)
	
	rotator_node = rotator_scene.instantiate()
	add_child(rotator_node)

	scaler_node = scaler_scene.instantiate()
	add_child(scaler_node)

	confirm_modification()

	rotator_node.visible = false
	for child in rotator_node.get_children():
		child.get_child(1).disabled = true

	mover_node.visible = false
	for child in mover_node.get_children():
		child.get_child(1).disabled = true

	scaler_node.visible = false
	for child in scaler_node.get_children():
		child.get_child(1).disabled = true


func _process(_delta):
	if Input.is_action_just_pressed("Redo"):
		SignalManager.redo_button_pressed.emit()
	elif Input.is_action_just_pressed("Undo"):
		SignalManager.undo_button_pressed.emit()

func toggle_tools(on: bool):
	if mover_enabled:
		mover_node.visible = on
		for child in mover_node.get_children():
			child.get_child(1).disabled = !on
	if rotator_enabled:
		rotator_node.visible = on
		for child in rotator_node.get_children():
			child.get_child(1).disabled = !on
	if scaler_enabled:
		scaler_node.visible = on
		for child in scaler_node.get_children():
			child.get_child(1).disabled = !on

func _input(event):
	if get_viewport().gui_get_hovered_control() != null:
		return # Stops things from happening if the hovering over the GUI
	
	if event is InputEventMouseMotion:
		if selected_mover:
			SignalManager.update_object_position.emit(target, target_axis, false)
			SignalManager.update_tools.emit(target)
		if selected_rotator:
			SignalManager.update_object_rotation.emit(target, target_axis, false)
			SignalManager.update_tools.emit(target)
		if selected_scaler:
			SignalManager.update_object_scale.emit(target, target_axis, false)
			SignalManager.update_tools.emit(target)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_position = get_viewport().get_mouse_position()
				var ray_start_position = camera.project_ray_origin(mouse_position)
				var ray_end_position = ray_start_position + camera.project_ray_normal(mouse_position) * camera.far

				var ray_cast_parameters = PhysicsRayQueryParameters3D.new()
				ray_cast_parameters.from = ray_start_position
				ray_cast_parameters.to = ray_end_position

				var ray_hits = []

				while true: # loop over every collider in the ray's path
					var ray_result = get_world_3d().direct_space_state.intersect_ray(ray_cast_parameters)
					if ray_result != {}:
						ray_hits.append(ray_result.collider)
						ray_cast_parameters.exclude = ray_hits
						if ray_result.collider.get_parent().name == "Mover":
							if ray_result.collider.name == "ArrowX":
								target_axis = target.transform.basis.x
							if ray_result.collider.name == "ArrowY":
								target_axis = target.transform.basis.y
							if ray_result.collider.name == "ArrowZ":
								target_axis = target.transform.basis.z
							SignalManager.update_object_position.emit(target, target_axis, true)
							SignalManager.update_tools.emit(target)
							selected_mover = true
							return
						elif ray_result.collider.get_parent().name == "Rotator":
							if ray_result.collider.name == "RingX":
								target_axis = target.transform.basis.x
							if ray_result.collider.name == "RingY":
								target_axis = target.transform.basis.y
							if ray_result.collider.name == "RingZ":
								target_axis = target.transform.basis.z
							SignalManager.update_object_rotation.emit(target, target_axis, true)
							SignalManager.update_tools.emit(target)
							selected_rotator = true
							return
						elif ray_result.collider.get_parent().name == "Scaler":
							if ray_result.collider.name == "StickX":
								target_axis = Vector3(1, 0, 0)
							if ray_result.collider.name == "StickY":
								target_axis = Vector3(0, 1, 0)
							if ray_result.collider.name == "StickZ":
								target_axis = Vector3(0, 0, 1)
							SignalManager.update_object_scale.emit(target, target_axis, true)
							SignalManager.update_tools.emit(target)
							selected_scaler = true
							return
					else:
						break
				#  If it didn't hit a tool than continue to see what it hit
				if ray_hits.size() != 0:
					target = ray_hits[0]
					confirm_modification()
					SignalManager.update_selection.emit(target, false, false)
					SignalManager.update_tools.emit(target)
					toggle_tools(target.get_node("MeshInstance3D/Outline").visible)
				else:
					SignalManager.update_selection.emit(target, true, false)
					target = null
					confirm_modification()
					toggle_tools(false)
			if !event.pressed:
				if selected_mover:
					selected_mover = false
					confirm_modification()
				if selected_rotator:
					selected_rotator = false
					confirm_modification()
				if selected_scaler:
					selected_scaler = false
					confirm_modification()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			SignalManager.update_selection.emit(target, true, false)
			target = null
			confirm_modification()
			toggle_tools(false)

func confirm_modification():
	if target == null:
		if undo_target_array.size() > 0 and undo_target_array[undo_index] == null:
			return
		undo_target_array.append(null)
		undo_transform_array.append(null)
		undo_index += 1
		return

	# Check if the user selected the same object
	if undo_transform_array.size() > 0 and undo_transform_array[undo_index] == target.global_transform:
		undo_target_array.append(null)
		undo_transform_array.append(null)
		undo_index += 1
		return

	# Max undos
	if undo_index + 1 > 200:
		undo_target_array.pop_front()
		undo_transform_array.pop_front()
		undo_index -= 1
		
	# Forget the future actions
	if undo_transform_array.size() > undo_index + 1:
		undo_transform_array.resize(undo_index + 1)
		undo_target_array.resize(undo_index + 1)

	undo_target_array.append(target.get_path())
	undo_transform_array.append(target.global_transform)
	undo_index += 1

# Signals

func _on_zoom_changed(zoom: float, _delta: float, power: float):
	scale = Vector3.ONE * pow(zoom, power) * 0.1 # Scale the tools at the same rate as the camera zooms
	if target != null:
		SignalManager.update_tools.emit(target)

func _on_tool_button_toggled(rotator_toggled_on: bool, mover_toggled_on: bool, scaler_toggled_on: bool):
	rotator_enabled = rotator_toggled_on
	mover_enabled = mover_toggled_on
	scaler_enabled = scaler_toggled_on
	
	if target != null and target.get_node("MeshInstance3D/Outline").visible:
		rotator_node.visible = rotator_enabled
		for child in rotator_node.get_children():
			child.get_child(1).disabled = !rotator_enabled

		mover_node.visible = mover_enabled
		for child in mover_node.get_children():
			child.get_child(1).disabled = !mover_enabled
	
		scaler_node.visible = scaler_enabled
		for child in scaler_node.get_children():
			child.get_child(1).disabled = !scaler_enabled

func _on_undo_button_pressed():
	if undo_transform_array.size() <= 0:
		return
	undo_index = max(undo_index - 1, 0)
	if undo_target_array[undo_index] == null:
		SignalManager.update_selection.emit(null, true, false)
		toggle_tools(false)
		return
	target = get_node(undo_target_array[undo_index])
	target.global_transform = undo_transform_array[undo_index]
	SignalManager.update_selection.emit(target, true, true)
	SignalManager.update_tools.emit(target)
	toggle_tools(true)

func _on_redo_button_pressed():
	if undo_transform_array.size() <= 0:
		return
	undo_index = min(undo_index + 1, undo_transform_array.size() - 1)
	if undo_target_array[undo_index] == null:
		SignalManager.update_selection.emit(null, true, false)
		toggle_tools(false)
		return
	target = get_node(undo_target_array[undo_index])
	target.global_transform = undo_transform_array[undo_index]
	SignalManager.update_selection.emit(target, true, true)
	SignalManager.update_tools.emit(target)
	toggle_tools(true)

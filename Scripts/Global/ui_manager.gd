extends Control

const ui_scene = preload("uid://cepiawuptnddt")

var ui_node: Control

var movetator_button: Button
var rotator_button: Button
var mover_button: Button
var scaler_button: Button
var selector_button: Button

var undo_button: Button
var redo_button: Button

# --- Add Button ---
var add_button: Button
var add_sphere_button: Button
var add_capsule_button: Button
var add_cylinder_button: Button
var add_cube_button: Button
var add_plane_button: Button
var add_quad_button: Button
var add_triangle_button: Button
# ------------------

func _ready():
	size = get_window().size
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	ui_node = ui_scene.instantiate()
	add_child(ui_node)

	var gui = ui_node.get_child(0)
	var h_box_container = gui.get_child(0)

	movetator_button = h_box_container.get_node("MovetatorButton")
	rotator_button = h_box_container.get_node("RotatorButton")
	mover_button = h_box_container.get_node("MoverButton")
	scaler_button = h_box_container.get_node("ScalerButton")
	selector_button = h_box_container.get_node("SelectorButton")

	undo_button = h_box_container.get_node("UndoButton")
	redo_button = h_box_container.get_node("RedoButton")

	# --- Add Button ---
	add_button = h_box_container.get_node("AddButton")
	var add_button_container = add_button.get_child(0).get_child(0)
	add_sphere_button = add_button_container.get_node("SphereButton")
	add_capsule_button = add_button_container.get_node("CapsuleButton")
	add_cylinder_button = add_button_container.get_node("CylinderButton")
	add_cube_button = add_button_container.get_node("CubeButton")
	add_plane_button = add_button_container.get_node("PlaneButton")
	add_quad_button = add_button_container.get_node("QuadButton")
	add_triangle_button = add_button_container.get_node("TriangleButton")
	# ------------------

	movetator_button.toggled.connect(_on_movetator_button_pressed)
	rotator_button.toggled.connect(_on_rotator_button_pressed)
	mover_button.toggled.connect(_on_mover_button_pressed)
	scaler_button.toggled.connect(_on_scaler_button_pressed)
	selector_button.toggled.connect(_on_selector_button_pressed)

	undo_button.pressed.connect(_on_undo_button_pressed)
	redo_button.pressed.connect(_on_redo_button_pressed)

	# --- Add Button ---
	add_button.pressed.connect(_on_add_button_pressed)
	add_sphere_button.pressed.connect(_on_add_sphere_button_pressed)
	add_capsule_button.pressed.connect(_on_add_capsule_button_pressed)
	add_cylinder_button.pressed.connect(_on_add_cylinder_button_pressed)
	add_cube_button.pressed.connect(_on_add_cube_button_pressed)
	add_plane_button.pressed.connect(_on_add_plane_button_pressed)
	add_quad_button.pressed.connect(_on_add_quad_button_pressed)
	add_triangle_button.pressed.connect(_on_add_triangle_button_pressed)
	# ------------------

func _input(event):
	if add_button.button_pressed and event is InputEventMouseMotion and get_viewport().gui_get_hovered_control() == null:
		add_button_panel_toggle(false)

func add_button_panel_toggle(on: bool):
	add_button.button_pressed = on
	add_button.get_child(0).visible = on

# ---------- Signals ----------

func _on_movetator_button_pressed(toggled_on: bool):
	if toggled_on:
		rotator_button.button_pressed = false
		mover_button.button_pressed = false
		scaler_button.button_pressed = false
		selector_button.button_pressed = false
	SignalManager.tool_button_toggled.emit(toggled_on, toggled_on, false)

func _on_rotator_button_pressed(toggled_on: bool):
	if toggled_on:
		movetator_button.button_pressed = false
		mover_button.button_pressed = false
		scaler_button.button_pressed = false
		selector_button.button_pressed = false
	SignalManager.tool_button_toggled.emit(toggled_on, false, false)

func _on_mover_button_pressed(toggled_on: bool):
	if toggled_on:
		movetator_button.button_pressed = false
		rotator_button.button_pressed = false
		scaler_button.button_pressed = false
		selector_button.button_pressed = false
	SignalManager.tool_button_toggled.emit(false, toggled_on, false)

func _on_scaler_button_pressed(toggled_on: bool):
	if toggled_on:
		movetator_button.button_pressed = false
		rotator_button.button_pressed = false
		mover_button.button_pressed = false
		selector_button.button_pressed = false
	SignalManager.tool_button_toggled.emit(false, false, toggled_on)

func _on_selector_button_pressed(toggled_on: bool):
	if toggled_on:
		movetator_button.button_pressed = false
		rotator_button.button_pressed = false
		mover_button.button_pressed = false
		scaler_button.button_pressed = false
	SignalManager.tool_button_toggled.emit(false, false, false)

func _on_undo_button_pressed():
	SignalManager.undo_button_pressed.emit()

func _on_redo_button_pressed():
	SignalManager.redo_button_pressed.emit()


# --- Add Button ---
func _on_add_button_pressed():
	add_button.get_child(0).visible = add_button.button_pressed

func _on_add_sphere_button_pressed():
	SignalManager.create_object.emit("sphere")
	add_button_panel_toggle(false)
func _on_add_capsule_button_pressed():
	SignalManager.create_object.emit("capsule")
	add_button_panel_toggle(false)
func _on_add_cylinder_button_pressed():
	SignalManager.create_object.emit("cylinder")
	add_button_panel_toggle(false)
func _on_add_cube_button_pressed():
	SignalManager.create_object.emit("cube")
	add_button_panel_toggle(false)
func _on_add_plane_button_pressed():
	SignalManager.create_object.emit("plane")
	add_button_panel_toggle(false)
func _on_add_quad_button_pressed():
	SignalManager.create_object.emit("quad")
	add_button_panel_toggle(false)
func _on_add_triangle_button_pressed():
	SignalManager.create_object.emit("triangle")
	add_button_panel_toggle(false)
# ------------------
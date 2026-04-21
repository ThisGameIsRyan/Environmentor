# Convert to Unity
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

# Called when the node enters the scene tree for the first time.
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

	movetator_button.toggled.connect(_on_movetator_button_pressed)
	rotator_button.toggled.connect(_on_rotator_button_pressed)
	mover_button.toggled.connect(_on_mover_button_pressed)
	scaler_button.toggled.connect(_on_scaler_button_pressed)
	selector_button.toggled.connect(_on_selector_button_pressed)

	undo_button.pressed.connect(_on_undo_button_pressed)
	redo_button.pressed.connect(_on_redo_button_pressed)

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

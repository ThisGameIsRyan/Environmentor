# Convert to Unity
extends Node
# UI Signals
signal tool_button_toggled(rotator_toggled_on: bool, mover_toggled_on: bool, scaler_toggled_on: bool)
signal undo_button_pressed()
signal redo_button_pressed()

# Camera Signals
signal zoom_changed(zoom: float, delta: float, power: float)

# Tool Signals
signal update_object_position(target: StaticBody3D, target_axis: Vector3, first: bool)
signal update_object_rotation(target: StaticBody3D, target_axis: Vector3, first: bool)
signal update_object_scale(target: StaticBody3D, target_axis: Vector3, first: bool)
signal update_tools(target: StaticBody3D)
signal update_selection(target: StaticBody3D, override_toggle: bool, visibility: bool)
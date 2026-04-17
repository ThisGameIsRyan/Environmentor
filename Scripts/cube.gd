extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.update_selection.connect(_on_update_selection)

func _on_update_selection(target: StaticBody3D, override_toggle: bool, visibility: bool):
	if override_toggle:
		if target == self:
			get_node("MeshInstance3D/Outline").visible = visibility
		else:
			get_node("MeshInstance3D/Outline").visible = false
	else:
		if target == self:
			get_node("MeshInstance3D/Outline").visible = !get_node("MeshInstance3D/Outline").visible
		else:
			get_node("MeshInstance3D/Outline").visible = false
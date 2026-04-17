extends Marker3D

var panning: bool = false
var moving: bool = false
var fast: bool = false

var zoom_index: float = 1.5

var fine_scroll_speed: float = 0.1
var coarse_scroll_speed: float = 5

@onready var camera: Camera3D = get_child(0)

func _ready():
	camera.position = Vector3(pow(zoom_index, 4), 0, 0)
	camera.look_at(position)
	rotate(Vector3(0, 0, 1), deg_to_rad(30))

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			SignalManager.zoom_changed.emit(zoom_index, 0, 4)
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if !panning and event.pressed:
				panning = true
			if panning and !event.pressed:
				panning = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var speed = 1
			if fast:
				speed = coarse_scroll_speed
			elif moving:
				speed = fine_scroll_speed
			zoom_index = max(zoom_index - (0.01 * speed), 0)
			SignalManager.zoom_changed.emit(zoom_index, 0.01 * -speed, 4)
			camera.position.x = pow(zoom_index, 4)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var speed = 1
			if fast:
				speed = coarse_scroll_speed
			elif moving:
				speed = fine_scroll_speed
			zoom_index += 0.01 * speed
			SignalManager.zoom_changed.emit(zoom_index, 0.01 * speed, 4)
			camera.position.x = pow(zoom_index, 4)
	if InputMap.event_is_action(event, "Fine"):
		if !moving and event.pressed:
			moving = true
		if moving and !event.pressed:
			moving = false
	if InputMap.event_is_action(event, "Coarse"):
		if !fast and event.pressed:
			fast = true
		if fast and !event.pressed:
			fast = false
	if event is InputEventMouseMotion:
		if panning:
			if moving:
				position += (transform.basis.z * event.relative.x * camera.position.x * 0.0015) + (transform.basis.y * event.relative.y * camera.position.x * 0.0015)
				return
			rotate(Vector3(0, 1, 0), event.relative.x * -0.01)
			rotate(transform.basis.z, event.relative.y * 0.01)

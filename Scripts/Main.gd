extends Node3D

@onready var observer: Camera3D = $ObserverCamera
@onready var player: CharacterBody3D = $DemoPlayer
@onready var player_camera: Camera3D = $DemoPlayer/Head/Camera3D

func _ready() -> void:
	_setup_input()
	observer.current = true
	_show_help()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera"):
		observer.current = not observer.current
		player_camera.current = not observer.current
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed and not observer.current:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _setup_input() -> void:
	_bind_key("move_forward", KEY_W)
	_bind_key("move_back", KEY_S)
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("jump", KEY_SPACE)
	_bind_key("sprint", KEY_SHIFT)
	_bind_key("toggle_camera", KEY_TAB)
	_bind_key("release_mouse", KEY_ESCAPE)
	_bind_key("observer_up", KEY_E)
	_bind_key("observer_down", KEY_Q)

func _bind_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _show_help() -> void:
	print("ARENA CONTROLS | Tab: observer/player | WASD: move | Shift: fast | Q/E: observer down/up | Mouse wheel: FOV | LMB: smash | Esc: release mouse")

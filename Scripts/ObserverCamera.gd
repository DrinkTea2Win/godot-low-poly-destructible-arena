extends Camera3D

@export var move_speed: float = 65.0
@export var fast_multiplier: float = 3.0

func _unhandled_input(event: InputEvent) -> void:
	if current and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fov = maxf(30.0, fov - 3.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fov = minf(90.0, fov + 3.0)

func _process(delta: float) -> void:
	if not current:
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var speed := move_speed * (fast_multiplier if Input.is_action_pressed("sprint") else 1.0)
	var forward := -global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := global_basis.x
	right.y = 0.0
	right = right.normalized()
	global_position += (right * input.x + forward * -input.y) * speed * delta
	if Input.is_action_pressed("observer_up"):
		global_position.y += speed * delta
	if Input.is_action_pressed("observer_down"):
		global_position.y -= speed * delta
	global_position.x = clampf(global_position.x, -400.0, 400.0)
	global_position.z = clampf(global_position.z, -400.0, 400.0)
	global_position.y = clampf(global_position.y, 20.0, 500.0)

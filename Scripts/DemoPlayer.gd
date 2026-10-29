extends CharacterBody3D

@export var move_speed: float = 9.0
@export var jump_velocity: float = 8.0
@export var mouse_sensitivity: float = 0.0025
@export var attack_damage: float = 45.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not camera.current:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_attack()

func _physics_process(delta: float) -> void:
	if not camera.current:
		return
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide()

func _attack() -> void:
	var from := camera.global_position
	var to := from - camera.global_transform.basis.z * 7.0
	var query := PhysicsRayQueryParameters3D.create(from, to, 1 | 2)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider: Object = hit.collider
	if collider.has_method("apply_damage"):
		collider.apply_damage(attack_damage, hit.position)
	elif collider is RigidBody3D:
		var impulse := (hit.position - from).normalized() * 16.0
		collider.apply_impulse(impulse, hit.position - collider.global_position)

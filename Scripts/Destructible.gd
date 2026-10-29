class_name Destructible
extends RigidBody3D

@export var max_health: float = 40.0
@export var impact_threshold: float = 7.0
@export var impact_damage_scale: float = 5.0
@export var debris_color: Color = Color("67452D")
@export var debris_count: int = 28

var _health: float
var _last_speed: float = 0.0
var _broken: bool = false

func _ready() -> void:
	_health = max_health
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = true
	collision_layer = 2
	collision_mask = 1 | 2 | 4
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	_last_speed = linear_velocity.length()

func apply_damage(amount: float, hit_position: Vector3 = Vector3.ZERO) -> void:
	if _broken or amount <= 0.0:
		return
	if hit_position == Vector3.ZERO:
		hit_position = global_position
	_health -= amount
	if _health <= 0.0:
		_break(hit_position)

func _on_body_entered(_body: Node) -> void:
	if _last_speed < impact_threshold:
		return
	var damage := (_last_speed - impact_threshold) * impact_damage_scale
	apply_damage(damage, global_position)

func _break(hit_position: Vector3) -> void:
	_broken = true
	_spawn_debris.call_deferred(hit_position)
	queue_free()

func _spawn_debris(hit_position: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "DestructionDebris"
	particles.amount = maxi(debris_count, 1)
	particles.lifetime = 0.65
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.local_coords = false
	particles.visibility_aabb = AABB(Vector3(-4, -4, -4), Vector3(8, 8, 8))

	var process := ParticleProcessMaterial.new()
	process.direction = Vector3.UP
	process.spread = 180.0
	process.initial_velocity_min = 2.5
	process.initial_velocity_max = 7.0
	process.gravity = Vector3(0, -16, 0)
	process.scale_min = 0.45
	process.scale_max = 1.35
	process.angular_velocity_min = -360.0
	process.angular_velocity_max = 360.0
	process.color = debris_color
	particles.process_material = process

	var shard := BoxMesh.new()
	shard.size = Vector3(0.12, 0.08, 0.16)
	shard.material = ArenaPalette.matte(debris_color)
	particles.draw_pass_1 = shard
	particles.material_override = ArenaPalette.matte(debris_color)

	get_parent().add_child(particles)
	particles.global_position = hit_position
	particles.restart()
	particles.emitting = true
	var cleanup := get_tree().create_timer(2.0)
	cleanup.timeout.connect(particles.queue_free)

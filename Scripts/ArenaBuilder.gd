extends Node3D

@export var world_seed: int = 470500
@export var generate_on_ready: bool = true

func _ready() -> void:
	if generate_on_ready:
		build_arena()

func build_arena() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed
	var ground_material := load("res://Materials/GroundTriplanar.tres") as Material
	TerrainBuilder.build(self, ground_material)
	ArchitectureBuilder.build(self, rng)
	ScatterBuilder.build(self, rng)
	_spawn_destructibles(rng)

func _spawn_destructibles(rng: RandomNumberGenerator) -> void:
	var group := Node3D.new()
	group.name = "DestructibleDecor"
	add_child(group)
	for i in range(42):
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(28.0, 58.0)
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		var position := Vector3(x, TerrainBuilder.height_at(x, z) + 1.2, z)
		if i % 3 == 0:
			_create_destructible(group, "WoodenCrate", Vector3(1.5, 1.5, 1.5), position, ArenaPalette.WOOD, 35.0)
		elif i % 3 == 1:
			_create_destructible(group, "ClayUrn", Vector3(0.9, 1.4, 0.9), position, ArenaPalette.CLAY, 20.0, 6)
		else:
			_create_destructible(group, "StoneBench", Vector3(2.8, 0.65, 0.8), position, ArenaPalette.STONE, 65.0)

func _create_destructible(parent: Node3D, name_text: String, size: Vector3, position: Vector3, color: Color, health: float, sides: int = 4) -> void:
	var body := Destructible.new()
	body.name = name_text
	body.position = position
	body.mass = 12.0 if color == ArenaPalette.STONE else 4.0
	body.max_health = health
	body.debris_color = color
	var shape: Shape3D
	if sides == 4:
		var mesh := BoxMesh.new()
		mesh.size = size
		var visual := _mesh_child(mesh)
		visual.material_override = ArenaPalette.matte(color)
		body.add_child(visual)
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape = box_shape
	else:
		var mesh := CylinderMesh.new()
		mesh.bottom_radius = size.x * 0.5
		mesh.top_radius = size.x * 0.32
		mesh.height = size.y
		mesh.radial_segments = sides
		mesh.rings = 1
		var visual := _mesh_child(mesh)
		visual.material_override = ArenaPalette.matte(color)
		body.add_child(visual)
		var cylinder_shape := CylinderShape3D.new()
		cylinder_shape.radius = size.x * 0.5
		cylinder_shape.height = size.y
		shape = cylinder_shape
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	body.rotation.y = randf() * TAU
	parent.add_child(body)

func _mesh_child(mesh: Mesh) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	return instance

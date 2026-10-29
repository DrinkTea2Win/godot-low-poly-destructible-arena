class_name TerrainBuilder
extends RefCounted

const SIZE := 500.0
const CELLS := 100
const CELL_SIZE := SIZE / CELLS

static func height_at(x: float, z: float) -> float:
	var broad := sin(x * 0.018) * 4.0 + cos(z * 0.021) * 3.5
	var detail := sin((x + z) * 0.065) * 1.2 + cos((x - z) * 0.052) * 0.9
	var radius := Vector2(x, z).length()
	var crater := -8.0 * exp(-pow(radius / 30.0, 2.0))
	var rim := 3.5 * exp(-pow((radius - 39.0) / 9.0, 2.0))
	var east_west_ridges := 8.0 * exp(-pow((absf(x) - 150.0) / 35.0, 2.0))
	return broad + detail + crater + rim + east_west_ridges

static func build(parent: Node3D, material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(CELLS):
		for x in range(CELLS):
			var x0 := -SIZE * 0.5 + x * CELL_SIZE
			var x1 := x0 + CELL_SIZE
			var z0 := -SIZE * 0.5 + z * CELL_SIZE
			var z1 := z0 + CELL_SIZE
			var a := Vector3(x0, height_at(x0, z0), z0)
			var b := Vector3(x1, height_at(x1, z0), z0)
			var c := Vector3(x0, height_at(x0, z1), z1)
			var d := Vector3(x1, height_at(x1, z1), z1)
			_add_triangle(surface, a, c, b)
			_add_triangle(surface, b, c, d)
	surface.generate_normals()
	var terrain := MeshInstance3D.new()
	terrain.name = "FacetedTerrain500m"
	terrain.mesh = surface.commit()
	terrain.material_override = material
	parent.add_child(terrain)

	var heights := PackedFloat32Array()
	heights.resize((CELLS + 1) * (CELLS + 1))
	for z in range(CELLS + 1):
		for x in range(CELLS + 1):
			var wx := -SIZE * 0.5 + x * CELL_SIZE
			var wz := -SIZE * 0.5 + z * CELL_SIZE
			heights[z * (CELLS + 1) + x] = height_at(wx, wz)
	var shape := HeightMapShape3D.new()
	shape.map_width = CELLS + 1
	shape.map_depth = CELLS + 1
	shape.map_data = heights
	var body := StaticBody3D.new()
	body.name = "TerrainCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.scale = Vector3(CELL_SIZE, 1.0, CELL_SIZE)
	body.add_child(collision)
	parent.add_child(body)

static func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_vertex(c)

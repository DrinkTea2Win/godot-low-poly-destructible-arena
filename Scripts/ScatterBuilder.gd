class_name ScatterBuilder
extends RefCounted

const MAP_LIMIT := 242.0

static func build(parent: Node3D, rng: RandomNumberGenerator) -> void:
	var tree_transforms: Array[Transform3D] = []
	var attempts := 0
	while tree_transforms.size() < 2200 and attempts < 16000:
		attempts += 1
		var x := rng.randf_range(-MAP_LIMIT, MAP_LIMIT)
		var z := rng.randf_range(-MAP_LIMIT, MAP_LIMIT)
		var north := z < -65.0
		if not north and rng.randf() > 0.055:
			continue
		if Vector2(x, z).length() < 65.0:
			continue
		if z > 70.0 and absf(x) < 150.0:
			continue
		if absf(absf(x) - 150.0) < 20.0:
			continue
		var y := TerrainBuilder.height_at(x, z)
		var scale_factor := rng.randf_range(0.75, 1.5)
		var basis := Basis(Vector3.UP, rng.randf_range(0.0, TAU)).scaled(Vector3.ONE * scale_factor)
		tree_transforms.append(Transform3D(basis, Vector3(x, y, z)))
	_build_forest(parent, tree_transforms)
	_build_rocks(parent, rng)
	_build_bushes(parent, rng)

static func _build_forest(parent: Node3D, transforms: Array[Transform3D]) -> void:
	var trunk := CylinderMesh.new()
	trunk.bottom_radius = 0.45
	trunk.top_radius = 0.30
	trunk.height = 5.0
	trunk.radial_segments = 8
	trunk.rings = 1
	_add_multimesh(parent, "TreeTrunks_8Sides", trunk, ArenaPalette.matte(ArenaPalette.WOOD), transforms, Vector3(0, 2.5, 0))

	var crown := CylinderMesh.new()
	crown.bottom_radius = 2.8
	crown.top_radius = 0.0
	crown.height = 6.0
	crown.radial_segments = 3
	crown.rings = 1
	_add_multimesh(parent, "SharpCrowns_Emerald", crown, ArenaPalette.matte(ArenaPalette.LEAF_GREEN), transforms, Vector3(0, 7.0, 0))

	var upper := CylinderMesh.new()
	upper.bottom_radius = 2.0
	upper.top_radius = 0.0
	upper.height = 5.0
	upper.radial_segments = 3
	upper.rings = 1
	_add_multimesh(parent, "SharpCrowns_OrangeTips", upper, ArenaPalette.matte(ArenaPalette.LEAF_ORANGE), transforms, Vector3(0, 10.0, 0))

static func _build_rocks(parent: Node3D, rng: RandomNumberGenerator) -> void:
	var transforms: Array[Transform3D] = []
	for i in range(650):
		var x := rng.randf_range(-MAP_LIMIT, MAP_LIMIT)
		var z := rng.randf_range(-MAP_LIMIT, MAP_LIMIT)
		if Vector2(x, z).length() < 55.0:
			continue
		var ridge_bias := absf(absf(x) - 150.0) < 45.0
		if not ridge_bias and rng.randf() > 0.25:
			continue
		var scale_vector := Vector3(rng.randf_range(0.5, 2.5), rng.randf_range(0.5, 2.0), rng.randf_range(0.5, 2.5))
		var basis := Basis(Vector3.UP, rng.randf_range(0.0, TAU)).scaled(scale_vector)
		transforms.append(Transform3D(basis, Vector3(x, TerrainBuilder.height_at(x, z) + 0.8, z)))
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = 1.4
	mesh.top_radius = 0.65
	mesh.height = 1.8
	mesh.radial_segments = 5
	mesh.rings = 1
	_add_multimesh(parent, "FacetedRocks", mesh, ArenaPalette.matte(ArenaPalette.STONE), transforms)

static func _build_bushes(parent: Node3D, rng: RandomNumberGenerator) -> void:
	var transforms: Array[Transform3D] = []
	for i in range(900):
		var x := rng.randf_range(-MAP_LIMIT, MAP_LIMIT)
		var z := rng.randf_range(-MAP_LIMIT, MAP_LIMIT)
		if Vector2(x, z).length() < 50.0:
			continue
		var s := rng.randf_range(0.5, 1.4)
		var basis := Basis(Vector3.UP, rng.randf_range(0.0, TAU)).scaled(Vector3.ONE * s)
		transforms.append(Transform3D(basis, Vector3(x, TerrainBuilder.height_at(x, z) + 0.55, z)))
	var mesh := PrismMesh.new()
	mesh.size = Vector3(1.8, 1.1, 1.8)
	_add_multimesh(parent, "AngularBushes", mesh, ArenaPalette.matte(ArenaPalette.LEAF_GREEN), transforms)

static func _add_multimesh(parent: Node3D, name_text: String, mesh: Mesh, material: Material, transforms: Array[Transform3D], offset: Vector3 = Vector3.ZERO) -> void:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for i in range(transforms.size()):
		var transform := transforms[i]
		transform.origin += transform.basis * offset
		multimesh.set_instance_transform(i, transform)
	var instance := MultiMeshInstance3D.new()
	instance.name = name_text
	instance.multimesh = multimesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)

class_name ArenaMeshFactory
extends RefCounted

static func box(parent: Node3D, name_text: String, size: Vector3, position: Vector3, material: Material, rotation_y: float = 0.0) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_text
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation.y = rotation_y
	parent.add_child(instance)
	return instance

static func cylinder(parent: Node3D, name_text: String, radius: float, height: float, sides: int, position: Vector3, material: Material, top_radius: float = -1.0) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_text
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = radius
	mesh.top_radius = radius if top_radius < 0.0 else top_radius
	mesh.height = height
	mesh.radial_segments = sides
	mesh.rings = 1
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	parent.add_child(instance)
	return instance

static func solid_box(parent: Node3D, name_text: String, size: Vector3, position: Vector3, material: Material, rotation_y: float = 0.0) -> CSGBox3D:
	var instance := CSGBox3D.new()
	instance.name = name_text
	instance.size = size
	instance.position = position
	instance.rotation.y = rotation_y
	instance.material = material
	instance.use_collision = true
	parent.add_child(instance)
	return instance

static func solid_cylinder(parent: Node3D, name_text: String, radius: float, height: float, position: Vector3, material: Material) -> CSGCylinder3D:
	var instance := CSGCylinder3D.new()
	instance.name = name_text
	instance.radius = radius
	instance.height = height
	instance.sides = 6
	instance.position = position
	instance.material = material
	instance.use_collision = true
	parent.add_child(instance)
	return instance

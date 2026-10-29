class_name ArchitectureBuilder
extends RefCounted

static func build(parent: Node3D, rng: RandomNumberGenerator) -> void:
	_build_central_arena(parent)
	_build_southern_ruins(parent, rng)
	_build_ridges_and_bridges(parent)

static func _build_central_arena(parent: Node3D) -> void:
	var arena := Node3D.new()
	arena.name = "Central_Crater_Arena"
	parent.add_child(arena)
	var stone := ArenaPalette.matte(ArenaPalette.STONE)
	var dark := ArenaPalette.matte(ArenaPalette.EARTH)
	var y := TerrainBuilder.height_at(0, 0)
	ArenaMeshFactory.solid_cylinder(arena, "ArenaPodium", 25.0, 1.2, Vector3(0, y + 0.6, 0), dark).sides = 32
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var x := cos(angle) * 34.0
		var z := sin(angle) * 34.0
		var ground := TerrainBuilder.height_at(x, z)
		var height := 4.0 if i % 3 == 0 else 9.0
		var column := ArenaMeshFactory.solid_cylinder(arena, "BrokenColumn_%02d" % i, 1.35, height, Vector3(x, ground + height * 0.5, z), stone)
		column.rotation.z = deg_to_rad(7.0) if i % 3 == 0 else 0.0
		ArenaMeshFactory.box(arena, "ColumnCapital", Vector3(3.5, 0.55, 3.5), Vector3(x, ground + height, z), stone, angle)
	for i in range(4):
		var angle := TAU * float(i) / 4.0 + PI * 0.25
		var pos := Vector3(cos(angle) * 18.0, y + 2.5, sin(angle) * 18.0)
		var color := ArenaPalette.CYAN if i % 2 == 0 else ArenaPalette.VIOLET
		var crystal := ArenaMeshFactory.cylinder(arena, "MagicCrystal", 0.75, 4.0, 4, pos, ArenaPalette.emissive(color), 0.0)
		crystal.rotation.z = 0.18
		var light := OmniLight3D.new()
		light.position = pos
		light.light_color = color
		light.light_energy = 2.0
		light.omni_range = 12.0
		arena.add_child(light)

static func _build_southern_ruins(parent: Node3D, rng: RandomNumberGenerator) -> void:
	var ruins := Node3D.new()
	ruins.name = "South_Ancient_City"
	parent.add_child(ruins)
	var stone := ArenaPalette.matte(ArenaPalette.STONE)
	var dark := ArenaPalette.matte(ArenaPalette.EARTH)
	for row in range(3):
		for column in range(5):
			var x := -100.0 + column * 48.0 + rng.randf_range(-4.0, 4.0)
			var z := 95.0 + row * 48.0 + rng.randf_range(-4.0, 4.0)
			var base_y := TerrainBuilder.height_at(x, z)
			var house := CSGCombiner3D.new()
			house.name = "RuinedHouse_%d_%d" % [row, column]
			house.position = Vector3(x, base_y, z)
			house.rotation.y = rng.randf_range(-0.12, 0.12)
			house.use_collision = true
			ruins.add_child(house)
			ArenaMeshFactory.solid_box(house, "Floor", Vector3(20, 0.8, 16), Vector3(0, 0.4, 0), dark)
			ArenaMeshFactory.solid_box(house, "BackWall", Vector3(20, rng.randf_range(4, 8), 1.2), Vector3(0, 3.0, 7.4), stone)
			ArenaMeshFactory.solid_box(house, "SideWall", Vector3(1.2, rng.randf_range(3, 7), 16), Vector3(-9.4, 2.5, 0), stone)
			ArenaMeshFactory.solid_box(house, "BrokenFrontLeft", Vector3(7.0, 3.8, 1.2), Vector3(-6.5, 1.9, -7.4), stone)
			ArenaMeshFactory.solid_box(house, "BrokenFrontRight", Vector3(5.0, 2.8, 1.2), Vector3(7.5, 1.4, -7.4), stone)
	for i in range(9):
		var x := -130.0 + i * 32.0
		var z := 75.0
		var h := rng.randf_range(3.0, 7.0)
		ArenaMeshFactory.solid_box(ruins, "CityWallFragment", Vector3(24, h, 2), Vector3(x, TerrainBuilder.height_at(x, z) + h * 0.5, z), stone)

static func _build_ridges_and_bridges(parent: Node3D) -> void:
	var group := Node3D.new()
	group.name = "EastWest_Ridges_And_Bridges"
	parent.add_child(group)
	var stone := ArenaPalette.matte(ArenaPalette.STONE)
	var wood := ArenaPalette.matte(ArenaPalette.WOOD)
	for side in [-1.0, 1.0]:
		for i in range(9):
			var z := -110.0 + i * 28.0
			var x := side * (150.0 + sin(i * 1.7) * 12.0)
			var y := TerrainBuilder.height_at(x, z)
			var rock := ArenaMeshFactory.solid_cylinder(group, "RidgeFacet", 8.0, 16.0, Vector3(x, y + 7.0, z), stone)
			rock.scale = Vector3(1.3, 1.0, 0.8)
		var bridge_y := TerrainBuilder.height_at(side * 150.0, 0) + 10.0
		for i in range(16):
			var x := side * (126.0 + i * 3.2)
			ArenaMeshFactory.solid_box(group, "BridgePlank", Vector3(3.0, 0.35, 7.0), Vector3(x, bridge_y, 0), wood)
		for z_side in [-3.6, 3.6]:
			ArenaMeshFactory.solid_box(group, "BridgeRail", Vector3(52, 0.25, 0.25), Vector3(side * 150, bridge_y + 1.2, z_side), wood)

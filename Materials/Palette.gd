class_name ArenaPalette
extends RefCounted

const EARTH := Color("3B3631")
const STONE := Color("5E6366")
const LEAF_GREEN := Color("2A5C38")
const LEAF_ORANGE := Color("C76B22")
const CYAN := Color("00E5FF")
const VIOLET := Color("9D00FF")
const WOOD := Color("67452D")
const CLAY := Color("A55435")
const DARK := Color("242729")

static func matte(color: Color, roughness: float = 0.9) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

static func emissive(color: Color, energy: float = 3.0) -> StandardMaterial3D:
	var material := matte(color, 0.45)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material

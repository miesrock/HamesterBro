extends Node3D

func _ready() -> void:
	print("Test Environment Loaded")
	_build_wall_debug_art()


func _build_wall_debug_art() -> void:
	var text_color := Color(0.9, 0.92, 0.88, 0.62)
	_add_wall_label("WALL-HAMARD\nTRAINING GRID 04\nCAT ZONE - TEST ART", Vector3(-12.0, 3.2, -39.78), 70, text_color)
	_add_wall_label("SCHEMATIC ARCHETYPE\nSPRAY CONE: ACTIVE\nENEMY FLOW: 160\nHAMSTER CORE: ONLINE", Vector3(12.0, 3.6, -39.78), 34, text_color)

	var cyan := _make_hologram_material(Color(0.3, 1.0, 1.0, 0.55))
	_add_holo_box("HoloCubeA", Vector3(8.0, 3.2, -34.0), Vector3(2.4, 2.0, 0.06), cyan)
	_add_holo_box("HoloCubeB", Vector3(12.0, 4.1, -34.0), Vector3(2.0, 1.3, 0.06), cyan)
	_add_holo_box("HoloGraphBase", Vector3(10.2, 2.35, -33.95), Vector3(5.4, 0.06, 0.06), cyan)
	_add_holo_box("HoloGraphRise", Vector3(9.0, 2.82, -33.95), Vector3(0.06, 1.0, 0.06), cyan)
	_add_holo_box("HoloGraphPeak", Vector3(10.8, 3.4, -33.95), Vector3(0.06, 2.1, 0.06), cyan)


func _add_wall_label(label_text: String, local_position: Vector3, font_size: int, color: Color) -> void:
	var label := Label3D.new()
	label.text = label_text
	label.font_size = font_size
	label.modulate = color
	label.outline_size = 2
	label.outline_modulate = Color(0.1, 0.12, 0.12, 0.5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = local_position
	label.rotation_degrees.x = 0.0
	add_child(label)


func _add_holo_box(node_name: String, local_position: Vector3, size: Vector3, material: Material) -> void:
	var box := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	box.name = node_name
	box.mesh = mesh
	box.material_override = material
	box.position = local_position
	add_child(box)


func _make_hologram_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = 1.4
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material

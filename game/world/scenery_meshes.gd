extends RefCounted

static var rock_source_arrays: Array = []

static func _branch(surface: SurfaceTool, start: Vector3, end: Vector3, bottom: float, top: float, color: Color) -> void:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = bottom
	mesh.top_radius = top
	mesh.height = start.distance_to(end)
	mesh.radial_segments = 8
	var rotation := Basis(Quaternion(Vector3.UP, (end - start).normalized()))
	_append(surface, mesh, Transform3D(rotation, (start + end) * 0.5), color, false)

static func _append(surface: SurfaceTool, mesh: Mesh, transform: Transform3D, color: Color, foliage: bool) -> void:
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var normal_basis := transform.basis.inverse().transposed()
	for index in indices:
		var vertex := vertices[index]
		if foliage:
			var scallop := 1.0 + 0.13 * sin(atan2(vertex.z, vertex.x) * 5.0 + vertex.y * 3.0)
			vertex.x *= scallop
			vertex.z *= scallop
		var tint := color.darkened(maxf(-vertex.y, 0) * (0.12 if foliage else 0.0)).lightened(maxf(normals[index].y, 0) * (0.22 if foliage else 0.06)).srgb_to_linear()
		tint.a = 1.0 if foliage else 0.0
		surface.set_color(tint)
		surface.set_smooth_group(0 if foliage else (1 if absf(normals[index].y) < 0.5 else 2))
		surface.set_normal((normal_basis * normals[index]).normalized())
		surface.add_vertex(transform * vertex)

static func tree(size: float, variant: int, palm: bool) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var turn := variant * 0.73
	var bend := Vector3(cos(turn), 0, sin(turn)) * 0.12
	var crown := (Vector3.UP * (2.35 if palm else 1.85) + bend) * size
	var previous := Vector3.ZERO
	for i in range(4):
		var t := (i + 1) / 4.0
		var end := Vector3(0, crown.y * t, 0) + bend * t * t * size
		_branch(surface, previous, end, lerpf(0.22, 0.075, i / 4.0) * size, lerpf(0.22, 0.075, t) * size, Color("997454") if palm else Color("927052"))
		previous = end
	if palm:
		for i in range(7):
			var angle := turn + i * TAU / 7
			var direction := Vector3(cos(angle), 0, sin(angle))
			var side := Vector3(-sin(angle), 0, cos(angle))
			for step in range(6):
				for corner in [Vector2(0, -1), Vector2(1, -1), Vector2(0, 1), Vector2(0, 1), Vector2(1, -1), Vector2(1, 1)]:
					var t: float = (step + corner.x) / 6.0
					var center := direction * t * 1.16 + Vector3.UP * (sin(t * PI) * 0.42 - t * t * 0.35)
					var width := sin(t * PI) * (0.22 if step % 2 else 0.17)
					var tint := Color("52945e").lerp(Color("a2bd63"), t).srgb_to_linear()
					tint.a = 1
					surface.set_color(tint)
					surface.set_smooth_group(0)
					surface.set_normal((Vector3.UP + side * corner.y * 0.4).normalized())
					surface.add_vertex(crown + (center + side * width * corner.y) * size)
	else:
		var leaf := SphereMesh.new()
		leaf.radius = 1
		leaf.height = 2
		leaf.radial_segments = 12
		leaf.rings = 6
		var slender := variant % 4 == 2
		for i in range(6):
			var angle := turn + i * TAU / 6
			var reach := (0.36 if slender else 0.62) * (0.88 + 0.12 * sin(variant + i * 2.4))
			var tip := crown + Vector3(cos(angle) * reach, 0.12 + float((i + variant) % 3) * 0.19, sin(angle) * reach) * size
			_branch(surface, crown * 0.62, tip, 0.08 * size, 0.025 * size, Color("927052"))
			var dimensions := Vector3(0.49, 0.81, 0.49) if slender else Vector3(0.62, 0.45 + float(i % 3) * 0.1, 0.57)
			var tint := Color(["75a65b", "91b968", "659e63"][(i + variant) % 3])
			if variant >= 100:
				tint = tint.lerp(Color("458574"), 0.35)
			var rotation := Basis.from_euler(Vector3(sin(angle) * 0.2, angle, cos(angle) * 0.2))
			_append(surface, leaf, Transform3D(rotation.scaled(dimensions * size), tip), tint, true)
			if i % 2 == 0:
				var upper := tip + Vector3(-cos(angle) * 0.13, 0.44, -sin(angle) * 0.13) * size
				_append(surface, leaf, Transform3D(rotation.scaled(dimensions * size * 0.7), upper), tint.lightened(0.06), true)
		_append(surface, leaf, Transform3D(Basis.from_scale(Vector3(0.6, 0.64 if slender else 0.48, 0.57) * size), crown + Vector3.UP * (1.0 if slender else 0.6) * size), Color("8bb465"), true)
	surface.generate_normals()
	surface.index()
	return surface.commit()

static func rock(size: Vector3, seed_value: int, moss: bool) -> ArrayMesh:
	if rock_source_arrays.is_empty():
		var source := SphereMesh.new()
		source.radius = 1
		source.height = 2
		source.radial_segments = 9
		source.rings = 4
		rock_source_arrays = source.surface_get_arrays(0)
	var vertices: PackedVector3Array = rock_source_arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = rock_source_arrays[Mesh.ARRAY_INDEX]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for index in indices:
		var vertex := vertices[index]
		var angle := atan2(vertex.z, vertex.x)
		var uneven := 0.88 + 0.09 * sin(angle * 3 + seed_value) + 0.03 * cos(vertex.y * 5 + seed_value)
		vertex *= uneven
		vertex.y = maxf(vertex.y, -0.6)
		var tint := Color.WHITE.darkened(0.08 + 0.08 * sin(angle + seed_value))
		if moss and vertex.y > 0.3 + sin(angle * 2 + seed_value) * 0.15:
			tint = tint.lerp(Color("7c9a62"), 0.6)
		surface.set_color(tint.srgb_to_linear())
		surface.add_vertex(vertex * size)
	surface.generate_normals()
	surface.index()
	return surface.commit()

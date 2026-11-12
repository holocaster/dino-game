extends Node3D

const TREE_SHADER := preload("res://world/tree.gdshader")
const POND := Vector2(-7.2, 0.1)
const AREAS := [Vector3(0, 1.0, 4.0), Vector3(-6.2, 0, 3.3), Vector3(0, -6.8, 3.2), Vector3(-11, -8, 4.2), Vector3(6, -12, 4.8), Vector3(0, -20, 3.7)]
const GRID := Rect2i(-80, -104, 145, 145)
const POND_SIZE := Vector2(1.55, 1.25)
var navigation := AStarGrid2D.new()
var trail := Curve2D.new()
var trails: Array[Curve2D] = []
var obstacles: Array[Vector3] = [Vector3(-3.3, -2.5, 0.8), Vector3(3.25, 0, 0.8), Vector3(0.5, -3.3, 0.75), Vector3(-2.1, -9.5, 1.0)]
var materials: Dictionary = {}
var trees: Array[Dictionary] = []
var race_track: Curve2D
var theme := "forest"

func height_at(x: float, z: float) -> float:
	if theme == "beach":
		var coast := ((Vector2(x, z) - Vector2(-1, -5)) / Vector2(21, 17.5)).length()
		return 0.16 + sin(x * 0.3) * cos(z * 0.3) * 0.08 - smoothstep(0.88, 1.08, coast) * 0.8
	return 0.08 + 0.10 * sin(x * 0.65) * sin(z * 0.6) + maxf(Vector2(x, z).length() - 27.0, 0) * 0.12 + 2.4 * smoothstep(9.0, 24.0, -z) - 0.32 * (1 - smoothstep(0.85, 1.2, ((Vector2(x, z) - POND) / POND_SIZE).length()))

func point(x: float, z: float) -> Vector3:
	return Vector3(x, height_at(x, z), z)

func blocked(p: Vector2) -> bool:
	if race_track:
		return distance_to_trail(p) > 2.8
	var inside := false
	for area in AREAS:
		if p.distance_to(Vector2(area.x, area.y)) < area.z:
			inside = true
	if not inside and distance_to_trail(p) > 1.2:
		return true
	if ((p - POND) / (POND_SIZE + Vector2.ONE * 0.45)).length() < 1:
		return true
	for obstacle in obstacles:
		if p.distance_to(Vector2(obstacle.x, obstacle.y)) < obstacle.z:
			return true
	return false

func distance_to_trail(p: Vector2) -> float:
	var distance := INF
	for path in trails:
		distance = minf(distance, p.distance_to(path.get_closest_point(p)))
	return distance

func _make_loop(points: Array) -> Curve2D:
	var path := Curve2D.new()
	path.bake_interval = 0.1
	for i in range(points.size() + 1):
		var index := i % points.size()
		var tangent: Vector2 = (points[(index + 1) % points.size()] - points[posmod(index - 1, points.size())]).normalized() * 0.7
		path.add_point(points[index], -tangent, tangent)
	return path

func _ready() -> void:
	if race_track:
		trail = race_track
		trails.append(trail)
	else:
		trail = _make_loop([Vector2(0, 2.8), Vector2(-3, 3), Vector2(-4.85, 2), Vector2(-4.85, -1.6), Vector2(-4.4, -4), Vector2(-1.2, -6.3), Vector2(1.3, -6.1), Vector2(2.4, -3.4), Vector2(2.1, -1.5), Vector2(2.3, 1.8)])
		trails.append(trail)
		trails.append(_make_loop([Vector2(-4.4, -4), Vector2(-8, -5), Vector2(-11, -8), Vector2(-10, -12), Vector2(-6, -16), Vector2(-2, -19), Vector2(0, -20), Vector2(4, -18), Vector2(7, -14), Vector2(6, -11), Vector2(3, -9), Vector2(1.3, -6.1), Vector2(-1.2, -6.3)]))
	if theme == "beach":
		_beach()
		return

	if not race_track:
		navigation.region = GRID
		navigation.cell_size = Vector2.ONE * 0.25
		navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		navigation.update()
		for x in range(GRID.position.x, GRID.end.x):
			for z in range(GRID.position.y, GRID.end.y):
				navigation.set_point_solid(Vector2i(x, z), blocked(Vector2(x, z) * 0.25))
	var backdrop := PlaneMesh.new()
	backdrop.size = Vector2.ONE * 200
	place(backdrop, Vector3(0, -0.45, 0), "7caa42")
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(-48, 41):
		for z in range(-74, 29):
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var p := Vector2(x + offset.x, z + offset.y) * 0.5
				var distance := distance_to_trail(p)
				var color := Color("8dbb46").lerp(Color("75a83d"), (sin(p.x * 1.8) * cos(p.y * 1.3) + 1) * 0.3)
				color = color.lerp(Color("61994c"), 1 - smoothstep(1.8, 4.2, p.distance_to(Vector2(0, -6.8))))
				color = color.lerp(Color("4e8961"), 1 - smoothstep(2.5, 5.5, p.distance_to(Vector2(-11, -8))))
				color = color.lerp(Color("a7bd5d"), 1 - smoothstep(3.0, 6.0, p.distance_to(Vector2(6, -12))))
				color = color.lerp(Color("aaa987"), 1 - smoothstep(2.5, 4.5, p.distance_to(Vector2(0, -20))))
				var width := 2.8 if race_track else 0.85
				if distance < width:
					color = Color("e8c483").lerp(color, smoothstep(width - 0.2, width, distance))
				surface.set_color(color.srgb_to_linear())
				surface.add_vertex(point(p.x, p.y))
	surface.generate_normals()
	var terrain := MeshInstance3D.new()
	terrain.mesh = surface.commit()
	terrain.material_override = StandardMaterial3D.new()
	terrain.material_override.vertex_color_use_as_albedo = true
	terrain.material_override.roughness = 1
	add_child(terrain)
	blob(Vector3(POND.x, 0.025, POND.y), Vector3(POND_SIZE.x, 0.07, POND_SIZE.y), "30aeb0")
	for i in range(5):
		var ripple := TorusMesh.new()
		ripple.inner_radius = 0.22 + i * 0.13
		ripple.outer_radius = ripple.inner_radius + 0.012
		var water := place(ripple, Vector3(POND.x - 0.2, 0.09, POND.y - 0.1), "9ae2cc")
		water.scale = Vector3(1.3, 0.03, 0.65)
	var rng := RandomNumberGenerator.new()
	rng.seed = 21403
	for area_index in range(AREAS.size()):
		var area: Vector3 = AREAS[area_index]
		var count := 8 if area_index >= 4 else 11
		for i in range(count):
			var angle := i * TAU / count
			var radius := area.z + rng.randf_range(1.5, 2.6)
			var p := Vector2(area.x, area.y) + Vector2(cos(angle), sin(angle)) * radius
			if area_index == 5 and p.y < area.y - 1:
				continue
			if blocked(p) and distance_to_trail(p) > 1.4:
				tree(p, rng.randf_range(1.45, 2.05), i + (100 if area_index in [2, 3] else 0))
	for i in range(18):
		var distance: float = trails[-1].get_baked_length() * i / 18.0
		var p: Vector2 = trails[-1].sample_baked(distance)
		var tangent: Vector2 = (trails[-1].sample_baked(minf(distance + 0.2, trails[-1].get_baked_length())) - p).normalized()
		p += Vector2(-tangent.y, tangent.x) * (3.0 if i % 2 else -3.0)
		if blocked(p) and distance_to_trail(p) > 1.6 and not trees.any(func(item): return item.position.distance_to(p) < 3.0) and p.y > -21:
			tree(p, rng.randf_range(1.5, 1.9), i)

	for i in range(obstacles.size()):
		tree(Vector2(obstacles[i].x, obstacles[i].y), 2.15 if i == 3 else 1.35, 100 if i == 3 else i)
	for i in range(3):
		var lily := Vector3(POND.x + i * 0.5 - 0.5, 0.105, POND.y + 0.35)
		blob(lily, Vector3(0.18, 0.015, 0.14), "65994b")
		blob(lily + Vector3.UP * 0.045, Vector3(0.065, 0.045, 0.065), "e3a4a0")
	for i in range(18):
		var angle := i * TAU / 18
		var p := POND + Vector2(cos(angle), sin(angle)) * (POND_SIZE + Vector2.ONE * 0.22)
		blob(point(p.x, p.y), Vector3(0.20, 0.19, 0.16), "99a18b", true)
	var leaves := SurfaceTool.new()
	leaves.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(1200):
		var p := Vector2(rng.randf_range(-20, 15), rng.randf_range(-26, 8))
		if not blocked(p) or distance_to_trail(p) < 1.25:
			continue
		if ((p - POND) / (POND_SIZE + Vector2.ONE * 0.1)).length() < 1:
			continue
		var base := point(p.x, p.y)
		for j in range(7):
			var angle := j * TAU / 7 + i
			var direction := Vector3(cos(angle), 0, sin(angle))
			var side := Vector3(-sin(angle), 0, cos(angle)) * 0.09
			var end := base + direction * 0.48 + Vector3.UP * 0.2
			var middle := base.lerp(end, 0.5) + Vector3.UP * 0.18
			leaves.set_color((Color("447f35") if j % 2 else Color("6fa333")).srgb_to_linear())
			for v in [base, middle + side, end, base, end, middle - side]:
				leaves.add_vertex(v)
	leaves.generate_normals()
	var plants := MeshInstance3D.new()
	plants.mesh = leaves.commit()
	plants.material_override = StandardMaterial3D.new()
	plants.material_override.vertex_color_use_as_albedo = true
	plants.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	plants.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(plants)

	_expanded_landscape()

func place(mesh: Mesh, position_3d: Vector3, color: String) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	if not materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(color)
		material.roughness = 0.95
		materials[color] = material
	node.material_override = materials[color]
	add_child(node)
	node.position = position_3d
	return node

func blob(position_3d: Vector3, size: Vector3, color: String, solid: bool = false) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 1
	mesh.height = 2
	mesh.radial_segments = 16
	mesh.rings = 10
	place(mesh, position_3d, color).scale = size
	if solid:
		_solid(position_3d, maxf(size.x, size.z), size.y * 2)

func _solid(position_3d: Vector3, radius: float, height: float) -> void:
	if not race_track:
		return
	var body := StaticBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	add_child(body)
	body.position = position_3d
	var shape := CollisionShape3D.new()
	shape.shape = CylinderShape3D.new()
	shape.shape.radius = radius
	shape.shape.height = height
	body.add_child(shape)

func tree(p: Vector2, size: float, variant: int) -> void:
	if race_track and distance_to_trail(p) < 3.6:
		return
	var first := get_child_count()
	var base := point(p.x, p.y)
	var trunk := CylinderMesh.new()
	trunk.bottom_radius = 0.22 * size
	trunk.top_radius = 0.12 * size
	trunk.height = 1.8 * size
	place(trunk, base + Vector3.UP * trunk.height / 2, "987044")
	for j in range(5):
		var angle := j * TAU / 5
		var canopy := base + Vector3(cos(angle) * 0.5, 1.8 + float(j % 2) * 0.35, sin(angle) * 0.5) * size
		if theme == "beach":
			var leaf_count := get_child_count()
			blob(canopy, Vector3(0.95, 0.12, 0.3) * size, ["448655", "64a75c", "548d38"][j % 3])
			get_child(leaf_count).rotation.y = -angle
		else:
			blob(canopy, Vector3(0.8, 0.62, 0.78) * size, (["306b47", "448655", "64a75c"] if variant >= 100 else ["548d38", "71a33c", "8db648"])[(j + variant) % 3])

	for i in range(first + 1, get_child_count()):
		get_child(i).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var meshes: Array[Node] = []
	for i in range(first, get_child_count()):
		meshes.append(get_child(i))
	var merged := SurfaceTool.new()
	merged.begin(Mesh.PRIMITIVE_TRIANGLES)
	for source in meshes:
		var arrays: Array = source.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var color: Color = source.material_override.albedo_color.srgb_to_linear()
		color.a = 0.0 if source.mesh is CylinderMesh else 1.0
		merged.set_color(color)
		var normal_basis: Basis = source.transform.basis.inverse().transposed()
		for index in indices:
			merged.set_normal((normal_basis * normals[index]).normalized())
			merged.add_vertex(source.transform * vertices[index])
		source.queue_free()
	merged.index()
	var tree_mesh := MeshInstance3D.new()
	tree_mesh.mesh = merged.commit()
	tree_mesh.material_override = ShaderMaterial.new()
	tree_mesh.material_override.shader = TREE_SHADER
	tree_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(tree_mesh)
	trees.append({"position": p, "radius": size * 1.4, "trunk_radius": size * 0.22, "node": tree_mesh, "canopy_alpha": 1.0, "trunk_alpha": 1.0})
	_solid(base + Vector3.UP * 0.9 * size, 0.22 * size, 1.8 * size)

func _beach() -> void:
	var water := PlaneMesh.new()
	water.size = Vector2.ONE * 200
	place(water, Vector3(0, -0.35, 0), "55c4cd")
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(-47, 44):
		for z in range(-49, 30):
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var p := Vector2(x + offset.x, z + offset.y) * 0.5
				var coast := ((p - Vector2(-1, -5)) / Vector2(21, 17.5)).length()
				var color := Color("efd7a0").lerp(Color("c5dc88"), 1 - smoothstep(0.3, 0.65, coast))
				color = color.lerp(Color("c9b582"), (1 - smoothstep(2.5, 2.8, distance_to_trail(p))) * 0.25)
				surface.set_color(color.srgb_to_linear())
				surface.add_vertex(point(p.x, p.y))
	surface.generate_normals()
	var terrain := MeshInstance3D.new()
	terrain.mesh = surface.commit()
	terrain.material_override = StandardMaterial3D.new()
	terrain.material_override.vertex_color_use_as_albedo = true
	terrain.material_override.roughness = 1
	add_child(terrain)
	for i in range(16):
		var angle := i * TAU / 16
		var p := Vector2(-1, -5) + Vector2(cos(angle) * 8, sin(angle) * 5)
		tree(p, 1.3 + (i % 3) * 0.15, i)
		blob(point(p.x + 0.8, p.y + 0.6), Vector3(0.35, 0.22, 0.3), "b3b5a1", true)
	for i in range(40):
		var angle := i * TAU / 40
		var p := Vector2(-1, -5) + Vector2(cos(angle) * 20, sin(angle) * 16.7)
		blob(Vector3(p.x, -0.31, p.y), Vector3(0.65, 0.025, 0.18), "daf2e2")

func reveal_character(camera: Vector3, character: Vector3, delta: float, subject_radius: float = 0.65) -> void:
	var start := Vector2(camera.x, camera.z)
	var end := Vector2(character.x, character.z)
	var direction := end - start
	for tree in trees:
		var t := clampf((tree.position - start).dot(direction) / maxf(direction.length_squared(), 0.0001), 0, 1)
		var sight_distance: float = tree.position.distance_to(start + direction * t)
		var camera_distance: float = tree.position.distance_to(start)
		var canopy_hidden: bool = sight_distance < tree.radius + maxf(1.0, subject_radius) or camera_distance < tree.radius + 2.0
		var trunk_hidden: bool = sight_distance < tree.trunk_radius + subject_radius or camera_distance < tree.trunk_radius + 0.7
		var canopy_alpha := move_toward(float(tree.canopy_alpha), 0.0 if canopy_hidden else 1.0, delta * 3.5)
		var trunk_alpha := move_toward(float(tree.trunk_alpha), 0.0 if trunk_hidden else 1.0, delta * 3.5)
		if canopy_alpha != tree.canopy_alpha or trunk_alpha != tree.trunk_alpha:
			tree.node.material_override.set_shader_parameter("canopy_alpha", canopy_alpha)
			tree.node.material_override.set_shader_parameter("trunk_alpha", trunk_alpha)
			tree.canopy_alpha = canopy_alpha
			tree.trunk_alpha = trunk_alpha
			tree.node.visible = canopy_alpha > 0 or trunk_alpha > 0

func nearest(p: Vector2) -> Vector2i:
	var rounded_cell := Vector2i((p / navigation.cell_size).round())
	if navigation.is_in_boundsv(rounded_cell) and not navigation.is_point_solid(rounded_cell):
		return rounded_cell
	var best := Vector2i.ZERO
	var distance := INF
	for x in range(GRID.position.x, GRID.end.x):
		for z in range(GRID.position.y, GRID.end.y):
			var cell := Vector2i(x, z)
			var candidate := Vector2(cell) * 0.25
			if not navigation.is_point_solid(cell) and p.distance_squared_to(candidate) < distance:
				distance = p.distance_squared_to(candidate)
				best = cell
	return best

func route(from: Vector3, destination: Vector3) -> PackedVector3Array:
	var points := PackedVector3Array()
	var end := Vector2(destination.x, destination.z)
	var path := navigation.get_point_path(nearest(Vector2(from.x, from.z)), nearest(end))
	for p in path:
		points.append(point(p.x, p.y))
	if not blocked(end):
		points.append(point(end.x, end.y))
	var smooth_path := PackedVector3Array()
	var current := from
	while not points.is_empty():
		var farthest := 0
		for i in range(points.size()):
			if clear_segment(current, points[i]):
				farthest = i
		current = points[farthest]
		smooth_path.append(current)
		for i in range(farthest + 1):
			points.remove_at(0)
	return smooth_path

func clear_segment(from: Vector3, to: Vector3) -> bool:
	var count := maxi(1, ceili(from.distance_to(to) / 0.04))
	for i in range(count + 1):
		var p := from.lerp(to, float(i) / count)
		if blocked(Vector2(p.x, p.z)):
			return false
	return true

func ground_hit(origin: Vector3, direction: Vector3) -> Vector3:
	var low := 0.0
	var high := 100.0
	for i in range(32):
		var middle := (low + high) * 0.5
		var p := origin + direction * middle
		if p.y > height_at(p.x, p.z):
			low = middle
		else:
			high = middle
	return origin + direction * high


func _expanded_landscape() -> void:
	for peak in [Vector4(-55, -44, 14, 16), Vector4(-7, -68, 18, 20), Vector4(15, -62, 15, 17), Vector4(55, -44, 14, 16)]:
		var mountain := CylinderMesh.new()
		mountain.top_radius = peak.z * 0.32
		mountain.bottom_radius = peak.z
		mountain.height = peak.w * 0.68
		mountain.radial_segments = 7
		var base := Vector3(peak.x, 0, peak.y)
		place(mountain, base + Vector3.UP * peak.w * 0.34, "96a58e")
		var cap := CylinderMesh.new()
		cap.top_radius = 0
		cap.bottom_radius = peak.z * 0.32
		cap.height = peak.w * 0.32
		cap.radial_segments = 7
		place(cap, base + Vector3.UP * peak.w * 0.84, "d9dbca")
	for i in range(10):
		var angle := i * TAU / 10
		var p := Vector2(0, -20) + Vector2(cos(angle), sin(angle)) * 5.5
		if distance_to_trail(p) > (3.7 if race_track else 1.8):
			blob(point(p.x, p.y) + Vector3.UP * 0.15, Vector3(0.65, 0.4, 0.55), "929b83", true)
	for i in range(14):
		var angle := i * TAU / 14
		var p := Vector2(6, -12) + Vector2(cos(angle), sin(angle)) * (2.4 + float(i % 3) * 0.6)
		if distance_to_trail(p) > (3.7 if race_track else 1.2):
			var base := point(p.x, p.y)
			blob(base + Vector3.UP * 0.15, Vector3(0.24, 0.20, 0.24), "86a04b")
			for j in range(3):
				blob(base + Vector3(cos(j * TAU / 3) * 0.18, 0.35, sin(j * TAU / 3) * 0.18), Vector3.ONE * 0.10, "f0d587" if i % 2 else "e2b2c3")
	for i in range(9):
		var angle := i * TAU / 9
		var p := Vector2(-11, -8) + Vector2(cos(angle), sin(angle)) * 2.8
		if distance_to_trail(p) > (3.7 if race_track else 1.4):
			var stem := CylinderMesh.new()
			stem.top_radius = 0.06
			stem.bottom_radius = 0.09
			stem.height = 0.4
			var base := point(p.x, p.y)
			place(stem, base + Vector3.UP * 0.2, "e8d7b8")
			blob(base + Vector3.UP * 0.43, Vector3(0.34, 0.18, 0.34), "b78196" if i % 2 else "caa06d")

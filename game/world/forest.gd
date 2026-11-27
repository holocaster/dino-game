extends Node3D

const SCENERY_MESHES := preload("res://world/scenery_meshes.gd")
const TREE_SHADER := preload("res://world/tree.gdshader")
const GROUND_SHADER := preload("res://world/forest_ground.gdshader")
const VALLEY_CENTER: Vector2 = preload("res://race/race_state.gd").VALLEY_CENTER
const VALLEY_FIELD := Vector2(36, 56)
const POND := Vector2(-7.2, 0.1)
const AREAS := [Vector3(0, 1.0, 4.0), Vector3(-6.2, 0, 3.3), Vector3(0, -6.8, 3.2), Vector3(-11, -8, 4.2), Vector3(6, -12, 4.8), Vector3(0, -20, 3.7)]
const GRID := Rect2i(-80, -104, 145, 145)
const POND_SIZE := Vector2(1.55, 1.25)
static var track_tree_meshes: Dictionary[Vector3, ArrayMesh] = {}
var navigation := AStarGrid2D.new()
var trail := Curve2D.new()
var trails: Array[Curve2D] = []
var obstacles: Array[Vector3] = [Vector3(-3.3, -2.5, 0.8), Vector3(3.25, 0, 0.8), Vector3(0.5, -3.3, 0.75), Vector3(-2.1, -9.5, 1.0)]
var materials: Dictionary = {}
var trees: Array[Dictionary] = []
var race_track: Curve2D
var theme := "forest"
var race_terrain: ArrayMesh
var lava_material: ShaderMaterial
var water_material: ShaderMaterial
var cave_stones: Array[MeshInstance3D] = []

func height_at(x: float, z: float) -> float:
	if theme == "cave":
		return 0.16 + sin(x * 0.24) * cos(z * 0.22) * 0.05
	if theme == "volcano":
		var basin := ((Vector2(x, z) - Vector2(-1, -5)) / Vector2(10.5, 8.8)).length()
		return 0.18 + sin(x * 0.3) * cos(z * 0.25) * 0.06 - (1 - smoothstep(0.92, 1.08, basin)) * 0.65
	if theme == "valley":
		var field := ((Vector2(x, z) - VALLEY_CENTER) / VALLEY_FIELD).length()
		return 0.12 + sin(x * 0.23) * cos(z * 0.19) * 0.1 - smoothstep(0.9, 1.1, field) * 0.6
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
	if theme == "valley":
		_valley()
		return
	if theme == "cave":
		_cave()
		return
	if theme == "volcano":
		_volcano()
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
	var horizon := place(backdrop, Vector3(0, -0.45, 0), "719864")
	horizon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	horizon.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var terrain := MeshInstance3D.new()
	terrain.name = "Terrain"
	terrain.mesh = race_terrain if race_terrain else _forest_mesh()
	terrain.material_override = _ground_material("bba98c", 2.8 if race_track else 0.85)
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(terrain)
	_pond()
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
		rock(point(p.x, p.y), Vector3(0.20, 0.19, 0.16), "99a18b", true)
	var leaves := SurfaceTool.new()
	leaves.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(600):
		var p := Vector2(rng.randf_range(-20, 15), rng.randf_range(-26, 8))
		if not blocked(p) or distance_to_trail(p) < (3.4 if race_track else 1.25):
			continue
		if ((p - POND) / (POND_SIZE + Vector2.ONE * 0.1)).length() < 1:
			continue
		var base := point(p.x, p.y)
		for j in range(7):
			var angle := j * TAU / 7 + i
			var direction := Vector3(cos(angle), 0, sin(angle))
			var side := Vector3(-sin(angle), 0, cos(angle))
			var length := rng.randf_range(0.36, 0.58)
			for step in range(4):
				for corner in [Vector2(0, -1), Vector2(1, -1), Vector2(0, 1), Vector2(0, 1), Vector2(1, -1), Vector2(1, 1)]:
					var t: float = (step + corner.x) / 4.0
					var center := base + direction * length * t + Vector3.UP * (sin(t * PI) * 0.25 + t * 0.12)
					var tint := Color("4f8956").lerp(Color("a3bf68") if j % 2 else Color("79ad67"), t)
					leaves.set_color(tint.srgb_to_linear())
					leaves.add_vertex(center + side * sin(t * PI) * corner.y * 0.10)
	leaves.generate_normals()
	var plants := MeshInstance3D.new()
	plants.name = "ForestPlants"
	plants.mesh = leaves.commit()
	plants.material_override = StandardMaterial3D.new()
	plants.material_override.vertex_color_use_as_albedo = true
	plants.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	plants.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(plants)

	_expanded_landscape()
	_track_border()
	_hills(Vector2(-1, -5), 64)

func _forest_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var distances: Dictionary[Vector2, float] = {}
	for x in range(-48, 41):
		for z in range(-74, 29):
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var p := Vector2(x + offset.x, z + offset.y) * 0.5
				if not distances.has(p):
					distances[p] = distance_to_trail(p)
				var distance := distances[p]
				var color := Color("7ba45a").lerp(Color("638e50"), (sin(p.x * 0.55) * cos(p.y * 0.45) + 1) * 0.3)
				color = color.lerp(Color("61994c"), 1 - smoothstep(1.8, 4.2, p.distance_to(Vector2(0, -6.8))))
				color = color.lerp(Color("4e8961"), 1 - smoothstep(2.5, 5.5, p.distance_to(Vector2(-11, -8))))
				color = color.lerp(Color("a7bd5d"), 1 - smoothstep(3.0, 6.0, p.distance_to(Vector2(6, -12))))
				color = color.lerp(Color("aaa987"), 1 - smoothstep(2.5, 4.5, p.distance_to(Vector2(0, -20))))
				surface.set_color(color.srgb_to_linear())
				surface.set_uv(Vector2(distance, 0))
				surface.add_vertex(point(p.x, p.y))
	surface.generate_normals()
	return surface.commit()

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

func tree(p: Vector2, size: float, variant: int, reuse_mesh: bool = false) -> void:
	if race_track and distance_to_trail(p) < 3.6:
		return
	var base := point(p.x, p.y)
	var tree_mesh := MeshInstance3D.new()
	var palm := theme == "beach"
	var share_variant := race_track != null and theme in ["forest", "valley"]
	if share_variant:
		tree_mesh.scale = Vector3.ONE * size
	if share_variant or reuse_mesh:
		var mesh_size := 1.0 if share_variant else size
		var key := Vector3(mesh_size, variant, int(palm))
		if not track_tree_meshes.has(key):
			track_tree_meshes[key] = SCENERY_MESHES.tree(mesh_size, variant, palm)
		tree_mesh.mesh = track_tree_meshes[key]
	else:
		tree_mesh.mesh = SCENERY_MESHES.tree(size, variant, palm)
	tree_mesh.position = base
	tree_mesh.material_override = ShaderMaterial.new()
	tree_mesh.material_override.shader = TREE_SHADER
	add_child(tree_mesh)
	trees.append({"position": p, "radius": size * 1.5, "trunk_radius": size * 0.22, "node": tree_mesh, "canopy_alpha": 1.0, "trunk_alpha": 1.0})
	_solid(base + Vector3.UP * 0.9 * size, 0.22 * size, 1.8 * size)

func rock(position_3d: Vector3, size: Vector3, color: String, solid: bool = false) -> void:
	var seed_value := int(position_3d.x * 19 + position_3d.z * 31)
	var node := place(SCENERY_MESHES.rock(size, seed_value, theme in ["forest", "valley"]), position_3d, color)
	node.name = "Rock"
	node.material_override = node.material_override.duplicate()
	node.material_override.vertex_color_use_as_albedo = true
	if solid:
		_solid(position_3d, maxf(size.x, size.z), size.y * 2)

func _hills(center: Vector2, radius: float) -> void:
	for i in range(12):
		var angle := i * TAU / 12
		var hill := Vector3(center.x + cos(angle) * radius, -1.5, center.y + sin(angle) * radius)
		var first := get_child_count()
		blob(hill, Vector3(24, 7 + i % 3 * 2, 18), ["88ad98", "9bbba2", "a7c7ae"][i % 3])
		get_child(first).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		get_child(first).material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func animate(time: float) -> void:
	for material in [water_material, lava_material]:
		if material != null:
			material.set_shader_parameter("animation_time", time)

func _water(center: Vector2, radius: Vector2, ocean: bool = false) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://world/water.gdshader")
	material.set_shader_parameter("water_center", center)
	material.set_shader_parameter("water_radius", radius)
	material.set_shader_parameter("ocean", ocean)
	if ocean:
		material.set_shader_parameter("deep_color", Color("348ba5"))
		material.set_shader_parameter("shallow_color", Color("79c4b9"))
	return material

func _pond() -> void:
	var water := SurfaceTool.new()
	var bank := SurfaceTool.new()
	water.begin(Mesh.PRIMITIVE_TRIANGLES)
	bank.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(64):
		for corner in [Vector2.ZERO, Vector2(1, 0), Vector2(1, 1)]:
			var angle: float = (i + corner.y) * TAU / 64
			var radius: float = corner.x * (0.97 + sin(angle * 3) * 0.025)
			var p: Vector2 = POND + Vector2(cos(angle), sin(angle)) * POND_SIZE * radius
			water.add_vertex(Vector3(p.x, 0.07, p.y))
		for corner in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1)]:
			var angle: float = (i + corner.y) * TAU / 64
			var radius := lerpf(0.95, 1.4, corner.x) + sin(angle * 3) * 0.025
			var p: Vector2 = POND + Vector2(cos(angle), sin(angle)) * POND_SIZE * radius
			bank.set_color(Color("a6ae82").lerp(Color("7e9a58"), corner.x).srgb_to_linear())
			bank.add_vertex(point(p.x, p.y) + Vector3.UP * 0.012)
	water.generate_normals()
	bank.generate_normals()
	water_material = _water(POND, POND_SIZE)
	var pond := place(water.commit(), Vector3.ZERO, "ffffff")
	pond.name = "PondWater"
	pond.material_override = water_material
	pond.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shore := place(bank.commit(), Vector3.ZERO, "ffffff")
	shore.name = "PondBank"
	shore.material_override = StandardMaterial3D.new()
	shore.material_override.vertex_color_use_as_albedo = true
	shore.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var reeds := SurfaceTool.new()
	reeds.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(16):
		var angle := i * TAU / 16
		var p := POND + Vector2(cos(angle), sin(angle)) * (POND_SIZE + Vector2.ONE * 0.28)
		if angle < 1.0 or angle > 4.8:
			continue
		var base := point(p.x, p.y)
		for j in range(5):
			var direction := Vector3(cos(j * 2.4 + angle), 0, sin(j * 2.4 + angle))
			var side := Vector3(-direction.z, 0, direction.x) * 0.035
			var tip := base + Vector3.UP * (0.4 + j * 0.07) + direction * 0.18
			reeds.set_color(Color("668757").lerp(Color("a9b974"), j / 5.0).srgb_to_linear())
			for vertex in [base - side, base + side, tip]:
				reeds.add_vertex(vertex)
	reeds.generate_normals()
	var rushes := place(reeds.commit(), Vector3.ZERO, "ffffff")
	rushes.name = "PondReeds"
	rushes.material_override = StandardMaterial3D.new()
	rushes.material_override.vertex_color_use_as_albedo = true
	rushes.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	rushes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _ground_material(soil: String, width: float = 2.8) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = GROUND_SHADER
	material.set_shader_parameter("soil_color", Color(soil).srgb_to_linear())
	material.set_shader_parameter("path_width", width)
	return material

func _track_border() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 81173
	var placements: Array[Transform3D] = []
	var colors: Array[Color] = []
	var width := 2.8 if race_track else 0.85
	for path in trails:
		var count := 120 if theme == "valley" else 72
		for i in range(count):
			var distance := path.get_baked_length() * i / count
			var p := path.sample_baked(distance)
			var direction := (path.sample_baked(fmod(distance + 0.15, path.get_baked_length())) - p).normalized()
			p += Vector2(-direction.y, direction.x) * (width + rng.randf_range(0.9, 1.8)) * (-1 if i % 2 else 1)
			if distance_to_trail(p) < width + 0.7 or ((p - POND) / (POND_SIZE + Vector2.ONE)).length() < 1:
				continue
			var base := point(p.x, p.y)
			for j in range(3):
				var offset := Vector3(rng.randf_range(-0.3, 0.3), 0.15, rng.randf_range(-0.3, 0.3))
				var dimensions := Vector3(0.30, rng.randf_range(0.22, 0.38), 0.26)
				placements.append(Transform3D(Basis.from_scale(dimensions), base + offset))
				var palette := ["548257", "71974f", "8da75c"]
				if theme == "beach":
					palette = ["73956a", "93aa70", "afbd7f"]
				elif theme == "volcano":
					palette = ["71616b", "957669", "a58a76"]
				colors.append(Color(palette[j]))
			if theme in ["forest", "valley"] and i % 3 == 0:
				for j in range(5):
					var angle := j * TAU / 5
					var petal := base + Vector3(cos(angle) * 0.11, 0.48, sin(angle) * 0.11)
					placements.append(Transform3D(Basis.from_scale(Vector3(0.09, 0.035, 0.09)), petal))
					colors.append(Color("f1cd79") if i % 2 else Color("e3a38d"))
				placements.append(Transform3D(Basis.from_scale(Vector3(0.065, 0.045, 0.065)), base + Vector3.UP * 0.49))
				colors.append(Color("f8e5a8"))
			else:
				placements.append(Transform3D(Basis.from_scale(Vector3(0.22, 0.16, 0.19)), base + Vector3(0.35, 0.08, 0.2)))
				colors.append(Color("a3a58c"))
	var mesh := SphereMesh.new()
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.radius = 1
	mesh.height = 2
	var border := MultiMeshInstance3D.new()
	border.name = "ForestBorder" if theme == "forest" else "TrackBorder"
	border.multimesh = MultiMesh.new()
	border.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	border.multimesh.use_colors = true
	border.multimesh.mesh = SCENERY_MESHES.rock(Vector3.ONE, 4, false) if theme == "volcano" else mesh
	border.multimesh.instance_count = placements.size()
	border.material_override = StandardMaterial3D.new()
	border.material_override.vertex_color_use_as_albedo = true
	border.material_override.roughness = 1
	border.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in range(placements.size()):
		border.multimesh.set_instance_transform(i, placements[i])
		border.multimesh.set_instance_color(i, colors[i].srgb_to_linear())
	add_child(border)

func _beach() -> void:
	var water := PlaneMesh.new()
	water.size = Vector2.ONE * 200
	water_material = _water(Vector2(-1, -5), Vector2(21, 17.5), true)
	var ocean := place(water, Vector3(0, -0.35, 0), "55c4cd")
	ocean.name = "OceanWater"
	ocean.material_override = water_material
	ocean.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var distances: Dictionary[Vector2, float] = {}
	for x in range(-47, 44):
		for z in range(-49, 30):
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var p := Vector2(x + offset.x, z + offset.y) * 0.5
				var coast := ((p - Vector2(-1, -5)) / Vector2(21, 17.5)).length()
				var color := Color("c2bda6").lerp(Color("8aa272"), 1 - smoothstep(0.3, 0.65, coast))

				surface.set_color(color.srgb_to_linear())
				if not distances.has(p):
					distances[p] = distance_to_trail(p)
				surface.set_uv(Vector2(distances[p], 0))
				surface.add_vertex(point(p.x, p.y))
	surface.generate_normals()
	var terrain := MeshInstance3D.new()
	terrain.name = "Terrain"
	terrain.mesh = surface.commit()
	terrain.material_override = _ground_material("c8bfa8")
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(terrain)
	for i in range(16):
		var angle := i * TAU / 16
		var p := Vector2(-1, -5) + Vector2(cos(angle) * 8, sin(angle) * 5)
		tree(p, 1.3 + (i % 3) * 0.15, i)
		rock(point(p.x + 0.8, p.y + 0.6), Vector3(0.35, 0.22, 0.3), "b3b5a1", true)
	_track_border()
	for island in [Vector3(-45, -1.0, -34), Vector3(35, -1.0, -46), Vector3(-42, -1.0, 36)]:
		rock(island, Vector3(8, 3.5, 6), "9faaa1")

func _valley() -> void:
	var backdrop := PlaneMesh.new()
	backdrop.size = Vector2.ONE * 240
	var horizon := place(backdrop, Vector3(VALLEY_CENTER.x, -0.45, VALLEY_CENTER.y), "6b8f66")
	horizon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	horizon.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var terrain := MeshInstance3D.new()
	terrain.name = "Terrain"
	terrain.mesh = race_terrain if race_terrain else _valley_mesh()
	terrain.material_override = _ground_material("bba98c")
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(terrain)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7301
	for i in range(70):
		var p := VALLEY_CENTER + Vector2(rng.randf_range(-32, 32), rng.randf_range(-50, 50))
		if distance_to_trail(p) > 7 and not trees.any(func(item): return item.position.distance_to(p) < 4.0):
			tree(p, rng.randf_range(1.4, 2.0), i)

	_track_border()
	_hills(VALLEY_CENTER, 100)

func _valley_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var distances: Dictionary[Vector2, float] = {}
	for x in range(-40, 40):
		for z in range(-60, 60):
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var p := VALLEY_CENTER + Vector2(x + offset.x, z + offset.y)
				var color := Color("7ca66b").lerp(Color("66865d"), (sin(p.x * 0.7) * cos(p.y * 0.5) + 1) * 0.5)

				surface.set_color(color.srgb_to_linear())
				if not distances.has(p):
					distances[p] = distance_to_trail(p)
				surface.set_uv(Vector2(distances[p], 0))
				surface.add_vertex(point(p.x, p.y))
	surface.generate_normals()
	return surface.commit()

func _cave() -> void:
	var backdrop := PlaneMesh.new()
	backdrop.size = Vector2.ONE * 200
	place(backdrop, Vector3(0, -0.3, 0), "c6bec7").cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var distances: Dictionary[Vector2, float] = {}
	for x in range(-38, 38):
		for z in range(-42, 33):
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var p: Vector2 = Vector2(x, z) + offset
				surface.set_color(Color("a59aac").lerp(Color("c8bfc8"), (sin(p.x * 0.4) * cos(p.y * 0.5) + 1) * 0.5).srgb_to_linear())
				if not distances.has(p):
					distances[p] = distance_to_trail(p)
				surface.set_uv(Vector2(distances[p], 0))
				surface.add_vertex(point(p.x, p.y))
	surface.generate_normals()
	var terrain := place(surface.commit(), Vector3.ZERO, "ffffff")
	terrain.name = "Terrain"
	terrain.material_override = _ground_material("c4b9a9")
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var walls := Node3D.new()
	walls.name = "CaveWalls"
	add_child(walls)
	for index in range(28):
		var angle := index * TAU / 28
		var p := Vector2(-1, -5) + Vector2(cos(angle) * 26, sin(angle) * 25)
		_cave_stone(point(p.x, p.y) + Vector3.UP * 3.2, Vector3(3.4, 4.5 + index % 3, 3.2), index, walls)
	for index in range(8):
		var angle := index * TAU / 8
		var p := Vector2(-1, -5) + Vector2(cos(angle) * 4.4, sin(angle) * 3.5)
		_cave_stone(point(p.x, p.y) + Vector3.UP * 2.1, Vector3(1.8, 3.6, 1.8), index + 30, walls)
	for index in range(3):
		var pose := trail.sample_baked_with_rotation(trail.get_baked_length() * (0.19 + index * 0.31))
		for side in [-1, 1]:
			var p: Vector2 = pose.origin + pose.y * side * 7.2
			_cave_stone(point(p.x, p.y) + Vector3.UP * 3.7, Vector3(1.3, 5.5, 1.4), index + 40, walls)
		for step in range(7):
			var p := pose.origin + pose.y * (step - 3) * 1.9
			_cave_stone(point(p.x, p.y) + Vector3.UP * (10.3 - absf(step - 3) * 0.45), Vector3(1.5, 1.0, 1.6), step + index * 7, walls)

func _cave_stone(base: Vector3, dimensions: Vector3, variant: int, holder: Node3D) -> void:
	var stone := place(SCENERY_MESHES.rock(dimensions, variant, false), base, "b8a9ba" if variant % 2 else "a79aaf")
	stone.name = "CaveStone"
	stone.material_override = stone.material_override.duplicate()
	stone.material_override.vertex_color_use_as_albedo = true
	stone.reparent(holder)
	cave_stones.append(stone)

func reveal_cave(camera_position: Vector3, subjects: Array) -> void:
	for stone in cave_stones:
		var bounds: AABB = stone.get_aabb().grow(0.8)
		stone.visible = not subjects.any(func(subject): return bounds.intersects_segment(camera_position - stone.position, subject + Vector3.UP * 0.8 - stone.position) != null)

func _volcano() -> void:
	var backdrop := PlaneMesh.new()
	backdrop.size = Vector2.ONE * 200
	var horizon := place(backdrop, Vector3(0, -0.55, 0), "78665f")
	horizon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	horizon.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var distances: Dictionary[Vector2, float] = {}
	for x in range(-32, 31):
		for z in range(-36, 27):
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var p: Vector2 = Vector2(x, z) + offset
				var grain := (sin(p.x * 0.9) * cos(p.y * 1.3) + 1) * 0.5
				var color := Color("65555b").lerp(Color("92786b"), grain)

				surface.set_color(color.srgb_to_linear())
				if not distances.has(p):
					distances[p] = distance_to_trail(p)
				surface.set_uv(Vector2(distances[p], 0))
				surface.add_vertex(point(p.x, p.y))
	surface.generate_normals()
	var terrain := place(surface.commit(), Vector3.ZERO, "ffffff")
	terrain.name = "Terrain"
	terrain.material_override = _ground_material("b3a28d")
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var lava := Node3D.new()
	lava.name = "Lava"
	add_child(lava)
	lava_material = ShaderMaterial.new()
	lava_material.shader = preload("res://world/lava.gdshader")
	var lake := CylinderMesh.new()
	lake.top_radius = 1
	lake.bottom_radius = 1
	lake.height = 0.06
	lake.radial_segments = 64
	var lake_node := place(lake, Vector3(-1, -0.14, -5), "ff8730")
	lake_node.scale = Vector3(10.2, 1, 8.5)
	lake_node.material_override = lava_material
	lake_node.reparent(lava)
	lake_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_volcanic_peak(Vector3(-1, -0.45, -5), 5.1, 4.0, lava)
	for i in range(48):
		var angle := i * TAU / 48
		var radius := Vector2(12, 10.6) if i % 2 else Vector2(22, 20)
		var p := Vector2(-1, -5) + Vector2(cos(angle), sin(angle)) * radius
		if distance_to_trail(p) > 4.3:
			var size := 0.35 + float(i % 4) * 0.14
			rock(point(p.x, p.y) + Vector3.UP * size * 0.2, Vector3(size, size * 0.65, size * 0.8), "4e4650" if i % 3 else "a86e58", true)
	for peak in [Vector3(-30, 6, -31), Vector3(22, 8, -38), Vector3(-26, 5, 23)]:
		_volcanic_peak(Vector3(peak.x, -0.5, peak.z), peak.y * 1.3, peak.y, lava)

	_track_border()

func _volcanic_peak(base: Vector3, radius: float, height: float, lava: Node3D) -> void:
	var top := radius * 0.31
	var cone := CylinderMesh.new()
	cone.top_radius = top
	cone.bottom_radius = radius
	cone.height = height
	cone.radial_segments = 16
	var mountain := place(cone, base + Vector3.UP * height * 0.5, "775453")
	mountain.name = "Volcano"
	var rim := TorusMesh.new()
	rim.inner_radius = top * 0.8
	rim.outer_radius = top * 1.16
	rim.rings = 24
	place(rim, base + Vector3.UP * height, "493d49").scale.y = 0.45
	var hot_rim := TorusMesh.new()
	hot_rim.inner_radius = top * 0.72
	hot_rim.outer_radius = top * 1.02
	hot_rim.rings = 24
	var hot_node := place(hot_rim, base + Vector3.UP * (height + 0.08), "ff8730")
	hot_node.scale.y = 0.35
	hot_node.material_override = lava_material
	hot_node.reparent(lava)
	hot_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var crater := CylinderMesh.new()
	crater.top_radius = top * 0.88
	crater.bottom_radius = top * 0.88
	crater.height = 0.04
	crater.radial_segments = 32
	var crater_node := place(crater, base + Vector3.UP * (height + 0.04), "ff8730")
	crater_node.material_override = lava_material
	crater_node.reparent(lava)
	crater_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var toward := (Vector2(-1, -5) - Vector2(base.x, base.z)).normalized()
	if toward == Vector2.ZERO:
		toward = Vector2(0, 1)
	var across := Vector2(-toward.y, toward.x)
	var stream := SurfaceTool.new()
	stream.begin(Mesh.PRIMITIVE_TRIANGLES)
	for step in range(12):
		for corner in [Vector2(0, -1), Vector2(1, -1), Vector2(0, 1), Vector2(0, 1), Vector2(1, -1), Vector2(1, 1)]:
			var t: float = (step + corner.x) / 12.0
			var p: Vector2 = toward * lerpf(top, radius, t) + across * (sin(t * 4) * 0.12 + corner.y * lerpf(top * 0.23, top * 0.42, t))
			stream.add_vertex(base + Vector3(p.x, lerpf(height + 0.1, 0.12, t), p.y))
	stream.generate_normals()
	var stream_node := place(stream.commit(), Vector3.ZERO, "ff8730")
	stream_node.material_override = lava_material
	stream_node.reparent(lava)
	stream_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

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
			rock(point(p.x, p.y) + Vector3.UP * 0.15, Vector3(0.65, 0.4, 0.55), "929b83", true)
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

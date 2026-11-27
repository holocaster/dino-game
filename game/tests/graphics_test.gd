extends SceneTree

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for palm in [false, true]:
		for variant in range(12):
			var mesh := preload("res://world/scenery_meshes.gd").tree(1.0, variant, palm)
			var arrays := mesh.surface_get_arrays(0)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for i in range(0, indices.size(), 3):
				var a := indices[i]
				var b := indices[i + 1]
				var c := indices[i + 2]
				if colors[a].a != 1.0 or colors[b].a != 1.0 or colors[c].a != 1.0:
					continue
				var face := (vertices[c] - vertices[a]).cross(vertices[b] - vertices[a])
				if face.length_squared() < 0.000001:
					continue
				var normal := (normals[a] + normals[b] + normals[c]).normalized()
				assert(normal.is_finite() and face.normalized().dot(normal) > 0.4, "Tree shading must follow the deformed surface")
	var baked: Dictionary = load("res://world/race_trees.res").get_meta("meshes")
	for key: Vector3 in baked:
		var generated := preload("res://world/scenery_meshes.gd").tree(key.x, int(key.y), bool(key.z))
		assert(baked[key].get_aabb() == generated.get_aabb())
		assert(baked[key].surface_get_arrays(0) == generated.surface_get_arrays(0))
	set_meta("race_selection", ["triceratops", "forest"])
	var game: Node3D = load("res://race/race.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	var plants: MeshInstance3D = game.forest.get_node("ForestPlants")
	assert(plants.mesh.get_surface_count() == 1)
	assert(plants.find_children("*", "CollisionObject3D", true, false).is_empty())
	var vertices: PackedVector3Array = plants.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	assert(vertices.size() > 1000 and vertices.size() < 120000, "Foliage must stay batched and bounded")
	for vertex in vertices:
		assert(vertex.is_finite())
		assert(game.forest.distance_to_trail(Vector2(vertex.x, vertex.z)) > game.race.TRACK_WIDTH, "Curved leaves must leave the full road clear")
	game.queue_free()
	await process_frame
	remove_meta("race_selection")
	print("Graphics checks passed: surface-aligned tree normals and bounded foliage outside the road.")
	quit()

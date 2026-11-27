extends SceneTree

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for circuit in ["forest", "beach", "valley", "volcano"]:
		set_meta("race_selection", ["triceratops", circuit])
		var game: Node3D = load("res://race/race.tscn").instantiate()
		root.add_child(game)
		game.set_physics_process(false)
		await process_frame
		var border := game.forest.get_node_or_null("ForestBorder") as MultiMeshInstance3D
		if circuit == "forest":
			assert(border != null and border.multimesh.instance_count > 100)
			assert(border.multimesh.instance_count < 600)
			assert(border.find_children("*", "CollisionObject3D", true, false).is_empty())
			for i in range(border.multimesh.instance_count):
				var placement := border.multimesh.get_instance_transform(i)
				var p := Vector2(placement.origin.x, placement.origin.z)
				var radius := maxf(placement.basis.x.length(), placement.basis.z.length())
				assert(game.forest.distance_to_trail(p) - radius > game.race.TRACK_WIDTH, "Scenery must leave the full track clear")
				assert(((p - game.forest.POND) / (game.forest.POND_SIZE + Vector2.ONE * radius)).length() > 1)
			var terrain: MeshInstance3D = game.forest.get_node("Terrain")
			assert(terrain.mesh.resource_path == "res://world/forest_terrain.res")
			assert(game.forest.trees.size() == 49)
			var meshes := {}
			for tree in game.forest.trees:
				meshes[tree.node.mesh] = true
			assert(meshes.size() == 30)
			var arrays := terrain.mesh.surface_get_arrays(0)
			var source: ArrayMesh = game.forest._forest_mesh()
			var original := source.surface_get_arrays(0)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			assert(source.get_aabb() == terrain.mesh.get_aabb())
			assert(indices.size() == original[Mesh.ARRAY_VERTEX].size())
			for i in indices.size():
				var j := indices[i]
				assert(original[Mesh.ARRAY_VERTEX][i] == arrays[Mesh.ARRAY_VERTEX][j])
				assert(original[Mesh.ARRAY_COLOR][i] == arrays[Mesh.ARRAY_COLOR][j])
				assert(original[Mesh.ARRAY_TEX_UV][i] == arrays[Mesh.ARRAY_TEX_UV][j])
				assert(original[Mesh.ARRAY_NORMAL][i].distance_to(arrays[Mesh.ARRAY_NORMAL][j]) < 0.0001)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var distances: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			for i in range(0, vertices.size(), 37):
				var p := Vector2(vertices[i].x, vertices[i].z)
				assert(is_equal_approx(vertices[i].y, game.forest.height_at(p.x, p.y)))
				assert(is_equal_approx(distances[i].x, game.forest.distance_to_trail(p)))
			assert(is_equal_approx(terrain.material_override.get_shader_parameter("path_width"), game.race.TRACK_WIDTH))
		else:
			assert(border == null, "Forest dressing must stay out of other tracks")
		game.queue_free()
		await process_frame
	remove_meta("race_selection")
	print("Forest scenery checks passed: clear track and pond, bounded batched decoration, terrain alignment and isolation from other themes.")
	quit()

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
		var border: MultiMeshInstance3D = game.forest.get_node("ForestBorder" if circuit == "forest" else "TrackBorder")
		for i in range(border.multimesh.instance_count):
			var placement := border.multimesh.get_instance_transform(i)
			var p := Vector2(placement.origin.x, placement.origin.z)
			var radius := maxf(placement.basis.x.length(), placement.basis.z.length())
			assert(game.forest.distance_to_trail(p) - radius > game.race.TRACK_WIDTH, "New dressing overlaps the road on " + circuit)
		var terrain: MeshInstance3D = game.forest.get_node("Terrain")
		assert(is_equal_approx(terrain.material_override.get_shader_parameter("path_width"), game.race.TRACK_WIDTH))
		for tree in game.forest.trees:
			var arrays: Array = tree.node.mesh.surface_get_arrays(0)
			var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			assert(Array(colors).any(func(color): return color.a == 0))
			assert(Array(colors).any(func(color): return color.a == 1))
			for vertex in vertices:
				assert(vertex.is_finite())
				assert(Vector2(vertex.x, vertex.z).length() <= tree.radius + 0.01, "Crown exceeds its visibility radius")
		if circuit in ["forest", "beach"]:
			assert(game.forest.water_material != null)
			game.restart()
			game._process(0.1)
			var time: float = game.forest.water_material.get_shader_parameter("animation_time")
			assert(time > 0)
			game._web_command(["pause"])
			game._process(0.1)
			assert(game.forest.water_material.get_shader_parameter("animation_time") == time)
			game._web_command(["resume"])
			game._process(0.1)
			assert(game.forest.water_material.get_shader_parameter("animation_time") > time)
			game.reset_race()
			assert(game.forest.water_material.get_shader_parameter("animation_time") == 0)
		if circuit == "forest":
			assert(game.forest.get_node("PondBank").find_children("*", "CollisionObject3D", true, false).is_empty())
			var pond: MeshInstance3D = game.forest.get_node("PondWater")
			for vertex in pond.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
				assert(((Vector2(vertex.x, vertex.z) - game.forest.POND) / game.forest.POND_SIZE).length() <= 1.0)
		game.queue_free()
		await process_frame
	remove_meta("race_selection")
	print("World detail checks passed: four clear roads, canopy/trunk masks and bounds, pond containment, animated water pause/resume/reset.")
	quit()

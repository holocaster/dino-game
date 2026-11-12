extends SceneTree

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var game: Node3D = load("res://park/park.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var forest: Node3D = game.forest
	assert(forest.AREAS.size() == 6)
	assert(forest.trail.sample_baked(0).distance_to(forest.trail.sample_baked(forest.trail.get_baked_length())) < 0.01)
	assert(forest.trail.get_baked_length() > 25)
	var total_length := 0.0
	for path in forest.trails:
		total_length += path.get_baked_length()
		assert(path.sample_baked(0).distance_to(path.sample_baked(path.get_baked_length())) < 0.01)
		for i in range(201):
			var point: Vector2 = path.sample_baked(path.get_baked_length() * i / 200.0)
			assert(not forest.blocked(point), "Trail blocked at " + str(point))
	assert(total_length > 80)
	var walkable := 0
	var maximum_slope := 0.0
	for x in range(forest.GRID.position.x, forest.GRID.end.x):
		for z in range(forest.GRID.position.y, forest.GRID.end.y):
			var cell := Vector2i(x, z)
			if not forest.navigation.is_point_solid(cell):
				walkable += 1
				var p := Vector2(cell) * 0.25
				for offset in [Vector2.RIGHT, Vector2.DOWN]:
					var neighbor: Vector2 = p + offset * 0.25
					if not forest.blocked(neighbor):
						maximum_slope = maxf(maximum_slope, absf(forest.height_at(p.x, p.y) - forest.height_at(neighbor.x, neighbor.y)) / 0.25)
	assert(walkable > 1772 * 2.5)
	assert(maximum_slope < 0.4)
	assert(forest.height_at(0, -20) - forest.height_at(0, 2.8) > 1.8)
	for item in game.discoveries:
		assert(not forest.blocked(Vector2(item.node.position.x, item.node.position.z)))
	var destinations := [Vector2(-5.05, 0.7), Vector2(-11, -8), Vector2(0, -20), Vector2(6, -12), Vector2(1, -6.3), Vector2(0, 2.8), Vector2(6, -12), Vector2(0, -20), Vector2(-11, -8), Vector2(-5.05, 0.7), Vector2(0, 2.8)]
	for destination in destinations:
		game._set_target(forest.point(destination.x, destination.y))
		assert(not game.route.is_empty())
		var previous: Vector3 = game.dinosaur.position
		for waypoint in game.route:
			assert(forest.clear_segment(previous, waypoint))
			previous = waypoint
		for step in range(350):
			game._process(0.2)
			assert(not forest.blocked(Vector2(game.dinosaur.position.x, game.dinosaur.position.z)))
			assert(absf(game.dinosaur.position.y - forest.height_at(game.dinosaur.position.x, game.dinosaur.position.z)) < 0.001)
		assert(game.dinosaur.position.distance_to(game.target) < 0.03)
		assert(game.camera_focus.distance_to(game.dinosaur.position) < 0.03)
	game.dinosaur.position = forest.point(0, -20)
	game._update_camera(1.0)
	root.size = Vector2i(390, 844)
	game._fit_camera()
	var destination: Vector3 = forest.point(1.8, -19)
	var screen: Vector2 = game.camera.unproject_position(destination)
	var hit: Vector3 = forest.ground_hit(game.camera.project_ray_origin(screen), game.camera.project_ray_normal(screen))
	assert(hit.distance_to(destination) < 0.02)
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = screen
	game._unhandled_input(touch)
	assert(game.target.distance_to(destination) < 0.02)
	game._set_target(forest.point(-20, -20))
	assert(not game.route.is_empty())
	assert(not forest.blocked(Vector2(game.target.x, game.target.z)))
	game.restart()
	assert(game.route.is_empty())
	assert(game.dinosaur.position.is_equal_approx(forest.point(0, 2.8)))
	game._web_command(["fruit"])
	for step in range(200):
		game._process(0.05)
	assert(game.discoveries[2].found)
	game.queue_free()
	print("Areas checks passed: two loops, six areas, ", walkable * 0.0625, " square units, ", total_length, " trail units, round trips, terrain, camera, restart and feeding.")
	quit()

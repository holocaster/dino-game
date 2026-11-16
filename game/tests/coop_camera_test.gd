extends SceneTree

var projections := 0

func _initialize() -> void:
	create_timer(90).timeout.connect(func(): quit(1))
	_run.call_deferred()

func check_runner(game: Node3D, runner: Node3D, envelope: bool = true) -> void:
	for x in ([-1.15, 1.15] if envelope else []):
		for y in [-0.2, 2.0]:
			for z in [-1.7, 1.7]:
				var point: Vector3 = runner.global_transform * Vector3(x, y, z)
				assert(not game.camera.is_position_behind(point))
				assert(root.get_visible_rect().has_point(game.camera.unproject_position(point)), "Whole dinosaur outside viewport: %s" % game.camera.unproject_position(point))
				projections += 1
	for mesh in runner.get_node("Model").find_children("*", "MeshInstance3D", true, false) + [runner.get_node("PlayerLabel")]:
		var box: AABB = mesh.get_aabb()
		for corner in range(8):
			var point: Vector3 = mesh.global_transform * box.get_endpoint(corner)
			assert(not game.camera.is_position_behind(point))
			assert(root.get_visible_rect().has_point(game.camera.unproject_position(point)), "Mesh/accessory outside viewport")
			projections += 1

func _run() -> void:
	for pair in [["triceratops", "forest"], ["trex", "beach"], ["raptor", "valley"]]:
		var species: String = pair[0]
		set_meta("race_selection", [species, pair[1], "coop", species])
		set_meta("race_appearances", [{"species": species, "color": "natural", "accessory": "cap"}, {"species": species, "color": "natural", "accessory": "glasses"}])
		var game: Node3D = load("res://race/race.tscn").instantiate()
		root.add_child(game)
		game.set_physics_process(false)
		await physics_frame
		for size in [Vector2i(1280, 220), Vector2i(390, 200)]:
			root.size = size
			game._fit_camera()
			game._update_camera(1, 0.05)
			check_runner(game, game.dinosaur, false)
			check_runner(game, game.friend, false)
		for size in [Vector2i(1280, 900), Vector2i(390, 844), Vector2i(390, 340)]:
			root.size = size
			game._fit_camera()
			for leader in [0, 1]:
				for sample_index in range(65):
					game.race.stage = "racing"
					var progress: float = game.race.lap_length * sample_index / 64
					game.race.distance = progress + (18 if leader == 0 else 0)
					game.race.rival_distance = progress + (18 if leader == 1 else 0)
					game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -1.65 if sample_index % 2 else 1.65, 3)
					game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 1.65 if sample_index % 2 else -1.65, 3)
					game.dinosaur_animation.advance(0.1)
					game.friend_animation.advance(0.1)
					var direction: Vector2 = game.race.sample(game.race.distance).x
					game.travel_yaw = atan2(-direction.x, -direction.y)
					var yaw: float = game.camera_yaw
					game._update_camera(0.2, 0.05)
					assert(absf(angle_difference(yaw, game.camera_yaw)) <= deg_to_rad(50) * 0.05 + 0.00001)
					check_runner(game, game.dinosaur)
					check_runner(game, game.friend)
				game.race.stage = "racing"
				game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.length + (1.5 if leader == 0 else -18), -1.6, 0)
				game._position_runner(game.friend, game.friend_animation, game.race.length + (1.5 if leader == 1 else -18), 1.6, 0)
				game._update_camera(1, 0.05)
				check_runner(game, game.dinosaur)
				check_runner(game, game.friend)
			game.race.stage = "finished"
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.length + 1.5, -1.6, 0)
			game._position_runner(game.friend, game.friend_animation, game.race.length + 1.5, 1.6, 0)
			game._update_camera(1, 0.05)
			check_runner(game, game.dinosaur)
			check_runner(game, game.friend)
		game.queue_free()
		await process_frame
	print("Coop camera passed: ", projections, " projected body/mesh/accessory bounds; three species, 18m/opposite lanes, all three tracks, either waiting finisher, arrival, 1280x900/390x844/390x340, <=50 degrees/s.")
	quit()

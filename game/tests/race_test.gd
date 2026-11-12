extends SceneTree

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

func _initialize() -> void:
	create_timer(45).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var game := RecordedRace.new()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await physics_frame
	await physics_frame
	assert(game.events.any(func(event): return event.type == "park-ready"))
	assert(game.fruit_nodes.size() == 20)
	for i in range(240):
		for edge in [-1, 1]:
			var border: Transform2D = game.race.sample(game.race.length * i / 240, edge * game.race.TRACK_WIDTH)
			assert(((border.origin - game.forest.POND) / (game.forest.POND_SIZE + Vector2.ONE * 0.4)).length() > 1)
		for side in [-1, 0, 1]:
			var pose: Transform2D = game.race.sample(game.race.length * i / 240, side * game.race.LATERAL_LIMIT)
			assert(not game.forest.blocked(pose.origin))
			assert(((pose.origin - game.forest.POND) / (game.forest.POND_SIZE + Vector2.ONE * 0.75)).length() > 1)
			for tree in game.forest.trees:
				assert(tree.position.distance_to(pose.origin) > tree.trunk_radius + 0.7)
	for size in [Vector2i(960, 640), Vector2i(390, 720)]:
		root.size = size
		game._fit_camera()
		game.restart()
		await physics_frame
		game._position_runner(game.dinosaur, game.dinosaur_animation, 0, game.race.LATERAL_LIMIT, 0)
		game._position_runner(game.friend, game.friend_animation, 0, -1.3, 0)
		game._update_camera(1.0)
		for runner in [game.dinosaur, game.friend]:
			for side in [-1, 1]:
				var edge: Vector3 = runner.position + Vector3.UP * 0.6 + game.camera.basis.x * side * 0.65
				assert(game.get_viewport().get_visible_rect().has_point(game.camera.unproject_position(edge)), "Runners clipped at opposite track edges in %s" % size)
		game.restart()
		await physics_frame
		var key := InputEventKey.new()
		key.keycode = KEY_RIGHT
		key.pressed = true
		game._unhandled_input(key)
		assert(game.right_pressed)
		game._web_command(["release"])
		assert(not game.right_pressed)
		for step in range(650):
			var yaw: float = game.camera_yaw
			var velocity: float = game.camera_turn_velocity
			game._process(0.1)
			await physics_frame
			assert(absf(angle_difference(yaw, game.camera_yaw)) <= deg_to_rad(50.0) * 0.1 + 0.0001)
			assert(absf(game.camera_turn_velocity - velocity) <= deg_to_rad(80.0) * 0.1 + 0.0001)
			var screen: Vector2 = game.camera.unproject_position(game.dinosaur.position + Vector3.UP * 0.6)
			assert(game.get_viewport().get_visible_rect().has_point(screen), "Character outside camera: %s in %s" % [screen, game.get_viewport().get_visible_rect()])
			assert(is_equal_approx(game.dinosaur.position.y, game.forest.height_at(game.dinosaur.position.x, game.dinosaur.position.z)))
			if game.race.stage == "finished":
				break
		assert(game.race.stage == "finished")
		assert(game.race.collected > 0)
		assert(game.events.any(func(event): return event.type == "park-sound" and event.name == "pickup"))
		assert(game.events.any(func(event): return event.type == "park-sound" and event.name == "happy"))
	game.restart()
	await physics_frame
	game._process(0.1)
	game._web_command(["right-down"])
	game._web_command(["pause"])
	var remaining: float = game.race.countdown
	game._process(0.1)
	assert(game.race.countdown == remaining and not game.right_pressed)
	game._web_command(["resume"])
	for step in range(40):
		game._process(0.1)
		await physics_frame
	game._web_command(["left-down"])
	game._process(0.1)
	await physics_frame
	var lateral: float = game.race.lateral
	game._web_command(["release"])
	game._process(0.1)
	await physics_frame
	assert(absf(game.race.lateral - lateral) < 0.002)
	game._web_command(["restart"])
	assert(game.race.stage == "countdown" and game.race.collected == 0)
	assert(game.fruit_nodes.all(func(fruit): return fruit.visible))
	assert(not game.left_pressed and not game.right_pressed)
	game.queue_free()
	print("Race scene checks passed: clear track, lake and trunks, both viewports, full lap, camera speed/acceleration, terrain, audio, native keys, bridge, pause, release and restart.")
	quit()

extends SceneTree

func _initialize() -> void:
	create_timer(20).timeout.connect(func(): quit(1))
	_run.call_deferred()

func travel(game: Node3D, destination: Vector2) -> void:
	game._set_target(game.forest.point(destination.x, destination.y))
	for step in range(400):
		var yaw: float = game.camera_yaw
		game._process(0.05)
		assert(absf(angle_difference(yaw, game.camera_yaw)) <= deg_to_rad(50.0) * 0.05 + 0.0001)
	assert(game.dinosaur.position.distance_to(game.target) < 0.02)
	var direction: Vector3 = -game.dinosaur.basis.z
	assert(orbit(game).dot(Vector2(direction.x, direction.z).normalized()) < -0.98)
	var ahead: Vector3 = game.forest.point(game.dinosaur.position.x + direction.x * 2.5, game.dinosaur.position.z + direction.z * 2.5)
	assert(game.camera.unproject_position(ahead).y < game.camera.unproject_position(game.dinosaur.position).y)

func orbit(game: Node3D) -> Vector2:
	var offset: Vector3 = game.camera.position - game.camera_focus
	return Vector2(offset.x, offset.z).normalized()

func _run() -> void:
	var game: Node3D = load("res://park/park.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game._web_command(["flowers"])
	var launch_yaw: float = game.camera_yaw
	for step in range(5):
		game._process(0.05)
	var launch_turn := rad_to_deg(absf(angle_difference(launch_yaw, game.camera_yaw)))
	if launch_turn > 4.0:
		push_error("Camera turns too quickly at walking start: " + str(launch_turn) + " degrees in 0.25 seconds")
		quit(1)
		return
	game.restart()
	travel(game, Vector2(-5.05, 0.7))
	var outgoing := orbit(game)
	travel(game, Vector2(0, 2.8))
	var returning := orbit(game)
	if outgoing.dot(returning) > 0:
		push_error("Camera kept the same side of the dinosaur after reversing the route: orbit dot=" + str(outgoing.dot(returning)))
		quit(1)
		return
	var settled := orbit(game)
	game.feeding.face(game.dinosaur, game.dinosaur.position + Vector3.LEFT)
	for step in range(40):
		game._process(0.05)
	assert(orbit(game).dot(settled) > 0.9999)
	for size in [Vector2i(960, 640), Vector2i(390, 844)]:
		root.size = size
		game._fit_camera()
		for heading in [0.0, PI / 2, PI, -PI / 2]:
			game.restart()
			game.dinosaur.position = game.forest.point(6, -12)
			game.target = game.dinosaur.position
			game.camera_yaw = heading
			game.travel_yaw = wrapf(heading + PI, -PI, PI)
			game._update_camera(1.0, 0.2)
			var forward := Vector3.FORWARD.rotated(Vector3.UP, game.camera_yaw)
			var destination: Vector3 = game.forest.point(6 + forward.x * 3.0, -12 + forward.z * 3.0)
			var screen: Vector2 = game.camera.unproject_position(destination)
			var hit: Vector3 = game.forest.ground_hit(game.camera.project_ray_origin(screen), game.camera.project_ray_normal(screen))
			assert(hit.distance_to(destination) < 0.02)
			if size.x > size.y:
				var click := InputEventMouseButton.new()
				click.pressed = true
				click.button_index = MOUSE_BUTTON_LEFT
				click.position = screen
				game._unhandled_input(click)
			else:
				var touch := InputEventScreenTouch.new()
				touch.pressed = true
				touch.position = screen
				game._unhandled_input(touch)
			assert(game.target.distance_to(destination) < 0.02)
			for step in range(20):
				game._process(0.05)
				assert(game.target.distance_to(destination) < 0.02)
	game.restart()
	assert(is_zero_approx(game.camera_yaw) and is_zero_approx(game.travel_yaw) and is_zero_approx(game.camera_turn_velocity))
	assert(game.dinosaur.rotation == Vector3.ZERO)
	game.queue_free()
	print("Camera checks passed: launch ", launch_turn, " degrees/0.25s, outbound/return chase, slower turn speed, ground ahead, stationary reactions, mouse/touch during rotation, fixed world targets and reset.")
	quit()

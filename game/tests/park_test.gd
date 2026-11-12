extends SceneTree

func _initialize() -> void:
	create_timer(25).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var game: Node3D = load("res://park/park.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.discoveries.size() == 6)
	assert(game.dinosaur.position.is_equal_approx(game.target))
	var initial_target: Vector3 = game.target
	game._web_command(["unknown"])
	game._web_command([42])
	assert(game.target == initial_target)
	for item in game.discoveries:
		game._web_command([item.data.id])
		assert(not item.found)
		for step in range(1600):
			game._process(0.05)
		assert(item.found)
		if item.data.id == "fruit":
			assert(game.dinosaur.position.distance_to(game.feeding.delivery) < 0.03)
			for step in range(40):
				game._process(0.05)
			continue
		assert(game.dinosaur.position.distance_to(item.node.position) < 0.02)
		var tween: Tween = item.tween
		game._process(0.05)
		assert(item.tween == tween)
		game._web_command([item.data.id])
		game._process(0.05)
		assert(item.tween != tween)
	game._web_command(["restart"])
	assert(game.dinosaur.position == initial_target)
	assert(game.target == initial_target)
	assert(not game.marker.visible)
	assert(game.active_discovery.is_empty())
	assert(game.body.scale == Vector3.ONE)
	for item in game.discoveries:
		assert(not item.found)
		if item.tween:
			assert(not item.tween.is_running())
		assert(is_equal_approx(item.node.position.y, game.forest.height_at(item.node.position.x, item.node.position.z)))
	var tracks: Dictionary = game.discoveries[1]
	game._interact(tracks)
	await create_timer(0.09).timeout
	game.restart()
	await create_timer(0.15).timeout
	for foot in tracks.node.get_children():
		assert(is_equal_approx(foot.position.y, 0.01))
	assert(is_equal_approx(game.friend.position.y, game.forest.height_at(game.friend.position.x, game.friend.position.z)))
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = game.camera.unproject_position(Vector3(100, 0.08, 100))
	game._unhandled_input(touch)
	assert(absf(game.target.x) <= game.park.bounds)
	assert(absf(game.target.z) <= game.park.bounds)
	game.queue_free()
	print("Park checks passed: visits, replay, reset during animation, input bounds.")
	quit()

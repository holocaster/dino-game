extends SceneTree

func _initialize() -> void:
	create_timer(15).timeout.connect(func(): quit(1))
	_run.call_deferred()

func until_stage(game: Node3D, stage: String) -> void:
	for step in range(600):
		if game.feeding.stage == stage:
			return
		game._process(0.05)
	assert(false, "Feeding did not reach " + stage)

func _run() -> void:
	var game: Node3D = load("res://park.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var feeding: Node3D = game.feeding
	var basket: Dictionary = game.discoveries[2]
	assert(not game.forest.blocked(Vector2(game.friend.position.x, game.friend.position.z)))
	for cycle in range(2):
		game._web_command(["fruit"])
		until_stage(game, "pickup")
		assert(not feeding.source.visible and feeding.fruit.visible)
		assert(basket.found == (cycle > 0))
		var elapsed: float = feeding.elapsed
		game._web_command(["fruit"])
		assert(feeding.elapsed == elapsed)
		until_stage(game, "carrying")
		game._process(0.05)
		assert(feeding.fruit.global_position.distance_to(game.dinosaur.to_global(Vector3(0.3, 0.85, -1.12))) < 0.01)
		until_stage(game, "eating")
		assert(basket.found == (cycle > 0))
		assert(game.friend_animation.current_animation == "feeding/eat")
		for step in range(10):
			game._process(0.05)
		var focus := Vector2(game.camera_focus.x, game.camera_focus.z)
		for tree in game.forest.trees:
			if (tree.position.distance_to(focus) < tree.radius + 1.0 or tree.position.distance_to(Vector2(game.camera.position.x, game.camera.position.z)) < tree.radius + 0.7):
				assert(tree.canopy_alpha == 0)
			var subject_radius: float = 0.65 + game.dinosaur.position.distance_to(game.friend.position) * 0.5
			if tree.position.distance_to(focus) < tree.trunk_radius + subject_radius:
				assert(tree.trunk_alpha == 0, "Trunk obscures feeding pair")
		var initial_scale: Vector3 = feeding.fruit.scale
		for step in range(24):
			game._process(0.05)
		assert(feeding.fruit.scale.length() < initial_scale.length())
		until_stage(game, "happy")
		assert(basket.found and not feeding.fruit.visible)
		game._process(0.1)
		assert(feeding.hearts[0].visible)
		until_stage(game, "idle")
		assert(feeding.source.visible)
	for stage in ["pickup", "carrying", "offering", "eating", "happy"]:
		game.restart()
		game._web_command(["fruit"])
		until_stage(game, stage)
		game.restart()
		for step in range(8):
			game._process(0.05)
		assert(not feeding.active() and not feeding.fruit.visible)
		assert(feeding.source.visible and not basket.found)
		assert(game.friend_animation.current_animation == "idle")
		for heart in feeding.hearts:
			assert(not heart.visible)
	for stage in ["pickup", "carrying", "offering", "eating"]:
		game.restart()
		game._web_command(["fruit"])
		until_stage(game, stage)
		game._web_command(["flowers"])
		for step in range(10):
			game._process(0.05)
		assert(not feeding.active() and feeding.source.visible)
		assert(not basket.found)
	game.queue_free()
	print("Feeding checks passed: pickup, carrying, eating, delayed reward, replay, interruption, reset in every stage.")
	quit()

extends SceneTree

func _initialize() -> void:
	create_timer(60).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for scenario in range(6):
		var index := scenario % 3
		set_meta("race_selection", [["triceratops", "trex", "raptor"][index], ["forest", "beach", "valley"][index], "none" if scenario < 3 else "playful"])
		var game := preload("res://race/race.gd").new()
		root.add_child(game)
		game.set_process(false)
		game.set_physics_process(false)
		game.race.rng.seed = 2002 + index
		game.reset_race()
		await physics_frame
		await physics_frame
		var nodes: int = game.scenery.find_children("*", "Node", true, false).size()
		assert(game.scenery.find_children("*", "CollisionObject3D", true, false).is_empty())
		var unchanged := _facts(game)
		game.scenery.reset()
		assert(_facts(game) == unchanged, "Resetting presentation never draws RNG or changes layout/physics")
		assert(game.scenery.baby.scale == Vector3.ONE and game.scenery.baby.get_child(0).scale.x < 0.5)
		for slot in game.race.fruits + game.race.arrows:
			if slot.lateral != 0:
				assert(game.scenery.paths.filter(func(path): return path.distance == slot.distance and is_equal_approx(absf(path.offset), absf(slot.lateral))).size() == 2)
		game.restart()
		game.race.advance(3)
		var puddle: Dictionary = game.scenery.puddles[0]
		game.race.distance = puddle.distance - 1.4
		game.race.lateral = -0.9
		game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -0.9, 0)
		for fruit in game.race.fruits:
			fruit.owner = "player"
		var shape: Transform3D = game.dinosaur.get_node("BodyShape").transform
		var speed: float = game.race.speed
		for step in range(10):
			game._process(0.05)
			await physics_frame
		assert(puddle.player_splashed)
		assert(absf(game.dinosaur.get_node("Model").rotation.z) > 0.01, "Puddle passage makes the visual model wobble")
		assert(game.dinosaur.get_node("BodyShape").transform == shape and game.race.speed == speed)
		for side in [-1, 1]:
			game.restart()
			game.race.advance(3)
			var path: Dictionary = game.scenery.paths.filter(func(item): return item.side == side and game.scenery.puddles.all(func(p): return absf(p.distance - item.distance) > 2))[0]
			game.race.distance = path.distance - 1.4
			game.race.lateral = path.offset
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, path.offset, 0)
			await physics_frame
			await physics_frame
			for step in range(10):
				var previous: Vector3 = game.dinosaur.position
				var other_previous: Vector3 = game.friend.position
				game.race.advance(0.05)
				unchanged = _facts(game)
				game.scenery.advance(0.05, previous, other_previous)
				assert(_facts(game) == unchanged, "Path effects cannot change physical motion, fruit, arrows, boosts or RNG")
				var model: Node3D = game.dinosaur.get_node("Model")
				assert(is_zero_approx(model.position.y) and is_zero_approx(model.rotation.x), "Fruit paths do not lift or pitch the runner")
				await physics_frame
			assert(path.player_played and path.node.visible, "Both existing fruit paths react to physical passage")
			assert(game.dinosaur.get_node("BodyShape").transform == shape)
			var piece: MeshInstance3D = path.node.get_child(0)
			assert((piece.mesh is BoxMesh) == (side < 0), "The two sides have distinct shapes")
			assert((piece.mesh.get_aabb().size * piece.scale).length() < 0.4, "Path pieces stay small enough to leave the runner visible")
			game._web_command(["pause"])
			var frozen := [game.scenery.elapsed, path.age, game.dinosaur.get_node("Model").transform]
			unchanged = _facts(game)
			game._process(0.1)
			assert(frozen == [game.scenery.elapsed, path.age, game.dinosaur.get_node("Model").transform] and unchanged == _facts(game))
			game._web_command(["resume"])
			game.scenery.advance(1, game.dinosaur.position, game.friend.position)
			assert(not path.node.visible and is_zero_approx(game.dinosaur.get_node("Model").position.y))
			if not game.race.solo:
				game.race.distance = path.distance + 4
				game.race.rival_distance = path.distance - 1.4
				game.race.rival_lateral = path.offset
				game.race.rival_think_time = INF
				game.race.rival_target_fruit = -1
				game.race.rival_lateral_velocity = 0
				game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -path.offset, 0)
				game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, path.offset, 0)
				await physics_frame
				await physics_frame
				for step in range(10):
					game._process(0.05)
					var model: Node3D = game.friend.get_node("Model")
					assert(is_zero_approx(model.position.y) and is_zero_approx(model.rotation.x), "Fruit paths do not lift or pitch the second runner")
					await physics_frame
				assert(path.rival_played, "Second body shares the same path effects")
		for fruit_count in [0, 4]:
			game.restart()
			game.race.advance(3)
			game.race.collected = fruit_count
			game.race.distance = game.race.length - 0.05
			game.race.rival_distance = game.race.length if fruit_count == 0 and not game.race.solo else game.race.length - 5
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -0.9, 0)
			game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 0.9, 0)
			await physics_frame
			await physics_frame
			for step in range(10):
				game._process(0.05)
				await physics_frame
			assert(game.race.stage == "finished")
			assert(game.scenery.baby_received == fruit_count and game.race.collected == fruit_count)
			assert(game.scenery.baby.position.y > game.scenery.baby_base.y, "Baby celebrates with and without fruit")
			assert(game.scenery.delivery.get_children().any(func(fruit): return fruit.visible) == (fruit_count > 0))
			var delivery_frozen := [game.scenery.delivery_age, game.scenery.baby.transform, game.scenery.delivery.get_child(0).position]
			game.race.paused = true
			game._process(0.1)
			assert(delivery_frozen == [game.scenery.delivery_age, game.scenery.baby.transform, game.scenery.delivery.get_child(0).position])
			game.race.paused = false
			if not game.race.solo:
				assert(game.race.winner == ("rival" if fruit_count == 0 else "player"))
			for size in [Vector2i(1280, 520), Vector2i(390, 340)]:
				root.size = size
				game._fit_camera()
				for step in range(20):
					game._update_camera(1, 0.1)
				for subject in [game.dinosaur, game.scenery.baby]:
					for height in [0.1, 1.3 if subject == game.dinosaur else 0.8]:
						var point: Vector3 = subject.position + Vector3.UP * height
						assert(root.get_visible_rect().has_point(game.camera.unproject_position(point)), "Runner and baby stay in the result viewport")
			game.reset_race()
			assert(game.scenery.baby_received == -1 and game.scenery.delivery_age == 0)
			assert(game.scenery.delivery.get_children().all(func(fruit): return not fruit.visible))
			assert(game.scenery.paths.all(func(path): return not path.node.visible and not path.player_played and not path.rival_played))
			assert(game.scenery.find_children("*", "Node", true, false).size() == nodes, "Restart reuses every effect and baby node")
		game.queue_free()
		await process_frame
	print("Playful scene checks passed: three species/tracks in Solo and Rival, both path effects without runner hops, puddle wobble, physical/collection/RNG invariance, pause/reset, baby with zero/fruit and win/loss, finish framing.")
	quit()

func _facts(game: Node3D) -> Array:
	var race = game.race
	return [race.distance, race.rival_distance, race.lateral, race.rival_lateral, race.speed, race.rival_speed, race.boost_left, race.rival_boost_left, race.collected, race.golden_collected, race.arrows_taken, race.fruits.duplicate(true), race.arrows.duplicate(true), race.rng.state, game.dinosaur.transform, game.friend.transform, game.dinosaur.get_node("BodyShape").transform, game.friend.get_node("BodyShape").transform]

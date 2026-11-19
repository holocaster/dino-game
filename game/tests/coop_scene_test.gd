extends SceneTree

func _initialize() -> void:
	create_timer(90).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	set_meta("race_appearances", [{"species": "trex", "color": "natural", "accessory": "cap"}, {"species": "raptor", "color": "natural", "accessory": "glasses"}])
	for track in ["forest", "beach", "valley", "volcano", "cave"]:
		set_meta("race_selection", ["trex", track, "coop", "raptor"])
		var game: Node3D = load("res://race/race.tscn").instantiate()
		root.add_child(game)
		game.set_physics_process(false)
		await physics_frame
		assert(game.race.mode == "coop" and game.race.partner_id == "raptor")
		assert(game.friend.visible and game.friend.get_node("Model").scale == Vector3.ONE)
		game.restart()
		game.race.advance(3)
		game._web_command(["input:1:right:down:page"])
		game._web_command(["input:2:left:down:frame"])
		game._process(0.1)
		assert(game.race.lateral > -0.9 and game.race.rival_lateral < 0.9)
		game._web_command(["input:1:left:down:page"])
		assert(game._steering(1) == 0 and game._steering(2) == -1)
		game._web_command(["input:1:right:down:frame"])
		game._web_command(["input:1:right:up:page"])
		assert(game._steering(1) == 0)
		game._web_command(["input:1:left:up:page"])
		assert(game._steering(1) == 1 and game._steering(2) == -1)
		game._web_command(["input:3:left:down:page"])
		game._web_command(["input:2:left:down:bad"])
		assert(game.input_sources.size() == 2)
		game._web_command(["pause"])
		assert(game.input_sources.is_empty() and game._steering(1) == 0 and game._steering(2) == 0)
		game._web_command(["input:1:right:down:page"])
		game._web_command(["resume"])
		assert(game._steering(1) == 0)
		var a := InputEventKey.new()
		a.keycode = KEY_A
		a.pressed = true
		game._unhandled_input(a)
		a = InputEventKey.new()
		a.keycode = KEY_RIGHT
		a.pressed = true
		game._unhandled_input(a)
		assert(game._steering(1) == -1 and game._steering(2) == 1)
		game._web_command(["release"])
		for leader in [0, 1]:
			game.reset_race()
			game.race.start()
			game.race.advance(3)
			game.race.collected = 4 if leader == 1 else 0
			game.race.partner_collected = 6 if leader == 1 else 0
			game.race.distance = game.race.length - (0.02 if leader == 0 else 3)
			game.race.rival_distance = game.race.length - (0.02 if leader == 1 else 3)
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -0.9, 0)
			game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 0.9, 0)
			await physics_frame
			for step in range(4):
				game._process(0.05)
				await physics_frame
			assert(game.race.stage == "racing")
			var waiting: Node3D = game.dinosaur if leader == 0 else game.friend
			assert(waiting.collision_layer == 0 and waiting.collision_mask == 0)
			assert(not game.speed_effects.runners[leader].trail.emitting)
			var waiting_position: Vector3 = waiting.position
			for step in range(80):
				game._process(0.05)
				await physics_frame
			assert(game.race.stage == "finished" and game.race.winner.is_empty())
			assert(waiting.position.is_equal_approx(waiting_position))
			assert(game.scenery.baby_received == (10 if leader == 1 else 0))
			var players: Array = game._players_report()
			assert(players.size() == 2 and players[0].finished and players[1].finished)
			assert(players[0].fruit == (4 if leader == 1 else 0) and players[1].fruit == (6 if leader == 1 else 0))
			game.reset_race()
			assert(game.friend.collision_layer == 1 and game.dinosaur.collision_layer == 1)
			assert(game.scenery.baby_received == -1 and game.input_sources.is_empty())
		for slot in [1, 2]:
			game.reset_race()
			game.race.start()
			game.race.advance(3)
			game.race.recovery_cooldown = 100
			var fruit: Dictionary = game.race.fruits[0]
			game.race.distance = fruit.distance - (0.3 if slot == 1 else 4)
			game.race.rival_distance = fruit.distance - (0.3 if slot == 2 else 4)
			game.race.lateral = fruit.lateral if slot == 1 else -fruit.lateral
			game.race.rival_lateral = fruit.lateral if slot == 2 else -fruit.lateral
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, game.race.lateral, 0)
			game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, game.race.rival_lateral, 0)
			await physics_frame
			await physics_frame
			game._process(0.05)
			assert(game.race.total_collected == 1)
			assert((game.race.collected if slot == 1 else game.race.partner_collected) == 1)
			game._process(0.05)
			assert(game.race.total_collected == 1, "Repeated physical contact counts once")
			game.reset_race()
			game.race.start()
			game.race.advance(3)
			for item in game.race.fruits:
				item.owner = "player"
			game.race.distance = 10 if slot == 1 else 27
			game.race.rival_distance = 10 if slot == 2 else 27
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -0.9, 0)
			game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 0.9, 0)
			await physics_frame
			await physics_frame
			for step in range(45):
				game._process(0.05)
				await physics_frame
				if game.race.total_golden == 1:
					break
			assert(game.race.total_golden == 1 and game.race.total_collected == 1)
			assert((game.race.golden_collected if slot == 1 else game.race.partner_golden) == 1)
			assert((game.dinosaur if slot == 1 else game.friend).get_node("RecoveryGlow").visible)
		game.queue_free()
		await process_frame
	print("Coop scene passed: human/native inputs, opposite and overlapping sources, pause/release, both first finishers on three tracks, nonblocking wait, team delivery/report/reset.")
	quit()

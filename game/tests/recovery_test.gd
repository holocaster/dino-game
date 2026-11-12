extends SceneTree

const Race := preload("res://race/race_state.gd")

func racing(dino: String = "triceratops", circuit: String = "forest", target: String = "player") -> Race:
	var race := Race.new()
	race.configure(dino, circuit)
	race.start()
	race.advance(3)
	race.fruits.clear()
	race.distance = 10 if target == "player" else 16.1
	race.rival_distance = 16.1 if target == "player" else 10
	return race

func _initialize() -> void:
	create_timer(40).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	if not _gain_checks():
		quit(1)
		return
	for dino in Race.DINOS:
		for circuit in ["forest", "beach"]:
			for target in ["player", "rival"]:
				var race := racing(dino, circuit, target)
				race.advance(0.01)
				assert(race.recovery_fruit.target == target)
				var progress: float = race.distance if target == "player" else race.rival_distance
				var offset: float = race.lateral if target == "player" else race.rival_lateral
				assert(is_equal_approx(race.recovery_fruit.distance, progress + 3))
				assert(race.recovery_fruit.lateral == offset)
				assert(race.recovery_fruit.left == 5 and race.recovery_cooldown == 10)
				for step in range(50):
					race.advance(0.05)
					if race.recovery_fruit.is_empty():
						break
				assert((race.recovery_boost_left if target == "player" else race.rival_recovery_boost_left) == 4)
				assert(is_equal_approx(race.speed if target == "player" else race.rival_speed, (race.base_speed if target == "player" else race.rival_base_speed) + 2))
				assert(race.collected == (1 if target == "player" else 0))
				var snapshot := [race.distance, race.recovery_cooldown, race.recovery_boost_left, race.rival_recovery_boost_left]
				race.paused = true
				race.advance(20)
				assert(snapshot == [race.distance, race.recovery_cooldown, race.recovery_boost_left, race.rival_recovery_boost_left])
				race.paused = false
				for step in range(81):
					race.advance(0.05)
				assert(race.recovery_boost_left == 0 and race.rival_recovery_boost_left == 0)
				assert(race.speed == race.base_speed and race.rival_speed == race.rival_base_speed)
				assert(race.recovery_fruit.is_empty())
				race.reset()
				assert(race.recovery_fruit.is_empty() and race.recovery_cooldown == 0)
	var race := racing()
	race.rival_distance = race.distance + Race.RECOVERY_GAP - 0.01
	race.advance(0.01)
	assert(race.recovery_fruit.is_empty())
	race.rival_distance = race.distance + Race.RECOVERY_GAP + 0.01
	race.advance(0.01)
	assert(not race.recovery_fruit.is_empty())
	var spawned := race.recovery_fruit.duplicate()
	race.paused = true
	race.advance(10)
	assert(race.recovery_fruit == spawned)
	race.paused = false
	race.resolve_motion = func(_previous, _rival_previous, _delta):
		race.distance = 10
		race.rival_distance = 17
	race.pickup_contact = func(_index, _rival): return false
	for step in range(101):
		race.advance(0.05)
	assert(race.recovery_fruit.is_empty() and race.collected == 0)
	assert(race.recovery_cooldown > 4.9)
	for step in range(100):
		race.advance(0.05)
	assert(not race.recovery_fruit.is_empty(), "Another fruit must wait ten seconds after the previous appearance")
	race.winner = "rival"
	race.advance(0.01)
	assert(race.recovery_fruit.is_empty() and race.recovery_boost_left == 0)
	race.resolve_motion = Callable()
	race.pickup_contact = Callable()
	race = racing()
	race.rival_distance = race.length - 12
	race.advance(0.01)
	assert(race.recovery_fruit.is_empty())
	race = racing()
	race.advance(0.01)
	race.pickup_contact = func(_index, rival): return rival
	for step in range(40):
		race.advance(0.05)
	assert(race.recovery_boost_left == 0 and race.rival_recovery_boost_left == 0, "The leader cannot take the trailing runner's fruit")
	race = racing()
	race.advance(0.01)
	while not race.recovery_fruit.is_empty():
		race.advance(0.05)
	for step in range(60):
		race.advance(0.05)
	race.fruits.append({"distance": race.distance + 0.2, "lateral": race.lateral, "owner": ""})
	race.advance(0.05)
	assert(race.collected == 2 and race.recovery_boost_left < 1.01)
	assert(is_equal_approx(race.speed, race.base_speed + 2))
	for step in range(21):
		race.advance(0.05)
	assert(race.recovery_boost_left == 0)
	assert(is_equal_approx(race.speed, race.base_speed + Race.FRUIT_BOOST), "Common fruit must keep its own timer and bonus after recovery ends")
	var physical_passed: bool = await _physical_checks()
	if not physical_passed:
		quit(1)
		return
	print("Recovery checks passed: both runners in all six configurations, threshold, placement, unique contact, four-second cap, independent common bonus, expiry, cooldown, finish, pause/reset and physical barrier.")
	quit()

func _gain_checks() -> bool:
	for dino in Race.DINOS:
		for circuit in ["forest", "beach"]:
			for target in ["player", "rival"]:
				var race := racing(dino, circuit, target)
				if target == "player":
					race.rival_speed = race.rival_base_speed + Race.MAX_BOOST
					race.rival_boost_left = 100
				else:
					race.speed = race.base_speed + Race.MAX_BOOST
					race.boost_left = 100
				for step in range(100):
					race.advance(0.05)
					if maxf(race.recovery_boost_left, race.rival_recovery_boost_left) > 0:
						break
				assert(maxf(race.recovery_boost_left, race.rival_recovery_boost_left) == 4)
				var gap := absf(race.distance - race.rival_distance)
				for step in range(79):
					race.advance(0.05)
				var remaining := race.rival_distance - race.distance if target == "player" else race.distance - race.rival_distance
				assert(gap - remaining >= 4.4, "Recovery too weak against maximum common boost: %s/%s target %s recovered %s" % [dino, circuit, target, gap - remaining])
				assert(remaining > 0 and race.winner.is_empty(), "Recovery must not guarantee passing the leader")
	return true

func _physical_checks() -> bool:
	var game: Node3D = load("res://race/race.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await physics_frame
	await physics_frame
	game.restart()
	game.race.advance(3)
	game.race.distance = 10
	game.race.rival_distance = 17
	game._position_runner(game.dinosaur, game.dinosaur_animation, 10, -0.9, 0)
	game._position_runner(game.friend, game.friend_animation, 17, 0.9, 0)
	for fruit in game.race.fruits:
		fruit.owner = "player"
	await physics_frame
	await physics_frame
	game._process(0.05)
	assert(game.recovery_node.visible and game.recovery_node.collision_layer == 4)
	for step in range(40):
		await physics_frame
		game._process(0.05)
		if game.race.recovery_boost_left > 0:
			break
	assert(game.race.recovery_boost_left == 4 and game.race.collected == 1)
	assert(not game.recovery_node.visible and game.recovery_node.collision_layer == 0)
	assert(game.dinosaur.get_node("RecoveryGlow").visible)
	assert(not game.friend.get_node("RecoveryGlow").visible)
	game._web_command(["pause"])
	var glow_yaw: float = game.dinosaur.get_node("RecoveryGlow").rotation.y
	game._process(0.1)
	assert(game.race.recovery_boost_left == 4 and game.dinosaur.get_node("RecoveryGlow").rotation.y == glow_yaw)
	game.reset_race()
	assert(not game.recovery_node.visible and not game.dinosaur.get_node("RecoveryGlow").visible)
	game.race.start()
	game.race.advance(3)
	game.race.distance = 17
	game.race.rival_distance = 10
	game._position_runner(game.dinosaur, game.dinosaur_animation, 17, -0.9, 0)
	game._position_runner(game.friend, game.friend_animation, 10, 0.9, 0)
	for fruit in game.race.fruits:
		fruit.owner = "player"
	await physics_frame
	await physics_frame
	game._process(0.05)
	for step in range(40):
		await physics_frame
		game._process(0.05)
		if game.race.rival_recovery_boost_left > 0:
			break
	assert(game.race.rival_recovery_boost_left == 4 and game.race.collected == 0)
	assert(game.friend.get_node("RecoveryGlow").visible)
	assert(not game.dinosaur.get_node("RecoveryGlow").visible)
	game._process(0.05)
	assert(game.race.rival_recovery_boost_left < 4 and game.race.collected == 0)
	game.reset_race()
	game.race.start()
	game.race.advance(3)
	game.race.distance = 10
	game.race.rival_distance = 17
	game._position_runner(game.dinosaur, game.dinosaur_animation, 10, -0.9, 0)
	game._position_runner(game.friend, game.friend_animation, 17, 0.9, 0)
	for fruit in game.race.fruits:
		fruit.owner = "player"
	var barrier := StaticBody3D.new()
	barrier.collision_layer = 2
	barrier.collision_mask = 0
	game.add_child(barrier)
	var pose: Transform2D = game.race.sample(11.5)
	barrier.position = game.forest.point(pose.origin.x, pose.origin.y) + Vector3.UP * 0.8
	barrier.rotation.y = atan2(-pose.x.x, -pose.x.y)
	var wall := CollisionShape3D.new()
	wall.shape = BoxShape3D.new()
	wall.shape.size = Vector3(7, 2.4, 0.2)
	barrier.add_child(wall)
	await physics_frame
	await physics_frame
	game._process(0.05)
	for step in range(105):
		await physics_frame
		game._process(0.05)
	assert(game.race.distance < 11.5 and game.race.collected == 0)
	assert(game.race.recovery_boost_left == 0 and not game.recovery_node.visible)
	game.queue_free()
	await process_frame
	return true

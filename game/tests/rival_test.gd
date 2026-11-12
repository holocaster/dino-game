extends SceneTree

const Race := preload("res://race/race_state.gd")

func isolated_race(items: Array) -> Race:
	var race := Race.new()
	race.start()
	race.advance(3)
	race.distance = 20
	race.recovery_cooldown = INF
	race.fruits.clear()
	for item in items:
		race.fruits.append({"distance": item[0], "lateral": item[1], "owner": item[2]})
	return race

func advance_smoothly(race: Race, count: int) -> void:
	for step in range(count):
		var lateral: float = race.rival_lateral
		var velocity: float = race.rival_lateral_velocity
		var finished: bool = race.rival_distance >= race.length
		race.advance(0.05)
		assert(absf(race.rival_lateral) <= Race.LATERAL_LIMIT)
		assert(absf(race.rival_lateral - lateral) <= Race.RIVAL_STEER_SPEED * 0.05 + 0.00001)
		if not finished:
			assert(absf(race.rival_lateral_velocity - velocity) <= Race.RIVAL_STEER_ACCELERATION * 0.05 + 0.00001)

func _initialize() -> void:
	create_timer(25).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var race := isolated_race([[4.0, -1.3, ""]])
	advance_smoothly(race, 45)
	assert(race.fruits[0].owner == "rival", "Rival ignores a reachable fruit on the other side of the track")
	assert(race.rival_lateral < 0)
	assert(is_equal_approx(race.rival_speed, Race.RIVAL_SPEED + Race.FRUIT_BOOST))
	race = isolated_race([[-1.0, 0.9, ""], [0.7, -1.3, ""], [3.0, 0.9, "player"], [5.5, 1.3, ""]])
	advance_smoothly(race, 50)
	assert(race.fruits[0].owner.is_empty() and race.fruits[1].owner.is_empty())
	assert(race.fruits[2].owner == "player" and race.fruits[3].owner == "rival")
	race = isolated_race([[5.0, -1.3, ""], [8.0, 1.3, ""]])
	advance_smoothly(race, 8)
	assert(race.rival_target_fruit == 0)
	race.fruits[0].owner = "player"
	advance_smoothly(race, 20)
	assert(race.rival_target_fruit == 1 and race.rival_lateral_velocity > 0)
	var snapshot := [race.rival_lateral, race.rival_lateral_velocity, race.rival_target_fruit, race.rival_think_time, race.rival_distance]
	race.paused = true
	race.advance(10)
	assert(snapshot == [race.rival_lateral, race.rival_lateral_velocity, race.rival_target_fruit, race.rival_think_time, race.rival_distance])
	race.paused = false
	advance_smoothly(race, 5)
	race.reset()
	assert(race.rival_target_fruit == -1 and race.rival_lateral_velocity == 0 and race.rival_think_time == Race.RIVAL_REACTION)
	race = isolated_race([[5.0, -1.3, ""], [5.1, 1.3, ""]])
	advance_smoothly(race, 8)
	var target: int = race.rival_target_fruit
	assert(target >= 0)
	for step in range(12):
		advance_smoothly(race, 1)
		assert(race.rival_target_fruit == target)
	race = isolated_race([[30.0, -1.3, ""]])
	advance_smoothly(race, 20)
	assert(race.rival_target_fruit == -1 and race.rival_lateral == 0.9)
	race = isolated_race([[4.0, -1.3, ""]])
	race.distance = 0
	for step in range(25):
		advance_smoothly(race, 1)
		assert(race.rival_lateral - race.lateral > 1.1)
	race = Race.new()
	race.start()
	var minimum_lateral := race.rival_lateral
	var maximum_lateral := race.rival_lateral
	for step in range(1200):
		advance_smoothly(race, 1)
		minimum_lateral = minf(minimum_lateral, race.rival_lateral)
		maximum_lateral = maxf(maximum_lateral, race.rival_lateral)
		if race.stage == "finished":
			break
	var pickups := race.fruits.filter(func(fruit): return fruit.get("rival_taken", false)).size()
	assert(pickups >= 4 and maximum_lateral - minimum_lateral > 1.0)
	assert(race.rival_speed >= race.rival_base_speed and race.rival_speed <= race.rival_base_speed + Race.MAX_BOOST)
	assert(race.stage == "finished")
	var game: Node3D = load("res://race/race.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await physics_frame
	await physics_frame
	game.restart()
	await physics_frame
	for frame in range(200):
		var before: Vector3 = game.friend.position
		var yaw: float = game.friend.rotation.y + game.friend.get_node("Model").rotation.y
		var delta := 0.4 if frame % 9 == 0 else 0.05
		game._process(delta)
		await physics_frame
		var movement: Vector3 = game.friend.position - before
		var visual_yaw: float = game.friend.rotation.y + game.friend.get_node("Model").rotation.y
		assert(absf(angle_difference(yaw, visual_yaw)) <= deg_to_rad(100) * minf(delta, 0.1) + 0.0001)
		if movement.length() > 0.001:
			assert((-game.friend.get_node("Model").global_basis.z).normalized().dot(movement.normalized()) > 0.9)
			var animated_distance: float = game.friend_animation.speed_scale * game.RUN_SPEED * game.friend.get_node("Model").scale.x * delta
			assert(absf(animated_distance - movement.length()) < 0.0001)
	var paused_yaw: float = game.friend.rotation.y
	game._web_command(["pause"])
	game._process(0.1)
	assert(game.friend.rotation.y == paused_yaw)
	game.restart()
	assert(game.race.rival_target_fruit == -1 and game.race.rival_lateral_velocity == 0)
	game.queue_free()
	print("Rival checks passed: reachable fruit, unique boost, unavailable/passed/unreachable fruit, replanning, target stability, reaction, smooth steering, space, pause/reset and full lap. Rival fruit: ", pickups)
	quit()

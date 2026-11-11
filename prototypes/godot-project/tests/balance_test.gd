extends SceneTree

const Race := preload("res://race_state.gd")

func _initialize() -> void:
	create_timer(15).timeout.connect(func(): quit(1))
	var race := Race.new()
	race.start()
	race.advance(3)
	race.pickup_contact = func(_index, rival): return not rival
	race.advance(0.05)
	assert(race.collected == 20)
	assert(is_equal_approx(race.speed, race.base_speed + Race.MAX_BOOST))
	assert(is_equal_approx(race.rival_speed, race.rival_base_speed))
	var boost := race.boost_left
	var cooldown: float = race.fruits[0].respawn
	race.paused = true
	race.advance(10)
	assert(race.boost_left == boost and race.fruits[0].respawn == cooldown)
	race.paused = false
	for step in range(31):
		race.advance(0.05)
	assert(race.fruits.all(func(fruit): return fruit.owner.is_empty()))
	assert(race.collected == 20, "Standing on respawning fruit must not grant repeated boosts")
	race.pickup_contact = func(_index, rival): return rival
	race.advance(0.05)
	assert(race.fruits.all(func(fruit): return fruit.owner == "friend" and fruit.player_taken and fruit.friend_taken))
	assert(is_equal_approx(race.rival_speed, race.rival_base_speed + Race.MAX_BOOST))
	race.pickup_contact = func(_index, _rival): return false
	for step in range(120):
		race.advance(0.05)
	assert(is_equal_approx(race.speed, race.base_speed))
	assert(is_equal_approx(race.rival_speed, race.rival_base_speed))
	assert(race.fruits.all(func(fruit): return fruit.owner == "friend"))
	race.reset()
	assert(race.boost_left == 0 and race.rival_boost_left == 0)
	assert(race.fruits.all(func(fruit): return not fruit.player_taken and not fruit.friend_taken and fruit.respawn == 0))
	for dino in Race.DINOS:
		for circuit in ["forest", "beach"]:
			assert(race.configure(dino, circuit))
			assert(race.base_speed == Race.DINOS[dino].speed and race.speed == race.base_speed)
			assert(race.steer_speed == Race.DINOS[dino].steer)
			assert(race.length > 75 and race.length < 95)
			assert(race.sample(0).origin.distance_to(race.sample(race.length).origin) < 0.001)
			assert(race.sample(0).x.dot(race.sample(race.length - 0.01).x) > 0.999)
			var configuration := [race.dino_id, race.track_id, race.length]
			assert(not race.configure("unknown", "beach"))
			assert(configuration == [race.dino_id, race.track_id, race.length])
			race.start()
			assert(not race.configure("triceratops", "forest"))
			race.reset()
	for species in Race.DINOS:
		race = Race.new()
		race.configure(species, "forest")
		race.start()
		race.advance(3)
		race.rival_distance = 8
		race.lateral = 0
		race.rival_lateral = 1.65
		race.rival_think_time = INF
		race.recovery_cooldown = INF
		for fruit in race.fruits:
			fruit.lateral = 0.0
			if fruit.distance < race.rival_distance:
				fruit.owner = "friend"
				fruit.friend_taken = true
				fruit.respawn = Race.FRUIT_RESPAWN
		var smallest_gap := 8.0
		for step in range(1100):
			var goal := race.lateral
			for fruit in race.fruits:
				if not fruit.player_taken and fruit.distance >= race.distance:
					goal = fruit.lateral
					break
			race.advance(0.05, clampf((goal - race.lateral) / (race.steer_speed * 0.05), -1, 1))
			smallest_gap = minf(smallest_gap, race.rival_distance - race.distance)
			if race.stage == "finished":
				break
		assert(race.collected >= 10 and race.winner == "player", "Collecting fruit must allow recovery when the leader misses fruit: %s; gap %s" % [species, smallest_gap])
		print("Recovery passed: ", species, ", fruit ", race.collected, ", smallest gap ", smallest_gap)
	print("Balance checks passed: shared respawn, per-runner pickup, capped temporary boost, expiry, pause/reset, all six configurations and invalid selection.")
	quit()

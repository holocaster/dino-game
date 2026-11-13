extends SceneTree

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		if data.type == "park-sound" and data.name == "splash":
			data.lap = race.lap
		events.append(data)

const Race := preload("res://race/race_state.gd")
const Bots := preload("res://tests/bots.gd")
const PRACTICAL_MAX_SPEED := 5.1

func _initialize() -> void:
	Engine.physics_ticks_per_second = 600
	create_timer(240).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	_catalog()
	_geometry()
	_laps()
	_lap_reset()
	_layout()
	_golden()
	_bots()
	_retorno()
	_decay()
	_lateral()
	_arrow_layout()
	_arrow_pickup()
	_level_three()
	_camera_bound()
	_playful_balance()
	print("Vale state checks passed: catalog, stadium geometry, three Voltas, per-Volta Frutinhas, layout, Fruta dourada margin, Sozinho assist, bots, Retorno decrescente, decay, lateral scaling, Setas, camera bound and Brincalhão balance.")
	for dino in Race.DINOS:
		await _scene(dino)
	remove_meta("race_selection")
	quit()

func _valley(rival: String = "playful", dino: String = "triceratops") -> Race:
	var race := Race.new()
	assert(race.configure(dino, "valley", rival))
	return race

func _racing(race: Race) -> void:
	race.start()
	race.advance(3)
	assert(race.stage == "racing")

func _catalog() -> void:
	assert(Race.TRACKS == ["forest", "beach", "valley"])
	for dino in Race.DINOS:
		for rival in Race.RIVALS.keys() + ["none"]:
			var race := Race.new()
			assert(race.can_configure(dino, "valley", rival) and race.configure(dino, "valley", rival))
			assert(race.track_id == "valley" and race.rival_id == rival)
	for circuit in ["forest", "beach"]:
		var race := Race.new()
		race.configure("triceratops", circuit)
		assert(race.laps == 1 and race.lap == 1 and race.lap_length == race.length)

func _geometry() -> void:
	var race := _valley()
	assert(race.lap_length >= 150 and race.lap_length <= 180, "Volta length %s" % race.lap_length)
	assert(race.laps == 3 and race.lap == 1 and is_equal_approx(race.length, race.lap_length * 3))
	var points := race.track.get_baked_points()
	assert(points[0].distance_to(points[-1]) < 0.01)
	assert(race.sample(race.lap_length + 5).origin.distance_to(race.sample(5).origin) < 0.001)
	assert(race.sample(race.lap_length * 2 + 5).origin.distance_to(race.sample(5).origin) < 0.001)
	var steps := int(race.lap_length)
	var step := race.lap_length / steps
	var turning := 0.0
	var straight_runs: Array[float] = []
	var run := 0.0
	var smallest_radius := INF
	for i in range(steps * 2):
		var a := race.sample(i * step).origin
		var b := race.sample((i + 1) * step).origin
		var c := race.sample((i + 2) * step).origin
		var bend := absf((b - a).angle_to(c - b))
		if i < steps:
			turning += (b - a).angle_to(c - b)
		if bend > 0.0001:
			smallest_radius = minf(smallest_radius, a.distance_to(c) / (2 * sin(bend)))
		if bend < 0.0001:
			run += step
		else:
			if run > 20 and i > steps and straight_runs.size() < 2:
				straight_runs.append(run)
			run = 0
	assert(absf(absf(turning) - TAU) < 0.01, "Stadium must close with one full turn: %s" % turning)
	assert(straight_runs.size() == 2 and straight_runs.all(func(length): return length > 30), "Expected two long straights: %s" % [straight_runs])
	assert(smallest_radius >= 10, "Curve radius %s" % smallest_radius)

func _laps() -> void:
	var race := _valley("none")
	_racing(race)
	var seen: Array[int] = [race.lap]
	var per_lap := {}
	while race.stage != "finished":
		var before := race.lap
		race.advance(0.05)
		assert(race.lap == before or race.lap == before + 1)
		if race.lap != seen[-1]:
			seen.append(race.lap)
		per_lap[race.lap] = race.collected
		assert(race.stage == "finished" or race.distance < race.length)
	assert(seen == [1, 2, 3], "Voltas seen: %s" % [seen])
	assert(race.distance == race.length and race.lap == 3 and race.winner == "player")
	assert(per_lap[1] > 0 and per_lap[2] > per_lap[1] and per_lap[3] > per_lap[2], "Sozinho assist collects every Volta: %s" % per_lap)
	race = _valley("speedy")
	_racing(race)
	race.distance = race.lap_length - 0.05
	race.rival_distance = race.lap_length * 2 - 0.05
	race.advance(0.1)
	assert(race.lap == 2 and race.stage == "racing" and race.winner.is_empty())
	race.distance = race.length - 0.05
	race.rival_distance = race.length - 3
	race.advance(0.1)
	assert(race.stage == "finished" and race.winner == "player" and race.lap == 3)

func _lap_reset() -> void:
	var race := _valley("playful")
	_racing(race)
	race.rival_think_time = INF
	var fruit: Dictionary = race.fruits[0]
	race.distance = fruit.distance - 0.6
	race.lateral = fruit.lateral
	race.rival_distance = 0
	race.advance(0.1)
	assert(race.collected == 1 and fruit.player_taken and fruit.owner == "player")
	var other: Dictionary = race.fruits[1]
	other.player_taken = true
	other.rival_taken = true
	other.owner = "rival"
	other.respawn = 0
	race.advance(0.1)
	assert(fruit.player_taken and other.owner == "rival")
	race.distance = race.lap_length - 0.05
	race.advance(0.1)
	assert(race.lap == 2)
	assert(not fruit.player_taken and not other.player_taken and other.rival_taken, "Player flags reset on a new Volta, Rival flags kept")
	assert(other.owner.is_empty(), "Frutinha hidden by both returns for the Corredor on a new Volta")
	race.lateral = 0
	race.rival_lateral = -signf(fruit.lateral) * Race.LATERAL_LIMIT
	race.rival_lateral_velocity = 0
	for step in range(40):
		race.advance(0.1)
	race.distance = race.lap_length + fruit.distance - 0.6
	race.lateral = fruit.lateral
	race.advance(0.1)
	assert(race.collected == 2 and fruit.player_taken, "Same Frutinha taken again on Volta 2")
	race.rival_distance = race.lap_length - 0.05
	race.advance(0.1)
	assert(not other.rival_taken)

func _layout() -> void:
	for seed in range(1, 21):
		var race := _valley("playful")
		race.rng.seed = seed
		race.reset()
		assert(race.fruits.size() >= 20)
		for fruit in race.fruits:
			assert(fruit.distance >= race.lap_length / 22 and fruit.distance <= race.lap_length - 8, "Frutinha at %s" % fruit.distance)

func _golden() -> void:
	for lap in [1, 2]:
		var race := _valley("playful")
		_racing(race)
		race.distance = race.lap_length * lap - 4
		race.rival_distance = race.distance - Race.VALLEY_RECOVERY_GAP - 3
		race.advance(0.05)
		assert(race.recovery_fruit.get("target", "") == "rival", "Fruta dourada allowed near the end of Volta %d" % lap)
	var race := _valley("playful")
	_racing(race)
	race.distance = race.length - 11.5
	race.rival_distance = race.distance - Race.VALLEY_RECOVERY_GAP - 3
	race.advance(0.05)
	assert(race.recovery_fruit.is_empty(), "No Fruta dourada in the last 12 u of the Corrida")
	for circuit in ["forest", "valley"]:
		race = Race.new()
		race.configure("triceratops", circuit, "playful")
		_racing(race)
		race.distance = 30
		race.rival_distance = 30 - Race.RECOVERY_GAP - 3
		race.advance(0.05)
		assert(race.recovery_fruit.is_empty() == (circuit == "valley"), "Fruta dourada gap: %s keeps %s u" % [circuit, Race.RECOVERY_GAP])
		race.recovery_fruit = {"target": "player", "distance": race.distance + 0.3, "lateral": race.lateral, "left": 1.0}
		race.advance(0.2)
		var boost: float = Race.VALLEY_RECOVERY_BOOST if circuit == "valley" else Race.RECOVERY_BOOST
		var duration: float = Race.VALLEY_RECOVERY_DURATION if circuit == "valley" else Race.RECOVERY_DURATION
		assert(race.golden_collected == 1 and is_equal_approx(race.recovery_boost_left, duration) and race.speed >= race.base_speed + boost, "Fruta dourada strength on %s" % circuit)
	assert(Race.VALLEY_RECOVERY_BOOST > Race.RECOVERY_BOOST and Race.VALLEY_RECOVERY_DURATION > Race.RECOVERY_DURATION and Race.VALLEY_RECOVERY_GAP > Race.RECOVERY_GAP)

func _bots() -> void:
	for bot in ["good", "medium", "idle"]:
		var race := _valley("playful")
		race.rng.seed = 7
		race.reset()
		_racing(race)
		var steps := 0
		while race.stage != "finished" and steps < 10000:
			race.advance(0.05, Callable(Bots, bot).call(race))
			steps += 1
		assert(race.stage == "finished" and not race.winner.is_empty() and race.lap == 3)
		if bot == "good":
			assert(race.collected > 30, "Good bot collects Frutinhas on every Volta: %d" % race.collected)

func _impulse_at(race: Race, arrow: Dictionary) -> float:
	var before: float = race.speed
	race.distance = arrow.distance - 0.05
	race.lateral = arrow.lateral
	race.rival_distance = 0
	race.advance(0.1)
	return race.speed - before

func _retorno() -> void:
	var race := _valley("playful")
	_racing(race)
	race.rival_think_time = INF
	var arrow: Dictionary = race.arrows[0]
	var gains: Array[float] = []
	var level_three := 0
	for i in range(30):
		gains.append(_impulse_at(race, arrow))
		assert(race.streak == i + 1 and race.collected == 0 and race.boost_left == Race.BOOST_DURATION)
		if level_three == 0 and Race.speed_level(race.speed - race.base_speed) == 3:
			level_three = i + 1
	assert(gains[0] >= Race.FRUIT_BOOST, "First Impulso %s" % gains[0])
	for i in range(1, gains.size()):
		assert(gains[i] > 0 and gains[i] < gains[i - 1], "Retorno decrescente gains %s" % [gains])
	assert(race.speed - race.base_speed > Race.MAX_BOOST * 2, "No fixed cap in the Vale")
	assert(level_three >= 6 and level_three <= 10, "Level 3 after %d Impulsos" % level_three)
	var fruit_race := _valley("playful")
	_racing(fruit_race)
	fruit_race.rival_think_time = INF
	var fruit: Dictionary = fruit_race.fruits[0]
	fruit_race.distance = fruit.distance - 0.6
	fruit_race.lateral = fruit.lateral
	fruit_race.advance(0.1)
	var seta_race := _valley("playful")
	_racing(seta_race)
	assert(fruit_race.collected == 1 and is_equal_approx(fruit_race.speed - fruit_race.base_speed, _impulse_at(seta_race, seta_race.arrows[0])), "Frutinha and Seta give the same Impulso")
	assert(fruit_race.boost_left == seta_race.boost_left and fruit_race.streak == seta_race.streak)

func _decay() -> void:
	var left := {}
	for circuit in ["forest", "valley"]:
		var race := Race.new()
		race.configure("triceratops", circuit, "playful")
		_racing(race)
		race.fruits.clear()
		race.arrows.clear()
		race.rival_think_time = INF
		race.speed = race.base_speed + Race.MAX_BOOST
		race.boost_left = 0.05
		race.streak = 4
		race.advance(0.1)
		assert(race.streak == 0, "Sequência resets when the Impulso ends")
		race.advance(0.9)
		left[circuit] = race.speed - race.base_speed
	assert(left.valley > left.forest + 0.3 and left.valley < Race.MAX_BOOST, "Vale decays slowly: %s" % left)

func _lateral() -> void:
	for circuit in ["forest", "valley"]:
		var scale := 2.0 if circuit == "valley" else 1.0
		var race := Race.new()
		race.configure("triceratops", circuit, "playful")
		_racing(race)
		race.rival_think_time = INF
		race.speed = race.base_speed * 2
		race.boost_left = 10
		assert(is_equal_approx(race.steer_speed, Race.DINOS.triceratops.steer * scale))
		race.lateral = 0
		race.advance(0.05, 1)
		assert(is_equal_approx(race.lateral, Race.DINOS.triceratops.steer * scale * 0.05), "%s player steering %s" % [circuit, race.lateral])
		var target := 0
		for i in range(race.fruits.size()):
			if absf(race.fruits[i].lateral) > 0.9 and race.fruits[i].distance > 8:
				target = i
				break
		var fruit: Dictionary = race.fruits[target]
		race.rival_distance = fruit.distance - 6
		race.distance = fruit.distance + 10
		race.rival_lateral = -signf(fruit.lateral) * Race.LATERAL_LIMIT
		race.rival_lateral_velocity = 0
		race.rival_target_fruit = target
		race.rival_speed = race.rival_base_speed * 2
		race.rival_boost_left = 10
		race.recovery_cooldown = 100
		race.advance(0.05)
		assert(is_equal_approx(absf(race.rival_lateral_velocity), Race.RIVAL_STEER_ACCELERATION * scale * 0.05), "%s Rival acceleration %s" % [circuit, race.rival_lateral_velocity])
		var fastest := 0.0
		for step in range(20):
			race.advance(0.05)
			fastest = maxf(fastest, absf(race.rival_lateral_velocity))
		assert(fastest > Race.RIVAL_STEER_SPEED * 1.5 if circuit == "valley" else fastest <= Race.RIVAL_STEER_SPEED + 0.0001, "%s Rival steer speed %s" % [circuit, fastest])
		var solo := Race.new()
		solo.configure("triceratops", circuit, "none")
		_racing(solo)
		var near: Dictionary = solo.fruits.filter(func(item): return absf(item.lateral) > 0.9)[0]
		solo.speed = solo.base_speed * 2
		solo.boost_left = 10
		solo.distance = near.distance - 2
		solo.lateral = near.lateral - signf(near.lateral) * 1.5
		var before := solo.lateral
		solo.advance(0.05)
		assert(is_equal_approx(absf(solo.lateral - before), Race.DINOS.triceratops.steer * scale * Race.ASSIST_STRENGTH * 0.05), "%s assist %s" % [circuit, solo.lateral - before])

func _arrow_layout() -> void:
	for circuit in ["forest", "beach"]:
		var race := Race.new()
		race.configure("triceratops", circuit)
		assert(race.arrows.is_empty())
	var sides := {}
	for seed in range(1, 21):
		var race := _valley("playful")
		race.rng.seed = seed
		race.reset()
		assert(race.arrows.size() == 2, "One Seta per straight")
		var straights := []
		for arrow in race.arrows:
			assert(arrow.distance >= race.lap_length / 22 and arrow.distance <= race.lap_length - 8, "Seta at %s" % arrow.distance)
			for offset in [-3.0, 0.0, 6.0]:
				assert(race.sample(arrow.distance).x.dot(race.sample(arrow.distance + offset).x) > 0.9999, "Seta must sit on a straight")
			var direction: Vector2 = race.sample(arrow.distance).x
			assert(not straights.any(func(other): return other.dot(direction) > 0), "Setas on different straights")
			straights.append(direction)
			var side := -signf(arrow.lateral)
			var level := race.fruits.filter(func(fruit): return is_equal_approx(fruit.distance, arrow.distance))
			assert(level.size() == 1 and signf(level[0].lateral) == side, "Seta opposite the first one-sided Frutinha")
			var stretch := race.fruits.filter(func(fruit): return fruit.distance >= arrow.distance - 3 and fruit.distance <= arrow.distance + 5)
			assert(stretch.size() >= 2 and stretch.all(func(fruit): return signf(fruit.lateral) == side), "Choice stretch Frutinhas are one-sided")
			sides["%d %s" % [straights.size(), side]] = true
	assert(sides.size() == 4, "Each straight draws its side per Corrida: %s" % sides)

func _arrow_pickup() -> void:
	var race := _valley("playful")
	_racing(race)
	race.rival_think_time = INF
	for lap in range(3):
		for arrow in race.arrows:
			var speed: float = race.speed
			var rival_speed: float = race.rival_speed
			var streak: int = race.streak
			race.distance = race.lap_length * lap + arrow.distance - 0.05
			race.rival_distance = race.distance
			race.lateral = -arrow.lateral
			race.rival_lateral = arrow.lateral
			race.rival_lateral_velocity = 0
			race.resolve_motion = func(_previous, _rival_previous, _delta): race.lateral = arrow.lateral
			race.advance(0.1)
			assert(race.speed > speed and race.rival_speed > rival_speed, "Both Corredores take the Seta on Volta %d" % (lap + 1))
			assert(race.boost_left == Race.BOOST_DURATION and race.rival_boost_left == Race.BOOST_DURATION and race.streak == streak + 1)
			assert(race.collected == 0, "Seta is not a Frutinha")
	assert(race.arrows_taken == 6)
	race.resolve_motion = Callable()
	var arrow: Dictionary = race.arrows[0]
	var speed: float = race.speed
	race.distance = arrow.distance - 0.05
	race.lateral = 0
	race.advance(0.1)
	assert(race.speed <= speed and race.arrows_taken == 6, "Seta needs the Corredor over it")

func _level_three() -> void:
	var race := _valley("playful")
	race.rng.seed = 7
	race.reset()
	_racing(race)
	var reached := false
	while race.stage != "finished":
		race.advance(0.05, Bots.good(race))
		if race.golden_collected == 0 and race.recovery_boost_left == 0 and Race.speed_level(race.speed - race.base_speed) == 3:
			reached = true
	assert(reached, "Good bot reaches level 3 without the Fruta dourada")

func _camera_bound() -> void:
	var race := _valley()
	var step := 0.25
	var sharpest := 0.0
	for i in range(int(race.lap_length / step)):
		var a := race.sample(i * step).origin
		var b := race.sample((i + 1) * step).origin
		var c := race.sample((i + 2) * step).origin
		sharpest = maxf(sharpest, absf((b - a).angle_to(c - b)) / a.distance_to(b))
	var turn_rate := rad_to_deg(sharpest * PRACTICAL_MAX_SPEED)
	assert(turn_rate < 50, "Camera must turn %s deg/s in the Vale curves" % turn_rate)

func _playful_balance() -> void:
	var wins := {}
	for bot in ["good", "idle"]:
		wins[bot] = 0
		for dino in Race.DINOS:
			for seed in range(1, 4):
				var race := _valley("playful", dino)
				race.rng.seed = seed
				race.reset()
				_racing(race)
				while race.stage != "finished":
					race.advance(0.05, Callable(Bots, bot).call(race))
					assert(bot != "good" or race.speed <= PRACTICAL_MAX_SPEED, "Good bot reached %s u/s" % race.speed)
				wins[bot] += int(race.winner == "player")
	assert(wins.good > wins.idle, "Good bot beats Brincalhão more often than the idle bot: %s" % wins)

func _scene(dino: String) -> void:
	set_meta("race_selection", [dino, "valley", "playful"])
	var game := RecordedRace.new()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await physics_frame
	await physics_frame
	assert(game.forest.theme == "valley" and game.race.track_id == "valley")
	var terrain: AABB = game.forest.get_node("Terrain").get_aabb()
	for i in range(int(game.race.lap_length * 2)):
		for side in [-1, 0, 1]:
			var p: Vector2 = game.race.sample(i * 0.5, side * game.race.LATERAL_LIMIT).origin
			assert(not game.forest.blocked(p))
			assert(game.forest.height_at(p.x, p.y) > -0.25)
			assert(p.distance_to(Vector2(0, -20)) > 7, "Vale must stay clear of the forest camera vista")
			for tree in game.forest.trees:
				assert(tree.position.distance_to(p) > tree.trunk_radius + 0.7)
			for margin in [Vector2(-8, -8), Vector2(8, 8)]:
				var q: Vector2 = p + margin
				assert(terrain.has_point(Vector3(q.x, terrain.get_center().y, q.y)), "Terrain under the track and its surroundings at %s" % q)
	assert(game.arrow_nodes.size() == 2)
	for index in range(2):
		var pose: Transform2D = game.race.sample(game.race.arrows[index].distance, game.race.arrows[index].lateral)
		assert(Vector2(game.arrow_nodes[index].position.x, game.arrow_nodes[index].position.z).distance_to(pose.origin) < 0.01)
	game.restart()
	var previous: float = game.race.distance
	for step in range(4000):
		game._process(0.1)
		await physics_frame
		assert(game.race.distance > previous - 0.01 and game.race.distance - previous < 1.0, "Progress jumped from %s to %s" % [previous, game.race.distance])
		previous = game.race.distance
		var screen: Vector2 = game.camera.unproject_position(game.dinosaur.position + Vector3.UP * 0.6)
		assert(game.get_viewport().get_visible_rect().has_point(screen), "Character outside camera at %s" % game.race.distance)
		if game.race.stage == "finished":
			break
	assert(game.race.stage == "finished" and game.race.distance == game.race.length, "Vale Corrida did not finish for %s" % dino)
	var reports := game.events.filter(func(event): return event.type == "park-race")
	assert(reports.all(func(report): return report.laps == 3))
	var laps := []
	for report in reports:
		if not laps.has(report.lap):
			laps.append(report.lap)
	assert(laps == [1, 2, 3], "Reported Voltas %s" % [laps])
	var splashes := []
	for event in game.events:
		if event.get("name", "") == "splash" and not splashes.has(event.lap):
			splashes.append(event.lap)
	assert(splashes == [1, 2, 3], "Puddles splash on every Volta: %s" % [splashes])
	game.restart()
	var events: int = game.events.size()
	var goal: float = game.race.arrows[0].lateral
	for step in range(200):
		game.right_pressed = goal > game.race.lateral + 0.1
		game.left_pressed = goal < game.race.lateral - 0.1
		game._process(0.1)
		await physics_frame
		if game.race.arrows_taken > 0:
			break
	assert(game.race.arrows_taken == 1 and game.race.collected == 0, "Player crosses the first Seta")
	assert(game.events.slice(events).any(func(event): return event.get("name", "") == "pickup"), "Seta Impulso plays the pickup sound")
	game.queue_free()
	await process_frame
	print("Vale scene passed: ", dino)

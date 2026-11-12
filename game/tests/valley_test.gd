extends SceneTree

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		if data.type == "park-sound" and data.name == "splash":
			data.lap = race.lap
		events.append(data)

const Race := preload("res://race/race_state.gd")
const Bots := preload("res://tests/bots.gd")

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
	print("Vale state checks passed: catalog, stadium geometry, three Voltas, per-Volta Frutinhas, layout, Fruta dourada margin, Sozinho assist and bots.")
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
		assert(race.fruits.size() >= 20 and race.fruits.size() % 5 == 0)
		for fruit in race.fruits:
			assert(fruit.distance >= race.lap_length / 22 and fruit.distance <= race.lap_length - 8, "Frutinha at %s" % fruit.distance)

func _golden() -> void:
	for lap in [1, 2]:
		var race := _valley("playful")
		_racing(race)
		race.distance = race.lap_length * lap - 4
		race.rival_distance = race.distance - 8
		race.advance(0.05)
		assert(race.recovery_fruit.get("target", "") == "rival", "Fruta dourada allowed near the end of Volta %d" % lap)
	var race := _valley("playful")
	_racing(race)
	race.distance = race.length - 11.5
	race.rival_distance = race.distance - 8
	race.advance(0.05)
	assert(race.recovery_fruit.is_empty(), "No Fruta dourada in the last 12 u of the Corrida")

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
	game.queue_free()
	await process_frame
	print("Vale scene passed: ", dino)

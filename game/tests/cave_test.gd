extends SceneTree

const Race := preload("res://race/race_state.gd")
const Bots := preload("res://tests/bots.gd")

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for species in Race.DINOS:
		for rival in Race.RIVALS.keys() + ["none", "coop"]:
			var race := Race.new()
			assert(race.configure_coop(species, "raptor", "cave") if rival == "coop" else race.configure(species, "cave", rival), "Cave must be selectable")
			assert(race.laps == 1 and race.length > 70 and race.length < 90)
			assert(race.sample(0).origin.distance_to(race.sample(race.length).origin) < 0.001)
			assert(race.sample(0).x.dot(race.sample(race.length - 0.01).x) > 0.999)
			assert(race.fruits.size() == 20 and race.arrows.is_empty())
			race.start()
			race.advance(3)
			for step in range(2000):
				race.advance(0.05, Bots.good(race))
				if race.stage == "finished":
					break
			assert(race.stage == "finished" and race.distance == race.length)
			if rival == "coop":
				assert(race.rival_distance == race.length and race.winner.is_empty())
	set_meta("race_selection", ["trex", "cave", "coop", "raptor"])
	var game := RecordedRace.new()
	root.add_child(game)
	game.set_physics_process(false)
	await physics_frame
	assert(game.forest.get_node_or_null("CaveWalls") != null)
	assert(game.scenery.crystals.size() == 3)
	assert(game.scenery.find_children("*", "CollisionObject3D", true, false).is_empty())
	for stone in game.forest.cave_stones:
		for vertex in stone.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
			var p: Vector3 = stone.transform * vertex
			assert(p.y > 8 or game.forest.distance_to_trail(Vector2(p.x, p.z)) > Race.TRACK_WIDTH, "Stone overlaps the drivable road")
	for encounter in game.scenery.crystals:
		for group in encounter.groups:
			for crystal in group.node.get_children():
				for vertex in crystal.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
					var p: Vector3 = crystal.global_transform * vertex
					assert(game.forest.distance_to_trail(Vector2(p.x, p.z)) > Race.TRACK_WIDTH, "Crystal overlaps the road")
	for step in range(200):
		for offset in [-1.65, 0, 1.65]:
			var pose: Transform2D = game.race.sample(game.race.length * step / 200.0, offset)
			assert(not game.forest.blocked(pose.origin))
			assert(game.forest.height_at(pose.origin.x, pose.origin.y) > 0.05)
	game.events.clear()
	for stage in ["ready", "countdown", "finished"]:
		game.race.stage = stage
		_pass(game, 0, -1.4, 1.4)
		assert(game.scenery.crystals[0].played == [false, false])
	assert(_sounds(game).is_empty())
	game.restart()
	game.race.advance(3)
	for encounter in range(3):
		_pass(game, encounter, 0, 0)
		assert(game.scenery.crystals[encounter].played == [false, false], "Center must ignore both groups")
	for encounter in range(3):
		var facts := _race_facts(game)
		_pass(game, encounter, -1.4, 1.4, 4.0)
		assert(_race_facts(game) == facts, "Crystal response changed race rules")
		assert(game.scenery.crystals[encounter].played == [true, true])
		assert(_sounds(game).slice(-2) == ["crystal-%d-left" % encounter, "crystal-%d-right" % encounter])
		var groups: Array = game.scenery.crystals[encounter].groups
		game.scenery.advance(0.3, game.dinosaur.position, game.friend.position)
		for group in groups:
			assert(group.node.get_child(0).material_override.emission_energy_multiplier > 0.08)
		var age: float = groups[0].age
		var emission: float = groups[0].node.get_child(0).material_override.emission_energy_multiplier
		game._web_command(["pause"])
		_pass(game, encounter, 1.4, -1.4)
		assert(groups[0].age == age and groups[0].node.get_child(0).material_override.emission_energy_multiplier == emission)
		game._web_command(["resume"])
		game.scenery.advance(0.2, game.dinosaur.position, game.friend.position)
		assert(groups[0].age > age)
		_pass(game, encounter, 1.4, -1.4)
		assert(_sounds(game).size() == (encounter + 1) * 2, "Repeated passage emitted another note")
	game.restart()
	assert(game.scenery.crystals.all(func(encounter): return encounter.played == [false, false] and encounter.groups.all(func(group): return group.age == game.scenery.CRYSTAL_DURATION and group.node.get_child(0).material_override.emission_energy_multiplier == 0)))
	game.race.advance(3)
	_pass(game, 0, 1.4, -1.4)
	assert(_sounds(game).slice(-2) == ["crystal-0-right", "crystal-0-left"])
	game.queue_free()
	await process_frame
	for species in Race.DINOS:
		for mode in ["none", "playful", "coop"]:
			set_meta("race_selection", [species, "cave", "coop", "raptor"] if mode == "coop" else [species, "cave", mode])
			game = RecordedRace.new()
			root.add_child(game)
			game.set_physics_process(false)
			game.restart()
			game.race.advance(3)
			game.race.distance = game.race.length - 0.03
			game.race.rival_distance = game.race.length - (0.9 if mode == "coop" else 0.03)
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -0.9, 0)
			game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 0.9, 0)
			await physics_frame
			game._process(0.1)
			if mode == "coop":
				assert(game.race.stage == "racing" and game.race.distance == game.race.length and game.race.rival_distance < game.race.length)
			for step in range(20):
				game._process(0.05)
				await physics_frame
			assert(game.race.stage == "finished", "Physical finish stalled for %s/%s" % [species, mode])
			game.queue_free()
			await process_frame
	remove_meta("race_selection")
	print("Cave checks passed: all species/modes, one lap, clear road, three paired encounters, both humans, center, swept fast passage, isolated rules, repeat gating and pause/resume/reset.")
	quit()

func _point(game: Node3D, progress: float, offset: float) -> Vector3:
	var pose: Transform2D = game.race.sample(progress, offset)
	return game.forest.point(pose.origin.x, pose.origin.y)

func _pass(game: Node3D, encounter: int, first: float, second: float, span: float = 1.5) -> void:
	var distance: float = game.scenery.crystals[encounter].distance
	game.dinosaur.position = _point(game, distance + span, first)
	game.friend.position = _point(game, distance + span, second)
	game.scenery.advance(0.01, _point(game, distance - span, first), _point(game, distance - span, second))

func _sounds(game: Node3D) -> Array:
	return game.events.filter(func(event): return event.type == "park-sound").map(func(event): return event.name)

func _race_facts(game: Node3D) -> Array:
	return [game.race.speed, game.race.rival_speed, game.race.distance, game.race.rival_distance, game.race.lateral, game.race.rival_lateral, game.race.fruits.duplicate(true), game.race.collected, game.race.partner_collected, game.race.boost_left, game.race.winner, game.dinosaur.collision_layer, game.friend.collision_layer]

extends SceneTree

const Race := preload("res://race/race_state.gd")
const Bots := preload("res://tests/bots.gd")

func _initialize() -> void:
	create_timer(90).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for species in Race.DINOS:
		for rival in Race.RIVALS.keys() + ["none", "coop"]:
			var race := Race.new()
			assert(race.configure_coop(species, "raptor", "volcano") if rival == "coop" else race.configure(species, "volcano", rival))
			assert(race.laps == 3 and not race.valley and is_equal_approx(race.length, race.lap_length * 3))
			assert(race.lap_length > 95 and race.lap_length < 105)
			assert(race.sample(0).origin.distance_to(race.sample(race.length).origin) < 0.001)
			assert(race.sample(0).x.dot(race.sample(race.length - 0.01).x) > 0.999)
			assert(race.fruits.size() == 20 and race.arrows.is_empty())
			race.start()
			race.advance(3)
			var seen := [race.lap]
			for step in range(5400):
				race.advance(0.05, Bots.good(race), 0)
				if seen[-1] != race.lap:
					seen.append(race.lap)
					assert(race.stage == "racing")
				assert(race.speed <= race.base_speed + Race.RECOVERY_BOOST + 0.001)
				if race.stage == "finished":
					break
			assert(race.stage == "finished" and race.distance == race.length)
			assert(seen == [1, 2, 3] and race.lap == 3)
			if rival == "coop":
				assert(race.rival_distance == race.length and race.winner.is_empty())
			assert(race.collected > 0)
	set_meta("race_selection", ["trex", "volcano", "coop", "raptor"])
	var game: Node3D = load("res://race/race.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	await physics_frame
	assert(game.forest.get_node_or_null("Lava") != null)
	for lava in game.forest.get_node("Lava").get_children():
		assert(lava is MeshInstance3D and lava.material_override is ShaderMaterial)
		assert(lava.material_override == game.forest.lava_material)
		var vertices: PackedVector3Array = lava.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		for vertex in vertices:
			var world: Vector3 = lava.transform * vertex
			assert(game.forest.distance_to_trail(Vector2(world.x, world.z)) > 4, "Lava must stay clear of both road edges")
	for step in range(200):
		for offset in [-1.65, 0, 1.65]:
			var pose: Transform2D = game.race.sample(game.race.length * step / 200.0, offset)
			assert(not game.forest.blocked(pose.origin))
			assert(game.forest.height_at(pose.origin.x, pose.origin.y) > 0.05)
	game.restart()
	game._process(0.1)
	var time: float = game.forest.lava_material.get_shader_parameter("animation_time")
	assert(time > 0)
	game._web_command(["pause"])
	game._process(0.1)
	assert(game.forest.lava_material.get_shader_parameter("animation_time") == time)
	game._web_command(["resume"])
	game._process(0.1)
	assert(game.forest.lava_material.get_shader_parameter("animation_time") > time)
	game.reset_race()
	assert(game.forest.lava_material.get_shader_parameter("animation_time") == 0.0)
	game.queue_free()
	await process_frame
	for species in Race.DINOS:
		for rival in ["none", "playful", "coop"]:
			set_meta("race_selection", [species, "volcano", "coop", "raptor"] if rival == "coop" else [species, "volcano", rival])
			game = load("res://race/race.tscn").instantiate()
			root.add_child(game)
			game.set_physics_process(false)
			game.race.start()
			game.race.advance(3)
			game.race.distance = game.race.length - 0.03
			game.race.rival_distance = game.race.length - 0.5
			game.race.lateral = -0.3976126
			game.race.rival_lateral = 0.9
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, game.race.lateral, 0)
			game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 0.9, 0)
			await physics_frame
			for step in range(20):
				game._process(0.05)
				await physics_frame
			assert(game.race.stage == "finished", "Physical finish stalled for %s/%s at %.12f" % [species, rival, game.race.distance / game.race.length])
			game.queue_free()
			await process_frame
	remove_meta("race_selection")
	print("Volcano checks passed: all dinos/modes, closed loop, fruit rules, lava clearance/pause/reset and physical finish for all three species in Rival/Sozinho/Dupla.")
	quit()

extends SceneTree

const Race := preload("res://race_state.gd")

func _initialize() -> void:
	create_timer(60).timeout.connect(func(): quit(1))
	_run.call_deferred()

func lap(race: Race, steering: float = 0) -> void:
	race.start()
	for step in range(1500):
		race.advance(0.05, steering)
		if race.stage == "finished":
			return

func _run() -> void:
	var race := Race.new()
	assert(not race.configure("triceratops", "forest", "unknown"))
	assert(race.rival_id == "playful" and race.rival_base_speed == Race.RIVAL_SPEED)
	for rival in Race.RIVALS:
		assert(race.configure("trex", "beach", rival))
		assert(race.rival_base_speed == Race.RIVALS[rival].speed and race.rival_speed == race.rival_base_speed)
		assert(race.rival_think_time == Race.RIVALS[rival].reaction)
	var skipped := 0
	for draw in range(10):
		race.configure("triceratops", "forest", "sleepy")
		skipped += race.fruits.filter(func(fruit): return fruit.rival_skip).size()
		race.configure("triceratops", "forest", "speedy")
		assert(race.fruits.all(func(fruit): return not fruit.rival_skip))
	assert(skipped > 20 and skipped < 140, "Sleepy rival must ignore some fruit: %s" % skipped)
	race.configure("triceratops", "forest", "sleepy")
	race.start()
	race.advance(3)
	race.rival_distraction_check = 0.01
	race.rng.seed = 1
	var distracted := false
	for attempt in range(40):
		race.rival_distraction_check = 0.01
		race.advance(0.05)
		if race.rival_distracted_left > 0:
			distracted = true
			break
	assert(distracted, "Sleepy rival must get distracted")
	assert(is_equal_approx(race.rival_speed, race.rival_base_speed - Race.DISTRACTION_SLOW))
	var target := race.rival_target_fruit
	var frozen := race.rival_distracted_left
	race.paused = true
	race.advance(5)
	assert(race.rival_distracted_left == frozen)
	race.paused = false
	race.advance(0.5)
	assert(race.rival_target_fruit == target)
	race.advance(Race.DISTRACTION_TIME)
	assert(race.rival_distracted_left == 0 and race.rival_speed >= race.rival_base_speed)
	race.reset()
	assert(race.rival_distracted_left == 0 and race.rival_distraction_check == Race.DISTRACTION_EVERY)
	race.configure("triceratops", "forest", "speedy")
	race.start()
	for step in range(400):
		race.advance(0.05)
		assert(race.rival_distracted_left == 0)
	for dino in Race.DINOS:
		for circuit in ["forest", "beach"]:
			race = Race.new()
			assert(race.configure(dino, circuit, "none") and race.solo)
			lap(race)
			assert(race.stage == "finished" and race.winner == "player")
			assert(race.rival_distance == 0 and race.golden_collected == 0 and race.recovery_fruit.is_empty())
			assert(race.collected >= 10, "Assist must help a passive child reach fruit: %s/%s got %s" % [dino, circuit, race.collected])
			race.reset()
			lap(race, -1)
			assert(race.collected <= 8, "Assist must not override the child's steering")
	race = Race.new()
	race.configure("triceratops", "forest", "none")
	race.fruits.clear()
	race.fruits.append({"distance": 2.0, "lateral": 0.6, "owner": ""})
	race.start()
	race.advance(3)
	var before := race.lateral
	race.advance(0.05)
	assert(race.lateral > before and race.lateral - before <= race.steer_speed * Race.ASSIST_STRENGTH * 0.05 + 0.00001)
	race.fruits[0].lateral = -1.65
	race.lateral = 1.0
	race.advance(0.05)
	assert(race.lateral == 1.0, "Fruit beyond the assist reach must be ignored")
	race = Race.new()
	race.configure("triceratops", "forest", "playful")
	race.fruits.clear()
	race.start()
	race.advance(3)
	race.distance = 10
	race.rival_distance = 20
	race.advance(0.01)
	race.distance = race.recovery_fruit.distance
	race.advance(0.05)
	assert(race.golden_collected == 1 and race.collected == 1)
	race.reset()
	assert(race.golden_collected == 0)
	for rival in ["none", "speedy"]:
		set_meta("race_selection", ["raptor", "beach", rival])
		set_meta("race_color", "ocean")
		var game: Node3D = load("res://race.tscn").instantiate()
		root.add_child(game)
		await physics_frame
		await physics_frame
		assert(game.race.rival_id == rival and game.race.dino_id == "raptor")
		assert(game.friend.visible == (rival != "none"))
		assert((game.friend.collision_layer == 0) == (rival == "none"))
		var meshes: Array = game.dinosaur.get_node("Model").find_children("*", "MeshInstance3D", true, false)
		var tinted: ShaderMaterial = meshes[0].get_surface_override_material(0)
		assert(tinted.get_shader_parameter("tint") == game.PLAYER_COLORS.ocean and tinted.get_shader_parameter("albedo_texture") != null)
		if rival != "none":
			var friend_mesh: MeshInstance3D = game.friend.get_node("Model").find_children("*", "MeshInstance3D", true, false)[0]
			assert(friend_mesh.get_surface_override_material(0).get_shader_parameter("tint") == game.RIVAL_COLORS[rival])
		game._web_command(["color:natural"])
		assert(meshes[0].get_surface_override_material(0) == null and get_meta("race_color") == "natural")
		game._web_command(["color:gold"])
		assert(get_meta("race_color") == "natural")
		game.restart()
		game.race.advance(3)
		for step in range(30):
			game._process(0.05)
			await physics_frame
		if rival == "none":
			assert(game.race.rival_distance == 0 and game.race.distance > 2)
			assert(game._camera_focus_point() == game.dinosaur.position)
		else:
			assert(game.race.rival_distance > 2)
		game.queue_free()
		await process_frame
	remove_meta("race_selection")
	remove_meta("race_color")
	print("Modes checks passed: three rival profiles, misses, distraction with pause/reset, solo lap without rival or golden fruit, light assist that yields to steering, golden counter, hidden solo rival, rival and player colors.")
	quit()

extends SceneTree

func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var directory := ProjectSettings.globalize_path("res://") + "../art/previews"
	assert(root.get_texture().get_image().save_png(directory.path_join(name + ".png")) == OK)
	print("Captured ", name)

func _run() -> void:
	for circuit in ["forest", "beach", "valley", "volcano", "cave"]:
		root.size = Vector2i(1114, 660)
		set_meta("race_selection", ["pteranodon", circuit, "coop", "pteranodon"])
		set_meta("race_appearances", [{"species": "pteranodon", "color": "natural", "accessory": "cap"}, {"species": "pteranodon", "color": "ocean", "accessory": "glasses"}])
		var game: Node3D = load("res://race/race.tscn").instantiate()
		root.add_child(game)
		game.set_physics_process(false)
		game.race.rng.seed = 73149
		game.reset_race()
		for animation in [game.dinosaur_animation, game.friend_animation]:
			animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			animation.play("idle", 0)
			animation.seek(0.2, true)
		if circuit == "forest":
			for frame in range(30):
				game._update_camera(1, 0.1)
			await _capture("flight-preview-accessories")
			game._apply_appearance(1, {"species": "pteranodon", "color": "natural", "accessory": "none"})
			var animation: AnimationPlayer = game.dinosaur_animation
			animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			animation.play("run", 0)
			game.friend.visible = false
			game.dinosaur.get_node("PlayerLabel").visible = false
			for phase in [0.225, 0.675]:
				animation.seek(phase, true)
				game.camera.position = game.dinosaur.position + Vector3(-2.3, 1.8, -3.0).rotated(Vector3.UP, game.dinosaur.rotation.y)
				game.camera.look_at(game.dinosaur.position + Vector3.UP * 1.2)
				await _capture("flight-wing-%s" % phase)
				game.camera.position = game.dinosaur.position + Vector3(3.2, 1.65, 0.3).rotated(Vector3.UP, game.dinosaur.rotation.y)
				game.camera.look_at(game.dinosaur.position + Vector3.UP * 1.2)
				await _capture("flight-side-%s" % phase)
			game.friend.visible = true
			game.dinosaur.get_node("PlayerLabel").visible = true
		game.race.stage = "racing"
		game.race.distance = game.race.lap_length * 0.23
		game.race.rival_distance = game.race.distance
		game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -0.9, 2.2)
		game._position_runner(game.friend, game.friend_animation, game.race.distance, 0.9, 2.2)
		for animation in [game.dinosaur_animation, game.friend_animation]:
			animation.seek(0.225, true)
		var direction: Vector2 = game.race.sample(game.race.distance).x
		game.travel_yaw = atan2(-direction.x, -direction.y)
		game.forest.animate(1.5)
		for frame in range(30):
			game._update_camera(1, 0.1)
		await _capture("flight-%s-desktop" % circuit)
		root.size = Vector2i(364, 674)
		game._fit_camera()
		for frame in range(30):
			game._update_camera(1, 0.1)
		await _capture("flight-%s-mobile" % circuit)
		game.free()
	remove_meta("race_selection")
	remove_meta("race_appearances")
	quit()

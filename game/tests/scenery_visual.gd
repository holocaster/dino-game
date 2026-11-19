extends SceneTree

func _initialize() -> void:
	create_timer(90).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("res://") + "../art/previews/" + name + ".png"
	assert(root.get_texture().get_image().save_png(path) == OK)
	print("Captured ", name)

func _run() -> void:
	for circuit in ["forest", "beach", "valley", "volcano"]:
		root.size = Vector2i(1114, 660)
		set_meta("race_selection", ["triceratops", circuit, "coop", "raptor"])
		var game: Node3D = load("res://race/race.tscn").instantiate()
		root.add_child(game)
		game.set_physics_process(false)
		game.set_process(false)
		game.race.stage = "racing"
		game.race.distance = game.race.lap_length * 0.23
		game.race.rival_distance = game.race.distance
		game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, -0.9, 0)
		game._position_runner(game.friend, game.friend_animation, game.race.distance, 0.9, 0)
		var direction: Vector2 = game.race.sample(game.race.distance).x
		game.travel_yaw = atan2(-direction.x, -direction.y)
		game.forest.animate(1.5)
		for frame in range(30):
			game._update_camera(1, 0.1)
		await _capture("scenery-%s-desktop" % circuit)
		root.size = Vector2i(364, 674)
		game._fit_camera()
		for frame in range(30):
			game._update_camera(1, 0.1)
		await _capture("scenery-%s-mobile" % circuit)
		if circuit == "forest":
			root.size = Vector2i(1114, 660)
			game._fit_camera()
			var center: Vector3 = Vector3(game.forest.POND.x, 0.1, game.forest.POND.y)
			game.camera.position = center + Vector3(4.1, 3.2, 4.8)
			game.camera.look_at(center)
			game.forest.reveal_character(game.camera.position, center, 1.0, 1.5)
			await _capture("scenery-pond")
		game.queue_free()
		await process_frame
	remove_meta("race_selection")
	quit()

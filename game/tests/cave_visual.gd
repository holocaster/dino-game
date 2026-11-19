extends SceneTree

func _initialize() -> void:
	create_timer(60).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _capture(label: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("res://") + "../art/previews/cave-" + label + ".png"
	assert(root.get_texture().get_image().save_png(path) == OK)
	print("Captured cave-", label)

func _run() -> void:
	set_meta("race_selection", ["triceratops", "cave", "coop", "raptor"])
	var game: Node3D = load("res://race/race.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.set_process(false)
	for size in [Vector2i(1114, 660), Vector2i(364, 674)]:
		root.size = size
		game._fit_camera()
		var format := "desktop" if size.x > size.y else "mobile"
		for index in range(3):
			game.restart()
			game.race.advance(3)
			var progress: float = game.scenery.crystals[index].distance
			game.race.distance = progress
			game.race.rival_distance = progress
			game._position_runner(game.dinosaur, game.dinosaur_animation, progress, -1.4, 0)
			game._position_runner(game.friend, game.friend_animation, progress, 1.4, 0)
			var direction: Vector2 = game.race.sample(progress).x
			game.travel_yaw = atan2(-direction.x, -direction.y)
			game.camera_yaw = game.travel_yaw
			var first: Transform2D = game.race.sample(progress - 1.5, -1.4)
			var second: Transform2D = game.race.sample(progress - 1.5, 1.4)
			game.scenery.advance(0.01, game.forest.point(first.origin.x, first.origin.y), game.forest.point(second.origin.x, second.origin.y))
			game.scenery.advance(0.4, game.dinosaur.position, game.friend.position)
			for frame in range(30):
				game._update_camera(1, 0.1)
			await _capture("encounter-%d-%s" % [index + 1, format])
	game.queue_free()
	await process_frame
	quit()

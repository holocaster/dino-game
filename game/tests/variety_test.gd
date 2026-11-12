extends SceneTree

func _initialize() -> void:
	create_timer(90).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for species in ["triceratops", "trex", "raptor"]:
		for circuit in ["forest", "beach"]:
			set_meta("race_selection", [species, circuit])
			var game: Node3D = load("res://race/race.tscn").instantiate()
			root.add_child(game)
			game.set_process(false)
			game.set_physics_process(false)
			await physics_frame
			await physics_frame
			assert(game.race.dino_id == species and game.forest.theme == circuit)
			assert(game.dinosaur.scale == Vector3.ONE and game.friend.scale == Vector3.ONE)
			assert(game.dinosaur_animation.has_animation("run") and game.dinosaur_animation.has_animation("idle"))
			for i in range(120):
				for side in [-1, 0, 1]:
					var p: Vector2 = game.race.sample(game.race.length * i / 120, side * game.race.LATERAL_LIMIT).origin
					assert(not game.forest.blocked(p))
					assert(game.forest.height_at(p.x, p.y) > -0.25)
					for tree in game.forest.trees:
						assert(tree.position.distance_to(p) > tree.trunk_radius + 0.7)
			if species != "triceratops":
				var skeleton := game.dinosaur.find_child("Skeleton3D", true, false) as Skeleton3D
				assert(skeleton != null)
				game.dinosaur_animation.play("run", 0)
				for i in range(49):
					var time := i * 0.8 / 48
					game.dinosaur_animation.seek(time, true)
					skeleton.force_update_all_bone_transforms()
					for leg in ["LeftFoot", "RightFoot"]:
						var height: float = skeleton.get_bone_global_pose(skeleton.find_bone(leg)).origin.y
						assert(height > 0.065 and height < 0.24, "Foot leaves calibrated ground range: %s" % height)
			game.restart()
			for step in range(600):
				var previous: Vector3 = game.dinosaur.position
				game._process(0.1)
				await physics_frame
				if game.race.stage == "racing" and previous.distance_to(game.dinosaur.position) > 0.001:
					assert(game.dinosaur_animation.current_animation == "run")
					var model: Node3D = game.dinosaur.get_node("Model")
					var cycle: float = model.get_meta("run_cycle_distance", game.RUN_CYCLE_DISTANCE)
					var animated_distance: float = game.dinosaur_animation.speed_scale * cycle / 0.8 * model.scale.x * 0.1
					assert(absf(animated_distance - previous.distance_to(game.dinosaur.position)) < 0.0001, "%s %s step %s clip %s animated %s moved %s" % [species, circuit, step, game.dinosaur_animation.current_animation, animated_distance, previous.distance_to(game.dinosaur.position)])
				var cap: float = game.race.RECOVERY_BOOST if game.race.recovery_boost_left > 0 else game.race.MAX_BOOST
				assert(game.race.speed <= game.race.base_speed + cap + 0.00001)
				assert(is_equal_approx(game.dinosaur.position.y, game.forest.height_at(game.dinosaur.position.x, game.dinosaur.position.z)))
				if game.race.stage == "finished":
					break
			assert(game.race.stage == "finished", "Race blocked for %s on %s" % [species, circuit])
			game._web_command(["menu"])
			assert(game.race.stage == "ready" and game.race.dino_id == species and game.race.track_id == circuit)
			assert(game.race.speed == game.race.base_speed and game.race.collected == 0)
			game._web_command(["start"])
			game._web_command(["select:raptor:beach:playful"])
			assert(game.race.stage == "countdown")
			game._web_command(["pause"])
			game._web_command(["menu"])
			assert(game.race.stage == "ready" and not game.race.paused)
			game.queue_free()
			await process_frame
			print("Variety lap passed: ", species, " / ", circuit)
	remove_meta("race_selection")
	quit()

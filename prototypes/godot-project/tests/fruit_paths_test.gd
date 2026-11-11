extends SceneTree

const Race := preload("res://race_state.gd")

func check_layout(race: Race) -> void:
	assert(race.fruits.size() == 20)
	var previous_end := -4.0
	for section in range(4):
		var index := section * 5
		var left: Dictionary = race.fruits[index]
		var right: Dictionary = race.fruits[index + 1]
		var left_next: Dictionary = race.fruits[index + 2]
		var right_next: Dictionary = race.fruits[index + 3]
		var join: Dictionary = race.fruits[index + 4]
		assert(left.distance >= previous_end + 4 and left.distance == right.distance, "Next fork must stay reachable from the previous central fruit")
		assert(left_next.distance == right_next.distance and left_next.distance > left.distance)
		assert(join.distance > left_next.distance and join.distance < race.length)
		assert(join.lateral == 0)
		assert(left.lateral < 0 and right.lateral > 0 and left_next.lateral < 0 and right_next.lateral > 0)
		assert(is_equal_approx(left.lateral, -right.lateral) and is_equal_approx(left_next.lateral, -right_next.lateral))
		assert(right.lateral - left.lateral > 1.6 and right_next.lateral - left_next.lateral > 1.6, "Center must not collect both branches")
		for fruit in [left, right, left_next, right_next]:
			assert(absf(fruit.lateral) <= Race.LATERAL_LIMIT)
		var available_time: float = (join.distance - left_next.distance) / (race.base_speed + Race.MAX_BOOST)
		assert(absf(left_next.lateral) / race.steer_speed < available_time, "Central fruit must be reachable at maximum speed")
		previous_end = join.distance
	assert(race.fruits[0].distance >= race.length / 22 and race.fruits[19].distance <= race.length - 8, "Fruit must not sit behind the start line")

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for species in Race.DINOS:
		for circuit in ["forest", "beach"]:
			var race := Race.new()
			race.configure(species, circuit)
			var layouts := {}
			for draw in range(25):
				race.reset()
				check_layout(race)
				layouts[str(race.fruits.map(func(fruit): return [fruit.distance, fruit.lateral]))] = true
			assert(layouts.size() > 20, "Fruit layout must change between races")
			for side in [-1, 1]:
				race.reset()
				race.start()
				race.advance(3)
				race.rival_distance = race.length
				for step in range(1100):
					var goal := race.lateral
					for fruit in race.fruits:
						if not fruit.player_taken and fruit.distance >= race.distance and fruit.lateral * side >= 0:
							goal = fruit.lateral
							break
					race.advance(0.05, clampf((goal - race.lateral) / (race.steer_speed * 0.05), -1, 1))
					if race.stage == "finished":
						break
				assert(race.stage == "finished" and race.collected == 12, "%s/%s side %s must collect two branch fruits and the central fruit in each section; got %s" % [species, circuit, side, race.collected])
				assert(race.fruits.all(func(fruit): return not fruit.player_taken or fruit.lateral * side >= 0))
				race.reset()
				assert(race.fruits.all(func(fruit): return fruit.owner.is_empty() and not fruit.player_taken and not fruit.friend_taken and fruit.respawn == 0))
	for circuit in ["forest", "beach"]:
		for side in [-1, 1]:
			set_meta("race_selection", ["triceratops", circuit])
			var game: Node3D = load("res://race.tscn").instantiate()
			root.add_child(game)
			game.set_process(false)
			game.set_physics_process(false)
			game.friend.collision_layer = 0
			game.friend.collision_mask = 0
			await physics_frame
			await physics_frame
			game.restart()
			game.race.rival_distance = game.race.length
			for step in range(200):
				var goal: float = game.race.lateral
				for fruit in game.race.fruits.slice(0, 5):
					if not fruit.player_taken and fruit.distance >= game.race.distance and fruit.lateral * side >= 0:
						goal = fruit.lateral
						break
				game.left_pressed = goal < game.race.lateral - 0.1
				game.right_pressed = goal > game.race.lateral + 0.1
				game._process(0.1)
				await physics_frame
				if game.race.distance > game.race.fruits[4].distance + 1.5:
					break
			assert(game.race.collected == 3, "Physical route must collect two side fruits and the central fruit: %s/%s got %s" % [circuit, side, game.race.collected])
			assert(game.race.fruits.slice(0, 5).all(func(fruit): return fruit.player_taken == (fruit.lateral * side >= 0)))
			game.reset_race()
			assert(game.fruit_nodes.all(func(fruit): return fruit.visible))
			for index in range(20):
				var pose: Transform2D = game.race.sample(game.race.fruits[index].distance, game.race.fruits[index].lateral)
				assert(game.fruit_nodes[index].position.is_equal_approx(game.forest.point(pose.origin.x, pose.origin.y)), "Fruit nodes must follow the new layout")
			game.queue_free()
			await process_frame
	remove_meta("race_selection")
	print("Fruit paths passed: four symmetric forks, equal rewards, center separation, reachable joins, both routes for all six configurations and clean reset.")
	quit()

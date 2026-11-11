extends SceneTree

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func overlaps_runner(game: Node3D, runner: CharacterBody3D) -> bool:
	var source: CollisionShape3D = runner.get_node("BodyShape")
	var shape := source.shape.duplicate() as CapsuleShape3D
	shape.radius -= 0.015
	shape.height -= 0.03
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = source.global_transform
	query.collision_mask = 1
	query.exclude = [runner.get_rid()]
	return not game.get_world_3d().direct_space_state.intersect_shape(query).is_empty()

func _run() -> void:
	var game: Node3D = load("res://race.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await physics_frame
	await physics_frame
	assert(game.dinosaur is CharacterBody3D and game.friend is CharacterBody3D)
	assert(game.dinosaur.scale == Vector3.ONE and game.friend.scale == Vector3.ONE)
	assert(is_equal_approx(game.friend.get_node("Model").scale.x, 0.86))
	assert(game.fruit_nodes.all(func(fruit): return fruit is Area3D))
	game.race.start()
	game.race.advance(3)
	game.race.rival_speed = game.race.speed
	for fruit in game.race.fruits:
		fruit.owner = "player"
	game._web_command(["right-down"])
	var minimum_gap := INF
	for step in range(50):
		game._process(0.05)
		await physics_frame
		minimum_gap = minf(minimum_gap, game.dinosaur.position.distance_to(game.friend.position))
		assert(not overlaps_runner(game, game.dinosaur))
		assert(not overlaps_runner(game, game.friend))
		assert(absf(game.race.lateral) < game.race.TRACK_WIDTH and absf(game.race.rival_lateral) < game.race.TRACK_WIDTH)
	assert(minimum_gap >= 0.88, "Runners overlap when pressing against the other runner at the track edge: %s" % minimum_gap)
	assert(game.race.distance > 2 and game.race.rival_distance > 2)
	var tree: Dictionary = game.forest.trees[0]
	var trunk: StaticBody3D
	for child in game.forest.get_children():
		if child is StaticBody3D and Vector2(child.position.x, child.position.z).distance_to(tree.position) < 0.01:
			trunk = child
			break
	assert(trunk != null)
	var away: Vector2 = (tree.position - game.race.track.get_closest_point(tree.position)).normalized()
	var start: Vector2 = tree.position + away * 2.5
	game.dinosaur.position = game.forest.point(start.x, start.y)
	game.dinosaur.rotation.y = atan2(away.x, away.y)
	await physics_frame
	await physics_frame
	var hit: KinematicCollision3D = game.dinosaur.move_and_collide(Vector3(-away.x, 0, -away.y) * 5)
	assert(hit != null and hit.get_collider() == trunk)
	game.restart()
	game.race.advance(3)
	var fruit_distance: float = game.race.fruits[0].distance
	for fruit in game.race.fruits.slice(1):
		fruit.owner = "player"
	game.race.distance = fruit_distance
	game.race.rival_distance = fruit_distance
	game.race.lateral = game.race.fruits[0].lateral + 0.45
	game.race.rival_lateral = game.race.lateral + 1.3
	game._position_runner(game.dinosaur, game.dinosaur_animation, fruit_distance, game.race.lateral, 0)
	game._position_runner(game.friend, game.friend_animation, fruit_distance, game.race.rival_lateral, 0)
	await physics_frame
	await physics_frame
	for step in range(5):
		game._process(0.05)
		await physics_frame
	assert(game.race.fruits[0].owner in ["player", "friend"])
	assert(is_equal_approx(game.race.speed - game.race.BASE_SPEED + game.race.rival_speed - game.race.RIVAL_SPEED, game.race.FRUIT_BOOST))
	assert(not game.fruit_nodes[0].visible)
	game.restart()
	game.race.advance(3)
	fruit_distance = game.race.fruits[0].distance
	game.race.distance = fruit_distance
	game.race.rival_lateral = game.race.fruits[0].lateral
	game.race.rival_think_time = INF
	game._position_runner(game.dinosaur, game.dinosaur_animation, fruit_distance, game.race.fruits[0].lateral, 0)
	game.race.rival_distance = fruit_distance - 3.8
	game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, game.race.rival_lateral, 0)
	await physics_frame
	await physics_frame
	game._process(0.05)
	assert(game.race.fruits[0].owner == "player")
	game.race.distance = fruit_distance + 5
	game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, game.race.lateral, 0)
	await physics_frame
	for step in range(35):
		game._process(0.05)
		await physics_frame
	assert(game.race.fruits[0].player_taken and game.race.fruits[0].friend_taken, "Respawn must let the trailing body collect the same fruit")
	assert(game.race.fruits[0].owner == "friend" and not game.fruit_nodes[0].visible)
	game.restart()
	game.race.advance(3)
	game.race.distance = game.race.length - 4
	game.race.rival_distance = game.race.length - 10
	game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, game.race.lateral, 0)
	game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, game.race.rival_lateral, 0)
	for fruit in game.race.fruits:
		fruit.owner = "player"
	game.race.fruits[0].owner = ""
	game.race.fruits[0].distance = game.race.length - 0.5
	var original_fruit_position: Vector3 = game.fruit_nodes[0].position
	var fruit_pose: Transform2D = game.race.sample(game.race.length - 0.5, game.race.lateral)
	game.fruit_nodes[0].position = game.forest.point(fruit_pose.origin.x, fruit_pose.origin.y)
	var barrier := StaticBody3D.new()
	barrier.collision_layer = 2
	barrier.collision_mask = 0
	game.add_child(barrier)
	var pose: Transform2D = game.race.sample(game.race.length - 2)
	barrier.position = game.forest.point(pose.origin.x, pose.origin.y) + Vector3.UP * 0.8
	barrier.rotation.y = atan2(-pose.x.x, -pose.x.y)
	var wall := CollisionShape3D.new()
	wall.shape = BoxShape3D.new()
	wall.shape.size = Vector3(7, 2.4, 0.2)
	barrier.add_child(wall)
	await physics_frame
	await physics_frame
	for step in range(30):
		game._process(0.4)
		await physics_frame
	assert(game.race.stage == "racing" and game.race.winner.is_empty())
	assert(game.race.distance < game.race.length - 1)
	assert(game.race.fruits[0].owner.is_empty() and game.race.collected == 0)
	assert(is_equal_approx(game.dinosaur.position.y, game.forest.height_at(game.dinosaur.position.x, game.dinosaur.position.z)))
	var stopped: Vector3 = game.dinosaur.position
	game._web_command(["pause"])
	game._process(0.1)
	await physics_frame
	assert(game.dinosaur.position == stopped)
	barrier.queue_free()
	game.fruit_nodes[0].position = original_fruit_position
	game.restart()
	await physics_frame
	assert(game.race.collected == 0 and game.race.winner.is_empty())
	assert(game.race.distance == 0 and game.race.rival_distance == 0)
	assert(not overlaps_runner(game, game.dinosaur))
	game.race.advance(3)
	game.race.distance = game.race.length - 2.5
	game.race.rival_distance = game.race.length
	game.race.lateral = 0
	game.race.rival_lateral = 0
	game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, 0, 0)
	game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 0, 0)
	await physics_frame
	await physics_frame
	for step in range(70):
		game._process(0.05)
		await physics_frame
		assert(not overlaps_runner(game, game.dinosaur))
		if game.race.stage == "finished":
			break
	assert(game.race.stage == "finished" and game.race.winner == "friend")
	game.queue_free()
	print("Collision checks passed: native bodies, unscaled shapes, sustained contact, sliding, track edges, solid trunk, high-speed sweep, physical fruit, trailing runner respawn, single boost, blocked progress/finish/pickup, terrain, pause and reset. Minimum runner gap: ", minimum_gap)
	quit()

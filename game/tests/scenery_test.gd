extends SceneTree

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for circuit in ["forest", "beach"]:
		set_meta("race_selection", ["triceratops", circuit])
		var game := RecordedRace.new()
		root.add_child(game)
		game.set_process(false)
		game.set_physics_process(false)
		await physics_frame
		await physics_frame
		var scenery: Node3D = game.scenery
		assert(scenery.puddles.size() == 4 and scenery.birds.size() == 8 and scenery.spectators.size() == 6)
		assert(scenery.find_children("*", "CollisionObject3D", true, false).is_empty())
		for child in scenery.get_children():
			if child is MeshInstance3D and child.mesh is ArrayMesh:
				var vertices: PackedVector3Array = child.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
				for index in range(0, vertices.size(), 3):
					assert((vertices[index + 1] - vertices[index]).cross(vertices[index + 2] - vertices[index]).length() > 0.0001, "Puddle triangles must cover the full surface without degenerate wedges")
				for vertex in vertices:
					assert(is_equal_approx(vertex.y, game.forest.height_at(vertex.x, vertex.z) + 0.025))
		game.events.clear()
		scenery.advance(0.1, game.dinosaur.position, game.friend.position)
		assert(not game.events.any(func(event): return event.type == "park-sound"))
		var bird_position: Vector3 = scenery.birds[0].node.position
		game.restart()
		game.race.advance(3)
		var puddle: Dictionary = scenery.puddles[0]
		var progress: float = puddle.distance
		var offset: float = -0.9
		game.race.distance = progress - 1.5
		game.race.rival_distance = progress - 5
		game.race.lateral = offset
		game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, offset, 0)
		game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, 0.9, 0)
		for fruit in game.race.fruits:
			fruit.owner = "player"
		await physics_frame
		await physics_frame
		var speed: float = game.race.speed
		for step in range(15):
			game._process(0.05)
			await physics_frame
		assert(puddle.player_splashed and not puddle.rival_splashed)
		assert(scenery.splashes[0].node.visible)
		assert(game.race.speed == speed and game.race.collected == 0)
		assert(game.events.filter(func(event): return event.get("name", "") == "splash").size() == 1)
		assert(game.events.any(func(event): return event.get("name", "") == "bird"))
		assert(game.events.any(func(event): return event.get("name", "") == "cheer"))
		assert(scenery.birds[0].node.position != bird_position)
		assert(scenery.spectators.any(func(item): return item.node.position.y > item.base.y))
		game._web_command(["pause"])
		var snapshot := [scenery.elapsed, scenery.splashes[0].age, scenery.birds[0].node.position, scenery.spectators[0].node.position, scenery.spectators[0].animation.current_animation_position, game.events.filter(func(event): return event.type == "park-sound").size()]
		game._process(0.1)
		assert(snapshot == [scenery.elapsed, scenery.splashes[0].age, scenery.birds[0].node.position, scenery.spectators[0].node.position, scenery.spectators[0].animation.current_animation_position, game.events.filter(func(event): return event.type == "park-sound").size()])
		game._web_command(["resume"])
		game.race.rival_distance = progress - 1.5
		game.race.rival_lateral = offset
		game.race.rival_think_time = INF
		game.race.rival_target_fruit = -1
		game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, offset, 0)
		await physics_frame
		await physics_frame
		for step in range(18):
			game._process(0.05)
			await physics_frame
		assert(puddle.rival_splashed)
		assert(game.events.filter(func(event): return event.get("name", "") == "splash").size() == 2)
		for step in range(20):
			game._process(0.05)
			await physics_frame
		assert(scenery.splashes.all(func(item): return not item.node.visible))
		assert(game.events.filter(func(event): return event.get("name", "") == "splash").size() == 2)
		game.race.stage = "finished"
		game._process(0.1)
		assert(scenery.spectators.all(func(item): return item.node.position.y >= item.base.y))
		game.reset_race()
		assert(scenery.elapsed == 0 and scenery.puddles.all(func(item): return not item.player_splashed and not item.rival_splashed))
		assert(scenery.splashes.all(func(item): return not item.node.visible))
		assert(scenery.spectators.all(func(item): return not item.cheered and item.node.position == item.base))
		game.queue_free()
		await process_frame
	remove_meta("race_selection")
	print("Scenery checks passed: terrain-following puddles, both runners, unique splash sounds, no speed or collision changes, birds, cheering, finish celebration, pause and reset in both tracks.")
	quit()

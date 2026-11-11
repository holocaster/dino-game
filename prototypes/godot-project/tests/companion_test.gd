extends SceneTree

class CompanionPark extends "res://park.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func tick(game: Node3D, delta: float = 0.05) -> void:
	var previous: Vector3 = game.companion.position
	game._process(delta)
	var npc: Node3D = game.companion
	assert(not game.forest.blocked(Vector2(npc.position.x, npc.position.z)))
	assert(absf(npc.position.y - game.forest.height_at(npc.position.x, npc.position.z)) < 0.001)
	assert(previous.distance_to(npc.position) <= minf(delta, 0.5) * 3.0 + 0.01)

func until_stage(game: Node3D, stage: String, limit: int = 800) -> void:
	for step in range(limit):
		if game.companion.stage == stage:
			return
		tick(game)
	assert(false, "Companion did not reach " + stage)

func place_player(game: Node3D, point: Vector2) -> void:
	game.dinosaur.position = game.forest.point(point.x, point.y)
	game.target = game.dinosaur.position
	game.route.clear()

func _run() -> void:
	var game := CompanionPark.new()
	root.add_child(game)
	game.set_process(false)
	var npc: Node3D = game.companion
	var home: Vector3 = npc.position
	var npc_mesh: MeshInstance3D = npc.find_children("*", "MeshInstance3D", true, false)[0]
	var hero_mesh: MeshInstance3D = game.body.find_children("*", "MeshInstance3D", true, false)[0]
	assert(npc_mesh.get_active_material(0) != hero_mesh.get_active_material(0))
	assert(npc_mesh.get_active_material(0).albedo_color != hero_mesh.get_active_material(0).albedo_color)
	var distance := 0.0
	for step in range(220):
		var previous: Vector3 = npc.position
		tick(game, 0.4 if step % 17 == 0 else 0.05)
		distance += previous.distance_to(npc.position)
	assert(distance > 3.0 and npc.stage == "patrol")
	assert(not game.events.any(func(event): return event.type == "park-companion"))
	game.restart()
	place_player(game, Vector2(6, -12))
	until_stage(game, "greeting")
	assert(not npc.armed and npc.route.is_empty())
	for step in range(10):
		tick(game)
	assert(npc.player.current_animation == "companion/hello")
	assert(not game.dinosaur_animation.has_animation("companion/hello"))
	assert(npc.player.get_animation("companion/hello") != game.dinosaur_animation.get_animation("idle"))
	until_stage(game, "following")
	var start: Vector3 = npc.position
	game._set_target(game.forest.point(4, -15))
	for step in range(200):
		tick(game)
		assert(npc.position.distance_to(game.dinosaur.position) > 1.4)
		if npc.stage == "returning":
			break
	assert(npc.stage == "returning" and npc.position.distance_to(start) > 1.0)
	until_stage(game, "patrol")
	assert(npc.position.distance_to(home) < 0.08)
	game.restart()
	game.events.clear()
	place_player(game, Vector2(6, -12))
	until_stage(game, "following")
	until_stage(game, "returning")
	until_stage(game, "patrol")
	for step in range(600):
		tick(game)
	assert(not npc.armed)
	assert(game.events.filter(func(event): return event.type == "park-companion" and event.stage == "greeting").size() == 1)
	game._set_target(game.forest.point(0, 2.8))
	for step in range(600):
		tick(game)
	assert(npc.armed)
	game._web_command(["butterflies"])
	until_stage(game, "greeting", 1000)
	assert(game.events.filter(func(event): return event.type == "park-companion" and event.stage == "greeting").size() == 2)
	game.restart()
	place_player(game, Vector2(6, -12))
	until_stage(game, "following")
	place_player(game, Vector2(0, -20))
	tick(game)
	assert(npc.stage == "returning")
	until_stage(game, "patrol")
	assert(npc.position.distance_to(home) < 0.08)
	game.restart()
	place_player(game, Vector2(6, -12))
	until_stage(game, "greeting")
	place_player(game, Vector2(0, 2.8))
	tick(game)
	assert(npc.stage == "returning")
	place_player(game, Vector2(0, -20))
	npc.position = game.forest.point(-5.05, 0.7)
	npc._return_home()
	until_stage(game, "patrol")
	assert(npc.position.distance_to(home) < 0.08)
	game.restart()
	place_player(game, Vector2(6, -12))
	until_stage(game, "following")
	place_player(game, Vector2(2.3, 1.8))
	game._interact(game.discoveries[2])
	game.events.clear()
	tick(game)
	assert(npc.stage == "returning")
	assert(not game.events.any(func(event): return event.type == "park-companion"))
	for stage in ["patrol", "approaching", "greeting", "following", "returning"]:
		game.restart()
		place_player(game, Vector2(6, -12))
		until_stage(game, stage)
		game.restart()
		assert(npc.stage == "patrol" and npc.position.distance_to(home) < 0.001)
		assert(npc.armed and npc.route.is_empty() and npc.player.current_animation == "idle")
		for step in range(10):
			tick(game)
		assert(npc.stage == "patrol")
	game.queue_free()
	print("Companion checks passed: patrol, terrain, approach, greeting, following, spacing, detours, return, re-entry, independent materials, feeding priority and reset in every stage.")
	quit()

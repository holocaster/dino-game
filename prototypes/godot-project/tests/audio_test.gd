extends SceneTree

class AudioPark extends "res://park.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

func _initialize() -> void:
	create_timer(15).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var game := AudioPark.new()
	root.add_child(game)
	game.set_process(false)
	game.events.clear()
	for step in range(20):
		game._process(0.05)
	assert(not game.events.any(func(event): return event.type == "park-sound"))
	game._web_command(["fruit"])
	for step in range(600):
		game._process(0.05)
		if game.discoveries[2].found and game.feeding.stage == "idle":
			break
	var sounds := game.events.filter(func(event): return event.type == "park-sound")
	assert(sounds.filter(func(event): return event.name == "step").size() > 0)
	assert(sounds.filter(func(event): return event.name == "pickup").size() == 1)
	assert(sounds.filter(func(event): return event.name == "bite").size() == 4)
	assert(sounds.filter(func(event): return event.name == "happy").size() == 1)
	for item in game.discoveries.slice(0, 2):
		game._interact(item)
		assert(game.events[-2] == {"type": "park-sound", "name": item.data.id})
	for point in [Vector2(-5.05, 0.7), Vector2(1, -6.3)]:
		game.dinosaur.position = game.forest.point(point.x, point.y)
		game._send_ambience()
		var event: Dictionary = game.events[-1]
		assert(event.lake >= 0 and event.lake <= 1 and event.grove >= 0 and event.grove <= 1)
		assert(event.lake > 0.9 if point.x < 0 else event.grove > 0.9)
	game.restart()
	game.events.clear()
	game._web_command(["fruit"])
	for step in range(600):
		game._process(0.05)
		if game.feeding.stage == "eating":
			break
	assert(game.feeding.stage == "eating")
	game.restart()
	game.events.clear()
	for step in range(100):
		game._process(0.05)
	assert(not game.events.any(func(event): return event.type == "park-sound"))
	assert(game.step_distance == 0)
	game.queue_free()
	print("Audio checks passed: stationary silence, movement, flowers, tracks, pickup, four bites, reward, proximity and cancellation.")
	quit()

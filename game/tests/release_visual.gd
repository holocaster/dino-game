extends Node

var game: Node3D
var callback: JavaScriptObject

func _ready() -> void:
	callback = JavaScriptBridge.create_callback(_select)
	JavaScriptBridge.get_interface("window").releaseFixture = callback
	_select(["preview:triceratops:forest:cap:glasses"])

func _process(delta: float) -> void:
	if game != null:
		game._update_camera(1 - exp(-delta * 5), delta)

func _select(arguments: Array) -> void:
	JavaScriptBridge.eval("window.releaseFixtureCase = ''; window.releaseFixtureReport = null;", true)
	var values: PackedStringArray = str(arguments[0]).split(":")
	assert(values.size() == 5)
	assert(values[0] in ["preview", "run", "paths", "puddle", "wait1", "wait2", "curve", "zero", "loss"])
	assert(values[1] in ["triceratops", "trex", "raptor"] and values[2] in ["forest", "beach", "valley", "volcano"])
	assert(values[3] in ["none", "cap", "glasses"] and values[4] in ["none", "cap", "glasses"])
	if game != null:
		remove_child(game)
		game.queue_free()
	get_tree().set_meta("race_selection", [values[1], values[2], "speedy"] if values[0] == "loss" else [values[1], values[2], "coop", values[1]])
	get_tree().set_meta("race_appearances", [{"species": values[1], "color": "ocean", "accessory": values[3]}, {"species": values[1], "color": "candy", "accessory": values[4]}])
	get_tree().set_meta("race_color", "ocean")
	game = load("res://race/race.tscn").instantiate()
	add_child(game)
	game.set_physics_process(false)
	JavaScriptBridge.eval("window.parkCommand = ((command) => value => { if (!value.startsWith('appearance:')) command(value); })(window.parkCommand);", true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	game._web_command(["appearance:1:%s:ocean:%s" % [values[1], values[3]]])
	game._web_command(["appearance:2:%s:candy:%s" % [values[1], values[4]]])
	if values[0] != "preview":
		game.restart()
		game.race.advance(3)
		game.race.distance = 8
		game.race.rival_distance = 8
		_position(8, -0.9, 8, 0.9)
	if values[0] == "paths":
		var left: Dictionary = game.scenery.paths.filter(func(path): return path.side < 0 and game.scenery.puddles.all(func(p): return absf(p.distance - path.distance) > 2))[0]
		var right: Dictionary = game.scenery.paths.filter(func(path): return path.side > 0 and path.distance == left.distance)[0]
		var before := _point(left.distance - 1.4, left.offset)
		var partner_before := _point(right.distance - 1.4, right.offset)
		game.race.distance = left.distance
		game.race.rival_distance = right.distance
		_position(left.distance, left.offset, right.distance, right.offset)
		game.scenery.advance(0.18, before, partner_before)
		assert(left.player_played and right.rival_played and left.node.visible and right.node.visible)
	elif values[0] == "puddle":
		var puddle: Dictionary = game.scenery.puddles[0]
		var before := _point(puddle.distance - 1.4, -0.9)
		game.race.distance = puddle.distance
		game.race.rival_distance = puddle.distance
		_position(puddle.distance, -0.9, puddle.distance, 0.9)
		game.scenery.advance(0.18, before, before)
		assert(puddle.player_splashed)
	elif values[0] in ["wait1", "wait2"]:
		var leader: int = 1 if values[0] == "wait1" else 2
		game.race.distance = game.race.length - (0.02 if leader == 1 else 5)
		game.race.rival_distance = game.race.length - (0.02 if leader == 2 else 5)
		_position(game.race.distance, -0.9, game.race.rival_distance, 0.9)
		await get_tree().physics_frame
		game._process(0.1)
		assert(game.race.stage == "racing")
		assert((game.dinosaur if leader == 1 else game.friend).collision_layer == 0)
	elif values[0] == "curve":
		game.race.distance = game.race.lap_length * 0.45
		game.race.rival_distance = game.race.distance - 18
		_position(game.race.distance, -1.65, game.race.rival_distance, 1.65)
	elif values[0] == "loss":
		game.race.distance = game.race.length - 0.05
		game.race.rival_distance = game.race.length
		_position(game.race.distance, -0.9, game.race.rival_distance, 0.9)
		await get_tree().physics_frame
		await get_tree().physics_frame
		for step in range(10):
			game._process(0.05)
			await get_tree().physics_frame
		assert(game.race.stage == "finished" and game.race.winner == "rival")
	elif values[0] == "zero":
		game.race.distance = game.race.length
		game.race.rival_distance = game.race.length
		game.race.collected = 0
		game.race.partner_collected = 0
		game.race.golden_collected = 0
		game.race.partner_golden = 0
		game.race.stage = "finished"
		game.race.winner = ""
		_position(game.race.length + 1.5, -1.6, game.race.length + 1.5, 1.6)
		game.scenery.advance(0.24, game.dinosaur.position, game.friend.position)
	if values[0] in ["zero", "loss"]:
		assert(game.scenery.baby_received == 0 and game.scenery.baby.position.y > game.scenery.baby_base.y)
		assert(game.scenery.delivery.get_children().all(func(fruit): return not fruit.visible))
	for animation in [game.dinosaur_animation, game.friend_animation]:
		animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		animation.play("idle" if values[0] in ["preview", "zero", "loss"] else "run")
		animation.advance(0.2)
	for frame in range(30):
		game._update_camera(1, 0.1)
	await get_tree().physics_frame
	assert(game.race.dino_id == values[1] and game.race.track_id == values[2])
	var models := [game.dinosaur.get_node("Model").scene_file_path, game.friend.get_node("Model").scene_file_path]
	var requested_model: String = preload("res://dinos/runner_model.gd").MODELS[values[1]].resource_path
	assert(models[0] == requested_model)
	if game.race.mode == "coop":
		assert(game.race.partner_id == values[1] and models[1] == requested_model)
	game._report()
	JavaScriptBridge.eval("window.releaseFixtureReport = %s;" % JSON.stringify({"case": arguments[0], "track": game.race.track_id, "stage": game.race.stage, "players": game._players_report(), "models": models, "appearances": get_tree().get_meta("race_appearances")}), true)
	JavaScriptBridge.get_interface("window").releaseFixtureCase = arguments[0]

func _point(progress: float, offset: float) -> Vector3:
	var pose: Transform2D = game.race.sample(progress)
	var position: Vector2 = pose.origin + pose.y * offset
	return game.forest.point(position.x, position.y)

func _position(first: float, left: float, second: float, right: float) -> void:
	game._position_runner(game.dinosaur, game.dinosaur_animation, first, left, 3)
	game._position_runner(game.friend, game.friend_animation, second, right, 3)
	var direction: Vector2 = game.race.sample(first).x
	game.travel_yaw = atan2(-direction.x, -direction.y)

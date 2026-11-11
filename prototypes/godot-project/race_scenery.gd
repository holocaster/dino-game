extends Node3D

const SPLASH_DURATION := 0.6

var game: Node3D
var elapsed := 0.0
var puddles: Array[Dictionary] = []
var splashes: Array[Dictionary] = []
var birds: Array[Dictionary] = []
var spectators: Array[Dictionary] = []

func setup(race_game: Node3D) -> void:
	game = race_game
	for index in range(4):
		var progress: float = 7 + game.race.length * index / 4
		var offset := -0.9 if index % 2 == 0 else 0.9
		var pose: Transform2D = game.race.sample(progress, offset)
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_normal(Vector3.UP)
		for segment in range(32):
			for vertex in range(3):
				var angle := (segment + vertex - 1) * TAU / 32
				var edge := Vector2.ZERO if vertex == 0 else Vector2(cos(angle) * 1.05, sin(angle) * 0.7) * (1 + sin(angle * 3) * 0.08)
				var p: Vector2 = pose.origin + Vector2(-pose.x.y, pose.x.x) * edge.x + pose.x * edge.y
				surface.add_vertex(game.forest.point(p.x, p.y) + Vector3.UP * 0.025)
		var water: MeshInstance3D = game._mesh(surface.commit(), Vector3.ZERO, "66c6d4", self)
		water.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
		water.material_override.roughness = 0.15
		for reflection in range(2):
			var p: Vector2 = pose.origin + pose.x * (reflection * 0.3 - 0.15)
			var shine: MeshInstance3D = game._sphere(game.forest.point(p.x, p.y) + Vector3.UP * 0.04, Vector3(0.25, 0.008, 0.04), "c8eef0", self)
			shine.rotation.y = atan2(-pose.x.x, -pose.x.y)
		puddles.append({"distance": progress, "pose": pose, "player_splashed": false, "friend_splashed": false})
	for runner in range(2):
		var splash := Node3D.new()
		add_child(splash)
		for drop in range(8):
			game._sphere(Vector3.ZERO, Vector3.ONE * 0.055, "d4f7f4" if drop % 2 else "64cfe0", splash)
		splashes.append({"node": splash, "origin": Vector3.ZERO, "age": SPLASH_DURATION})
	for index in range(8):
		_create_bird(index)
	for index in range(6):
		_create_spectator(index)
	reset()

func _create_bird(index: int) -> void:
	var bird := Node3D.new()
	add_child(bird)
	var color := "eaf2e8" if game.race.track_id == "beach" else "82b9c9"
	game._sphere(Vector3.ZERO, Vector3(0.13, 0.12, 0.23), color, bird)
	game._sphere(Vector3(0, 0.08, -0.19), Vector3.ONE * 0.10, color, bird)
	game._sphere(Vector3(0, 0.06, -0.30), Vector3(0.045, 0.04, 0.10), "eab85b", bird)
	for side in [-1, 1]:
		game._sphere(Vector3(side * 0.085, 0.11, -0.23), Vector3.ONE * 0.018, "31454a", bird)
		var wing := Node3D.new()
		wing.name = "LeftWing" if side < 0 else "RightWing"
		bird.add_child(wing)
		game._sphere(Vector3(side * 0.22, 0, 0.025), Vector3(0.28, 0.035, 0.12), color, wing)
	var pose: Transform2D = game.race.sample(8 + game.race.length * (index / 2) / 4)
	birds.append({"node": bird, "anchor": pose.origin, "phase": index * 1.7, "sung": false})

func _create_spectator(index: int) -> void:
	var progress: float = 8 + game.race.length * (index / 2) / 3
	var side := -1 if index % 2 == 0 else 1
	var pose: Transform2D
	for attempt in range(12):
		pose = game.race.sample(progress + attempt * 0.6, side * 3.65)
		if not game.forest.trees.any(func(tree): return tree.position.distance_to(pose.origin) < tree.trunk_radius + 0.8):
			break
	var spectator := Node3D.new()
	add_child(spectator)
	spectator.position = game.forest.point(pose.origin.x, pose.origin.y)
	var toward: Vector2 = game.race.sample(progress).origin - pose.origin
	spectator.rotation.y = atan2(-toward.x, -toward.y)
	var species: String = ["triceratops", "trex", "raptor"][index % 3]
	var model := preload("res://runner_model.gd").create(species)
	spectator.add_child(model)
	model.scale = Vector3.ONE * (0.60 + (index % 2) * 0.08)
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var animation: AnimationPlayer = model.get_node("AnimationPlayer")
	animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	animation.play("idle")
	var flag := Node3D.new()
	spectator.add_child(flag)
	flag.position = Vector3(0.4, 0.5, 0)
	game._box(Vector3(0.035, 0.9, 0.035), Vector3(0, 0.45, 0), "b58a59", flag)
	game._box(Vector3(0.42, 0.28, 0.035), Vector3(0.20, 0.78, 0), "e89aab" if index % 2 else "8ed6c4", flag)
	spectators.append({"node": spectator, "base": spectator.position, "animation": animation, "flag": flag, "cheered": false})

func reset() -> void:
	elapsed = 0
	for puddle in puddles:
		puddle.player_splashed = false
		puddle.friend_splashed = false
	for splash in splashes:
		splash.age = SPLASH_DURATION
		splash.node.visible = false
	for bird in birds:
		bird.sung = false
	for spectator in spectators:
		spectator.cheered = false
		spectator.animation.seek(0, true)
	_update_animals(0)

func advance(delta: float, previous: Vector3, rival_previous: Vector3) -> void:
	if game.race.paused:
		return
	elapsed += delta
	_update_animals(delta)
	if game.race.stage == "racing" or game.race.stage == "finished":
		for index in range(2):
			var runner: Node3D = game.dinosaur if index == 0 else game.friend
			var before := previous if index == 0 else rival_previous
			if before.distance_squared_to(runner.position) < 0.000001:
				continue
			for puddle in puddles:
				var key := "player_splashed" if index == 0 else "friend_splashed"
				if not puddle[key] and _crossed_puddle(puddle.pose, before, runner.position):
					puddle[key] = true
					splashes[index].age = 0.0
					splashes[index].origin = runner.position
					if index == 0 or game.dinosaur.position.distance_to(runner.position) < 8:
						game._notify({"type": "park-sound", "name": "splash"})
	for splash in splashes:
		splash.age = minf(SPLASH_DURATION, splash.age + delta)
		splash.node.visible = splash.age < SPLASH_DURATION
		for index in range(splash.node.get_child_count()):
			var angle := index * TAU / 8
			var radius: float = 0.12 + splash.age * 1.6
			var p: Vector3 = splash.origin + Vector3(cos(angle), 0, sin(angle)) * radius
			p.y = game.forest.height_at(p.x, p.z) + maxf(0.03, 0.08 + splash.age * 3 - 4.8 * splash.age * splash.age)
			var drop: Node3D = splash.node.get_child(index)
			drop.position = p
			drop.scale = Vector3.ONE * 0.065 * (1 - splash.age / SPLASH_DURATION * 0.7)

func _crossed_puddle(pose: Transform2D, before: Vector3, after: Vector3) -> bool:
	var side := Vector2(-pose.x.y, pose.x.x)
	var a := Vector2(before.x, before.z) - pose.origin
	var b := Vector2(after.x, after.z) - pose.origin
	a = Vector2(a.dot(side) / 1.05, a.dot(pose.x) / 0.7)
	b = Vector2(b.dot(side) / 1.05, b.dot(pose.x) / 0.7)
	var motion := b - a
	var closest := a.lerp(b, clampf(-a.dot(motion) / motion.length_squared(), 0, 1)) if motion.length_squared() > 0 else a
	return closest.length_squared() <= 1

func _update_animals(delta: float) -> void:
	var active: bool = game.race.stage in ["racing", "finished"]
	for bird in birds:
		var phase: float = elapsed * 0.7 + bird.phase
		var p: Vector2 = bird.anchor + Vector2(sin(phase) * 2.8, cos(phase) * 1.4)
		bird.node.position = game.forest.point(p.x, p.y) + Vector3.UP * (2.3 + sin(phase * 2) * 0.25)
		bird.node.rotation.y = atan2(-cos(phase) * 2.8, sin(phase) * 1.4)
		bird.node.get_node("LeftWing").rotation.z = sin(elapsed * 12 + bird.phase) * 0.65
		bird.node.get_node("RightWing").rotation.z = -sin(elapsed * 12 + bird.phase) * 0.65
		if active and not bird.sung and bird.node.position.distance_to(game.dinosaur.position) < 7:
			bird.sung = true
			if birds.find(bird) % 2 == 0:
				game._notify({"type": "park-sound", "name": "bird"})
	for index in range(spectators.size()):
		var spectator: Dictionary = spectators[index]
		var nearby: float = minf(spectator.base.distance_to(game.dinosaur.position), spectator.base.distance_to(game.friend.position))
		var excitement := (1 - smoothstep(4, 9, nearby)) if active else 0.0
		if game.race.stage == "finished":
			excitement = 1
		spectator.node.position = spectator.base + Vector3.UP * absf(sin(elapsed * 8 + index)) * 0.25 * excitement
		spectator.node.rotation.z = sin(elapsed * 5 + index) * 0.09 * excitement
		spectator.flag.rotation.z = sin(elapsed * 7 + index) * 0.3 * excitement
		spectator.animation.advance(delta)
		if active and not spectator.cheered and spectator.base.distance_to(game.dinosaur.position) < 7:
			spectator.cheered = true
			if index % 2 == 0:
				game._notify({"type": "park-sound", "name": "cheer"})

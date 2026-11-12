extends Node3D

const HOME := Vector2(8.4, -12.6)
const PATROL := [Vector2(8.4, -12.6), Vector2(8.0, -10.4), Vector2(4.0, -10.2), Vector2(3.5, -13.4)]
const MODEL_SCALE := 0.78

var game: Node3D
var player: AnimationPlayer
var stage := "patrol"
var elapsed := 0.0
var route := PackedVector3Array()
var patrol_index := 1
var rest := 1.2
var armed := true
var cooldown := 0.0
var repath := 0.0
var follow_side := 1.0

func setup(park: Node3D) -> void:
	game = park
	scale = Vector3.ONE * MODEL_SCALE
	var model := preload("res://assets/triceratops.glb").instantiate()
	add_child(model)
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		for surface in range(mesh.mesh.get_surface_count()):
			var material = mesh.get_active_material(surface).duplicate()
			if material is StandardMaterial3D:
				material.albedo_color = Color(0.55, 1.0, 0.8)
			mesh.set_surface_override_material(surface, material)
	player = model.get_node("AnimationPlayer")
	var hello := player.get_animation("idle").duplicate() as Animation
	hello.loop_mode = Animation.LOOP_NONE
	hello.length = 1.4
	for track in range(hello.get_track_count()):
		if str(hello.track_get_path(track)).ends_with(":Head"):
			for key in range(hello.track_get_key_count(track)):
				var time := hello.track_get_key_time(track, key)
				hello.track_set_key_value(track, key, Quaternion(Vector3.RIGHT, sin(time * TAU * 1.5) * 0.18))
	var library := AnimationLibrary.new()
	library.add_animation("hello", hello)
	player.add_animation_library("companion", library)
	reset()

func reset() -> void:
	position = game.forest.point(HOME.x, HOME.y)
	rotation = Vector3(0, PI / 4, 0)
	stage = "patrol"
	elapsed = 0
	route.clear()
	patrol_index = 1
	rest = 1.2
	armed = true
	cooldown = 0
	repath = 0
	follow_side = 1
	player.speed_scale = 1
	player.play("idle", 0)
	player.seek(0, true)

func _enter(next_stage: String, message: String) -> void:
	stage = next_stage
	elapsed = 0
	route.clear()
	repath = 0
	if not game.feeding.active():
		game._notify({"type": "park-companion", "stage": stage, "message": message})

func _return_home() -> void:
	_enter("returning", "Seu amigo vai continuar brincando no prado.")
	route = game.forest.route(position, game.forest.point(HOME.x, HOME.y))

func _make_space(delta: float) -> void:
	var away := Vector2(position.x - game.dinosaur.position.x, position.z - game.dinosaur.position.z)
	if away.length() >= 1.5:
		return
	var distance := minf(1.5 - away.length(), minf(delta, 0.5) * 1.6)
	var direction := away.normalized() if away.length() > 0.01 else Vector2(game.dinosaur.basis.x.x, game.dinosaur.basis.x.z)
	for side in [direction, Vector2(-direction.y, direction.x), Vector2(direction.y, -direction.x)]:
		var p: Vector2 = Vector2(position.x, position.z) + side * distance
		var candidate: Vector3 = game.forest.point(p.x, p.y)
		if game.forest.clear_segment(position, candidate):
			position = candidate
			return

func _side_route(destination: Vector3) -> PackedVector3Array:
	var origin := Vector2(position.x, position.z)
	var center := Vector2(game.dinosaur.position.x, game.dinosaur.position.z)
	var end := Vector2(destination.x, destination.z)
	var segment := end - origin
	var t := clampf((center - origin).dot(segment) / maxf(segment.length_squared(), 0.0001), 0, 1)
	if center.distance_to(origin + segment * t) < 1.55:
		var offset := origin - center
		var angle := offset.angle()
		if offset.length() >= 2.0:
			angle = rotate_toward(angle, (end - center).angle(), PI / 3)
		var p := center + Vector2(cos(angle), sin(angle)) * 2.3
		destination = game.forest.point(p.x, p.y)
	return game.forest.route(position, destination)

func _walk(delta: float, speed: float) -> void:
	var budget := minf(delta, 0.5) * speed
	while budget > 0 and not route.is_empty():
		var candidate := position.move_toward(route[0], budget)
		if candidate.distance_to(game.dinosaur.position) < 1.5 or not game.forest.clear_segment(position, candidate):
			route.clear()
			return
		var direction := candidate - position
		if direction.length() > 0.001:
			rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(delta * 6, 1))
		var distance := position.distance_to(candidate)
		position = game.forest.point(candidate.x, candidate.z)
		budget -= distance
		if position.distance_to(route[0]) < 0.02:
			route.remove_at(0)
		else:
			return

func advance(delta: float) -> void:
	var previous_position := position
	var previous_elapsed := elapsed
	elapsed += delta
	cooldown = maxf(0, cooldown - delta)
	repath = maxf(0, repath - delta)
	var distance_to_player := position.distance_to(game.dinosaur.position)
	if distance_to_player > 4.5:
		armed = true
	_make_space(delta)
	match stage:
		"patrol":
			if armed and cooldown <= 0 and distance_to_player < 3.0 and not game.feeding.active():
				armed = false
				follow_side = -1.0 if (position - game.dinosaur.position).dot(game.dinosaur.basis.x) < 0 else 1.0
				_enter("approaching", "Olha! Um novo amigo veio dizer olá.")
				player.speed_scale = 1
				player.play("idle", 0.15)
			else:
				rest = maxf(0, rest - delta)
				if rest <= 0:
					if route.is_empty():
						var p: Vector2 = PATROL[patrol_index]
						route = game.forest.route(position, game.forest.point(p.x, p.y))
						patrol_index = (patrol_index + 1) % PATROL.size()
					_walk(delta, 0.65)
					if route.is_empty():
						rest = 1.2
		"approaching":
			var lateral: float = absf((position - game.dinosaur.position).dot(game.dinosaur.basis.x))
			if distance_to_player > 5.0 or game.feeding.active():
				_return_home()
			elif elapsed >= 2.5 or (lateral >= 1.35 and elapsed >= 0.4):
				_enter("greeting", "Olá, amiguinho!")
				player.speed_scale = 1
				player.play("idle", 0.15)
			elif lateral < 1.35:
				if repath <= 0:
					var p: Vector3 = game.dinosaur.position + game.dinosaur.basis.x * 2.1 * follow_side
					route = _side_route(game.forest.point(p.x, p.z))
					repath = 0.65
				_walk(delta, 0.9)

		"greeting":
			var direction: Vector3 = game.dinosaur.position - position
			rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(delta * 6, 1))
			if distance_to_player > 5.0 or game.feeding.active():
				_return_home()
			elif previous_elapsed < 0.4 and elapsed >= 0.4:
				player.play("companion/hello", 0.15)
				game._notify({"type": "park-sound", "name": "happy"})
			elif elapsed >= 1.8:
				follow_side = -1.0 if (position - game.dinosaur.position).dot(game.dinosaur.basis.x) < 0 else 1.0
				_enter("following", "Vamos passear juntos por um pouquinho!")
		"following":
			var home: Vector3 = game.forest.point(HOME.x, HOME.y)
			if elapsed >= 8.0 or position.distance_to(home) > 7.0 or game.dinosaur.position.distance_to(home) > 9.0 or game.feeding.active():
				_return_home()
			else:
				if repath <= 0:
					var lateral: float = (position - game.dinosaur.position).dot(game.dinosaur.basis.x)
					if absf(lateral) > 0.3:
						follow_side = signf(lateral)
					var p: Vector3 = game.dinosaur.position + game.dinosaur.basis.x * 1.7 * follow_side - game.dinosaur.basis.z * 0.3
					route = _side_route(game.forest.point(p.x, p.z))
					repath = 0.65
				_walk(delta, 1.3)
		"returning":
			var home: Vector3 = game.forest.point(HOME.x, HOME.y)
			if position.distance_to(home) < 0.08 or (game.dinosaur.position.distance_to(home) < 2.0 and position.distance_to(home) < 2.0):
				stage = "patrol"
				elapsed = 0
				route.clear()
				rest = 1.2
				cooldown = 3.0
			elif route.is_empty() and repath <= 0:
				route = game.forest.route(position, home)
				repath = 0.65
			_walk(delta, 0.8)
	if stage != "greeting":
		var distance := previous_position.distance_to(position)
		player.play("walk" if distance > 0.001 else "idle", 0.15)
		player.speed_scale = distance / maxf(delta * game.WALK_SPEED * MODEL_SCALE, 0.0001) if distance > 0.001 else 1.0

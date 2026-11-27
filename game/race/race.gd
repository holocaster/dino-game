extends "res://common/dino_scene.gd"

const RUN_CYCLE_DISTANCE := 0.52 / 0.6
const RUN_SPEED := RUN_CYCLE_DISTANCE / 0.8

var race := preload("res://race/race_state.gd").new()
var fruit_nodes: Array[Node3D] = []
var arrow_nodes: Array[Node3D] = []
var recovery_node: Area3D
var left_pressed := false
var right_pressed := false
var input_sources: Dictionary = {}
var report_elapsed := 0.0
var player_contacts: Array[Node3D] = []
var rival_contacts: Array[Node3D] = []
var rival_runout := 0.0
var scenery: Node3D
var speed_effects: Node3D
var base_fov := 48.0

const FOV_RUSH := 8.0

const TINT_SHADER := preload("res://dinos/dino_tint.gdshader")
const RIVAL_COLORS := {"sleepy": Color(0.72, 0.66, 1.0), "playful": Color(0.5, 0.9, 0.55), "speedy": Color(1.0, 0.85, 0.3)}
const PLAYER_COLORS := {"natural": Color.WHITE, "sunset": Color(1.0, 0.5, 0.38), "ocean": Color(0.42, 0.68, 1.0), "candy": Color(1.0, 0.58, 0.85)}

func _ready() -> void:
	var started_at := Time.get_ticks_usec()
	var selection: Array = get_tree().get_meta("race_selection", ["triceratops", "forest"])
	if OS.has_feature("web") and not get_tree().has_meta("race_selection"):
		var pending: Variant = JSON.parse_string(JavaScriptBridge.eval("window.frameElement?.dataset.raceSelection || 'null'", true))
		if pending is Array and pending.size() in [3, 4] and pending.all(func(value): return value is String):
			selection = pending
	if not _configure_selection(selection):
		race.configure("triceratops", "forest")
	var appearance := _appearance(1).duplicate()
	appearance.species = race.dino_id
	appearance.color = get_tree().get_meta("race_color", "natural")
	get_tree().set_meta("race_appearances", [appearance, _appearance(2).duplicate()])
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("cdeef0") if race.track_id == "beach" else Color("e8f2ed")
	if race.track_id == "volcano":
		environment.background_color = Color("f2d4ba")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("f4f2df")
	environment.ambient_light_energy = 0.4
	if race.track_id == "forest":
		environment.background_color = Color("bdddde")
		environment.ambient_light_color = Color("dce9f0")
		environment.ambient_light_energy = 0.55
	elif race.track_id == "beach":
		environment.background_color = Color("b7dce6")
		environment.ambient_light_color = Color("e4ece7")
		environment.ambient_light_energy = 0.50
	elif race.track_id == "valley":
		environment.background_color = Color("c7dfda")
		environment.ambient_light_color = Color("dfe9ee")
		environment.ambient_light_energy = 0.52
	elif race.track_id == "volcano":
		environment.background_color = Color("ead5c5")
		environment.ambient_light_color = Color("eadbce")
		environment.ambient_light_energy = 0.55
	elif race.track_id == "cave":
		environment.background_color = Color("e1ece8")
		environment.ambient_light_color = Color("eee6f2")
		environment.ambient_light_energy = 0.72
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -30, 0)
	light.light_color = Color("fff3db")
	light.light_energy = 0.8
	light.shadow_enabled = true
	light.shadow_opacity = 0.82
	light.shadow_blur = 1.5
	light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	light.directional_shadow_blend_splits = true
	light.directional_shadow_max_distance = 28
	add_child(light)
	camera = Camera3D.new()
	add_child(camera)
	camera.current = true
	_fit_camera()
	get_viewport().size_changed.connect(_fit_camera)
	forest = preload("res://world/forest.gd").new()
	forest.race_track = race.track
	forest.theme = race.track_id
	if race.track_id in ["forest", "beach", "valley"]:
		forest.race_terrain = load("res://world/%s_terrain.res" % race.track_id)
	if race.track_id in ["forest", "valley"]:
		forest.load_race_tree_meshes()
	add_child(forest)
	_create_runners()
	for index in range(race.fruits.size()):
		fruit_nodes.append(_create_fruit("e88a63"))
	for arrow in race.arrows:
		arrow_nodes.append(_create_arrow())
	recovery_node = _create_fruit("ffd34e")
	var golden_material: StandardMaterial3D = recovery_node.get_child(0).material_override
	golden_material.emission_enabled = true
	golden_material.emission = Color("b38319")
	_decorate_track()
	_track_boundaries()
	scenery = preload("res://race/race_scenery.gd").new()
	add_child(scenery)
	scenery.setup(self)
	race.resolve_motion = _resolve_motion
	race.pickup_contact = _pickup_contact
	if OS.has_feature("web"):
		web_callback = JavaScriptBridge.create_callback(_web_command)
		JavaScriptBridge.get_interface("window").parkCommand = web_callback
	reset_race()
	_notify_ready(started_at)
	set_process(false)
	set_physics_process(true)

func _configure_selection(selection: Array) -> bool:
	if selection.size() == 4 and selection[2] == "coop":
		return race.configure_coop(selection[0], selection[3], selection[1])
	return race.configure(selection[0], selection[1], selection[2] if selection.size() > 2 else "playful")

func _notify_ready(started_at: int) -> void:
	_notify({"type": "park-ready", "track": race.track_id, "rival": "coop" if race.mode == "coop" else race.rival_id, "setupMs": (Time.get_ticks_usec() - started_at) / 1000.0})

func _create_fruit(color: String) -> Area3D:
	var holder := Area3D.new()
	holder.collision_layer = 4
	holder.collision_mask = 0
	holder.monitoring = false
	add_child(holder)
	_sphere(Vector3(0, 0.42, 0), Vector3.ONE * 0.27, color, holder)
	_sphere(Vector3(0.10, 0.68, 0), Vector3(0.15, 0.04, 0.08), "588c43", holder)
	var shape := CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	shape.shape.radius = 0.32
	shape.position.y = 0.42
	holder.add_child(shape)
	return holder

func _create_arrow() -> Node3D:
	var holder := Node3D.new()
	add_child(holder)
	for tip in [-0.35, 0.25]:
		for side in [-1, 1]:
			var arm := _box(Vector3(0.14, 0.03, 0.6), Vector3(side * 0.2, 0.04, tip + 0.2), "f6b93b", holder)
			arm.rotation.y = side * PI / 4
	return holder

func _create_runners() -> void:
	dinosaur = _runner(false)
	friend = _runner(true)
	dinosaur_animation = dinosaur.get_node("Model/AnimationPlayer")
	friend_animation = friend.get_node("Model/AnimationPlayer")
	_tint(dinosaur, PLAYER_COLORS.get(get_tree().get_meta("race_color", "natural"), Color.WHITE))
	if race.solo:
		friend.visible = false
		friend.collision_layer = 0
		friend.collision_mask = 0
	speed_effects = preload("res://race/speed_effects.gd").new()
	add_child(speed_effects)
	speed_effects.setup(self)
	speed_effects.paint(0, _trail_color())
	if race.mode == "coop":
		speed_effects.paint(1, _partner_trail_color())

func _runner(green: bool) -> Node3D:
	var runner := CharacterBody3D.new()
	runner.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	runner.collision_layer = 1
	runner.collision_mask = 3
	add_child(runner)
	var partner: bool = green and race.mode == "coop"
	var species: String = race.partner_id if partner else ("triceratops" if green else race.dino_id)
	var model := preload("res://dinos/runner_model.gd").create(species, _appearance(2 if green else 1).accessory if not green or partner else "none")
	model.name = "Model"
	runner.add_child(model)
	model.get_node("AnimationPlayer").callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	var model_scale := 0.86 if green and not partner else 1.0
	model.scale = Vector3.ONE * model_scale
	var shape := CollisionShape3D.new()
	shape.name = "BodyShape"
	shape.shape = CapsuleShape3D.new()
	shape.shape.radius = 0.48 * model_scale
	shape.shape.height = 2.1 * model_scale
	shape.rotation.x = PI / 2
	shape.position = Vector3(0, 0.6, 0.08) * model_scale
	runner.add_child(shape)
	if green:
		_tint(runner, PLAYER_COLORS[_appearance(2).color] if partner else RIVAL_COLORS.get(race.rival_id, RIVAL_COLORS.playful))
	if race.mode == "coop":
		var label := Label3D.new()
		label.name = "PlayerLabel"
		label.text = "Jogador 2" if green else "Jogador 1"
		label.position.y = 2.35 if species == "pteranodon" else 1.9
		label.font_size = 40
		label.pixel_size = 0.005
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		runner.add_child(label)
	var glow := Node3D.new()
	glow.name = "RecoveryGlow"
	runner.add_child(glow)
	for index in range(5):
		var angle := index * TAU / 5
		var sparkle := _sphere(Vector3(cos(angle) * 0.85, 0.8 + sin(angle * 2) * 0.25, sin(angle) * 0.85), Vector3.ONE * 0.055, "ffe095", glow)
		sparkle.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return runner

func _trail_color() -> Color:
	var tint: Color = PLAYER_COLORS.get(get_tree().get_meta("race_color", "natural"), Color.WHITE)
	return speed_effects.DINO_COLORS.get(race.dino_id, Color.WHITE) if tint == Color.WHITE else tint

func _partner_trail_color() -> Color:
	var tint: Color = PLAYER_COLORS[_appearance(2).color]
	return speed_effects.DINO_COLORS[race.partner_id] if tint == Color.WHITE else tint

func _tint(runner: Node3D, color: Color) -> void:
	for mesh in runner.get_node("Model").find_children("*", "MeshInstance3D", true, false):
		if mesh.skin == null:
			continue
		for surface in range(mesh.mesh.get_surface_count()):
			var material: ShaderMaterial = null
			if color != Color.WHITE:
				material = ShaderMaterial.new()
				material.shader = TINT_SHADER
				material.set_shader_parameter("albedo_texture", mesh.mesh.surface_get_material(surface).albedo_texture)
				material.set_shader_parameter("tint", color)
			mesh.set_surface_override_material(surface, material)

func _track_boundaries() -> void:
	var boundary := StaticBody3D.new()
	boundary.collision_layer = 2
	boundary.collision_mask = 0
	add_child(boundary)
	var segments := maxi(96, ceili(race.lap_length))
	for side in [-1, 1]:
		for index in range(segments):
			var a: Vector2 = race.sample(race.lap_length * index / segments, side * race.TRACK_WIDTH).origin
			var b: Vector2 = race.sample(race.lap_length * (index + 1) / segments, side * race.TRACK_WIDTH).origin
			var center := (a + b) * 0.5
			var shape := CollisionShape3D.new()
			shape.shape = BoxShape3D.new()
			shape.shape.size = Vector3(0.12, 2.4, a.distance_to(b) + 0.15)
			shape.position = forest.point(center.x, center.y) + Vector3.UP * 0.8
			shape.rotation.y = atan2(b.x - a.x, b.y - a.y)
			boundary.add_child(shape)

func _move_runner(runner: CharacterBody3D, progress: float, offset: float, delta: float) -> void:
	var pose: Transform2D = race.sample(progress, offset)
	var destination: Vector3 = forest.point(pose.origin.x, pose.origin.y)
	var motion := destination - runner.position
	var heading := atan2(-pose.x.x, -pose.x.y)
	if runner == friend and Vector2(motion.x, motion.z).length() > 0.001:
		heading = atan2(-motion.x, -motion.z)
	runner.rotation.y = lerp_angle(runner.rotation.y, heading, 1 - exp(-delta * 7))
	for slide in range(3):
		var contact := runner.move_and_collide(motion, false, 0.002, true, 4)
		runner.position.y = forest.height_at(runner.position.x, runner.position.z)
		if contact == null:
			break
		var normal := contact.get_normal()
		normal.y = 0
		if normal.length() < 0.001:
			break
		motion = contact.get_remainder().slide(normal.normalized())
		motion.y = forest.height_at(runner.position.x + motion.x, runner.position.z + motion.z) - runner.position.y
		if motion.length() < 0.00001:
			break

func _track_coordinates(runner: Node3D, previous: float) -> Vector2:
	var p := Vector2(runner.position.x, runner.position.z)
	var requested: float = race.distance if runner == dinosaur else race.rival_distance
	if requested == race.length and previous < race.length:
		var offset: float = race.lateral if runner == dinosaur else race.rival_lateral
		if p.is_equal_approx(race.sample(race.length, offset).origin):
			return Vector2(race.length, offset)
	var progress: float = race.track.get_closest_offset(p)
	progress += roundf((previous - progress) / race.lap_length) * race.lap_length
	var pose: Transform2D = race.sample(progress)
	return Vector2(progress, (p - pose.origin).dot(Vector2(-pose.x.y, pose.x.x)))

func _fruit_contacts(runner: CharacterBody3D) -> Array[Node3D]:
	var shape: CollisionShape3D = runner.get_node("BodyShape")
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape.shape
	query.transform = shape.global_transform
	query.collision_mask = 4
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result: Array[Node3D] = []
	for contact in get_world_3d().direct_space_state.intersect_shape(query):
		result.append(contact.collider)
	return result

func _resolve_motion(previous: float, rival_previous: float, delta: float) -> void:
	if race.solo:
		_move_runner(dinosaur, race.distance, race.lateral, delta)
		var solo_position := _track_coordinates(dinosaur, previous)
		race.distance = clampf(solo_position.x, 0, race.length)
		race.lateral = solo_position.y
		player_contacts = _fruit_contacts(dinosaur)
		return
	if race.mode == "coop":
		if previous < race.length:
			race.distance = minf(race.distance, rival_previous + race.COOP_MAX_GAP)
			_move_runner(dinosaur, race.distance, race.lateral, delta)
			var position_1 := _track_coordinates(dinosaur, previous)
			race.distance = clampf(position_1.x, previous, race.distance)
			race.lateral = position_1.y
		if rival_previous < race.length:
			race.rival_distance = minf(race.rival_distance, previous + race.COOP_MAX_GAP)
			_move_runner(friend, race.rival_distance, race.rival_lateral, delta)
			var position_2 := _track_coordinates(friend, rival_previous)
			race.rival_distance = clampf(position_2.x, rival_previous, race.rival_distance)
			race.rival_lateral = position_2.y
		player_contacts = _fruit_contacts(dinosaur)
		rival_contacts = _fruit_contacts(friend)
		return
	var rival_goal: float = race.rival_distance
	if rival_previous >= race.length:
		rival_runout = minf(2.5, rival_runout + delta * 1.8)
		rival_goal += rival_runout
	if previous >= rival_previous:
		_move_runner(dinosaur, race.distance, race.lateral, delta)
		_move_runner(friend, rival_goal, race.rival_lateral, delta)
	else:
		_move_runner(friend, rival_goal, race.rival_lateral, delta)
		_move_runner(dinosaur, race.distance, race.lateral, delta)
	var player_position := _track_coordinates(dinosaur, previous)
	var rival_position := _track_coordinates(friend, rival_previous + rival_runout)
	race.distance = clampf(player_position.x, 0, race.length)
	race.lateral = player_position.y
	race.rival_distance = race.length if rival_previous >= race.length else clampf(rival_position.x, 0, race.length)
	race.rival_lateral = rival_position.y
	player_contacts = _fruit_contacts(dinosaur)
	rival_contacts = _fruit_contacts(friend)

func _pickup_contact(index: int, rival: bool) -> bool:
	if (race.rival_distance if rival else race.distance) >= race.length:
		return false
	var fruit: Node3D = recovery_node if index == -1 else fruit_nodes[index]
	return fruit in (rival_contacts if rival else player_contacts)

func _update_recovery_visuals() -> void:
	recovery_node.visible = not race.recovery_fruit.is_empty()
	recovery_node.collision_layer = 4 if recovery_node.visible else 0
	if recovery_node.visible:
		var pose: Transform2D = race.sample(race.recovery_fruit.distance, race.recovery_fruit.lateral)
		recovery_node.position = forest.point(pose.origin.x, pose.origin.y)
		recovery_node.get_child(0).position.y = 0.42 + sin(elapsed * 3) * 0.06
	for runner in [dinosaur, friend]:
		var glow: Node3D = runner.get_node("RecoveryGlow")
		glow.visible = (race.recovery_boost_left if runner == dinosaur else race.rival_recovery_boost_left) > 0 and race.stage == "racing"
		glow.rotation.y = elapsed * 2

func _camera_focus_point() -> Vector3:
	if race.mode == "coop":
		return dinosaur.position.lerp(friend.position, 0.5)
	if race.solo:
		return dinosaur.position
	var weight := 0.5 * (1 - smoothstep(3.0, 6.0, dinosaur.position.distance_to(friend.position)))
	return dinosaur.position.lerp(friend.position, weight)

func _update_camera(weight: float, delta: float = 1.0) -> void:
	if race.mode == "coop" and race.stage == "ready":
		var focus := _camera_focus_point() + Vector3.UP * 0.7
		var direction := Vector3(-2.8, 1.9, -3.2).rotated(Vector3.UP, dinosaur.rotation.y).normalized()
		camera.position = focus + direction * 4.5
		camera.look_at(focus)
		var size := get_viewport().get_visible_rect().size
		var vertical := tan(deg_to_rad(camera.fov * 0.5))
		var horizontal := vertical * size.x / maxf(1, size.y)
		var view_distance := 4.5
		for runner in [dinosaur, friend]:
			for mesh in runner.get_node("Model").find_children("*", "MeshInstance3D", true, false) + [runner.get_node("PlayerLabel")]:
				var bounds: AABB = mesh.get_aabb()
				for corner in range(8):
					var point: Vector3 = mesh.global_transform * bounds.get_endpoint(corner) - focus
					view_distance = maxf(view_distance, point.dot(camera.basis.z) + maxf(absf(point.dot(camera.basis.x)) / horizontal, absf(point.dot(camera.basis.y)) / vertical) * 1.12)
		camera.position = focus + direction * view_distance
		camera_yaw = atan2(direction.x, direction.z)
		camera_turn_velocity = 0
		forest.reveal_character(camera.position, focus, delta, 2.5)
	elif race.mode == "coop":
		var focus := _camera_focus_point() + Vector3.UP * 0.8
		if race.stage == "finished":
			focus = (dinosaur.position + friend.position + scenery.baby_base) / 3 + Vector3.UP * 0.8
		var radius := maxf(focus.distance_to(dinosaur.position + Vector3.UP * 0.8), focus.distance_to(friend.position + Vector3.UP * 0.8)) + 2.5
		if race.stage == "finished":
			radius = maxf(radius, focus.distance_to(scenery.baby_base) + 1.2)
		_aim_camera(focus, radius, weight, delta)
		var size := get_viewport().get_visible_rect().size
		var half_fov := deg_to_rad(camera.fov * 0.5)
		var narrow_fov := minf(half_fov, atan(tan(half_fov) * size.x / maxf(1, size.y)))
		var view_distance := maxf(7, radius / sin(narrow_fov) * 1.12)
		camera.position = focus + Vector3(0, 0.7, 1).normalized().rotated(Vector3.UP, camera_yaw) * view_distance
		camera.look_at(focus)
		forest.reveal_character(camera.position, dinosaur.position, delta, 2.5)
		forest.reveal_character(camera.position, friend.position, delta, 2.5)
	elif race.stage == "finished":
		_aim_camera(dinosaur.position.lerp(scenery.baby_base, 0.5), 2.5, weight, delta)
	elif race.stage == "ready":
		camera.position = dinosaur.position + Vector3(-2.8, 1.9, -3.2).rotated(Vector3.UP, dinosaur.rotation.y)
		camera.look_at(dinosaur.position + Vector3.UP * 0.72)
		forest.reveal_character(camera.position, dinosaur.position, delta, 0.9)
	else:
		super._update_camera(weight, delta)

	if race.track_id == "cave":
		forest.reveal_cave(camera.position, [dinosaur.position, friend.position] if race.mode == "coop" else [dinosaur.position])

func _fit_camera() -> void:
	super._fit_camera()
	var size := get_viewport().get_visible_rect().size
	if size.x < size.y:
		camera.fov = 64
	base_fov = camera.fov

func _decorate_track() -> void:
	var gate := Node3D.new()
	add_child(gate)
	var start: Transform2D = race.sample(0)
	gate.position = forest.point(start.origin.x, start.origin.y)
	for side in [-1, 1]:
		_box(Vector3(0.12, 2.6, 0.12), Vector3(side * 3.3, 1.3, 0), "b58a59", gate)
		_sphere(Vector3(side * 3.3, 2.7, 0), Vector3.ONE * 0.18, "e9b75d", gate)
		_box(Vector3(0.8, 0.5, 0.06), Vector3(side * 3.7, 2.25, 0), "df9865" if side < 0 else "719d68", gate)
	if race.track_id == "cave":
		_box(Vector3(7.0, 0.4, 0.4), Vector3(0, 4.6, 0), "b8a9ba", gate)
		for side in [-1, 1]:
			_box(Vector3(0.45, 4.6, 0.5), Vector3(side * 3.5, 2.3, 0), "b8a9ba", gate)
			_sphere(Vector3(side * 2.3, 4.6, -0.26), Vector3(0.25, 0.32, 0.12), "76cec9" if side < 0 else "c5a0df", gate)
	for row in range(2):
		for column in range(12):
			var x := start.origin.x + (column - 5.5) * 0.46
			var z := start.origin.y + row * 0.3
			_box(Vector3(0.46, 0.025, 0.3), forest.point(x, z) + Vector3.UP * 0.025, "fff4d4" if (row + column) % 2 else "7c9462").cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in range(0 if race.track_id in ["volcano", "cave"] else 40):
		if race.track_id == "forest" and i % 4 >= 2:
			continue
		var pose: Transform2D = race.sample(race.lap_length * i / 40, 6.2 if i % 2 else -6.2)
		var p := pose.origin
		if p.distance_to(forest.POND) > 3.5 and not forest.trees.any(func(tree): return tree.position.distance_to(p) < 2.5):
			forest.tree(p, 1.5 + float(i % 3) * 0.15, i, true)
	var markers := maxi(50, ceili(race.lap_length / 2))
	for i in range(markers):
		for side in [-1, 1]:
			var pose: Transform2D = race.sample(race.lap_length * i / markers, side * race.TRACK_WIDTH)
			var p: Vector3 = forest.point(pose.origin.x, pose.origin.y)
			_sphere(p + Vector3.UP * 0.06, Vector3(0.16, 0.08, 0.16), "fff0ba").cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func reset_race() -> void:
	race.reset()
	elapsed = 0
	forest.animate(0.0)
	_release_inputs()
	if race.mode == "coop":
		for runner in [dinosaur, friend]:
			runner.collision_layer = 1
			runner.collision_mask = 3
	step_distance = 0
	rival_runout = 0
	player_contacts.clear()
	rival_contacts.clear()
	for index in range(fruit_nodes.size()):
		var pose: Transform2D = race.sample(race.fruits[index].distance, race.fruits[index].lateral)
		fruit_nodes[index].position = forest.point(pose.origin.x, pose.origin.y)
		fruit_nodes[index].visible = true
	for index in range(arrow_nodes.size()):
		var pose: Transform2D = race.sample(race.arrows[index].distance, race.arrows[index].lateral)
		arrow_nodes[index].position = forest.point(pose.origin.x, pose.origin.y)
		arrow_nodes[index].rotation.y = atan2(-pose.x.x, -pose.x.y)
	_update_recovery_visuals()
	_position_runner(dinosaur, dinosaur_animation, 0, race.lateral, 0)
	_position_runner(friend, friend_animation, 0, race.rival_lateral, 0)
	travel_yaw = dinosaur.rotation.y
	camera_yaw = travel_yaw
	camera_turn_velocity = 0
	camera_focus = dinosaur.position
	camera.fov = base_fov
	_update_camera(1.0)
	scenery.reset()
	speed_effects.reset()
	_report()

func restart() -> void:
	reset_race()
	race.start()
	_report()

func _appearance(slot: int) -> Dictionary:
	var appearances: Array = get_tree().get_meta("race_appearances", [])
	if appearances.size() == 2:
		return appearances[slot - 1]
	return {"species": race.dino_id if slot == 1 else "trex", "color": get_tree().get_meta("race_color", "natural") if slot == 1 else "natural", "accessory": "none"}

func _apply_appearance(slot: int, appearance: Dictionary) -> void:
	var appearances := [_appearance(1).duplicate(), _appearance(2).duplicate()]
	var changed_species: bool = appearance.species != (race.dino_id if slot == 1 else race.partner_id)
	if appearances[slot - 1] == appearance and not changed_species:
		return
	appearances[slot - 1] = appearance
	get_tree().set_meta("race_appearances", appearances)
	if slot == 2 and race.mode != "coop":
		return
	var runner: Node3D = dinosaur if slot == 1 else friend
	if slot == 1:
		get_tree().set_meta("race_color", appearance.color)
	if changed_species:
		if race.mode == "coop":
			race.configure_coop(appearances[0].species, appearances[1].species, race.track_id)
			get_tree().set_meta("race_selection", [race.dino_id, race.track_id, "coop", race.partner_id])
		else:
			race.configure(appearance.species, race.track_id, race.rival_id)
			get_tree().set_meta("race_selection", [race.dino_id, race.track_id, race.rival_id])
	var old_model := runner.get_node("Model")
	runner.remove_child(old_model)
	old_model.queue_free()
	var model := preload("res://dinos/runner_model.gd").create(appearance.species, appearance.accessory)
	model.name = "Model"
	runner.add_child(model)
	var animation: AnimationPlayer = model.get_node("AnimationPlayer")
	if runner.has_node("PlayerLabel"):
		runner.get_node("PlayerLabel").position.y = 2.35 if appearance.species == "pteranodon" else 1.9
	animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	if slot == 1:
		dinosaur_animation = animation
	else:
		friend_animation = animation
	_tint(runner, PLAYER_COLORS[appearance.color])
	speed_effects.paint(slot - 1, _trail_color() if slot == 1 else _partner_trail_color())
	if changed_species:
		reset_race()
	else:
		_animate_runner(runner, animation, 0)
		_report()

func _release_inputs() -> void:
	left_pressed = false
	right_pressed = false
	input_sources.clear()

func _steering(slot: int) -> float:
	var left := left_pressed if slot == 1 else false
	var right := right_pressed if slot == 1 else false
	for source in input_sources.values():
		if source.slot == slot:
			left = left or source.direction == "left"
			right = right or source.direction == "right"
	return float(right) - float(left)

func _select_race(selection: Array) -> void:
	if selection[1] == race.track_id:
		var started_at := Time.get_ticks_usec()
		_configure_selection(selection)
		get_tree().set_meta("race_selection", selection)
		for node in [dinosaur, friend, speed_effects]:
			remove_child(node)
			node.queue_free()
		_create_runners()
		reset_race()
		_notify_ready(started_at)
		return
	var previous: Array = get_tree().get_meta("race_selection", ["triceratops", "forest"])
	get_tree().set_meta("race_selection", selection)
	if get_tree().reload_current_scene() != OK:
		get_tree().set_meta("race_selection", previous)
		_notify({"type": "park-error"})

func _web_command(arguments: Array) -> void:
	if arguments.size() != 1 or not arguments[0] is String:
		return
	if arguments[0].begins_with("input:"):
		var values: PackedStringArray = arguments[0].split(":")
		if values.size() != 5 or values[1] not in ["1", "2"] or values[2] not in ["left", "right"] or values[3] not in ["down", "up"] or values[4] not in ["page", "frame"] or (values[1] == "2" and race.mode != "coop"):
			return
		var key := "%s:%s:%s" % [values[1], values[2], values[4]]
		if values[3] == "up":
			input_sources.erase(key)
		elif race.stage == "racing" and not race.paused:
			input_sources[key] = {"slot": int(values[1]), "direction": values[2]}
		return
	if arguments[0].begins_with("select-coop:"):
		var values: PackedStringArray = arguments[0].split(":")
		if values.size() != 4 or not race.can_configure_coop(values[1], values[2], values[3]):
			return
		_release_inputs()
		_select_race([values[1], values[3], "coop", values[2]])
		return
	if arguments[0].begins_with("appearance:"):
		var values: PackedStringArray = arguments[0].split(":")
		if values.size() != 5 or values[1] not in ["1", "2"] or not race.DINOS.has(values[2]) or not PLAYER_COLORS.has(values[3]) or values[4] not in preload("res://dinos/runner_model.gd").ACCESSORIES or race.stage not in ["ready", "finished"]:
			return
		_apply_appearance(int(values[1]), {"species": values[2], "color": values[3], "accessory": values[4]})
		return
	if arguments[0].begins_with("color:"):
		var color: String = arguments[0].substr(6)
		if PLAYER_COLORS.has(color):
			var appearance := _appearance(1).duplicate()
			appearance.color = color
			get_tree().set_meta("race_appearances", [appearance, _appearance(2).duplicate()])
			get_tree().set_meta("race_color", color)
			_tint(dinosaur, PLAYER_COLORS[color])
			speed_effects.paint(0, _trail_color())
		return
	if arguments[0].begins_with("select:"):
		var selection: PackedStringArray = arguments[0].split(":")
		if selection.size() != 4 or not race.can_configure(selection[1], selection[2], selection[3]):
			return
		_select_race([selection[1], selection[2], selection[3]])
		return
	match arguments[0]:
		"start": race.start()
		"restart": restart()
		"menu":
			if race.paused or race.stage == "finished":
				reset_race()
		"left-down": left_pressed = race.stage in ["countdown", "racing"] and not race.paused
		"left-up": left_pressed = false
		"right-down": right_pressed = race.stage in ["countdown", "racing"] and not race.paused
		"right-up": right_pressed = false
		"release": _release_inputs()
		"pause":
			if race.stage in ["countdown", "racing"]:
				race.paused = true
			_release_inputs()
		"resume": race.paused = false
	_report()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		if race.mode != "coop" and event.keycode in [KEY_LEFT, KEY_RIGHT]:
			if event.keycode == KEY_LEFT:
				left_pressed = event.pressed and race.stage in ["countdown", "racing"] and not race.paused
			else:
				right_pressed = event.pressed and race.stage in ["countdown", "racing"] and not race.paused
			return
		var slot := 2 if race.mode == "coop" and event.keycode in [KEY_LEFT, KEY_RIGHT] else 1
		if event.keycode in ([KEY_A, KEY_D, KEY_LEFT, KEY_RIGHT] if race.mode == "coop" else [KEY_LEFT, KEY_RIGHT]):
			var key := "native:%s" % event.keycode
			if not event.pressed:
				input_sources.erase(key)
			elif race.stage == "racing" and not race.paused:
				input_sources[key] = {"slot": slot, "direction": "left" if event.keycode in [KEY_A, KEY_LEFT] else "right"}
		elif event.keycode == KEY_ESCAPE and event.pressed:
			_web_command(["resume" if race.paused else "pause"])

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and not OS.has_feature("web"):
		_web_command(["pause"])

func _position_runner(runner: Node3D, animation: AnimationPlayer, progress: float, offset: float, speed: float) -> void:
	var pose: Transform2D = race.sample(progress, offset)
	runner.position = forest.point(pose.origin.x, pose.origin.y)
	runner.rotation.y = atan2(-pose.x.x, -pose.x.y)
	runner.get_node("Model").rotation.y = 0
	_animate_runner(runner, animation, speed)

func _animate_runner(runner: Node3D, animation: AnimationPlayer, speed: float) -> void:
	animation.play("run" if speed > 0 else "idle", 0.2)
	var model: Node3D = runner.get_node("Model")
	var cycle_distance: float = model.get_meta("run_cycle_distance", RUN_CYCLE_DISTANCE)
	animation.speed_scale = speed / (cycle_distance / 0.8 * model.scale.x) if speed > 0 else 1.0
	if model.get_meta("flying", false):
		animation.speed_scale = clampf(speed / race.BASE_SPEED, 0.8, 1.6) if speed > 0 else 1.0
	if race.paused:
		animation.speed_scale = 0

func _physics_process(delta: float) -> void:
	_process(delta)

func _process(delta: float) -> void:
	if dinosaur == null:
		return
	var frame_delta := maxf(delta, 0.000001)
	delta = minf(delta, 0.1)
	var previous := dinosaur.position
	var previous_rival_position := friend.position
	var previous_rival_yaw: float = friend.rotation.y + friend.get_node("Model").rotation.y
	var collected: int = race.total_collected
	var arrows_taken: int = race.arrows_taken
	var stage: String = race.stage
	race.advance(delta, _steering(1), _steering(2))
	if race.mode == "coop":
		for index in range(2):
			var progress: float = race.distance if index == 0 else race.rival_distance
			var runner: Node3D = dinosaur if index == 0 else friend
			if progress >= race.length:
				runner.collision_layer = 0
				runner.collision_mask = 0
				_position_runner(runner, dinosaur_animation if index == 0 else friend_animation, race.length + 1.5, -1.6 if index == 0 else 1.6, 0)
	var moving: bool = race.stage == "racing" and not race.paused
	var rival_movement := friend.position - previous_rival_position
	if Vector2(rival_movement.x, rival_movement.z).length() > 0.001:
		var heading := atan2(-rival_movement.x, -rival_movement.z)
		friend.get_node("Model").rotation.y = angle_difference(friend.rotation.y, lerp_angle(previous_rival_yaw, heading, 1 - exp(-delta * 7)))
	_animate_runner(dinosaur, dinosaur_animation, previous.distance_to(dinosaur.position) / frame_delta if moving else 0)
	_animate_runner(friend, friend_animation, rival_movement.length() / frame_delta if moving else 0)
	var direction: Vector2 = race.sample(race.distance).x
	travel_yaw = atan2(-direction.x, -direction.y)
	if not race.paused:
		elapsed += delta
		forest.animate(elapsed)
		_update_camera(1.0 - exp(-delta * 5), delta)
		var rush := clampf((race.speed - race.base_speed) / race.RECOVERY_BOOST, 0, 1) if race.stage == "racing" else 0.0
		camera.fov = lerpf(camera.fov, base_fov + FOV_RUSH * rush, 1 - exp(-delta * 2.5))
		_update_audio(0.0 if race.dino_id == "pteranodon" else previous.distance_to(dinosaur.position), delta, dinosaur.get_node("Model").get_meta("run_cycle_distance", RUN_CYCLE_DISTANCE) / 2)
	for i in range(fruit_nodes.size()):
		fruit_nodes[i].visible = race.fruits[i].owner.is_empty()
		fruit_nodes[i].get_child(0).position.y = 0.42 + sin(elapsed * 3 + i) * 0.06
	_update_recovery_visuals()
	scenery.advance(delta, previous, previous_rival_position)
	speed_effects.advance()
	if race.total_collected > collected or race.arrows_taken > arrows_taken:
		_notify({"type": "park-sound", "name": "pickup"})
	if race.arrows_taken > arrows_taken:
		var nearest: Node3D = arrow_nodes[0]
		for arrow in arrow_nodes:
			if arrow.position.distance_squared_to(dinosaur.position) < nearest.position.distance_squared_to(dinosaur.position):
				nearest = arrow
		nearest.scale = Vector3.ONE * 2.2
		create_tween().tween_property(nearest, "scale", Vector3.ONE, 0.5)
	if race.stage == "finished" and stage != "finished":
		_notify({"type": "park-sound", "name": "happy"})
	report_elapsed += delta
	if report_elapsed >= 0.1 or stage != race.stage or collected != race.total_collected or arrows_taken != race.arrows_taken:
		report_elapsed = 0
		_report()

func _players_report() -> Array:
	var players := [{"species": race.dino_id, "progress": race.distance / race.length, "lap": race.lap, "fruit": race.collected, "golden": race.golden_collected, "speed": race.speed, "baseSpeed": race.base_speed, "finished": race.distance >= race.length}]
	if race.mode == "coop":
		players.append({"species": race.partner_id, "progress": race.rival_distance / race.length, "lap": race.rival_lap, "fruit": race.partner_collected, "golden": race.partner_golden, "speed": race.rival_speed, "baseSpeed": race.rival_base_speed, "finished": race.rival_distance >= race.length})
	return players

func _report() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.parkMode = %s;" % JSON.stringify(race.mode), true)
	_notify({"type": "park-race", "mode": race.mode, "players": _players_report(), "stage": race.stage, "countdown": ceili(race.countdown), "paused": race.paused, "progress": race.distance / race.length, "rivalProgress": race.rival_distance / race.length, "fruit": race.total_collected, "speed": race.speed, "baseSpeed": race.base_speed, "boostLeft": race.boost_left, "recoveryBoostLeft": race.recovery_boost_left, "rivalRecoveryBoostLeft": race.rival_recovery_boost_left, "recoveryTarget": race.recovery_fruit.get("target", ""), "dino": race.dino_id, "track": race.track_id, "winner": race.winner, "lateral": race.lateral, "rivalLateral": race.rival_lateral, "rivalSpeed": race.rival_speed, "rival": race.rival_id, "golden": race.total_golden, "rivalDistracted": race.rival_distracted_left > 0, "speedLevel": race.speed_level(race.speed - race.base_speed), "streak": race.streak, "lap": race.lap, "laps": race.laps, "arrows": race.arrows_taken})

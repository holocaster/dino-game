extends Node3D

const WALK_SPEED := 0.846154

var park: Dictionary
var camera: Camera3D
var dinosaur: Node3D
var target := Vector3.ZERO
var marker: MeshInstance3D
var discoveries: Array[Dictionary] = []
var elapsed := 0.0
var body: Node3D
var active_discovery := ""
var web_callback: JavaScriptObject
var reaction: Tween
var friend: Node3D
var dinosaur_animation: AnimationPlayer
var forest: Node3D
var route := PackedVector3Array()
var camera_focus := Vector3.ZERO
var camera_yaw := 0.0
var camera_turn_velocity := 0.0
var travel_yaw := 0.0
var feeding: Node3D
var basket_fruit: Node3D
var companion: Node3D
var friend_animation: AnimationPlayer
var step_distance := 0.0
var ambience_elapsed := 0.0

func _ready() -> void:
	park = JSON.parse_string(FileAccess.get_file_as_string("res://park.json"))
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("e8f2ed")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("f4f2df")
	environment.ambient_light_energy = 0.4
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -30, 0)
	light.light_color = Color("fff3db")
	light.light_energy = 0.6
	light.shadow_enabled = true
	add_child(light)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 11.0
	camera.position = Vector3(10, 12, 10)
	add_child(camera)
	camera.look_at(Vector3(0, 0.15, 0))
	camera.current = true
	_fit_camera()
	get_viewport().size_changed.connect(_fit_camera)
	forest = preload("res://forest.gd").new()
	add_child(forest)
	for item in park.discoveries:
		var position_3d: Vector3 = forest.point(item.position[0], item.position[1])
		var holder := Node3D.new()
		add_child(holder)
		holder.position = position_3d
		var ring := _ring(position_3d, 0.64, "eaf0cd")
		_discovery_art(holder, item.id)
		discoveries.append({"data": item, "node": holder, "ring": ring, "found": false, "tween": null})
	dinosaur = Node3D.new()
	add_child(dinosaur)
	dinosaur.position = forest.point(park.start[0], park.start[1])
	target = dinosaur.position
	dinosaur.rotation.y = 0.0
	body = Node3D.new()
	dinosaur.add_child(body)
	var model := preload("res://assets/triceratops.glb").instantiate()
	body.add_child(model)
	dinosaur_animation = model.get_node("AnimationPlayer")
	dinosaur_animation.play("idle")
	friend = Node3D.new()
	add_child(friend)
	friend.position = forest.point(2.6, -0.9)
	friend.scale = Vector3.ONE * 0.7
	friend.rotation.y = PI * 0.75
	var friend_model := preload("res://assets/triceratops.glb").instantiate()
	friend.add_child(friend_model)
	friend_animation = friend_model.get_node("AnimationPlayer")
	friend_animation.play("idle")
	feeding = preload("res://feeding.gd").new()
	add_child(feeding)
	feeding.setup(self, discoveries[2], basket_fruit, friend_animation)
	marker = _ring(Vector3.ZERO, 0.23, "fffbe1")
	marker.visible = false
	companion = preload("res://companion.gd").new()
	add_child(companion)
	companion.setup(self)
	if OS.has_feature("web"):
		web_callback = JavaScriptBridge.create_callback(_web_command)
		JavaScriptBridge.get_interface("window").parkCommand = web_callback
	_reset_discoveries()
	camera_focus = dinosaur.position
	_update_camera(1.0)
	_notify({"type": "park-ready"})

func _fit_camera() -> void:
	var size := get_viewport().get_visible_rect().size
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 58 if size.x < size.y else 48

func _camera_focus_point() -> Vector3:
	return dinosaur.position

func _update_camera(weight: float, delta: float = 1.0) -> void:
	var focus := _camera_focus_point()
	var subject_radius := 0.65
	if feeding and feeding.stage in ["offering", "eating", "happy"]:
		focus = (dinosaur.position + friend.position) * 0.5
		subject_radius += dinosaur.position.distance_to(friend.position) * 0.5
	elif companion and companion.stage in ["approaching", "greeting", "following"] and companion.position.distance_to(dinosaur.position) < 4.5:
		focus = (dinosaur.position + companion.position) * 0.5
		subject_radius += dinosaur.position.distance_to(companion.position) * 0.5
	camera_focus = camera_focus.lerp(focus, weight)
	var difference := angle_difference(camera_yaw, travel_yaw)
	var desired_velocity := clampf(difference * 1.5, -deg_to_rad(50.0), deg_to_rad(50.0))
	camera_turn_velocity = move_toward(camera_turn_velocity, desired_velocity, deg_to_rad(80.0) * delta)
	var turn := camera_turn_velocity * delta
	if turn * difference >= 0 and absf(turn) >= absf(difference):
		turn = difference
		camera_turn_velocity = 0
	camera_yaw = wrapf(camera_yaw + turn, -PI, PI)
	var vista := 1.0 - smoothstep(3.0, 7.0, Vector2(camera_focus.x, camera_focus.z).distance_to(Vector2(0, -20)))
	camera.position = camera_focus + Vector3(0, 3.2, 6.0).lerp(Vector3(0, 2.8, 8.5), vista).rotated(Vector3.UP, camera_yaw)
	camera.look_at(camera_focus + Vector3(0, 0.65 + vista * 0.75, -vista * 2.0).rotated(Vector3.UP, camera_yaw))
	forest.reveal_character(camera.position, camera_focus, delta, subject_radius)

func _mesh(mesh: Mesh, position_3d: Vector3, color: String, holder: Node3D = self) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.roughness = 0.92
	instance.material_override = material
	holder.add_child(instance)
	instance.position = position_3d
	return instance

func _sphere(position_3d: Vector3, dimensions: Vector3, color: String, holder: Node3D = self) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = 1
	sphere.height = 2
	sphere.radial_segments = 20
	sphere.rings = 12
	var instance := _mesh(sphere, position_3d, color, holder)
	instance.scale = dimensions
	return instance

func _box(dimensions: Vector3, position_3d: Vector3, color: String, holder: Node3D = self) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = dimensions
	return _mesh(box, position_3d, color, holder)

func _ring(position_3d: Vector3, radius: float, color: String) -> MeshInstance3D:
	var ring := TorusMesh.new()
	ring.inner_radius = radius - 0.025
	ring.outer_radius = radius
	ring.rings = 24
	ring.ring_segments = 8
	var result := _mesh(ring, position_3d + Vector3(0, 0.015, 0), color)
	result.scale.y = 0.25
	return result

func _discovery_art(holder: Node3D, id: String) -> void:
	if id == "flowers":
		for flower in [Vector3(-0.35, 0.3, 0), Vector3(0, 0.5, -0.1), Vector3(0.35, 0.27, 0.1)]:
			_box(Vector3(0.035, flower.y, 0.035), Vector3(flower.x, flower.y / 2, flower.z), "7e9e6c", holder)
			for i in range(6):
				var angle := i * TAU / 6
				_sphere(flower + Vector3(cos(angle) * 0.12, sin(angle) * 0.12, 0), Vector3(0.09, 0.09, 0.06), "f0cf76" if flower.x == 0 else "de9a91", holder)
			_sphere(flower + Vector3(0, 0, -0.065), Vector3(0.07, 0.07, 0.045), "ffedb2", holder)
	elif id == "tracks":
		for foot in [Vector3(-0.25, 0.01, 0.15), Vector3(0.22, 0.01, -0.05), Vector3(-0.05, 0.01, -0.35)]:
			_sphere(foot, Vector3(0.12, 0.016, 0.16), "b5a17c", holder)
			for x in [-0.09, 0.0, 0.09]:
				_sphere(foot + Vector3(x, 0, -0.16), Vector3(0.042, 0.018, 0.05), "b5a17c", holder)
	elif id == "fruit":
		_box(Vector3(0.8, 0.28, 0.5), Vector3(0, 0.14, 0), "bb9366", holder)
		_box(Vector3(0.85, 0.07, 0.55), Vector3(0, 0.29, 0), "d1b17b", holder)
		for x in [-0.25, 0, 0.25]:
			var apple := Node3D.new()
			holder.add_child(apple)
			apple.position = Vector3(x, 0.38, 0)
			_sphere(Vector3.ZERO, Vector3.ONE * 0.17, "d78d78" if x == 0 else "e7bc69", apple)
			_sphere(Vector3(0.06, 0.16, 0), Vector3(0.09, 0.025, 0.04), "7f9b60", apple)
			if x == 0:
				basket_fruit = apple

	elif id == "mushrooms":
		for i in range(3):
			var p := Vector3((i - 1) * 0.42, 0, float(i % 2) * 0.22)
			var size := 0.7 if i != 1 else 1.0
			_sphere(p + Vector3.UP * 0.24 * size, Vector3(0.09, 0.24, 0.09) * size, "ecdcc0", holder)
			_sphere(p + Vector3.UP * 0.48 * size, Vector3(0.32, 0.18, 0.32) * size, "ba819c" if i % 2 else "d1a16c", holder)
			for j in range(3):
				var angle := j * TAU / 3
				_sphere(p + Vector3(cos(angle) * 0.16, 0.62, sin(angle) * 0.16) * size, Vector3.ONE * 0.045 * size, "f2e5cc", holder)
	elif id == "butterflies":
		for i in range(3):
			var butterfly := Node3D.new()
			holder.add_child(butterfly)
			butterfly.position = Vector3((i - 1) * 0.75, 1.2, float(i % 2) * 0.55 - 0.35)
			for side in [-1, 1]:
				_sphere(Vector3(side * 0.14, 0, 0), Vector3(0.17, 0.18, 0.035), ["e8be72", "d895af", "a8c7df"][i], butterfly)
			_sphere(Vector3.ZERO, Vector3(0.035, 0.13, 0.035), "6d6048", butterfly)
	elif id == "lookout":
		for i in range(3):
			_sphere(Vector3(0, 0.14 + i * 0.22, 0), Vector3(0.40 - i * 0.08, 0.15, 0.28 - i * 0.05), "a8ac92" if i % 2 else "c8c8ad", holder)

func _unhandled_input(event: InputEvent) -> void:
	var screen: Vector2
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		screen = event.position
	elif event is InputEventScreenTouch and event.pressed:
		screen = event.position
	else:
		return
	var hit: Vector3 = forest.ground_hit(camera.project_ray_origin(screen), camera.project_ray_normal(screen))
	var destination: Vector3 = forest.point(clampf(hit.x, -park.bounds, park.bounds), clampf(hit.z, -park.bounds, park.bounds))
	active_discovery = ""
	for item in discoveries:
		var point: Vector3 = item.node.position
		if not camera.is_position_behind(point) and camera.unproject_position(point + Vector3(0, 0.25, 0)).distance_to(screen) < 46:
			destination = point
			active_discovery = item.data.id
			break
	if active_discovery != "fruit" or not feeding.active():
		feeding.cancel()
		_set_target(destination)

func _set_target(destination: Vector3) -> void:
	route = forest.route(dinosaur.position, destination)
	if route.is_empty():
		return
	target = route[-1]
	marker.position = target + Vector3(0, 0.025, 0)
	marker.visible = true

func _web_command(arguments: Array) -> void:
	if arguments.size() != 1 or not arguments[0] is String:
		return
	var command: String = arguments[0]
	if command == "restart":
		restart()
		return
	for item in discoveries:
		if item.data.id == command:
			if command == "fruit" and feeding.active():
				return
			feeding.cancel()
			active_discovery = command
			_set_target(item.node.position)
			return

func restart() -> void:
	companion.reset()
	step_distance = 0
	ambience_elapsed = 0
	feeding.cancel()
	friend.rotation.y = PI * 0.75
	if reaction:
		reaction.kill()
	dinosaur.position = forest.point(park.start[0], park.start[1])
	dinosaur.rotation = Vector3.ZERO
	camera_yaw = 0
	camera_turn_velocity = 0
	travel_yaw = 0
	body.scale = Vector3.ONE
	dinosaur_animation.play("idle", 0)
	dinosaur_animation.seek(0, true)
	dinosaur_animation.speed_scale = 1
	target = dinosaur.position
	route.clear()
	camera_focus = dinosaur.position
	_update_camera(1.0)
	marker.visible = false
	active_discovery = ""
	_reset_discoveries()
	_send_ambience()

func _reset_discoveries() -> void:
	friend.position.y = forest.height_at(friend.position.x, friend.position.z)
	for item in discoveries:
		if item.tween:
			item.tween.kill()
		item.found = false
		item.node.position.y = forest.height_at(item.node.position.x, item.node.position.z)
		item.node.scale = Vector3.ONE * (0.45 if item.data.id == "flowers" else 1.0)
		if item.data.id == "tracks":
			for foot in item.node.get_children():
				foot.position.y = 0.01
		item.ring.scale = Vector3(1, 0.25, 1)
		item.ring.material_override.albedo_color = Color("eaf0cd")

func _interact(item: Dictionary) -> void:
	if item.data.id == "fruit":
		if not feeding.active():
			feeding.start()
		return
	item.found = true
	active_discovery = ""
	item.ring.scale = Vector3(1, 0.25, 1)
	item.ring.material_override.albedo_color = Color("fff3c2")
	if item.tween:
		item.tween.kill()
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	item.tween = tween
	if item.data.id != "tracks":
		tween.tween_property(item.node, "scale", Vector3.ONE * 1.25, 0.45)
		tween.tween_property(item.node, "scale", Vector3.ONE, 0.3)
	elif item.data.id == "tracks":
		for foot in item.node.get_children():
			foot.position.y = 0.01
			tween.tween_property(foot, "position:y", 0.12, 0.06).as_relative()
			tween.tween_property(foot, "position:y", -0.12, 0.06).as_relative()
	if reaction:
		reaction.kill()
	reaction = create_tween().set_trans(Tween.TRANS_SINE)
	reaction.tween_property(body, "scale", Vector3(1.06, 0.94, 1.06), 0.2)
	reaction.tween_property(body, "scale", Vector3.ONE, 0.3)
	_notify({"type": "park-sound", "name": "flowers" if item.data.id in ["mushrooms", "butterflies", "lookout"] else item.data.id})
	_notify({"type": "park-discovery", "id": item.data.id, "message": item.data.message})

func _process(delta: float) -> void:
	if dinosaur == null:
		return
	elapsed += delta
	while not route.is_empty() and dinosaur.position.distance_to(route[0]) < 0.02:
		route.remove_at(0)
	var waypoint: Vector3 = route[0] if not route.is_empty() else target
	var direction := waypoint - dinosaur.position
	var moving := direction.length() > 0.015
	var previous_position := dinosaur.position
	if moving:
		dinosaur.rotation.y = lerp_angle(dinosaur.rotation.y, atan2(-direction.x, -direction.z), minf(delta * 8, 1))
		var budget := minf(delta, 0.5) * 1.2
		while budget > 0 and not route.is_empty():
			var distance := dinosaur.position.distance_to(route[0])
			if distance <= budget:
				dinosaur.position = route[0]
				budget -= distance
				route.remove_at(0)
			else:
				dinosaur.position = dinosaur.position.move_toward(route[0], budget)
				budget = 0
		dinosaur.position.y = forest.height_at(dinosaur.position.x, dinosaur.position.z)
	else:
		marker.visible = false
	dinosaur_animation.play("walk" if moving else "idle", 0.15)
	dinosaur_animation.speed_scale = previous_position.distance_to(dinosaur.position) / maxf(delta * WALK_SPEED, 0.0001) if moving else 1.0
	var movement := dinosaur.position - previous_position
	if Vector2(movement.x, movement.z).length() > 0.001:
		travel_yaw = atan2(-movement.x, -movement.z)
	_update_audio(movement.length(), delta)
	feeding.advance(delta)
	companion.advance(delta)
	_update_camera(1.0 - exp(-delta * 5.0), delta)
	for item in discoveries:
		if item.data.id == "butterflies":
			for i in range(item.node.get_child_count()):
				var butterfly: Node3D = item.node.get_child(i)
				butterfly.position.y = 1.2 + sin(elapsed * 2.5 + i) * 0.13
				var flap := sin(elapsed * 9 + i) * 0.7
				butterfly.get_child(0).rotation.y = flap
				butterfly.get_child(1).rotation.y = -flap
		if item.data.id == "fruit" and active_discovery != "fruit":
			continue
		if not item.found:
			var pulse := 1.0 + sin(elapsed * 2.4) * 0.08
			item.ring.scale = Vector3(pulse, 0.25, pulse)
		if (not item.found or active_discovery == item.data.id) and dinosaur.position.distance_to(item.node.position) < 0.65 and not feeding.active():
			_interact(item)

func _send_ambience() -> void:
	var position_2d := Vector2(dinosaur.position.x, dinosaur.position.z)
	_notify({"type": "park-ambience", "lake": 1 - smoothstep(1.7, 6.0, position_2d.distance_to(forest.POND)), "grove": 1 - smoothstep(2.5, 6.0, minf(position_2d.distance_to(Vector2(0, -6.8)), position_2d.distance_to(Vector2(-11, -8))))})

func _update_audio(distance: float, delta: float, step_length: float = 0.34) -> void:
	if distance > 0.001:
		step_distance += distance
		if step_distance >= step_length:
			step_distance = fmod(step_distance, step_length)
			_notify({"type": "park-sound", "name": "step"})
	else:
		step_distance = 0
	ambience_elapsed += delta
	if ambience_elapsed >= 0.25:
		ambience_elapsed = 0
		_send_ambience()

func _notify(data: Dictionary) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.parent.postMessage(%s, window.location.origin);" % JSON.stringify(data), true)

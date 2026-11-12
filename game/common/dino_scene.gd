extends Node3D

var camera: Camera3D
var forest: Node3D
var dinosaur: Node3D
var friend: Node3D
var dinosaur_animation: AnimationPlayer
var friend_animation: AnimationPlayer
var web_callback: JavaScriptObject
var elapsed := 0.0
var camera_focus := Vector3.ZERO
var camera_yaw := 0.0
var camera_turn_velocity := 0.0
var travel_yaw := 0.0
var step_distance := 0.0
var ambience_elapsed := 0.0

func _fit_camera() -> void:
	var size := get_viewport().get_visible_rect().size
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 58 if size.x < size.y else 48

func _camera_focus_point() -> Vector3:
	return dinosaur.position

func _update_camera(weight: float, delta: float = 1.0) -> void:
	_aim_camera(_camera_focus_point(), 0.65, weight, delta)

func _aim_camera(focus: Vector3, subject_radius: float, weight: float, delta: float) -> void:
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

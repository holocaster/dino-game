extends Node3D

const DINO_COLORS := {"triceratops": Color("df9865"), "trex": Color("aa85c5"), "raptor": Color("4dafa2"), "pteranodon": Color("e7a349")}

var game: Node3D
var runners: Array[Dictionary] = []

func setup(scene: Node3D) -> void:
	game = scene
	var dust := Color("f3e3bb") if game.race.track_id == "beach" else Color("e2c792")
	for runner in [game.dinosaur, game.friend]:
		var effects := {
			"dust": _emitter(runner, 14, 0.6, _ball(0.09, dust), Vector3(0.35, 0.05, 0.3), Vector3(0, 0.1, 0.35)),
			"trail": _emitter(runner, 40, 0.6, _ball(0.1, Color.WHITE), Vector3(0.16, 0.18, 0.1), Vector3(0, 0.7, 0.85)),
			"sparks": _emitter(runner, 24, 0.25, _streak(), Vector3(0.45, 0.45, 0.45), Vector3(0, 0.8, 0)),
		}
		effects.dust.direction = Vector3.UP
		effects.dust.spread = 60
		effects.dust.initial_velocity_min = 0.4
		effects.dust.initial_velocity_max = 0.8
		effects.dust.gravity = Vector3(0, -1.2, 0)
		effects.trail.direction = Vector3.BACK
		effects.trail.spread = 10
		effects.trail.initial_velocity_min = 0.5
		effects.trail.initial_velocity_max = 0.9
		effects.sparks.spread = 180
		effects.sparks.initial_velocity_min = 1.5
		effects.sparks.initial_velocity_max = 3.0
		effects.sparks.particle_flag_align_y = true
		runners.append(effects)
	paint(1, game.RIVAL_COLORS.get(game.race.rival_id, game.RIVAL_COLORS.playful))

func paint(index: int, color: Color) -> void:
	runners[index].trail.mesh.material.albedo_color = color

func level(index: int) -> int:
	if game.race.stage != "racing":
		return 0
	var race = game.race
	if race.mode == "coop" and (race.distance if index == 0 else race.rival_distance) >= race.length:
		return 0
	return race.speed_level(race.speed - race.base_speed if index == 0 else race.rival_speed - race.rival_base_speed)

func advance() -> void:
	for index in range(runners.size()):
		var current := level(index)
		var effects: Dictionary = runners[index]
		var runner: Node3D = game.dinosaur if index == 0 else game.friend
		var flying: bool = runner.get_node("Model").get_meta("flying", false)
		effects.dust.emitting = current >= 1 and not flying
		effects.trail.position.y = 1.1 if flying else 0.7
		effects.trail.emitting = current >= 2
		effects.sparks.emitting = current >= 3
		for emitter in effects.values():
			emitter.speed_scale = 0.0 if game.race.paused else 1.0

func reset() -> void:
	for effects in runners:
		for emitter in effects.values():
			emitter.restart()
			emitter.emitting = false

func _emitter(runner: Node3D, amount: int, lifetime: float, mesh: Mesh, extents: Vector3, offset: Vector3) -> CPUParticles3D:
	var emitter := CPUParticles3D.new()
	emitter.emitting = false
	emitter.amount = amount
	emitter.lifetime = lifetime
	emitter.local_coords = false
	emitter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	emitter.mesh = mesh
	emitter.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	emitter.emission_box_extents = extents
	emitter.position = offset
	emitter.gravity = Vector3.ZERO
	emitter.initial_velocity_min = 0
	emitter.initial_velocity_max = 0
	var shrink := Curve.new()
	shrink.add_point(Vector2(0, 1))
	shrink.add_point(Vector2(1, 0))
	emitter.scale_amount_curve = shrink
	runner.add_child(emitter)
	return emitter

func _ball(radius: float, color: Color) -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = _glow(color)
	return mesh

func _streak() -> Mesh:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.045, 0.45, 0.045)
	mesh.material = _glow(Color("fff1b0"))
	return mesh

func _glow(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material

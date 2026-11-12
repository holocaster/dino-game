extends SceneTree

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

func _initialize() -> void:
	create_timer(20).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var model: Node3D = load("res://assets/triceratops.glb").instantiate()
	root.add_child(model)
	var player := model.get_node("AnimationPlayer") as AnimationPlayer
	var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	assert(player.has_animation("run"))
	var length := player.get_animation("run").length
	assert(is_equal_approx(length, 0.8))
	for leg in [["HindLeft", 0.0], ["HindRight", 0.5], ["FrontLeft", 0.5], ["FrontRight", 0.0]]:
		var foot := skeleton.find_bone(leg[0] + "Foot")
		var rest := skeleton.get_bone_global_rest(foot).origin
		var previous_phase := -1.0
		var previous_z := 0.0
		var maximum_lift := 0.0
		player.play("run", 0)
		for frame in range(81):
			var time := length * frame / 80
			var phase := fposmod(time / length + float(leg[1]), 1)
			player.seek(time, true)
			skeleton.force_update_all_bone_transforms()
			var pose := skeleton.get_bone_global_pose(foot)
			maximum_lift = maxf(maximum_lift, pose.origin.y - rest.y)
			assert(pose.origin.y >= rest.y - 0.002)
			var world_z := pose.origin.z - time * (0.52 / (0.6 * 0.8))
			if phase < 0.59:
				assert(absf(pose.origin.y - rest.y) < 0.002)
				assert(pose.basis.get_euler().length() < deg_to_rad(0.3))
				if previous_phase >= 0 and phase > previous_phase and previous_phase < 0.59:
					assert(absf(world_z - previous_z) < 0.002)
			previous_phase = phase
			previous_z = world_z
		assert(maximum_lift > 0.11)
	var minimum_foot := INF
	for phase in range(16):
		player.play("run", 0)
		player.seek(phase * length / 16, true)
		player.play("idle", 0.2)
		for frame in range(20):
			player.advance(1.0 / 60)
			skeleton.force_update_all_bone_transforms()
			for leg in ["HindLeft", "HindRight", "FrontLeft", "FrontRight"]:
				var foot := skeleton.find_bone(leg + "Foot")
				minimum_foot = minf(minimum_foot, skeleton.get_bone_global_pose(foot).origin.y)
		assert(absf(skeleton.get_bone_pose_position(skeleton.find_bone("Root")).y) < 0.001)
		assert(skeleton.get_bone_pose_rotation(skeleton.find_bone("Body")).is_equal_approx(Quaternion.IDENTITY))
	assert(minimum_foot >= 0.05, "Transition foot height: %s" % minimum_foot)
	var game := RecordedRace.new()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await physics_frame
	await physics_frame
	for speed in [2.2, 3.48]:
		for runner in [game.dinosaur, game.friend]:
			var animation: AnimationPlayer = runner.get_node("Model/AnimationPlayer")
			game._position_runner(runner, animation, 0, 0, speed)
			assert(animation.current_animation == "run")
			assert(is_equal_approx(animation.speed_scale * game.RUN_SPEED * runner.get_node("Model").scale.x, speed))
			assert(animation.speed_scale / length < 5.0)
	game.step_distance = 0
	game.events.clear()
	for step in range(24):
		game._update_audio(0.05, 0.01, game.RUN_CYCLE_DISTANCE / 2)
	assert(game.events.filter(func(event): return event.type == "park-sound" and event.name == "step").size() == 2)
	game.restart()
	game.race.advance(3)
	await physics_frame
	var before: Vector3 = game.dinosaur.position
	game._process(0.4)
	var animated_distance: float = game.dinosaur_animation.speed_scale * game.RUN_SPEED * 0.4
	assert(is_equal_approx(animated_distance, before.distance_to(game.dinosaur.position)), "Animation advances farther than the dinosaur on a slow frame: %s versus %s" % [animated_distance, before.distance_to(game.dinosaur.position)])
	game.race.paused = true
	game._position_runner(game.dinosaur, game.dinosaur_animation, 0, 0, 0)
	assert(game.dinosaur_animation.speed_scale == 0)
	model.queue_free()
	game.queue_free()
	print("Gait checks passed: run clip, support contact, stride, toe roll, both model sizes, cadence, transitions, pause and step audio. Minimum transition foot height: ", minimum_foot)
	quit()

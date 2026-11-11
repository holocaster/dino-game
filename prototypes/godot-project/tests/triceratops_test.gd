extends SceneTree

func _initialize() -> void:
	create_timer(10).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var model: Node3D = load("res://assets/triceratops.glb").instantiate()
	root.add_child(model)
	var player := model.get_node("AnimationPlayer") as AnimationPlayer
	var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
	assert(skeleton.get_bone_count() == 16)
	var mesh := skeleton.get_node("Mesh") as MeshInstance3D
	assert(mesh.skin != null and mesh.skin.get_bind_count() == 16)
	var arrays := mesh.mesh.surface_get_arrays(0)
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	assert(weights.size() == arrays[Mesh.ARRAY_VERTEX].size() * 4)
	for index in range(0, weights.size(), 4):
		assert(absf(weights[index] + weights[index + 1] + weights[index + 2] + weights[index + 3] - 1) < 0.001)
	assert(player.has_animation("walk") and player.has_animation("idle"))
	for clip in ["walk", "idle"]:
		assert(player.get_animation(clip).loop_mode == Animation.LOOP_LINEAR)
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var length := player.get_animation("walk").length
	assert(is_equal_approx(length, 0.8))
	for leg in [["HindLeft", 0.0], ["HindRight", 0.5], ["FrontLeft", 0.75], ["FrontRight", 0.25]]:
		var foot := skeleton.find_bone(leg[0] + "Foot")
		var knee := skeleton.find_bone(leg[0] + "Knee")
		var hip := skeleton.find_bone(leg[0] + "Hip")
		assert(foot >= 0 and knee >= 0 and hip >= 0)
		var rest := skeleton.get_bone_global_rest(foot).origin
		var maximum_lift := 0.0
		var maximum_knee_angle := 0.0
		var maximum_hip_angle := 0.0
		var previous_world_z := 0.0
		var previous_phase := -1.0
		player.play("walk")
		for frame in range(81):
			var time := length * frame / 80.0
			var phase := fposmod(time / length + float(leg[1]), 1.0)
			player.seek(time, true)
			skeleton.force_update_all_bone_transforms()
			var pose := skeleton.get_bone_global_pose(foot)
			maximum_lift = maxf(maximum_lift, pose.origin.y - rest.y)
			maximum_knee_angle = maxf(maximum_knee_angle, skeleton.get_bone_pose_rotation(knee).get_angle())
			maximum_hip_angle = maxf(maximum_hip_angle, skeleton.get_bone_pose_rotation(hip).get_angle())
			assert(pose.origin.y >= rest.y - 0.002)
			assert(pose.basis.get_euler().length() < deg_to_rad(0.2))
			assert(absf(pose.origin.x - rest.x) < 0.001)
			var world_z := pose.origin.z - time * 0.846154
			if phase < 0.64:
				assert(absf(pose.origin.y - rest.y) < 0.002)
				if previous_phase >= 0 and phase > previous_phase and previous_phase < 0.64:
					assert(absf(world_z - previous_world_z) < 0.001)
			previous_phase = phase
			previous_world_z = world_z
		assert(maximum_lift > 0.11)
		assert(maximum_knee_angle > 0.1 and maximum_hip_angle > 0.1)
		player.play("idle")
		for time in [0.0, 0.8, 1.6, 2.4, 3.2]:
			player.seek(time, true)
			skeleton.force_update_all_bone_transforms()
			assert(skeleton.get_bone_global_pose(foot).origin.distance_to(rest) < 0.001)
			assert(skeleton.get_bone_pose_rotation(knee).is_equal_approx(Quaternion.IDENTITY))
	for phase in range(16):
		player.play("walk", 0)
		player.seek(phase * length / 16, true)
		player.play("idle", 0.15)
		for frame in range(12):
			player.advance(1.0 / 60)
			skeleton.force_update_all_bone_transforms()
			for leg in ["HindLeft", "HindRight", "FrontLeft", "FrontRight"]:
				var foot := skeleton.find_bone(leg + "Foot")
				assert(skeleton.get_bone_global_pose(foot).origin.y >= 0.055)
	var game: Node3D = load("res://park.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.dinosaur_animation.current_animation == "idle")
	game._set_target(game.target + Vector3(0, 0, -0.5))
	game._process(0.05)
	assert(game.dinosaur_animation.current_animation == "walk")
	assert(absf(game.dinosaur_animation.speed_scale * game.WALK_SPEED - 1.2) < 0.001)
	var before: Vector3 = game.dinosaur.position
	game._process(0.2)
	var distance: float = before.distance_to(game.dinosaur.position)
	assert(absf(game.dinosaur_animation.speed_scale * game.WALK_SPEED * 0.2 - distance) < 0.001)
	for step in range(12):
		game._process(0.05)
	assert(game.dinosaur_animation.current_animation == "idle")
	game._set_target(game.target + Vector3(0.5, 0, 0))
	game._process(0.05)
	game.restart()
	assert(game.dinosaur_animation.current_animation == "idle")
	assert(game.dinosaur_animation.speed_scale == 1)
	assert(game.dinosaur_animation.current_animation_position == 0)
	game.queue_free()
	model.queue_free()
	print("Triceratops checks passed: skin, four articulated legs, foot contact, stride, idle, movement, reset.")
	quit()

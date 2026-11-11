extends SceneTree

func _initialize() -> void:
	create_timer(20).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for species in ["trex", "raptor"]:
		var model: Node3D = load("res://runner_model.gd").create(species)
		root.add_child(model)
		var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
		assert(skeleton != null and skeleton.get_bone_count() == 12)
		var mesh := skeleton.get_node("Mesh") as MeshInstance3D
		assert(mesh.skin != null and mesh.skin.get_bind_count() == 12)
		var material := mesh.get_active_material(0) as StandardMaterial3D
		assert(material != null and material.albedo_texture != null, "Biped must have a real albedo texture")
		assert(material.albedo_texture.get_width() >= 1024 and material.albedo_texture.get_width() <= 2048)
		assert(material.albedo_texture.get_height() <= 2048)
		var arrays := mesh.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		assert(vertices.size() > 5000 and arrays[Mesh.ARRAY_TEX_UV].size() == vertices.size())
		for index in range(0, weights.size(), 4):
			assert(absf(weights[index] + weights[index + 1] + weights[index + 2] + weights[index + 3] - 1) < 0.001)
		for vertex in range(vertices.size()):
			if vertices[vertex].y < 0.08:
				for influence in range(4):
					var index := vertex * 4 + influence
					if weights[index] > 0.001:
						assert(mesh.skin.get_bind_name(bones[index]) in ["LeftFoot", "RightFoot"], "Sole vertices must follow the feet, not stretch with the torso")
		var player := model.get_node("AnimationPlayer") as AnimationPlayer
		player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		assert(player.has_animation("run") and player.has_animation("idle"))
		assert(player.get_animation("run").loop_mode == Animation.LOOP_LINEAR)
		assert(player.get_animation("idle").loop_mode == Animation.LOOP_LINEAR)
		for leg in [["LeftFoot", 0.0], ["RightFoot", 0.5]]:
			var foot := skeleton.find_bone(leg[0])
			var rest := skeleton.get_bone_global_rest(foot).origin
			var maximum_lift := 0.0
			var previous_phase := -1.0
			var previous_world_z := 0.0
			player.play("run", 0)
			for frame in range(81):
				var time := frame * 0.8 / 80
				var phase := fposmod(time / 0.8 + float(leg[1]), 1.0)
				player.seek(time, true)
				skeleton.force_update_all_bone_transforms()
				var pose := skeleton.get_bone_global_pose(foot)
				maximum_lift = maxf(maximum_lift, pose.origin.y - rest.y)
				assert(pose.origin.y >= rest.y - 0.002)
				assert(absf(pose.origin.x - rest.x) < 0.001)
				assert(pose.basis.get_euler().length() < deg_to_rad(0.3), "%s %s phase %s foot angle %s" % [species, leg[0], phase, rad_to_deg(pose.basis.get_euler().length())])
				var world_z := pose.origin.z - time
				if phase < 0.49:
					assert(absf(pose.origin.y - rest.y) < 0.002)
					if previous_phase >= 0 and phase > previous_phase and previous_phase < 0.49:
						assert(absf(world_z - previous_world_z) < 0.002)
				previous_phase = phase
				previous_world_z = world_z
			assert(maximum_lift > 0.11)
			player.play("idle", 0)
			for time in [0.0, 0.8, 1.6, 2.4]:
				player.seek(time, true)
				skeleton.force_update_all_bone_transforms()
				assert(skeleton.get_bone_global_pose(foot).origin.distance_to(rest) < 0.001)
		for phase in range(16):
			player.play("run", 0)
			player.seek(phase * 0.8 / 16, true)
			player.play("idle", 0.2)
			for frame in range(20):
				player.advance(1.0 / 60)
				skeleton.force_update_all_bone_transforms()
				for leg in ["LeftFoot", "RightFoot"]:
					var height := skeleton.get_bone_global_pose(skeleton.find_bone(leg)).origin.y
					assert(height >= 0.055, "%s transition at phase %s sinks foot to %s" % [species, phase, height])
		print("Textured biped passed: ", species, ", UVs, texture, weights, run/idle, planted feet and smooth stride")
		model.queue_free()
	quit()

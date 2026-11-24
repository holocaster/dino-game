extends SceneTree

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

const Models := preload("res://dinos/runner_model.gd")

func _initialize() -> void:
	Engine.physics_ticks_per_second = 600
	create_timer(90).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _rig() -> bool:
	var model := Models.create("pteranodon")
	root.add_child(model)
	assert(model.get_meta("flying"))
	var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
	var mesh := skeleton.get_node("Mesh") as MeshInstance3D
	assert(skeleton.get_bone_count() == 10 and mesh.skin.get_bind_count() == 10)
	assert(mesh.get_active_material(0).albedo_texture.get_width() >= 1024)
	var arrays := mesh.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var feet_driven_by_wings := 0
	for vertex in range(vertices.size()):
		if vertices[vertex].y >= 0.8:
			continue
		for influence in range(4):
			var index := vertex * 4 + influence
			if weights[index] > 0.01 and "Wing" in mesh.skin.get_bind_name(bones[index]):
				feet_driven_by_wings += 1
	var animation: AnimationPlayer = model.get_node("AnimationPlayer")
	animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for clip in ["idle", "run"]:
		var duration := animation.get_animation(clip).length
		assert(animation.get_animation(clip).loop_mode == Animation.LOOP_LINEAR)
		animation.play(clip, 0)
		var lowest_tip := INF
		var highest_tip := -INF
		var foot_pose := {}
		for frame in range(33):
			animation.seek(duration * frame / 32, true)
			skeleton.force_update_all_bone_transforms()
			var body := skeleton.get_bone_global_pose(skeleton.find_bone("Body"))
			var forward := body.basis.y.normalized().dot(Vector3.FORWARD)
			if forward < 0.95 or feet_driven_by_wings > 0:
				push_error("Flight posture: torso forward alignment %.3f (must exceed 0.95), foot influences from wings %d (must be zero)" % [forward, feet_driven_by_wings])
				model.free()
				return false
			var transforms: Array[Transform3D] = []
			for bind in range(mesh.skin.get_bind_count()):
				var bone := skeleton.find_bone(mesh.skin.get_bind_name(bind))
				transforms.append(skeleton.get_bone_global_pose(bone) * skeleton.get_bone_global_rest(bone).affine_inverse())
			var left_height := 0.0
			var right_height := 0.0
			var left_count := 0
			var right_count := 0
			for vertex in range(vertices.size()):
				var position := Vector3.ZERO
				var total := 0.0
				for influence in range(4):
					var index := vertex * 4 + influence
					assert(weights[index] >= 0)
					total += weights[index]
					position += (transforms[bones[index]] * vertices[vertex]) * weights[index]
				assert(absf(total - 1) < 0.001)
				assert(position.y > 0.35 and position.y < 2.3, "Flight must stay above the track and below the camera envelope")
				if vertices[vertex].y < 0.75 and vertices[vertex].z < 0.15 and absf(vertices[vertex].x) > 0.1:
					assert(position.z > body.origin.z + 0.2 and absf(position.x) < 0.25, "Feet must stay tucked behind the torso: bind %s, posed %s, body %s" % [vertices[vertex], position, body.origin])
					var relative := position - body.origin
					assert(not foot_pose.has(vertex) or relative.distance_to(foot_pose[vertex]) < 0.002, "Flapping must not spread the feet")
					foot_pose[vertex] = relative
				if vertices[vertex].x < -0.95:
					left_height += position.y
					left_count += 1
				elif vertices[vertex].x > 0.95:
					right_height += position.y
					right_count += 1
			assert(left_count > 0 and right_count > 0)
			left_height /= left_count
			right_height /= right_count
			assert(absf(left_height - right_height) < 0.12, "Both wings must flap together")
			lowest_tip = minf(lowest_tip, left_height)
			highest_tip = maxf(highest_tip, left_height)
		assert(highest_tip - lowest_tip > 0.5, "Wing geometry must actually deform")
		assert(not foot_pose.is_empty(), "The posture check must exercise the actual feet")
	model.free()
	return true

func _run() -> void:
	if not _rig():
		quit(1)
		return
	for circuit in ["forest", "beach", "valley", "volcano", "cave"]:
		for slot in [1, 2]:
			var first := "pteranodon" if slot == 1 else "triceratops"
			var second := "pteranodon" if slot == 2 else "trex"
			set_meta("race_selection", [first, circuit, "coop", second])
			set_meta("race_appearances", [{"species": first, "color": "natural", "accessory": "cap"}, {"species": second, "color": "ocean", "accessory": "glasses"}])
			var game := RecordedRace.new()
			root.add_child(game)
			game.set_physics_process(false)
			await physics_frame
			var runner: Node3D = game.dinosaur if slot == 1 else game.friend
			var animation: AnimationPlayer = runner.get_node("Model/AnimationPlayer")
			assert(runner.get_node("BodyShape").position == Vector3(0, 0.6, 0.08))
			assert(is_equal_approx(game.race.base_speed, 2.2) and is_equal_approx(game.race.rival_base_speed, 2.2 if slot == 2 else 2.27))
			game.race.start()
			game.race.advance(3)
			var fruit: Dictionary = game.race.fruits[0]
			game.race.distance = fruit.distance if slot == 1 else fruit.distance - 5
			game.race.rival_distance = fruit.distance if slot == 2 else fruit.distance - 5
			game.race.lateral = fruit.lateral
			game.race.rival_lateral = fruit.lateral
			game._position_runner(game.dinosaur, game.dinosaur_animation, game.race.distance, fruit.lateral, 2.2)
			game._position_runner(game.friend, game.friend_animation, game.race.rival_distance, fruit.lateral, 2.2)
			await physics_frame
			await physics_frame
			game.events.clear()
			for step in range(8):
				game._process(0.05)
				await physics_frame
			assert(fruit.player_taken if slot == 1 else fruit.rival_taken, "Flying player must collect fruit through the existing body")
			if slot == 1:
				assert(not game.events.any(func(event): return event.type == "park-sound" and event.name == "step"))
			game.race.speed = game.race.base_speed + 2
			game.race.rival_speed = game.race.rival_base_speed + 2
			game.speed_effects.advance()
			var effects: Dictionary = game.speed_effects.runners[slot - 1]
			assert(not effects.dust.emitting and effects.trail.emitting)
			game.race.paused = true
			game._animate_runner(runner, animation, 2.2)
			assert(animation.speed_scale == 0)
			var paused_time := animation.current_animation_position
			await physics_frame
			await physics_frame
			assert(animation.current_animation_position == paused_time)
			game.race.paused = false
			game._animate_runner(runner, animation, 100)
			assert(is_equal_approx(animation.speed_scale, 1.6))
			game.reset_race()
			assert(game.race.stage == "ready" and game.race.total_collected == 0)
			assert(animation.current_animation == "idle" and animation.speed_scale == 1)
			game.free()
	remove_meta("race_selection")
	remove_meta("race_appearances")
	print("Flight passed: horizontal torso, tucked feet independent of flapping, skinned wings, clearance, fruit in either slot on five tracks, speed, pause, reset, no footsteps or ground dust.")
	quit()

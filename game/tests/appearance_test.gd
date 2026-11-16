extends SceneTree

const Models := preload("res://dinos/runner_model.gd")

func _initialize() -> void:
	create_timer(60).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	for species in Models.MODELS:
		for accessory in ["none", "cap", "glasses"]:
			var model: Node3D = Models.create(species, accessory)
			root.add_child(model)
			assert(model.find_children("*", "CollisionObject3D", true, false).is_empty())
			var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
			var head := skeleton.find_bone("Head")
			var attachment := skeleton.get_node_or_null("Accessory") as BoneAttachment3D
			if accessory == "none":
				assert(attachment == null)
			else:
				assert(attachment != null and attachment.bone_name == "Head" and not attachment.override_pose)
				var animation := model.get_node("AnimationPlayer") as AnimationPlayer
				animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
				var rest := skeleton.get_bone_global_rest(head)
				var moved := false
				for clip in ["idle", "run"]:
					animation.play(clip, 0)
					for time in [0.0, 0.2, 0.4, 0.6]:
						animation.seek(time, true)
						skeleton.force_update_all_bone_transforms()
						await process_frame
						var pose := skeleton.get_bone_global_pose(head)
						assert(attachment.transform.is_equal_approx(pose), "Accessory must follow animated head")
						moved = moved or not pose.is_equal_approx(rest)
				assert(moved, "Head animation must actually exercise attachment")
			model.free()
	for species in Models.MODELS:
		set_meta("race_selection", [species, "forest", "none"])
		var game: Node3D = load("res://race/race.tscn").instantiate()
		root.add_child(game)
		game.set_physics_process(false)
		var shape: CollisionShape3D = game.dinosaur.get_node("BodyShape")
		var body_shape := shape.shape
		var body_transform := shape.transform
		var base_speed: float = game.race.base_speed
		var fruit_layout: Array = game.race.fruits.duplicate(true)
		for accessory in ["none", "cap", "glasses"]:
			game._web_command(["appearance:1:%s:ocean:%s" % [species, accessory]])
			assert(get_meta("race_appearances", [])[0] == {"species": species, "color": "ocean", "accessory": accessory})
			assert(shape.shape == body_shape and shape.transform == body_transform)
			assert(game.race.base_speed == base_speed and game.race.collected == 0 and game.race.stage == "ready")
			assert(game.race.fruits == fruit_layout, "Cosmetic changes must not redraw fruit or consume race RNG")
			var meshes: Array = game.dinosaur.get_node("Model").find_children("*", "MeshInstance3D", true, false)
			for mesh in meshes:
				if mesh.skin != null:
					assert(mesh.get_surface_override_material(0).get_shader_parameter("tint") == game.PLAYER_COLORS.ocean)
				else:
					assert(mesh.get_surface_override_material(0) == null and mesh.material_override is StandardMaterial3D)
		var saved: Array = get_meta("race_appearances").duplicate(true)
		for invalid in ["appearance:0:trex:natural:cap", "appearance:3:trex:natural:cap", "appearance:1:unknown:natural:cap", "appearance:1:trex:gold:cap", "appearance:1:trex:natural:hat", "appearance:1:trex:natural:cap:extra", "select:unknown:forest:none", "select:trex:unknown:none"]:
			game._web_command([invalid])
			assert(get_meta("race_appearances") == saved and game.race.dino_id == species)
		game._web_command(["appearance:2:raptor:natural:cap"])
		assert(get_meta("race_appearances")[1] == {"species": "raptor", "color": "natural", "accessory": "cap"})
		game.restart()
		game._web_command(["appearance:1:trex:natural:none"])
		assert(get_meta("race_appearances")[0] == saved[0] and game.race.dino_id == species)
		game._web_command(["pause"])
		game._web_command(["appearance:2:trex:natural:glasses"])
		assert(get_meta("race_appearances")[1].species == "raptor")
		game._web_command(["menu"])
		assert(game.race.stage == "ready" and get_meta("race_appearances")[0] == saved[0])
		game._web_command(["appearance:1:raptor:sunset:cap"])
		assert(game.race.dino_id == "raptor" and is_equal_approx(game.race.base_speed, 2.13))
		assert(game.dinosaur_animation == game.dinosaur.get_node("Model/AnimationPlayer"))
		game.free()
	remove_meta("race_selection")
	remove_meta("race_color")
	remove_meta("race_appearances")
	print("Appearance models passed: three species, three accessories, animated head and no physical bodies.")
	quit()

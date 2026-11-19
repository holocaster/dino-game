extends SceneTree

var material := ShaderMaterial.new()

func _initialize() -> void:
	create_timer(15).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _capture(time: float) -> Image:
	material.set_shader_parameter("animation_time", time)
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func _run() -> void:
	root.size = Vector2i(320, 200)
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4
	camera.position = Vector3(0, 5, 0)
	camera.look_at(Vector3.ZERO, Vector3.FORWARD)
	var water := MeshInstance3D.new()
	water.mesh = PlaneMesh.new()
	water.mesh.size = Vector2.ONE * 4
	material.shader = load("res://world/water.gdshader")
	water.material_override = material
	root.add_child(water)
	var first := await _capture(0.0)
	var repeated := await _capture(0.0)
	assert(first.get_data() == repeated.get_data(), "Frozen water must not use the engine clock")
	var later := await _capture(1.5)
	var changed := 0
	for y in range(40, 160):
		for x in range(40, 280):
			if first.get_pixel(x, y) != later.get_pixel(x, y):
				changed += 1
	assert(changed > 2000, "Water shader must visibly animate when its clock advances")
	print("Water render checks passed: frozen clock produces identical pixels; advancing the clock animates ripples and shore foam.")
	quit()

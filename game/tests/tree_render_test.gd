extends SceneTree

var material := ShaderMaterial.new()

func _initialize() -> void:
	create_timer(10).timeout.connect(func(): quit(1))
	_run.call_deferred()

func capture(canopy: float, trunk: float) -> Image:
	material.set_shader_parameter("canopy_alpha", canopy)
	material.set_shader_parameter("trunk_alpha", trunk)
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func coverage(image: Image, left: bool) -> float:
	var count := 0
	for x in range(65 if left else 185, 135 if left else 255):
		for y in range(65, 135):
			var color := image.get_pixel(x, y)
			if maxf(color.r, color.g) > 0.3:
				count += 1
	return count / 4900.0

func _run() -> void:
	root.size = Vector2i(320, 200)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.01, 0.01, 0.01)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 1
	root.add_child(world)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.position.z = 5
	root.add_child(camera)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1, 1]:
		surface.set_color(Color(0.8, 0.1, 0.05, 0) if side < 0 else Color(0.05, 0.8, 0.1, 1))
		for point in [Vector2(-0.7, -0.8), Vector2(-0.7, 0.8), Vector2(0.7, -0.8), Vector2(0.7, -0.8), Vector2(-0.7, 0.8), Vector2(0.7, 0.8)]:
			surface.set_normal(Vector3.BACK)
			surface.add_vertex(Vector3(point.x + side, point.y, 0))
	var mesh := MeshInstance3D.new()
	mesh.mesh = surface.commit()
	material.shader = load("res://world/tree.gdshader")
	mesh.material_override = material
	root.add_child(mesh)
	var opaque: Image = await capture(1, 1)
	assert(coverage(opaque, true) > 0.95 and coverage(opaque, false) > 0.95, "Opaque coverage: %s / %s" % [coverage(opaque, true), coverage(opaque, false)])
	var canopy_hidden: Image = await capture(0, 1)
	assert(coverage(canopy_hidden, true) > 0.95 and coverage(canopy_hidden, false) == 0)
	var halfway: Image = await capture(0.5, 1)
	assert(coverage(halfway, false) > 0.4 and coverage(halfway, false) < 0.6)
	var trunk_hidden: Image = await capture(1, 0)
	assert(coverage(trunk_hidden, true) == 0 and coverage(trunk_hidden, false) > 0.95)
	print("Tree render checks passed: opaque, canopy hidden, half coverage, independent trunk visibility.")
	quit()

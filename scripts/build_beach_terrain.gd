extends SceneTree

func _initialize() -> void:
	var race := preload("res://race/race_state.gd").new()
	race.configure("triceratops", "beach")
	var forest := preload("res://world/forest.gd").new()
	forest.theme = "beach"
	forest.trails.append(race.track)
	var surface := SurfaceTool.new()
	surface.create_from(forest._beach_mesh(), 0)
	surface.index()
	var result := ResourceSaver.save(surface.commit(), "res://world/beach_terrain.res", ResourceSaver.FLAG_COMPRESS)
	forest.free()
	if result != OK:
		push_error(error_string(result))
	quit(int(result != OK))

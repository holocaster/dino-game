extends SceneTree

func _initialize() -> void:
	_build.call_deferred()

func _build() -> void:
	var race := preload("res://race/race_state.gd").new()
	race.configure("triceratops", "valley")
	var forest := preload("res://world/forest.gd").new()
	forest.theme = "valley"
	forest.race_track = race.track
	root.add_child(forest)
	var terrain := forest.get_node("Terrain") as MeshInstance3D
	var result := ResourceSaver.save(terrain.mesh, "res://world/valley_terrain.res", ResourceSaver.FLAG_COMPRESS)
	if result != OK:
		push_error(error_string(result))
	quit(int(result != OK))

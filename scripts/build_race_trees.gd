extends SceneTree

const WORLD := preload("res://world/forest.gd")

func _initialize() -> void:
	_build.call_deferred()

func _build() -> void:
	for track in ["forest", "valley"]:
		var game := preload("res://race/race.tscn").instantiate()
		game.race.configure("triceratops", track)
		var forest := WORLD.new()
		forest.theme = track
		forest.race_track = game.race.track
		forest.race_terrain = load("res://world/%s_terrain.res" % track)
		root.add_child(forest)
		game.forest = forest
		game._decorate_track()
		game.free()
		forest.free()
	var pack := Resource.new()
	pack.set_meta("meshes", WORLD.track_tree_meshes)
	var result := ResourceSaver.save(pack, "res://world/race_trees.res", ResourceSaver.FLAG_COMPRESS)
	if result != OK:
		push_error(error_string(result))
	quit(int(result != OK))

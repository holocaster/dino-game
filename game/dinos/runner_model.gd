extends RefCounted

const MODELS := {
	"triceratops": preload("res://assets/triceratops.glb"),
	"trex": preload("res://assets/trex.glb"),
	"raptor": preload("res://assets/raptor.glb")
}

static func create(species: String) -> Node3D:
	var model: Node3D = MODELS[species].instantiate()
	if species != "triceratops":
		model.set_meta("run_cycle_distance", 0.8)
	return model

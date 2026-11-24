extends RefCounted

const MODELS := {
	"triceratops": preload("res://assets/triceratops.glb"),
	"trex": preload("res://assets/trex.glb"),
	"raptor": preload("res://assets/raptor.glb"),
	"pteranodon": preload("res://assets/pteranodon.glb")
}

const ACCESSORIES := ["none", "cap", "glasses"]
const FIT := {
	"triceratops": {"cap": Vector3(0, 0.26, -0.32), "glasses": Vector3(0, 0.07, -0.49), "width": 0.52},
	"trex": {"cap": Vector3(0, 0.52, -0.13), "glasses": Vector3(0, 0.38, -0.18), "width": 0.51},
	"raptor": {"cap": Vector3(0, 0.51, -0.21), "glasses": Vector3(0, 0.47, -0.23), "width": 0.47},
	"pteranodon": {"cap": Vector3(0, 0.36, 0.02), "glasses": Vector3(0, 0.12, -0.16), "width": 0.43}
}

static func create(species: String, accessory: String = "none") -> Node3D:
	var model: Node3D = MODELS[species].instantiate()
	model.set_meta("flying", species == "pteranodon")
	if species != "triceratops":
		model.set_meta("run_cycle_distance", 0.8)
	if accessory in ["cap", "glasses"]:
		var skeleton := model.find_child("Skeleton3D", true, false) as Skeleton3D
		var attachment := BoneAttachment3D.new()
		attachment.name = "Accessory"
		attachment.bone_name = "Head"
		skeleton.add_child(attachment)
		var holder := Node3D.new()
		holder.name = accessory
		holder.position = FIT[species][accessory]
		attachment.add_child(holder)
		if accessory == "cap":
			var crown := SphereMesh.new()
			crown.radius = 1
			crown.height = 2
			var dome := _part(holder, crown, Vector3.ZERO, "e85d47")
			dome.scale = Vector3(FIT[species].width * 0.57, 0.15, 0.28)
			var brim := SphereMesh.new()
			brim.radius = 1
			brim.height = 2
			var visor := _part(holder, brim, Vector3(0, -0.08, -0.19), "ffd066")
			visor.scale = Vector3(FIT[species].width * 0.64, 0.035, 0.29)
		else:
			for side in [-1, 1]:
				var lens := BoxMesh.new()
				lens.size = Vector3(FIT[species].width * 0.43, 0.18, 0.065)
				_part(holder, lens, Vector3(side * FIT[species].width * 0.27, 0, 0), "243e54")
				var arm := BoxMesh.new()
				arm.size = Vector3(0.035, 0.045, 0.37)
				_part(holder, arm, Vector3(side * FIT[species].width * 0.5, 0.02, 0.16), "ffd066")
			var bridge := BoxMesh.new()
			bridge.size = Vector3(FIT[species].width * 0.18, 0.045, 0.07)
			_part(holder, bridge, Vector3.ZERO, "ffd066")
	return model

static func _part(holder: Node3D, mesh: Mesh, offset: Vector3, color: String) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = offset
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.roughness = 0.8
	part.material_override = material
	holder.add_child(part)
	return part

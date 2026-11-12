extends Node3D

var game: Node3D
var basket: Dictionary
var source: Node3D
var fruit: MeshInstance3D
var friend_player: AnimationPlayer
var stage := "idle"
var elapsed := 0.0
var delivery := Vector3.ZERO
var start_position := Vector3.ZERO
var hearts: Array[MeshInstance3D] = []

func setup(park: Node3D, item: Dictionary, basket_fruit: Node3D, player: AnimationPlayer) -> void:
	game = park
	basket = item
	source = basket_fruit
	friend_player = player
	fruit = game._sphere(Vector3.ZERO, Vector3.ONE * 0.24, "e79760", self)
	fruit.visible = false
	game._sphere(Vector3(0.25, 0.95, 0), Vector3(0.45, 0.15, 0.25), "6d9b3f", fruit)
	var eating := friend_player.get_animation("idle").duplicate() as Animation
	eating.loop_mode = Animation.LOOP_NONE
	for track in range(eating.get_track_count()):
		if str(eating.track_get_path(track)).ends_with(":Head"):
			for key in range(eating.track_get_key_count(track)):
				var time := eating.track_get_key_time(track, key)
				eating.track_set_key_value(track, key, Quaternion(Vector3.RIGHT, sin(time * TAU * 2.5) * 0.12))
	var library := AnimationLibrary.new()
	library.add_animation("eat", eating)
	friend_player.add_animation_library("feeding", library)
	for i in range(3):
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for segment in range(32):
			for angle in [-1.0, segment * TAU / 32, (segment + 1) * TAU / 32]:
				var point := Vector3.ZERO if angle < 0 else Vector3(16 * pow(sin(angle), 3), 13 * cos(angle) - 5 * cos(2 * angle) - 2 * cos(3 * angle) - cos(4 * angle), 0) * 0.012
				surface.add_vertex(point)
		surface.generate_normals()
		var heart: MeshInstance3D = game._mesh(surface.commit(), Vector3.ZERO, "ed997d", self)
		heart.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
		heart.visible = false
		hearts.append(heart)

func active() -> bool:
	return stage != "idle"

func message(text: String) -> void:
	game._notify({"type": "park-feeding", "stage": stage, "message": text})

func start() -> void:
	if active():
		return
	stage = "pickup"
	elapsed = 0
	source.visible = false
	fruit.visible = true
	fruit.scale = Vector3.ONE * 0.24
	start_position = source.global_position
	fruit.global_position = start_position
	game.route.clear()
	game.target = game.dinosaur.position
	game.marker.visible = false
	face(game.dinosaur, basket.node.global_position)
	game._notify({"type": "park-sound", "name": "pickup"})
	message("Uma frutinha para o amigo!")

func face(character: Node3D, destination: Vector3) -> void:
	var direction := destination - character.global_position
	character.rotation.y = atan2(-direction.x, -direction.z)

func cancel() -> void:
	stage = "idle"
	elapsed = 0
	fruit.visible = false
	fruit.scale = Vector3.ONE * 0.24
	source.visible = true
	friend_player.play("idle", 0)
	friend_player.seek(0, true)
	for heart in hearts:
		heart.visible = false

func advance(delta: float) -> void:
	if not active():
		return
	var previous_elapsed := elapsed
	elapsed += delta
	var held: Vector3 = game.dinosaur.to_global(Vector3(0.3, 0.85, -1.12))
	var mouth: Vector3 = game.friend.to_global(Vector3(-0.23, 0.78, -1.12))
	match stage:
		"pickup":
			var progress := smoothstep(0, 0.7, elapsed)
			fruit.global_position = start_position.lerp(held, progress) + Vector3.UP * sin(progress * PI) * 0.18
			if elapsed >= 0.7:
				stage = "carrying"
				elapsed = 0
				delivery = game.forest.point(1.4, 0.65)
				game._set_target(delivery)
				message("Vamos levar a frutinha para o amigo.")
		"carrying":
			fruit.global_position = held
			if game.route.is_empty() and game.dinosaur.position.distance_to(delivery) < 0.03:
				face(game.dinosaur, game.friend.global_position)
				face(game.friend, game.dinosaur.global_position)
				stage = "offering"
				elapsed = 0
				start_position = fruit.global_position
		"offering":
			fruit.global_position = start_position.lerp(mouth, smoothstep(0, 0.7, elapsed))
			if elapsed >= 0.7:
				stage = "eating"
				elapsed = 0
				friend_player.play("feeding/eat", 0.15)
				game._notify({"type": "park-sound", "name": "bite"})
				message("Nhac, nhac! Que frutinha gostosa!")
		"eating":
			if int(elapsed / 0.8) > int(previous_elapsed / 0.8) and elapsed < 3.2:
				game._notify({"type": "park-sound", "name": "bite"})
			fruit.global_position = mouth + Vector3.UP * sin(elapsed * TAU * 2.5) * 0.025
			fruit.scale = Vector3.ONE * 0.24 * maxf(0, 1 - floorf(elapsed / 0.8) / 4.0)
			if elapsed >= 3.2:
				fruit.visible = false
				friend_player.play("idle", 0.2)
				stage = "happy"
				elapsed = 0
				basket.found = true
				basket.ring.material_override.albedo_color = Color("fff3c2")
				game.active_discovery = ""
				game._notify({"type": "park-sound", "name": "happy"})
				game._notify({"type": "park-discovery", "id": "fruit", "message": basket.data.message})
		"happy":
			for i in range(hearts.size()):
				var heart := hearts[i]
				heart.visible = true
				heart.global_position = game.friend.global_position + Vector3((i - 1) * 0.35, 1.25 + elapsed * 0.22 + sin(i * 2.0) * 0.05, 0)
				heart.scale = Vector3.ONE * minf(elapsed * 4, 1) * (1 - smoothstep(1, 1.6, elapsed))
				heart.look_at(game.camera.global_position, Vector3.UP, true)
			if elapsed >= 1.6:
				cancel()

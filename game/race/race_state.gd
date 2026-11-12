extends RefCounted

const TRACK_WIDTH := 2.8
const LATERAL_LIMIT := 1.65
const BASE_SPEED := 2.2
const FRUIT_BOOST := 0.16
const MAX_BOOST := FRUIT_BOOST * 4
const BOOST_DURATION := 4.0
const FRUIT_RESPAWN := 1.5
const STEER_SPEED := 2.4
const RIVAL_SPEED := 2.15
const RIVALS := {
	"sleepy": {"speed": 2.2, "reaction": 0.5, "miss": 0.35, "distraction": 0.5},
	"playful": {"speed": RIVAL_SPEED, "reaction": 0.3, "miss": 0.0, "distraction": 0.0},
	"speedy": {"speed": 2.3, "reaction": 0.25, "miss": 0.0, "distraction": 0.0}
}
const DISTRACTION_EVERY := 4.0
const DISTRACTION_TIME := 1.5
const DISTRACTION_SLOW := 0.8
const ASSIST_RANGE := 3.0
const ASSIST_REACH := 1.6
const ASSIST_STRENGTH := 0.6
const RIVAL_REACTION := 0.3
const RIVAL_STEER_SPEED := 1.6
const RIVAL_STEER_ACCELERATION := 3.2
const RECOVERY_GAP := 5.0
const RECOVERY_AHEAD := 3.0
const RECOVERY_BOOST := 2.0
const RECOVERY_DURATION := 4.0
const RECOVERY_LIFETIME := 5.0
const RECOVERY_COOLDOWN := 10.0
const RECOVERY_FINISH_MARGIN := 12.0
const VALLEY_LAPS := 3
const VALLEY_SECTIONS := 6
const VALLEY_CENTER := Vector2(24, -5)
const VALLEY_RADIUS := 12.0
const VALLEY_STRAIGHT := 45.0

var track := Curve2D.new()
var length := 0.0
var lap_length := 0.0
var laps := 1
var lap: int:
	get:
		return _lap_index(distance) + 1
var rival_lap: int:
	get:
		return _lap_index(rival_distance) + 1
var stage := "ready"
var countdown := 3.0
var paused := false
var distance := 0.0
var rival_distance := 0.0
var lateral := -0.9
var rival_lateral := 0.9
var _speed := BASE_SPEED
var _rival_speed := RIVAL_SPEED
var speed: float:
	get:
		return maxf(_speed, base_speed + RECOVERY_BOOST) if recovery_boost_left > 0 else _speed
	set(value):
		_speed = value
var rival_speed: float:
	get:
		var value := maxf(_rival_speed, rival_base_speed + RECOVERY_BOOST) if rival_recovery_boost_left > 0 else _rival_speed
		return value - DISTRACTION_SLOW if rival_distracted_left > 0 else value
	set(value):
		_rival_speed = value
var rival_target_fruit := -1
var rival_id := "playful"
var rival_reaction := RIVAL_REACTION
var rival_think_time := RIVAL_REACTION
var rival_distracted_left := 0.0
var rival_distraction_check := DISTRACTION_EVERY
var golden_collected := 0
var rival_lateral_velocity := 0.0
var collected := 0
var streak := 0
var winner := ""
var fruits: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var resolve_motion: Callable
var pickup_contact: Callable
var boost_left := 0.0
var rival_boost_left := 0.0
var recovery_fruit: Dictionary = {}
var recovery_cooldown := 0.0
var recovery_boost_left := 0.0
var rival_recovery_boost_left := 0.0
var dino_id := "triceratops"
var track_id := "forest"
var base_speed := BASE_SPEED
var rival_base_speed := RIVAL_SPEED
var steer_speed := STEER_SPEED

const DINOS := {
	"triceratops": {"speed": 2.2, "steer": 2.4},
	"trex": {"speed": 2.27, "steer": 2.2},
	"raptor": {"speed": 2.13, "steer": 2.7}
}
const TRACKS := ["forest", "beach", "valley"]
const SPEED_LEVELS := [0.3, 0.6, 1.0]

func _init() -> void:
	_build_track()
	reset()

var solo: bool:
	get:
		return rival_id == "none"

static func speed_level(bonus: float) -> int:
	return SPEED_LEVELS.filter(func(threshold): return bonus >= threshold).size()

func can_configure(dino: String, circuit: String, rival: String) -> bool:
	return DINOS.has(dino) and circuit in TRACKS and (RIVALS.has(rival) or rival == "none") and stage in ["ready", "finished"]

func configure(dino: String, circuit: String, rival: String = "playful") -> bool:
	if not can_configure(dino, circuit, rival):
		return false
	dino_id = dino
	track_id = circuit
	rival_id = rival
	var profile: Dictionary = RIVALS.get(rival, RIVALS.playful)
	rival_base_speed = profile.speed
	rival_reaction = profile.reaction
	base_speed = DINOS[dino].speed
	steer_speed = DINOS[dino].steer
	_build_track()
	reset()
	return true

func _build_track() -> void:
	track.clear_points()
	track.bake_interval = 0.08
	laps = 1
	if track_id == "valley":
		_build_stadium()
		return
	for i in range(5):
		var angle := i * PI / 2
		var radii := Vector2(13, 14) if track_id == "forest" else Vector2(15, 11)
		var p := Vector2(-1, -5) + Vector2(cos(angle), -sin(angle)) * radii
		var tangent := Vector2(-sin(angle), -cos(angle)) * radii * 0.55228475
		track.add_point(p, -tangent, tangent)
	lap_length = track.get_baked_length()
	length = lap_length

func _build_stadium() -> void:
	var half := VALLEY_STRAIGHT / 2
	var handle := VALLEY_RADIUS * 0.55228475
	var right := VALLEY_CENTER.x + VALLEY_RADIUS
	var left := VALLEY_CENTER.x - VALLEY_RADIUS
	var points := [
		[Vector2(right, VALLEY_CENTER.y), Vector2.ZERO, Vector2.ZERO],
		[Vector2(right, VALLEY_CENTER.y - half), Vector2.ZERO, Vector2(0, -handle)],
		[VALLEY_CENTER + Vector2(0, -half - VALLEY_RADIUS), Vector2(handle, 0), Vector2(-handle, 0)],
		[Vector2(left, VALLEY_CENTER.y - half), Vector2(0, -handle), Vector2.ZERO],
		[Vector2(left, VALLEY_CENTER.y + half), Vector2.ZERO, Vector2(0, handle)],
		[VALLEY_CENTER + Vector2(0, half + VALLEY_RADIUS), Vector2(-handle, 0), Vector2(handle, 0)],
		[Vector2(right, VALLEY_CENTER.y + half), Vector2(0, handle), Vector2.ZERO],
		[Vector2(right, VALLEY_CENTER.y), Vector2.ZERO, Vector2.ZERO]
	]
	for point in points:
		track.add_point(point[0], point[1], point[2])
	laps = VALLEY_LAPS
	lap_length = track.get_baked_length()
	length = lap_length * laps

func _lap_index(progress: float) -> int:
	return mini(floori(progress / lap_length), laps - 1)

func _lap_local(progress: float, reference: float) -> float:
	return progress - _lap_index(reference) * lap_length

func reset() -> void:
	stage = "ready"
	countdown = 3.0
	paused = false
	distance = 0
	rival_distance = 0
	lateral = -0.9
	rival_lateral = 0.9
	speed = base_speed
	rival_speed = rival_base_speed
	boost_left = 0
	rival_boost_left = 0
	recovery_fruit.clear()
	recovery_cooldown = 0
	recovery_boost_left = 0
	rival_recovery_boost_left = 0
	rival_target_fruit = -1
	rival_think_time = rival_reaction
	rival_lateral_velocity = 0
	rival_distracted_left = 0
	rival_distraction_check = DISTRACTION_EVERY
	collected = 0
	streak = 0
	golden_collected = 0
	winner = ""
	fruits.clear()
	var slots: Array[Vector2] = []
	var sections := VALLEY_SECTIONS if laps > 1 else 4
	var window := (lap_length - 8 - lap_length / 22) / sections
	for section in range(sections):
		var start := lap_length / 22 + section * window + rng.randf() * (window - 12)
		for step in range(2):
			var offset := rng.randf_range(1.0, 1.55)
			for side in [-1, 1]:
				slots.append(Vector2(start + step * 4, side * offset))
		slots.append(Vector2(start + 8, 0))
	for slot in slots:
		fruits.append({"distance": float(slot.x), "lateral": float(slot.y), "owner": "", "respawn": 0.0, "player_taken": false, "rival_taken": false, "rival_skip": rng.randf() < RIVALS.get(rival_id, RIVALS.playful).miss})

func start() -> void:
	if stage == "ready":
		stage = "countdown"

func sample(progress: float, offset: float = 0) -> Transform2D:
	var pose := track.sample_baked_with_rotation(fposmod(progress, lap_length), true)
	pose.origin += Vector2(-pose.x.y, pose.x.x) * offset
	return pose

func _choose_rival_fruit() -> void:
	rival_target_fruit = -1
	var best_score := INF
	var rival_local := _lap_local(rival_distance, rival_distance)
	var player_local := _lap_local(distance, distance)
	for i in range(fruits.size()):
		var fruit: Dictionary = fruits[i]
		var ahead: float = fruit.distance - rival_local
		if not fruit.owner.is_empty() or fruit.get("rival_taken", false) or fruit.get("rival_skip", false) or ahead <= 0.55:
			continue
		var arrival := ahead / rival_speed
		var crossing := maxf(0, absf(fruit.lateral - rival_lateral) - 0.65) / RIVAL_STEER_SPEED
		if arrival > 3.0 or arrival < crossing + rival_reaction:
			continue
		var player_arrival: float = (fruit.distance - player_local) / speed
		if player_arrival >= 0 and absf(lateral - fruit.lateral) < 0.8 and player_arrival + rival_reaction < arrival:
			continue
		var score := arrival + crossing * 0.4
		if score < best_score:
			best_score = score
			rival_target_fruit = i

func _steer_rival(delta: float) -> void:
	if rival_distance >= length:
		rival_target_fruit = -1
		rival_lateral_velocity = 0
		return
	rival_distraction_check -= delta
	if rival_distraction_check <= 0:
		rival_distraction_check = DISTRACTION_EVERY
		if rng.randf() < RIVALS.get(rival_id, RIVALS.playful).distraction:
			rival_distracted_left = DISTRACTION_TIME
	if rival_distracted_left > 0:
		rival_lateral_velocity = move_toward(rival_lateral_velocity, 0, RIVAL_STEER_ACCELERATION * delta)
		rival_lateral = clampf(rival_lateral + rival_lateral_velocity * delta, -LATERAL_LIMIT, LATERAL_LIMIT)
		return
	var rival_local := _lap_local(rival_distance, rival_distance)
	rival_think_time = maxf(0, rival_think_time - delta)
	if rival_think_time <= 0:
		rival_think_time = rival_reaction
		if rival_target_fruit < 0 or not fruits[rival_target_fruit].owner.is_empty() or fruits[rival_target_fruit].distance < rival_local - 0.55:
			_choose_rival_fruit()
	var goal := rival_lateral
	if rival_target_fruit >= 0 and fruits[rival_target_fruit].owner.is_empty() and fruits[rival_target_fruit].distance >= rival_local - 0.55:
		goal = fruits[rival_target_fruit].lateral
	if not recovery_fruit.is_empty() and recovery_fruit.target == "rival" and recovery_fruit.distance > rival_distance + 0.55:
		goal = recovery_fruit.lateral
	var gap := distance - rival_distance
	var predicted_gap := gap + (speed - rival_speed) * 0.5
	if minf(absf(gap), absf(predicted_gap)) < 2.0:
		var side := signf(rival_lateral - lateral)
		if absf(rival_lateral - lateral) < 0.1:
			side = 1.0 if lateral <= 0 else -1.0
		goal = maxf(goal, lateral + 1.25) if side > 0 else minf(goal, lateral - 1.25)
	goal = clampf(goal, -LATERAL_LIMIT, LATERAL_LIMIT)
	var desired_velocity := clampf((goal - rival_lateral) * 2.5, -RIVAL_STEER_SPEED, RIVAL_STEER_SPEED)
	rival_lateral_velocity = move_toward(rival_lateral_velocity, desired_velocity, RIVAL_STEER_ACCELERATION * delta)
	rival_lateral = clampf(rival_lateral + rival_lateral_velocity * delta, -LATERAL_LIMIT, LATERAL_LIMIT)

func advance(delta: float, steering: float = 0) -> void:
	if paused or stage in ["ready", "finished"] or delta <= 0:
		return
	if stage == "countdown":
		var waiting := minf(delta, countdown)
		countdown = maxf(0, countdown - waiting)
		if countdown < 0.00001:
			countdown = 0
		delta -= waiting
		if countdown > 0:
			return
		stage = "racing"
	boost_left = maxf(0, boost_left - delta)
	rival_boost_left = maxf(0, rival_boost_left - delta)
	recovery_boost_left = maxf(0, recovery_boost_left - delta)
	rival_recovery_boost_left = maxf(0, rival_recovery_boost_left - delta)
	recovery_cooldown = maxf(0, recovery_cooldown - delta)
	rival_distracted_left = maxf(0, rival_distracted_left - delta)
	if boost_left == 0:
		streak = 0
		speed = move_toward(_speed, base_speed, FRUIT_BOOST * 4 * delta)
	if rival_boost_left == 0:
		rival_speed = move_toward(_rival_speed, rival_base_speed, FRUIT_BOOST * 4 * delta)
	for fruit in fruits:
		if fruit.get("respawn", 0.0) > 0:
			fruit.respawn = maxf(0, fruit.respawn - delta)
			if fruit.respawn == 0 and not (fruit.get("player_taken", false) and fruit.get("rival_taken", false)):
				fruit.owner = ""
	var previous := distance
	var rival_previous := rival_distance
	if solo and steering == 0 and delta > 0:
		steering = _assist(delta)
	lateral = clampf(lateral + clampf(steering, -1, 1) * steer_speed * delta, -LATERAL_LIMIT, LATERAL_LIMIT)
	if not solo:
		_steer_rival(delta)
	distance = minf(length, distance + speed * delta)
	if not solo:
		rival_distance = minf(length, rival_distance + rival_speed * delta)
	if resolve_motion.is_valid() and delta > 0:
		resolve_motion.call(previous, rival_previous, delta)
	if winner.is_empty():
		var player_time := (length - previous) / speed if distance >= length else INF
		var rival_time := (length - rival_previous) / rival_speed if rival_distance >= length else INF
		if minf(player_time, rival_time) <= delta:
			winner = "both" if is_equal_approx(player_time, rival_time) else ("player" if player_time < rival_time else "rival")
	if _lap_index(distance) > _lap_index(previous):
		_new_lap("player_taken")
	if _lap_index(rival_distance) > _lap_index(rival_previous):
		_new_lap("rival_taken")
	var local := _lap_local(distance, distance)
	var local_previous := _lap_local(previous, distance)
	var rival_local := _lap_local(rival_distance, rival_distance)
	var rival_local_previous := _lap_local(rival_previous, rival_distance)
	for index in range(fruits.size()):
		var fruit: Dictionary = fruits[index]
		if not fruit.owner.is_empty():
			continue
		var player_hit: bool = local_previous < fruit.distance + 0.55 and local >= fruit.distance - 0.55 and absf(lateral - fruit.lateral) < 0.8
		var rival_hit: bool = rival_local_previous < fruit.distance + 0.55 and rival_local >= fruit.distance - 0.55 and absf(rival_lateral - fruit.lateral) < 0.8
		if pickup_contact.is_valid():
			player_hit = pickup_contact.call(index, false)
			rival_hit = pickup_contact.call(index, true)
		player_hit = player_hit and not fruit.get("player_taken", false) and previous < length
		rival_hit = rival_hit and not fruit.get("rival_taken", false) and rival_previous < length
		if player_hit and (not rival_hit or (fruit.distance - local_previous) / speed <= (fruit.distance - rival_local_previous) / rival_speed):
			fruit.owner = "player"
			fruit.player_taken = true
			fruit.respawn = FRUIT_RESPAWN
			collected += 1
			streak += 1
			speed = minf(base_speed + MAX_BOOST, _speed + FRUIT_BOOST)
			boost_left = BOOST_DURATION
		elif rival_hit:
			fruit.owner = "rival"
			fruit.rival_taken = true
			fruit.respawn = FRUIT_RESPAWN
			rival_speed = minf(rival_base_speed + MAX_BOOST, _rival_speed + FRUIT_BOOST)
			rival_boost_left = BOOST_DURATION
	_advance_recovery(delta, previous, rival_previous)
	if distance >= length:
		stage = "finished"

func _new_lap(taken: String) -> void:
	for fruit in fruits:
		fruit[taken] = false
		if fruit.respawn == 0:
			fruit.owner = ""

func _advance_recovery(delta: float, previous: float, rival_previous: float) -> void:
	if not winner.is_empty():
		recovery_fruit.clear()
		return
	if not recovery_fruit.is_empty():
		recovery_fruit.left = maxf(0, recovery_fruit.left - delta)
		var rival: bool = recovery_fruit.target == "rival"
		var progress := rival_distance if rival else distance
		var before := rival_previous if rival else previous
		if recovery_fruit.left == 0 or progress > recovery_fruit.distance + 0.55:
			recovery_fruit.clear()
		else:
			var contact: bool = before < recovery_fruit.distance + 0.55 and progress >= recovery_fruit.distance - 0.55 and absf((rival_lateral if rival else lateral) - recovery_fruit.lateral) < 0.8
			if pickup_contact.is_valid():
				contact = pickup_contact.call(-1, rival)
			if contact:
				if rival:
					rival_recovery_boost_left = RECOVERY_DURATION
				else:
					recovery_boost_left = RECOVERY_DURATION
					collected += 1
					golden_collected += 1
				recovery_fruit.clear()
		return
	if solo or recovery_cooldown > 0 or absf(distance - rival_distance) < RECOVERY_GAP or maxf(distance, rival_distance) >= length - RECOVERY_FINISH_MARGIN:
		return
	var rival := rival_distance < distance
	recovery_fruit = {"target": "rival" if rival else "player", "distance": (rival_distance if rival else distance) + RECOVERY_AHEAD, "lateral": clampf(rival_lateral if rival else lateral, -LATERAL_LIMIT, LATERAL_LIMIT), "left": RECOVERY_LIFETIME}
	recovery_cooldown = RECOVERY_COOLDOWN

func _assist(delta: float) -> float:
	var best := INF
	var goal := lateral
	var local := _lap_local(distance, distance)
	for fruit in fruits:
		var ahead: float = fruit.distance - local
		var offset: float = fruit.lateral - lateral
		if fruit.owner.is_empty() and not fruit.get("player_taken", false) and ahead > 0 and ahead <= ASSIST_RANGE and absf(offset) < ASSIST_REACH and ahead + absf(offset) < best:
			best = ahead + absf(offset)
			goal = fruit.lateral
	return clampf((goal - lateral) / (steer_speed * delta), -ASSIST_STRENGTH, ASSIST_STRENGTH)

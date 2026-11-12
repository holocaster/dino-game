extends RefCounted

static func good(race, delta: float = 0.05) -> float:
	var targets: Array = race.fruits.duplicate()
	var arrows = race.get("arrows")
	if arrows:
		targets.append_array(arrows)
	return _steer(race, targets, delta)

static func medium(race, delta: float = 0.05) -> float:
	var rows: Array = []
	for fruit in race.fruits:
		if not rows.has(fruit.distance):
			rows.append(fruit.distance)
	rows.sort()
	return _steer(race, race.fruits.filter(func(fruit): return rows.find(fruit.distance) % 2 == 0), delta)

static func idle(_race, _delta: float = 0.05) -> float:
	return 0.0

static func _steer(race, targets: Array, delta: float) -> float:
	var goal: float = race.lateral
	var best := INF
	var progress: float = race.distance - (race.lap - 1) * race.lap_length
	for target in targets:
		var ahead: float = target.distance - progress
		var score := ahead + absf(target.lateral - race.lateral)
		if ahead >= 0 and not target.get("player_taken", false) and score < best:
			best = score
			goal = target.lateral
	return clampf((goal - race.lateral) / (race.steer_speed * delta), -1, 1)

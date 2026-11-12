extends SceneTree

const Race := preload("res://race/race_state.gd")
const Bots := preload("res://tests/bots.gd")
const SEEDS := 30
const STEP := 0.05

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	print("| Rival | Bot | Floresta/Praia win % | Vale win % | Vale median Volta s | Vale median Corrida s | Fruta dourada per Corrida (F/P, Vale) | Vale level 3 % | Vale max speed |")
	print("|---|---|---|---|---|---|---|---|---|")
	var fastest := 0.0
	for rival in Race.RIVALS:
		for bot in ["good", "medium", "idle"]:
			var base := _cell(rival, bot, ["forest", "beach"])
			var vale := _cell(rival, bot, ["valley"])
			fastest = maxf(fastest, vale.fastest)
			print("| %s | %s | %d | %d | %.1f | %.1f | %.1f / %.1f | %d | %.2f |" % [rival, bot, base.wins, vale.wins, _median(vale.voltas), _median(vale.corridas), base.golden, vale.golden, vale.level_three, vale.fastest])
	print("Practical maximum speed observed in the Vale: %.2f u/s" % fastest)
	quit()

func _cell(rival: String, bot: String, circuits: Array) -> Dictionary:
	var runs := 0
	var wins := 0
	var golden := 0
	var level_three := 0
	var fastest := 0.0
	var voltas: Array[float] = []
	var corridas: Array[float] = []
	for circuit in circuits:
		for dino in Race.DINOS:
			for seed in range(1, SEEDS + 1):
				var race := Race.new()
				race.configure(dino, circuit, rival)
				race.rng.seed = seed
				race.reset()
				race.start()
				race.advance(3)
				var time := 0.0
				var lap_start := 0.0
				var lap := 1
				var offered := false
				var reached := false
				while race.stage != "finished" and time < 600:
					race.advance(STEP, Callable(Bots, bot).call(race, STEP))
					time += STEP
					if race.lap != lap or race.stage == "finished":
						voltas.append(time - lap_start)
						lap_start = time
						lap = race.lap
					if not race.recovery_fruit.is_empty() and not offered:
						golden += 1
					offered = not race.recovery_fruit.is_empty()
					fastest = maxf(fastest, race.speed)
					if race.recovery_boost_left == 0 and Race.speed_level(race.speed - race.base_speed) == 3:
						reached = true
				runs += 1
				corridas.append(time)
				wins += int(race.winner == "player")
				level_three += int(reached)
	return {"wins": roundi(100.0 * wins / runs), "golden": float(golden) / runs, "level_three": roundi(100.0 * level_three / runs), "fastest": fastest, "voltas": voltas, "corridas": corridas}

func _median(values: Array[float]) -> float:
	var sorted := values.duplicate()
	sorted.sort()
	return sorted[sorted.size() / 2]

extends SceneTree

const Race := preload("res://race/race_state.gd")

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	var largest_gap := 0.0
	var race := Race.new()
	assert(race.configure_coop("trex", "raptor", "forest"))
	assert(race.mode == "coop" and not race.solo)
	assert(race.base_speed == 2.27 and race.rival_base_speed == 2.13)
	race.start()
	assert(not race.configure_coop("trex", "trex", "beach"))
	race.advance(3)
	race.advance(0.1, 1, -1)
	assert(race.lateral > -0.9 and race.rival_lateral < 0.9)
	var before := [race.distance, race.rival_distance, race.track_id, race.dino_id, race.partner_id]
	assert(not race.configure_coop("bad", "trex", "beach"))
	assert([race.distance, race.rival_distance, race.track_id, race.dino_id, race.partner_id] == before)
	race.advance(NAN)
	race.advance(0.1, INF)
	assert([race.distance, race.rival_distance, race.track_id, race.dino_id, race.partner_id] == before)
	for first in Race.DINOS:
		for second in Race.DINOS:
			for track in Race.TRACKS:
				race = Race.new()
				race.rng.seed = 71
				assert(race.configure_coop(first, second, track))
				assert(race.base_speed == Race.DINOS[first].speed and race.rival_base_speed == Race.DINOS[second].speed)
				race.start()
				for step in range(16000):
					var old := Vector2(race.distance, race.rival_distance)
					race.advance(0.05, sin(step * 0.02), -sin(step * 0.03))
					assert(race.distance >= old.x and race.rival_distance >= old.y)
					largest_gap = maxf(largest_gap, absf(race.distance - race.rival_distance))
					assert(absf(race.distance - race.rival_distance) <= 18.00001)
					assert(race.winner.is_empty() and race.rival_distracted_left == 0 and race.rival_target_fruit == -1)
					if race.stage == "finished":
						break
				assert(race.stage == "finished" and race.distance == race.length and race.rival_distance == race.length, "%s/%s/%s" % [first, second, track])
				assert(race.lap == race.laps and race.rival_lap == race.laps)
	for leader in [0, 1]:
		race = Race.new()
		race.configure_coop("trex", "raptor", "valley")
		race.fruits.clear()
		race.arrows.clear()
		race.start()
		race.advance(3)
		for step in range(3000):
			race.speed = 60 if leader == 0 else 2.27
			race.rival_speed = 60 if leader == 1 else 2.13
			race.boost_left = 1
			race.rival_boost_left = 1
			var old := Vector2(race.distance, race.rival_distance)
			race.advance(0.1, -1 if leader == 0 else 1, 1 if leader == 0 else -1)
			assert(race.distance >= old.x and race.rival_distance >= old.y)
			largest_gap = maxf(largest_gap, absf(race.distance - race.rival_distance))
			assert(absf(race.distance - race.rival_distance) <= 18.00001)
		assert(race.lateral == (-1.65 if leader == 0 else 1.65))
		assert(race.rival_lateral == (1.65 if leader == 0 else -1.65))
	for track in Race.TRACKS:
		for leader in [0, 1]:
			race = Race.new()
			race.configure_coop("triceratops", "trex", track)
			race.start()
			race.advance(3)
			race.fruits.clear()
			race.arrows.clear()
			race.distance = race.length - (0.01 if leader == 0 else 2)
			race.rival_distance = race.length - (0.01 if leader == 1 else 2)
			race.advance(0.1)
			assert(race.stage == "racing" and race.winner.is_empty())
			race.paused = true
			before = [race.distance, race.rival_distance]
			race.advance(20, -1, 1)
			assert([race.distance, race.rival_distance] == before)
			race.paused = false
			race.advance(2)
			assert(race.stage == "finished" and race.winner.is_empty())
			race.reset()
			assert(race.total_collected == 0 and race.total_golden == 0 and race.partner_arrows == 0 and race.partner_streak == 0)
			assert(race.configure("raptor", "forest", "none") and race.mode == "solo")
			assert(race.configure("trex", "beach", "sleepy") and race.mode == "competitive")
	for track in Race.TRACKS:
		race = Race.new()
		race.configure_coop("triceratops", "raptor", track)
		race.start()
		race.advance(3)
		race.fruits = [{"distance": 6.0, "lateral": 0.0, "owner": "", "respawn": 0.0, "player_taken": false, "rival_taken": false}]
		race.arrows.clear()
		race.lateral = 0
		race.rival_lateral = 0
		race.recovery_cooldown = 100
		race.distance = 5
		race.rival_distance = 0
		race.advance(0.4)
		assert(race.collected == 1 and race.partner_collected == 0 and race.total_collected == 1)
		race.advance(0.1)
		assert(race.total_collected == 1)
		for step in range(50):
			race.advance(0.05)
		assert(race.partner_collected == 1 and race.total_collected == 2)
		if track == "valley":
			race.distance = race.lap_length - 0.05
			race.rival_distance = race.lap_length - 4
			race.advance(0.1)
			assert(race.lap == 2 and race.rival_lap == 1)
			assert(not race.fruits[0].player_taken and race.fruits[0].rival_taken)
			race.advance(1.5)
			race.distance = race.lap_length + 5.8
			race.advance(0.1)
			assert(race.collected == 2 and race.partner_collected == 1)
			race.fruits.clear()
			race.arrows = [{"distance": 3.0, "lateral": 0.0}]
			race.distance = 2.9
			race.rival_distance = 2.9
			var total := race.total_collected
			race.advance(0.1)
			assert(race.arrows_taken == 1 and race.partner_arrows == 1 and race.total_collected == total)
		for target in ["player", "rival"]:
			race.reset()
			race.start()
			race.advance(3)
			race.fruits.clear()
			race.arrows.clear()
			race.distance = 20 if target == "player" else 37
			race.rival_distance = 20 if target == "rival" else 37
			race.advance(0.01)
			assert(race.recovery_fruit.target == target)
			assert(race.recovery_fruit.left == 5 and race.recovery_cooldown == 10)
			if target == "player":
				race.distance = race.recovery_fruit.distance - 0.4
			else:
				race.rival_distance = race.recovery_fruit.distance - 0.4
			race.advance(0.05)
			assert(race.total_collected == 1 and race.total_golden == 1)
			assert((race.golden_collected if target == "player" else race.partner_golden) == 1)
			assert((race.recovery_boost_left if target == "player" else race.rival_recovery_boost_left) == (6 if track == "valley" else 4))
	assert(largest_gap > 15, "Vale recovery threshold remains reachable under bounded help")
	print("Largest observed assisted gap: ", largest_gap, " m")
	print("Coop state passed: 27 species/track combinations, both leaders under extreme speed, monotonic progress/separation, both first finishers, waits/pause/reset/modes, respawn and unequal laps, arrows, golden for both slots on all tracks.")
	quit()

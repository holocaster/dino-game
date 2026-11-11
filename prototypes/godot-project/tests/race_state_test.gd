extends SceneTree

const Race := preload("res://race_state.gd")

func _initialize() -> void:
	create_timer(15).timeout.connect(func(): quit(1))
	var race := Race.new()
	assert(race.length > 80 and race.length < 90)
	assert(race.sample(0).origin.distance_to(race.sample(race.length).origin) < 0.001)
	assert(race.sample(0).x.dot(race.sample(race.length - 0.01).x) > 0.999)
	race.advance(1)
	assert(race.distance == 0 and race.stage == "ready")
	race.start()
	race.advance(2.9, 1)
	assert(race.distance == 0 and race.lateral == -0.9)
	race.advance(0.1)
	assert(race.stage == "racing" and race.distance < 0.001)
	for i in range(60):
		race.advance(0.1)
		if race.collected > 0:
			break
	assert(race.collected == 1 and is_equal_approx(race.speed, Race.BASE_SPEED + Race.FRUIT_BOOST))
	var count := race.collected
	for i in range(5):
		race.advance(0.1)
	assert(race.collected == count)
	race.paused = true
	var distance := race.distance
	race.advance(20, 1)
	assert(race.distance == distance)
	race.paused = false
	for i in range(30):
		race.advance(0.1, 1)
	assert(is_equal_approx(race.lateral, Race.LATERAL_LIMIT))
	for i in range(30):
		race.advance(0.1, -1)
	assert(is_equal_approx(race.lateral, -Race.LATERAL_LIMIT))
	for i in range(700):
		race.advance(0.1)
	assert(race.stage == "finished" and race.distance == race.length)
	assert(race.winner in ["player", "friend", "both"])
	var finish := race.distance
	race.advance(10, 1)
	assert(race.distance == finish)
	race.reset()
	assert(race.stage == "ready" and race.distance == 0 and race.rival_distance == 0)
	assert(race.speed == Race.BASE_SPEED and race.collected == 0 and race.winner.is_empty())
	assert(race.lateral == -0.9 and not race.paused)
	assert(race.fruits.all(func(fruit): return fruit.owner.is_empty()))
	race.start()
	race.advance(3)
	race.distance = race.length - 0.1
	race.rival_distance = race.length - 0.2
	race.speed = 3
	race.rival_speed = 2.35
	race.advance(0.1)
	assert(race.winner == "player")
	race.reset()
	race.start()
	race.advance(3)
	race.distance = race.length - 0.2
	race.rival_distance = race.length - 0.1
	race.advance(0.1)
	assert(race.winner == "friend")
	print("Race state checks passed: closed loop, countdown, automatic movement, unique pickup, boost, pause, lateral bounds, finish, both winners and reset.")
	quit()

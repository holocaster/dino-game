extends SceneTree

class RecordedRace extends "res://race/race.gd":
	var events: Array[Dictionary] = []
	func _notify(data: Dictionary) -> void:
		events.append(data)

func _initialize() -> void:
	create_timer(30).timeout.connect(func(): quit(1))
	_run.call_deferred()

func emitting(effects: Dictionary) -> Array:
	return [effects.dust.emitting, effects.trail.emitting, effects.sparks.emitting]

func _run() -> void:
	set_meta("race_selection", ["raptor", "beach", "speedy"])
	set_meta("race_color", "natural")
	var game := RecordedRace.new()
	root.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	await physics_frame
	var effects: Node3D = game.speed_effects
	var player: Dictionary = effects.runners[0]
	var rival: Dictionary = effects.runners[1]
	assert(player.dust.get_parent() == game.dinosaur and rival.dust.get_parent() == game.friend)
	assert(player.trail.mesh.material.albedo_color == effects.DINO_COLORS.raptor)
	assert(rival.trail.mesh.material.albedo_color == game.RIVAL_COLORS.speedy)
	var race = game.race
	race.speed = race.base_speed + race.MAX_BOOST
	effects.advance()
	assert(emitting(player) == [false, false, false], "No effects before the race starts")
	race.start()
	race.advance(3.1)
	assert(race.stage == "racing")
	race.speed = race.base_speed + race.FRUIT_BOOST * 2
	race.rival_speed = race.rival_base_speed
	effects.advance()
	assert(emitting(player) == [true, false, false] and emitting(rival) == [false, false, false])
	race.speed = race.base_speed + race.MAX_BOOST
	effects.advance()
	assert(emitting(player) == [true, true, false])
	race.recovery_boost_left = race.RECOVERY_DURATION
	race.rival_recovery_boost_left = race.RECOVERY_DURATION
	effects.advance()
	assert(emitting(player) == [true, true, true] and emitting(rival) == [true, true, true])
	game.events.clear()
	game._report()
	assert(game.events[0].speedLevel == 3)
	race.paused = true
	effects.advance()
	assert(player.values().all(func(emitter): return emitter.speed_scale == 0.0))
	race.paused = false
	effects.advance()
	assert(player.values().all(func(emitter): return emitter.speed_scale == 1.0))
	var base_fov: float = game.base_fov
	for i in range(20):
		race.recovery_boost_left = race.RECOVERY_DURATION
		game._process(0.1)
	assert(game.camera.fov > base_fov + game.FOV_RUSH * 0.8 and game.camera.fov <= base_fov + game.FOV_RUSH)
	game._web_command(["color:ocean"])
	assert(player.trail.mesh.material.albedo_color == game.PLAYER_COLORS.ocean)
	game.reset_race()
	assert(game.camera.fov == base_fov)
	assert(emitting(player) == [false, false, false] and emitting(rival) == [false, false, false])
	effects.advance()
	assert(emitting(player) == [false, false, false], "Ready stage keeps effects off after restart")
	print("Speed effects passed: levels, both runners, colors, pause, camera rush and reset")
	quit(0)

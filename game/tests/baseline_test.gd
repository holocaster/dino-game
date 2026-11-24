extends SceneTree

const Race := preload("res://race/race_state.gd")
const Bots := preload("res://tests/bots.gd")

const EXPECTED := {
	"triceratops/forest/sleepy/good": "player 12 0 700 84.8639 2.4880 80.1120",
	"triceratops/forest/sleepy/medium": "player 8 0 735 84.8639 2.2000 78.0740",
	"triceratops/forest/sleepy/idle": "rival 8 0 773 84.8639 2.2000 84.8639",
	"triceratops/forest/playful/good": "player 12 0 706 84.8639 2.2000 84.7106",
	"triceratops/forest/playful/medium": "rival 8 0 752 84.8639 2.2000 84.8639",
	"triceratops/forest/playful/idle": "rival 9 1 711 84.8639 2.2000 84.8639",
	"triceratops/forest/speedy/good": "player 12 0 698 84.8639 2.2000 81.6740",
	"triceratops/forest/speedy/medium": "rival 8 0 739 84.8639 2.2000 84.8639",
	"triceratops/forest/speedy/idle": "rival 9 1 699 84.8639 2.2000 84.8639",
	"triceratops/forest/none/good": "player 12 0 704 84.8639 2.2000 0.0000",
	"triceratops/forest/none/medium": "player 9 0 733 84.8639 2.2000 0.0000",
	"triceratops/forest/none/idle": "player 12 0 699 84.8639 2.2000 0.0000",
	"triceratops/beach/sleepy/good": "player 12 0 681 82.1770 2.2000 77.5500",
	"triceratops/beach/sleepy/medium": "player 9 0 717 82.1770 2.2320 78.8028",
	"triceratops/beach/sleepy/idle": "player 8 0 749 82.1770 2.2000 76.8700",
	"triceratops/beach/playful/good": "player 12 0 674 82.1770 2.2000 80.5810",
	"triceratops/beach/playful/medium": "rival 8 0 730 82.1770 2.2000 82.1770",
	"triceratops/beach/playful/idle": "rival 9 1 686 82.1770 2.2000 82.1770",
	"triceratops/beach/speedy/good": "player 12 0 677 82.1770 2.2000 79.0766",
	"triceratops/beach/speedy/medium": "rival 8 0 695 82.1770 2.2000 82.1770",
	"triceratops/beach/speedy/idle": "rival 9 1 671 82.1770 2.2000 82.1770",
	"triceratops/beach/none/good": "player 12 0 677 82.1770 2.2000 0.0000",
	"triceratops/beach/none/medium": "player 9 0 706 82.1770 2.2000 0.0000",
	"triceratops/beach/none/idle": "player 12 0 675 82.1770 2.2000 0.0000",
	"trex/forest/sleepy/good": "player 12 0 676 84.8639 2.2700 83.3120",
	"trex/forest/sleepy/medium": "player 8 0 693 84.8639 2.2700 79.1100",
	"trex/forest/sleepy/idle": "rival 8 0 751 84.8639 2.2700 84.8639",
	"trex/forest/playful/good": "player 12 0 684 84.8639 2.2700 81.3088",
	"trex/forest/playful/medium": "rival 8 0 719 84.8639 2.2700 84.8639",
	"trex/forest/playful/idle": "rival 8 0 736 84.8639 2.2700 84.8639",
	"trex/forest/speedy/good": "player 12 0 668 84.8639 2.3980 83.2640",
	"trex/forest/speedy/medium": "player 8 0 701 84.8639 2.2700 84.2974",
	"trex/forest/speedy/idle": "rival 9 1 676 84.8639 2.2700 84.8639",
	"trex/forest/none/good": "player 12 0 678 84.8639 2.2700 0.0000",
	"trex/forest/none/medium": "player 9 0 711 84.8639 2.2700 0.0000",
	"trex/forest/none/idle": "player 12 0 677 84.8639 2.6220 0.0000",
	"trex/beach/sleepy/good": "player 12 0 656 82.1770 2.2700 75.6336",
	"trex/beach/sleepy/medium": "rival 8 0 708 82.1770 2.2700 82.1770",
	"trex/beach/sleepy/idle": "rival 8 0 712 82.1770 2.2700 82.1770",
	"trex/beach/playful/good": "player 12 0 656 82.1770 2.2700 79.3260",
	"trex/beach/playful/medium": "rival 8 0 698 82.1770 2.2700 82.1770",
	"trex/beach/playful/idle": "rival 8 0 728 82.1770 2.2700 82.1770",
	"trex/beach/speedy/good": "rival 12 0 664 82.1770 2.2700 82.1770",
	"trex/beach/speedy/medium": "rival 8 0 697 82.1770 2.2700 82.1770",
	"trex/beach/speedy/idle": "rival 9 1 653 82.1770 2.2700 82.1770",
	"trex/beach/none/good": "player 12 0 670 82.1770 2.3340 0.0000",
	"trex/beach/none/medium": "player 9 0 687 82.1770 2.2700 0.0000",
	"trex/beach/none/idle": "player 12 0 664 82.1770 2.2700 0.0000",
	"raptor/forest/sleepy/good": "player 12 0 731 84.8639 2.1300 83.2740",
	"raptor/forest/sleepy/medium": "player 9 0 767 84.8639 2.1300 80.7652",
	"raptor/forest/sleepy/idle": "rival 8 0 795 84.8639 2.1300 84.8639",
	"raptor/forest/playful/good": "player 12 0 709 84.8639 2.1300 83.1995",
	"raptor/forest/playful/medium": "rival 8 0 758 84.8639 2.1300 84.8639",
	"raptor/forest/playful/idle": "rival 9 1 733 84.8639 2.1300 84.8639",
	"raptor/forest/speedy/good": "rival 11 0 734 84.8639 2.2260 84.8639",
	"raptor/forest/speedy/medium": "rival 9 1 717 84.8639 2.1300 84.8639",
	"raptor/forest/speedy/idle": "rival 9 1 719 84.8639 2.1300 84.8639",
	"raptor/forest/none/good": "player 12 0 725 84.8639 2.1300 0.0000",
	"raptor/forest/none/medium": "player 9 0 752 84.8639 2.1300 0.0000",
	"raptor/forest/none/idle": "player 12 0 721 84.8639 2.1620 0.0000",
	"raptor/beach/sleepy/good": "player 12 0 693 82.1770 2.1300 76.9820",
	"raptor/beach/sleepy/medium": "player 9 0 754 82.1770 2.1300 79.8600",
	"raptor/beach/sleepy/idle": "rival 8 0 771 82.1770 2.1300 82.1770",
	"raptor/beach/playful/good": "player 12 0 691 82.1770 2.1300 76.6453",
	"raptor/beach/playful/medium": "player 9 1 707 82.1770 2.1300 81.9525",
	"raptor/beach/playful/idle": "rival 9 1 696 82.1770 2.1300 82.1770",
	"raptor/beach/speedy/good": "player 12 0 686 82.1770 2.2900 78.4300",
	"raptor/beach/speedy/medium": "rival 9 1 682 82.1770 2.4180 82.1770",
	"raptor/beach/speedy/idle": "rival 9 1 680 82.1770 2.1300 82.1770",
	"raptor/beach/none/good": "player 12 0 699 82.1770 2.1300 0.0000",
	"raptor/beach/none/medium": "player 9 0 744 82.1770 2.1300 0.0000",
	"raptor/beach/none/idle": "player 12 0 694 82.1770 2.1300 0.0000"
}

func _initialize() -> void:
	create_timer(15).timeout.connect(func(): quit(1))
	_run.call_deferred()

func _run() -> void:
	var runs := 0
	var mismatches: Array[String] = []
	for dino in ["triceratops", "trex", "raptor"]:
		for circuit in ["forest", "beach"]:
			for rival in ["sleepy", "playful", "speedy", "none"]:
				for bot in ["good", "medium", "idle"]:
					runs += 1
					var race := Race.new()
					race.configure(dino, circuit, rival)
					race.rng.seed = runs
					race.reset()
					race.start()
					var steps := 0
					while race.stage != "finished" and steps < 5000:
						race.advance(0.05, Callable(Bots, bot).call(race))
						steps += 1
					var key := "%s/%s/%s/%s" % [dino, circuit, rival, bot]
					var actual := "%s %d %d %d %.4f %.4f %.4f" % [race.winner, race.collected, race.golden_collected, steps, race.distance, race.speed, race.rival_distance]
					if EXPECTED.get(key) != actual:
						mismatches.append("\t\"%s\": \"%s\"," % [key, actual])
	assert(runs == EXPECTED.size(), "Run count %d differs from %d recorded fingerprints" % [runs, EXPECTED.size()])
	assert(mismatches.is_empty(), "Floresta/Praia behaviour changed (expected values recorded before Vale):\n" + "\n".join(mismatches))
	print("Baseline checks passed: %d Floresta/Praia Corridas match their recorded fingerprints." % runs)
	quit()

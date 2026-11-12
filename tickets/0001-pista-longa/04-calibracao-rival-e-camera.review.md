status: approved
ticket: tickets/0001-pista-longa/04-calibracao-rival-e-camera.md
reviewed_range: 2f074301fad6ef8b21b1f94ef94c761938d0c23e..7c59ed3b114ee932d095560042567882e9e8a590

All 7 acceptance criteria pass. Security (BRANCH, gitleaks): 0 findings. npm test 18/18, test:godot all pass, sim:valley rerun matches the implementer's table.

Simulation (player win % F/P -> Vale): sleepy 96/83/52 -> 99/90/48, playful 92/57/13 -> 97/51/7, speedy 82/10/2 -> 81/9/0. Idle level 3: 2/4/14%. Median Corrida: good 148-157 s, medium 175-185 s, idle 176-197 s. Max speed 5.05 u/s, camera 24.6 deg/s.
Constants: VALLEY_DECAY 0.28, VALLEY_SECTIONS 8, VALLEY_RECOVERY_GAP 30, VALLEY_RIVALS sleepy miss 0.3; playful speed 2.3 miss 0.6; speedy speed 2.5 miss 0.65.
Reference table differs from measured baseline by >10 pp in sleepy/medium and speedy/good (reported, not tuned).

Suggestion (accepted and logged by Main): Fruta dourada up to 8.6 per Corrida in lopsided Vale races (~3.5/min vs ~2.1/min on F/P); kept as comeback mechanic, no Vale cooldown.

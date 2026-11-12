status: approved
ticket: tickets/0001-pista-longa/03-retorno-decrescente-e-setas.md
reviewed_range: cde874a6f2bf8880f6c879911949041fe196f99b..918268da9a83bd47901797ab6c37d7ccb88766c6

All 10 acceptance criteria pass. Security (BRANCH, gitleaks): 0 findings. npm test 18/18, test:godot all pass, baseline unchanged.

Suggestions: _layout check weakened to >= 20 fruits (could assert 8x5 + 2x2); Seta placement relies on section % (sections/2) == 0 landing on straights, keep _arrow_layout green if ticket 04 retunes geometry.
Residual for ticket 04: speed reaches ~3x base, idle bot reaches level 3 in every Corrida, median Corrida 114-134 s. Pre-existing physics push-back (~0.1 u) could in theory let a Corredor re-cross a Seta (unreproduced).

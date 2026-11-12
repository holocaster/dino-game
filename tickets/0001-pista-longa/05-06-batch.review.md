status: changes_requested
ticket: [tickets/0001-pista-longa/05-hud-voltas-e-adesivo.md, tickets/0001-pista-longa/06-entrega-0-25-0.md]
reviewed_range: f9bd4f71118a4f73e4e9d55ac3270d513a3ad908..f68a2cb7c7549d4a452675285b518475f8ee6a7b

All automated criteria pass (npm test 19/19, test:godot, pack byte-identical to fresh export, +5,840 B). Security (BRANCH, gitleaks): 0 findings. Deviations (last-lap re-arm on lap < laps, copy keyed on laps > 1, project.godot version bump) accepted.

Findings:
1. important - web/game.css:163 compact landscape (max-height 500px) clips .invitation to 1x1 px, so #lap-count ("Volta N/3") and the "Última volta!" text are invisible there. Required: make "Volta N/3" visible in that layout (e.g. move #lap-count out of .invitation into the grid/HUD, or show the Volta in the HUD there).
2. important - changelog.md 0.25.0 "Problemas aceitos" omits the brief's second accepted issue: median Corrida 175-197 s for medium/idle robots, a little above 3 min, accepted to keep level 3 an achievement. Required: add it.
3. suggestion - web/game.js solo finish panel title "Volta tranquila completa!" stays singular after three Voltas; use a plural form when laps > 1.

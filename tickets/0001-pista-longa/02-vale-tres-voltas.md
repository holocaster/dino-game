# 02: Vale playable over three Voltas

**What to build:** a child can pick the "Vale" card and race a full three-Volta Corrida on a stadium-shaped Pista in an open field, against any Rival or Sozinho, with the existing (capped) speed rules. Frutinhas come back every Volta, the finish and progress cover the whole Corrida, and the Godot report tells the page which Volta the player is on. Floresta and Praia are untouched.

**Blocked by:** 01 (Pin Floresta/Praia behaviour with a characterization test and shared bots).

**Spec:** `docs/specs/0001-pista-longa.md` - Requirements R1, R2, R3, R4, R5, R11 (three Voltas part), R12 (finish margin), R15, R18; Implementation Decisions (Race state: Track catalog, Lap vs race length, Lap-local positions, Per-lap reset; Race scene and scenery; Web page: track card); Testing Decisions (Vale rule test). **ADRs:** `docs/adrs/0001-retorno-decrescente-so-no-vale.md`.

- [ ] `TRACKS` is `forest, beach, valley`; `configure(dino, "valley", rival)` succeeds for every Dino and Rival including `none`, and `select:<dino>:valley:<rival>` is accepted by the bridge.
- [ ] The Vale curve is a closed stadium: two straights and two curves, `lap_length` between 150 and 180 u, centre-line minimum curve radius at least 10 u.
- [ ] Race state exposes `lap_length`, `laps` (1 on Floresta/Praia, 3 on Vale) and `lap` (player's Volta, 1..laps); `length == lap_length * laps`; `sample()` wraps by `lap_length`.
- [ ] Frutinha distances are lap-local; pickup, Rival target choice and assist use lap-local progress; each Corredor's taken flags reset when it starts a new Volta, so it can take each Frutinha again (the same layout every Volta). Within a Volta the existing respawn/single-owner rules hold.
- [ ] A Vale Frutinha layout exists (forks in today's 5-fruit shape spread along the Volta; the one-sided choice stretches on the straights are added in ticket 03), none in the first `lap_length / 22` or last 8 u of a Volta.
- [ ] Winner and `stage == "finished"` happen only at the end of the third Volta; the Fruta dourada finish margin (12 u) applies to the end of the Corrida only.
- [ ] Scene: boundaries, start gate, edge markers, track coordinate unwrapping, puddles, birds and spectators follow `lap_length`; runners keep correct progress across Volta boundaries (no jump back to 0 and no skipped Volta); puddles splash on every pass.
- [ ] `world/forest.gd` has a `valley` theme: open-field terrain under the whole stadium and surroundings, gentle height, trees away from the track via the existing rules, no pond, no new assets. The forest-only camera "vista" zone does not affect the Vale.
- [ ] The `park-race` report includes `lap` and `laps` on every Pista.
- [ ] Web: third card "Vale" (`value="valley"`) with a CSS-only preview in "Onde vamos brincar?"; `catalog.test.mjs` passes.
- [ ] New Godot Vale test (added to `test:race`) covers: geometry bounds, closed loop, `lap` progression 1->2->3, finish at `length`, per-Volta Frutinha reset, Fruta dourada not spawning in the last 12 u of the Corrida but allowed near the end of Voltas 1-2, Sozinho finishing three Voltas with the assist collecting Frutinhas, and a scene run (all Dinos) checking track clear of trunks/blocked cells, terrain under the track, character on screen, finish reached, and `lap`/`laps` in the report.
- [ ] The characterization test from ticket 01 passes unchanged; all existing Godot and Node tests pass.
- [ ] Browser validation is done by the orchestrator (Playwright) after implementation; do not require a browser. No version bump (ticket 06).

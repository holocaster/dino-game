# Spec 0001 - Pista longa (Vale)

Brief: `docs/briefs/0001-pista-longa.md`. Vocabulary: `docs/CONTEXT.md`. Decision record: `docs/adrs/0001-retorno-decrescente-so-no-vale.md`.

## Problem Statement

A Corrida on Floresta or Praia is one short Volta (about 85 u, well under a minute). Children lose the feeling of a real race: there is no long stretch to build up speed, the Impulso is capped at four Frutinhas, and the race ends just as it gets exciting. Any change to the speed rules of the existing Pistas would break the Rival win rates that were calibrated by simulation and protected by tests.

## Solution

A third Pista, **Vale**: a stadium-shaped circuit with long straights and wide curves, raced over three Voltas of about 150-180 u each (45-60 s per Volta, a 2-3 minute Corrida). Only in the Vale, speed follows the **Retorno decrescente** rule: every Impulso adds less the faster the Corredor already is, with no fixed cap; when the Impulso ends, speed falls slowly; steering speed grows with forward speed. Each straight has one **Seta de impulso** on the side opposite that stretch's Frutinhas, so the child chooses between Seta and Frutinha. The Rival follows the same rule and each personality is recalibrated by simulation to keep today's win rates. The web page gets a third track card, a "Volta N/3" counter, a "Última volta!" cue, and a new Adesivo. Floresta and Praia do not change at all.

## Requirements

Each requirement has an id used by the tickets for traceability.

- **R1 Vale selectable.** "Vale" is the third card in "Onde vamos brincar?", after Floresta and Praia. Track id `valley` is accepted by the selection validation and the web bridge (`select:<dino>:valley:<rival>`), for every Dino and every Rival including Sozinho.
- **R2 Stadium geometry.** The Vale is a closed stadium: two long straights joined by two wide curves. One Volta measures 150-180 u. The minimum radius of the centre line in the curves is at least 10 u.
- **R3 Three Voltas.** A Vale Corrida is three Voltas. Progress, finish, winner, Fruta dourada finish margin and the progress bar are measured over the whole Corrida (3 x Volta). Floresta and Praia stay one Volta.
- **R4 Scenery.** Vale scenery uses the existing terrain and tree generators (open field, trees kept away from the track), with no new GLB or asset. The track is clear: no tree trunk, rock or boundary intrudes into the drivable band, and terrain exists under the whole track and its surroundings.
- **R5 Frutinhas every Volta.** Each Volta of the Vale repeats the same Frutinha layout (drawn once per Corrida). Each Corredor can take each Frutinha once per Volta; the existing shared respawn rule still applies within a Volta.
- **R6 Retorno decrescente (Vale only).** Each Impulso adds strictly less bonus the higher the Corredor's current Impulso bonus, is always positive, and there is no fixed cap. The first Impulso from base speed is at least as strong as a Floresta Frutinha.
- **R7 Slow decay (Vale only).** When the Impulso timer ends, speed returns to base speed more slowly than on Floresta/Praia.
- **R8 Lateral grows with speed (Vale only).** Steering speed (player, Rival, Sozinho assist) scales with the Corredor's current forward speed relative to its base speed.
- **R9 Setas de impulso.** Exactly one Seta per straight per Volta, placed on the side opposite to the Frutinhas of that stretch. Passing over a Seta gives the same Impulso as a Frutinha (same timer, same Retorno decrescente gain), increments the Sequência and therefore the Nível de velocidade, works for both Corredores, in every Volta, with no cooldown. A Seta does not count as a Frutinha (fruit counter and "Cesta cheia" are unaffected).
- **R10 Rival same rule, recalibrated.** The Rival uses R6-R9. Each personality (Dorminhoco, Brincalhão, Rapidinho) has Vale-only overrides calibrated by simulation so that the player's win rates against the good/medium/idle bots in the Vale match the Floresta/Praia baseline measured with the same bots (reference values: Dorminhoco 93/66/53%, Brincalhão 91/51/13%, Rapidinho 70/19/2%), within 10 percentage points per cell, keeping good > medium > idle.
- **R11 Sozinho works.** A Sozinho Corrida on the Vale completes three Voltas with no Rival and no Fruta dourada, and the assist still helps a passive child reach Frutinhas.
- **R12 Fruta dourada unchanged.** Same rule. The 12 u finish margin applies to the end of the Corrida, not to each Volta. The 5 u trigger gap may be raised for the Vale only if the simulation shows the Fruta dourada appearing too often; Floresta/Praia keep 5 u.
- **R13 Speed levels unchanged.** Thresholds stay 0.3 / 0.6 / 1.0. In the Vale, level 3 is reachable with a long Sequência of Frutinhas and Setas alone (no Fruta dourada): it takes at least 6 consecutive Impulsos and at most 10.
- **R14 Camera.** In the Vale curves, the camera turn rate needed to follow the centre line (speed x curvature) stays below 50 deg/s at the highest speed reachable in practice (the maximum speed observed in the balance simulation, Fruta dourada included).
- **R15 Report.** The Godot `park-race` report adds `lap` (the player's current Volta, 1..laps, equal to `laps` once finished) and `laps` (1 on Floresta/Praia, 3 on the Vale).
- **R16 Web Volta HUD.** In the Vale only, the footer shows "Volta N/3". When the player enters the last Volta, the status message shows "Última volta!" and a short new sound plays. The progress bars cover the whole Corrida.
- **R17 Rewards.** New Adesivo `valley` "Explorador do vale" (hint "Corra no vale"), earned by finishing a Vale Corrida; total 9. The "Cesta cheia" hint becomes "Pegue 10 frutinhas numa corrida"; its rule (10 Frutinhas in the report) does not change.
- **R18 No regression.** Floresta and Praia rules, balance and visuals are identical (proved by a characterization test captured before any change). Every existing Godot and Node test keeps passing.
- **R19 Delivery.** The web pack grows less than 200 KB. SemVer minor bump to 0.25.0 with changelog entry; every `?v=` equals the `package.json` version; README updated concisely.

## User Stories

1. As a child, I want to pick a third Pista called Vale, so that I can try a longer race (R1).
2. As a child, I want long straights and wide curves, so that I can feel my dino gain speed (R2, R4).
3. As a child, I want the Vale race to last three Voltas, so that the race lasts 2-3 minutes and I have time to come back (R3, R5).
4. As a child, I want every Frutinha to make me faster even when I am already fast, so that a long Sequência keeps paying off (R6, R13).
5. As a child, I want my speed to fade slowly after the Impulso ends, so that a missed Frutinha does not feel like a punishment (R7).
6. As a child, I want my dino to steer faster when it runs faster, so that I can still reach Frutinhas at high speed (R8).
7. As a child, I want a Seta de impulso on each straight opposite the Frutinhas, so that I choose between the Seta and the Frutinha (R9).
8. As a child racing a Rival, I want the Rival to follow the same rules and be as beatable as on the other Pistas, so that the Vale feels fair (R10, R12).
9. As a child playing Sozinho, I want the Vale to work without a Rival, so that I can just enjoy the long ride (R11).
10. As a child, I want the camera to follow smoothly in the curves even at top speed, so that I do not get dizzy or lose my dino (R14).
11. As a child, I want to see "Volta 2/3" and hear when it is the last Volta, so that I know how much is left (R15, R16).
12. As a child, I want a new Adesivo for racing in the Vale, so that I have a reason to try it (R17).
13. As a parent, I want Floresta and Praia to stay exactly as they are, so that the races my child already likes do not change (R18).
14. As a player on a slow connection, I want the update to stay small, so that the game still loads fast (R19).

## Implementation Decisions

### Race state (`race_state.gd`) - the one deep module

All Vale rules live inside the race state. Callers (scene, scenery, tests, web) learn only a few new read-only facts. Floresta and Praia must take exactly the same numeric path as today (R18).

- **Track catalog.** `TRACKS` gains `valley` (order: forest, beach, valley; the web catalog test compares this list with the page). `configure()` builds the Vale curve when `track_id == "valley"`.
- **Lap vs race length.** `length` keeps its meaning: the full race distance (finish line, progress denominator, winner, Fruta dourada margin). New read-only facts: `lap_length` (baked length of the closed curve), `laps` (1 or 3) and `lap` (player's current Volta, `min(floor(distance / lap_length), laps - 1) + 1`). `length = lap_length * laps`. `sample(progress, offset)` wraps by `lap_length`. Rejected alternative: keep `length` as the Volta and add a race length, because every finish/progress caller would have to change.
- **Lap-local positions.** Frutinha and Seta `distance` values are lap-local (0..lap_length). Pickup, Rival target choice and assist compare against the Corredor's lap-local progress (`progress - lap_index * lap_length`, with `lap_index` clamped to `laps - 1`). With `laps == 1` this is the identity, so Floresta/Praia math is unchanged.
- **Per-lap reset.** When a Corredor starts a new Volta, its own `*_taken` flags are cleared; a Frutinha hidden only because both had taken it becomes available again to that Corredor (visible). Respawn and single-owner rules within a Volta are unchanged. `rival_skip` is drawn once per Corrida (not re-drawn per Volta).
- **Vale rules behind one gate.** A Vale-only rule set (constants prefixed `VALLEY_`, or a small per-track rule lookup) holds: laps, Retorno decrescente gain parameters, decay rate, Rival overrides and optional Fruta dourada gap. Callers never branch on the track for speed rules.
- **Single Impulso path.** One internal function applies an Impulso to a Corredor (gain, timer, Sequência for the player). Frutinhas and Setas both call it. On Floresta/Praia it reproduces today's capped behaviour exactly (`min(base + MAX_BOOST, speed + FRUIT_BOOST)`); in the Vale it applies Retorno decrescente.
- **Retorno decrescente shape (recommended, calibrate numbers).** `gain = VALLEY_GAIN / (1 + bonus / VALLEY_SOFTNESS)` where `bonus` is the current Frutinha/Seta bonus over base speed (Fruta dourada excluded). `VALLEY_GAIN >= FRUIT_BOOST`. Calibrate so that level 3 needs 6-10 consecutive Impulsos (R13).
- **Decay.** In the Vale, after the Impulso timer ends, speed moves toward base at `VALLEY_DECAY` u/s^2, smaller than the current `FRUIT_BOOST * 4`. The Sequência still resets when the timer ends (unchanged rule).
- **Lateral scaling.** In the Vale, the player's steer speed, the Rival's steer speed and acceleration, and the assist use a factor `current speed / base speed` (effective speed, Fruta dourada included). On Floresta/Praia the factor is not applied.
- **Setas de impulso.** New `arrows: Array[Dictionary]` with `distance` (lap-local) and `lateral`. Empty on Floresta/Praia. Pickup is geometric in the state (lap-local crossing `previous < d <= current` and `abs(lateral - arrow.lateral) <` the Frutinha pickup half-width 0.8), evaluated after `resolve_motion` like Frutinhas, for both Corredores, in every Volta, no cooldown. Not counted in `collected`. Physics contacts are not used for Setas.
- **Vale layout (drawn per Corrida, repeated every Volta).** Fork sections in the same 5-fruit shape as today (two symmetric pairs plus a central Frutinha) along the Volta, plus, on each straight, one choice stretch: a one-sided group of Frutinhas (recommended 2 in a row) on side S drawn per straight per Corrida, and the Seta on side -S level with the first Frutinha of that group. Spacing is a calibration choice, but along at least one path consecutive Impulsos must be close enough to sustain a Sequência long enough for level 3 (R13). No Frutinha or Seta in the first `lap_length / 22` or last 8 u of a Volta.
- **Rival overrides.** A separate constant (for example `VALLEY_RIVALS`) holds per-personality Vale overrides (base speed at least; reaction/miss/distraction only if calibration needs them). `RIVALS` keeps its shape and values (the catalog test reads its keys). The Rival does not actively steer toward Setas; it gets the Impulso when it crosses one.
- **Fruta dourada.** Logic unchanged; it uses race `length` for the finish margin, which already means "end of the Corrida". The trigger gap reads a Vale override only if calibration sets one.

### Race scene (`race.gd`) and scenery

- Everything that describes the closed circuit uses `lap_length`, not `length`: track boundaries, start gate and decorations, edge markers, track coordinate unwrapping (`_track_coordinates` unwraps the closest lap offset to the multiple of `lap_length` nearest the previous progress), puddles, birds and spectators. Segment counts for boundaries/markers may scale with `lap_length` so curves stay smooth.
- Setas are rendered as flat ground chevrons built from existing primitive helpers (no GLB), one node per `race.arrows` entry, positioned on reset.
- Puddles splash on every pass in the Vale (each Corredor's splash flag re-arms when it starts a new Volta). Birds and spectators keep their once-per-Corrida sounds.
- An Impulso from a Seta plays the existing `pickup` sound (no new Godot sound).
- The report adds `lap` and `laps` (R15).
- `world/forest.gd` gets a `valley` theme (like the existing `beach` branch): open-field terrain mesh and gentle `height_at` covering the stadium and its surroundings, trees placed away from the track by the existing `tree()` rule, no pond. The forest-only camera "vista" zone near (0, -20) in the shared camera code must not affect the Vale: place the stadium away from it or gate it by theme.

### Web page

- Third track card "Vale" (`value="valley"`) with a CSS-only preview, like `.forest-preview`/`.beach-preview`.
- Footer element showing "Volta N/3", visible only when `laps > 1` during a Corrida, hidden in the menu.
- When the reported `lap` becomes equal to `laps` (with `laps > 1`) during racing, the status message shows "Última volta!" and `audio.mjs` plays a new short sound (`last-lap`). The message is not repeated for later reports of the same lap; restart resets it.
- `RaceReport` typedef gains `lap`, `laps`, and `valley` in the track union; the report validation accepts the new numeric fields.
- Copy consistency (planner assumption, see Further Notes): in the Vale the HUD title reads "TRÊS VOLTAS" instead of "UMA VOLTA", and the finish status says "Três voltas completas!" instead of "Uma volta completa!". Floresta/Praia copy is unchanged.
- `rewards.mjs`: add `valley` Adesivo after `beach`; change only the "Cesta cheia" hint text. The static "0/8" counter becomes "0/9".

### Delivery

- Version 0.25.0 in `package.json`, every `?v=` (page, `game.js` imports, Godot shell and exported `godot/index.html`), changelog entry, short README update, web pack re-export and `fileSizes["index.pck"]` update. New `.gd` scripts get their `.uid` files from `godot --headless --path game --import`.

## Testing Decisions

- Good tests assert observable behaviour through the race state's public surface (`configure`, `reset`, `start`, `advance`, `sample`, and the read-only fields: `length`, `lap_length`, `laps`, `lap`, `distance`, `speed`, `streak`, `collected`, `fruits`, `arrows`, `winner`), through the scene's report/events, or through the web modules' exports. They do not restate formulas or inspect private helpers.
- **Characterization test (written first, against unchanged code).** A new Godot test runs fixed-seed, state-only Corridas for every Dino x {forest, beach} x {sleepy, playful, speedy, none} x {good, medium, idle} bot and compares a compact fingerprint per run (winner, collected, golden_collected, finish step, final distance/speed rounded) with values recorded from the current code. It must pass unchanged after every later ticket. Prior art: `balance_test.gd`, `modes_test.gd`.
- **Shared bot policies.** A small test helper script provides the steering policies used by the characterization test and the Vale simulation: good (steer to the nearest Frutinha not yet taken by the player this Volta, or Seta, ahead), medium (only every other Frutinha, no Setas), idle (no steering). Prior art: the steering loop in `balance_test.gd` and `fruit_paths_test.gd`.
- **Vale rule test** (new Godot test, added to `test:race`): geometry (lap length range, closed loop, two straights, minimum curve radius), three Voltas and `lap` progression, finish at `length`, per-Volta Frutinha reset, Seta pickup for both Corredores in every Volta without cooldown and without counting as fruit, Retorno decrescente monotonic and uncapped, slow decay versus Floresta, lateral scaling, level 3 bounds (6-10 Impulsos), Fruta dourada margin at the end of the Corrida, Sozinho three Voltas with assist, camera bound (max curvature x practical max speed < 50 deg/s), plus a scene check (track clear of trunks, terrain under the track, character on screen, report carries `lap`/`laps`). Prior art: `race_state_test.gd`, `fruit_paths_test.gd`, `race_test.gd`, `variety_test.gd`.
- **Vale balance simulation** (on-demand Godot script, npm script `sim:valley`, not in `npm test`/`test:race` because of runtime): measures the Floresta/Praia baseline and the Vale win rates for each personality x bot over 3 Dinos x 30 seeded layouts, plus median Volta time, Fruta dourada appearances and maximum observed speed. Its output is pasted into the changelog/validation note. The practical maximum speed it reports is stored as a constant used by the camera bound in the Vale rule test, which also asserts that a good bot never exceeds it in its fixed-seed runs.
- **Web tests:** `catalog.test.mjs` (track ids now include `valley`; `?v=` check), `rewards.test.mjs` (Adesivo `valley`, total 9, new hint), `audio.test.mjs` (`last-lap` sound plays and respects mute/pause). Browser behaviour (cards, footer, messages, layout) is validated by the orchestrator with Playwright after implementation; implementers do not need a browser.
- Existing tests that iterate over `["forest", "beach"]` keep doing so; Vale coverage lives in the new tests.

## Out of Scope

- Any rule, balance or visual change on Floresta or Praia (see ADR 0001).
- Speed level 4 or new trail effects.
- A Volta banner inside Godot.
- New biome, GLB models or other assets.
- Rival AI that actively seeks Setas.

## Further Notes

- Numbers left to calibration (brief open question): Retorno decrescente gain/softness, decay rate, straight length, curve radius, Frutinha spacing, Vale Rival overrides, Vale Fruta dourada gap. Calibrated values and the simulation table go in the changelog.
- Planner assumptions the orchestrator may veto: (a) on each straight the Frutinhas of the choice stretch are one-sided, because the brief places the Seta "on the opposite side" and symmetric forks have no opposite side; (b) Setas reuse the `pickup` sound; (c) Vale-only copy "TRÊS VOLTAS" / "Três voltas completas!"; (d) puddle splashes re-arm every Volta; (e) R10 tolerance of 10 percentage points per cell with 90 runs per cell; (f) R13 bound of 6-10 consecutive Impulsos as the measurable meaning of "sequência longa".
- Expected Corrida length: three Voltas of 150-180 u at a typical average of about 3 u/s give 2.5-3 min; an idle player at base speed takes longer (about 3.5-4 min). The simulation reports the median per bot.

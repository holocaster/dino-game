# 04: Calibrate Vale Rivals by simulation and bound the camera

**What to build:** each Rival personality is as beatable in the Vale as on Floresta/Praia, the Fruta dourada does not appear too often, the Corrida lasts about 2-3 minutes, and the camera follows the curves without saturating even at the highest speed reached in practice.

**Blocked by:** 01 (Pin Floresta/Praia behaviour with a characterization test and shared bots), 03 (Retorno decrescente and Setas de impulso in the Vale).

**Spec:** `docs/specs/0001-pista-longa.md` - Requirements R10, R11 (assist), R12, R14, R18; Implementation Decisions (Rival overrides, Fruta dourada); Testing Decisions (Vale balance simulation, Vale rule test camera bound). **ADRs:** `docs/adrs/0001-retorno-decrescente-so-no-vale.md`.

- [ ] An on-demand Godot simulation script (npm script `sim:valley`, not part of `npm test` or `test:race`) uses the shared bots and prints, per personality x bot: Floresta/Praia baseline win rate, Vale win rate, median Volta time, Fruta dourada appearances per Corrida, and the maximum speed observed (3 Dinos x 30 seeded layouts per cell).
- [ ] Vale-only per-personality overrides (separate constant, `RIVALS` unchanged) bring every Vale cell within 10 percentage points of the measured baseline, with good > medium > idle. If the baseline itself differs from the reference table (93/66/53, 91/51/13, 70/19/2) by more than 10 points in any cell, report it instead of tuning to the reference.
- [ ] If the simulation shows the Fruta dourada too frequent in the Vale, a Vale-only trigger gap above 5 u is set; Floresta/Praia stay at 5 u. Calibrated numbers (gain, decay, Rival overrides, gap) may be retuned here within the R6-R9 and R13 constraints, keeping ticket 03's tests green.
- [ ] The highest observed speed is stored as a practical maximum constant; the Vale test asserts centre-line max curvature x that speed < 50 deg/s, and that the good bot never exceeds it in its fixed-seed runs.
- [ ] The Vale test adds a fast fixed-seed sanity check of balance ordering for Brincalhão (good bot beats Brincalhão in more runs than idle bot does).
- [ ] The simulation table (baseline and Vale), median Volta/Corrida times and final constants are written into the ticket's handoff for the changelog in ticket 06.
- [ ] Characterization test and all existing tests pass; no browser required; no version bump (ticket 06).

# 01: Pin Floresta/Praia behaviour with a characterization test and shared bots

**What to build:** before any Vale change, a fixed-seed test that records how Corridas on Floresta and Praia play out today, so any later change to the shared race state that alters their rules or balance fails loudly. The bot steering policies it uses become a shared test helper for the Vale simulation.

**Blocked by:** None (can start immediately).

**Spec:** `docs/specs/0001-pista-longa.md` - Requirements R18; Testing Decisions (Characterization test, Shared bot policies). **ADRs:** `docs/adrs/0001-retorno-decrescente-so-no-vale.md`.

- [x] A test helper script under `game/tests/` exposes the three bot policies (good, medium, idle) as defined in the spec, returning a steering value for a race state. Good also targets Setas when `arrows` exists (empty today, so no effect yet); medium takes every other Frutinha and no Setas; idle never steers.
- [x] A new Godot test runs state-only (no scene) Corridas for every Dino x {forest, beach} x {sleepy, playful, speedy, none} x {good, medium, idle}, each with a fixed `rng` seed applied after `configure()` and followed by `reset()`, stepping `advance(0.05, steering)` until finished.
- [x] For each run it compares a compact fingerprint (winner, collected, golden_collected, finish step count, final distance and final speed rounded to 4 decimals) with expected values recorded from the unchanged code and stored literally in the test.
- [x] The expected values are captured from the current code without modifying `race_state.gd`, `race.gd` or any production file in this ticket.
- [x] The test is added to `npm run test:race`, runs well within its own timeout, and prints a one-line summary.
- [x] `npm test` and `npm run test:godot` pass. Run Godot with `XDG_CONFIG_HOME=/tmp/dino-godot-config XDG_DATA_HOME=/tmp/dino-godot-data XDG_CACHE_HOME=/tmp/dino-godot-cache`; after adding `.gd` files run `godot --headless --path game --import` and commit the generated `.uid` files.
- [x] No version bump or changelog entry in this ticket (done in ticket 06).

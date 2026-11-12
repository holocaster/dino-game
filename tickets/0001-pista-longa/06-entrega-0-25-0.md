# 06: Deliver 0.25.0 (export, version, changelog, README)

**What to build:** the Vale ships in the web build as version 0.25.0: re-exported Godot pack, consistent cache versions, a changelog entry with the calibration results, and a concise README update, with the pack growing less than 200 KB.

**Blocked by:** 03 (Retorno decrescente and Setas de impulso in the Vale), 04 (Calibrate Vale Rivals by simulation and bound the camera), 05 (Volta HUD, "Última volta!" and the Vale Adesivo on the page).

**Spec:** `docs/specs/0001-pista-longa.md` - Requirements R18, R19; Implementation Decisions (Delivery).

- [ ] `package.json` version 0.25.0 and every `?v=` (page, `game.js` imports, `game/shell.html`, exported `web/godot/index.html`) equal to it; `catalog.test.mjs` passes.
- [ ] Pack re-exported with `godot --headless --path game --export-pack Web ../web/godot/index.pck`; `fileSizes["index.pck"]` in `web/godot/index.html` updated; new size minus 14,765,324 bytes is under 200 KB (state both sizes in the changelog).
- [ ] Changelog 0.25.0 entry (Portuguese, like previous entries): Vale, three Voltas, Retorno decrescente (Vale only, ADR 0001), Setas, calibrated constants and the simulation table from ticket 04, HUD/Adesivo changes, new tests.
- [ ] README: mentions the Vale and the test count changes, staying concise.
- [ ] `npm test` and `npm run test:godot` pass in full, including the characterization test.
- [ ] Final browser validation (Playwright) is done by the orchestrator after this ticket.

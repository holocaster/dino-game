# 05: Volta HUD, "Última volta!" and the Vale Adesivo on the page

**What to build:** during a Vale Corrida the page footer shows "Volta N/3"; entering the last Volta shows "Última volta!" with a short sound; the progress bars cover the whole Corrida. Finishing a Vale Corrida earns the new Adesivo "Explorador do vale", and "Cesta cheia" now says it counts the whole Corrida. Floresta/Praia copy is unchanged.

**Blocked by:** 02 (Vale playable over three Voltas).

**Spec:** `docs/specs/0001-pista-longa.md` - Requirements R15, R16, R17; Implementation Decisions (Web page); Further Notes (copy assumptions).

- [ ] Footer element shows "Volta N/3" from the report's `lap`/`laps`, only when `laps > 1` and a Corrida is shown; hidden in the menu and on Floresta/Praia.
- [ ] When `lap` becomes equal to `laps` (with `laps > 1`) while racing, the status message shows "Última volta!" and `audio.mjs` plays a new short `last-lap` sound once; not repeated by later reports of the same Volta; reset on restart and menu.
- [ ] Progress bars use the report's whole-Corrida progress (no per-Volta reset).
- [ ] Vale-only copy: HUD title "TRÊS VOLTAS" and finish status "Três voltas completas!" (Floresta/Praia keep "UMA VOLTA" / "Uma volta completa!").
- [ ] `RaceReport` typedef includes `lap`, `laps` and `valley` in the track union; the message validation accepts the report with the new numeric fields.
- [ ] `rewards.mjs`: Adesivo `valley` "Explorador do vale" / "Corra no vale" after `beach`, earned when `track === 'valley'`; 9 Adesivos in total; "Cesta cheia" hint "Pegue 10 frutinhas numa corrida" with the same rule; static counter "0/9".
- [ ] `rewards.test.mjs` and `audio.test.mjs` cover the new Adesivo, the total, the hint text and the `last-lap` sound (including mute/pause); `npm test` passes.
- [ ] Browser checks (layout of footer, messages, card) are done by the orchestrator with Playwright; do not require a browser. No version bump (ticket 06).

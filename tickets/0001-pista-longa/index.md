# Tickets: 0001-pista-longa

Spec: `docs/specs/0001-pista-longa.md` · ADR: `docs/adrs/0001-retorno-decrescente-so-no-vale.md`

| # | Title | Blocked by | Status |
|---|-------|-----------|--------|
| 01 | Pin Floresta/Praia behaviour with a characterization test and shared bots | none | ready |
| 02 | Vale playable over three Voltas | 01 | ready |
| 03 | Retorno decrescente and Setas de impulso in the Vale | 02 | ready |
| 04 | Calibrate Vale Rivals by simulation and bound the camera | 01, 03 | ready |
| 05 | Volta HUD, "Última volta!" and the Vale Adesivo on the page | 02 | ready |
| 06 | Deliver 0.25.0 (export, version, changelog, README) | 03, 04, 05 | ready |

## Requirement coverage

| Requirement | Tickets |
|---|---|
| R1 Vale selectable | 02 |
| R2 Stadium geometry | 02 |
| R3 Three Voltas | 02, 05 |
| R4 Scenery | 02 |
| R5 Frutinhas every Volta | 02 |
| R6 Retorno decrescente | 03 |
| R7 Slow decay | 03 |
| R8 Lateral grows with speed | 03 |
| R9 Setas de impulso | 03 |
| R10 Rival recalibrated | 04 |
| R11 Sozinho works | 02, 04 |
| R12 Fruta dourada | 02, 04 |
| R13 Speed levels / level 3 | 03 |
| R14 Camera | 04 |
| R15 Report lap/laps | 02, 05 |
| R16 Web Volta HUD | 05 |
| R17 Rewards | 05 |
| R18 No regression | 01, 02, 03, 04, 06 |
| R19 Delivery | 06 |

Frontier after 02: 03 and 05 can run in parallel (05 touches only the web page).

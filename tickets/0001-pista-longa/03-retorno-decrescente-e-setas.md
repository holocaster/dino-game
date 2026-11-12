# 03: Retorno decrescente and Setas de impulso in the Vale

**What to build:** in the Vale, every Impulso keeps making the dino faster, just less the faster it already is; speed fades slowly after the Impulso ends; steering grows with speed. Each straight offers a Seta de impulso on the side opposite that stretch's Frutinhas, giving the same Impulso as a Frutinha to either Corredor on every Volta. A long Sequência reaches speed level 3 without the Fruta dourada. Floresta and Praia keep the capped rule.

**Blocked by:** 02 (Vale playable over three Voltas).

**Spec:** `docs/specs/0001-pista-longa.md` - Requirements R6, R7, R8, R9, R13, R18; Implementation Decisions (Vale rules behind one gate, Single Impulso path, Retorno decrescente shape, Decay, Lateral scaling, Setas de impulso, Vale layout; Race scene: Seta rendering and sound). **ADRs:** `docs/adrs/0001-retorno-decrescente-so-no-vale.md`.

- [ ] One internal Impulso path is used by Frutinhas and Setas for both Corredores; on Floresta/Praia it gives exactly today's capped result (characterization test unchanged).
- [ ] Vale gain: strictly positive, strictly decreasing as the current Frutinha/Seta bonus grows, no cap; the first Impulso from base is at least `FRUIT_BOOST`.
- [ ] Vale decay after the Impulso timer ends is slower than Floresta/Praia; the Sequência still resets when the timer ends.
- [ ] Vale lateral scaling: player steering, Rival steer speed and acceleration, and the Sozinho assist scale by current speed / base speed; not applied on Floresta/Praia.
- [ ] `arrows` holds exactly one Seta per straight (two per Volta), lap-local, empty on Floresta/Praia. Each straight's choice stretch has one-sided Frutinhas on side S (drawn per straight per Corrida) and the Seta on side -S level with the first of them.
- [ ] Crossing a Seta gives the same Impulso as a Frutinha (timer and gain), increments the player's Sequência, does not change `collected`, works for both Corredores at the same time, on every Volta, with no cooldown, and is evaluated after the scene's motion resolution.
- [ ] Level 3 (bonus >= 1.0) needs at least 6 consecutive Impulsos and is reached with at most 10; a good bot reaches level 3 at least once in a fixed-seed Vale Corrida without picking a Fruta dourada.
- [ ] Scene renders each Seta as a flat ground chevron from existing primitive helpers (no GLB), repositioned on reset; a Seta Impulso emits the existing `pickup` sound.
- [ ] Vale test extended with: monotonic uncapped gain, slow decay versus Floresta, lateral scaling, Seta pickup rules above for both Corredores across Voltas, Seta not counted as fruit, level 3 bounds, layout rule (Seta opposite the one-sided Frutinhas, one per straight).
- [ ] Characterization test and all existing tests pass; no browser required; no version bump (ticket 06).

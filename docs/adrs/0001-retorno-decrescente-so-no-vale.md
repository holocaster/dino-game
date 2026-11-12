# ADR 0001 - Retorno decrescente só no Vale

Status: accepted (brief 0001-pista-longa, 2026-11-12)

## Context

Floresta and Praia cap the fruit Impulso at a fixed ceiling (`MAX_BOOST`, four Frutinhas). Their Rival win rates (Dorminhoco 93/66/53%, Brincalhão 91/51/13%, Rapidinho 70/19/2% against good/medium/idle players) were calibrated by simulation and are protected by tests. The new long Pista, Vale, needs speed that keeps growing over a three-Volta Corrida.

## Decision

The Retorno decrescente rule (each Impulso adds less the faster the Corredor is, no fixed cap, slow decay, steering that grows with speed) applies only to the Vale. Floresta and Praia keep the fixed `MAX_BOOST` cap and their current decay and steering, with identical numeric behaviour.

## Alternatives

- Apply the new model to every Pista: rejected, it would force recalibrating and re-testing the balance of Floresta and Praia for no user benefit.

## Consequences

- The race state carries two speed rules selected by track. Do not "unify" them without recalibrating every Pista and Rival personality.
- A characterization test pins Floresta/Praia behaviour so an accidental change to the shared code path fails loudly.

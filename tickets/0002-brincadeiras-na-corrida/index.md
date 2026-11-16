# Tickets: 0002-brincadeiras-na-corrida

Implementação sequencial; trabalhar somente um ticket por vez. Estado de cada ticket é mantido neste índice.

| # | Title | Blocked by | Status |
|---|-------|-----------|--------|
| 01 | [Aparência com prévia e acessórios salvos](01-aparencia-e-acessorios.md) | none | ready |
| 02 | [Reações, caminhos expressivos e Filhote na chegada](02-brincadeiras-e-filhote.md) | none | ready |
| 03 | [Dupla completa no mesmo aparelho](03-dupla-cooperativa.md) | 01, 02 | ready |
| 04 | [Entrega 0.28.0 e validação no navegador](04-entrega-0-28-0.md) | 01, 02, 03 | ready |

## Cobertura

| Requisitos da spec | Tickets |
|---|---|
| R1, R2 | 01, 03, 04 |
| R3, R4, R5 | 02, 03, 04 |
| R6, R7, R8, R9, R10, R11, R12 | 03, 04 |
| R13, R14, R15 | 01, 02 (quando aplicável), 03, 04 |
| R16 | 04 |

Spec canônica: `docs/specs/0002-brincadeiras-na-corrida.md`. Próximo ticket recomendado: 01.

# ADR 0002 — Dupla com modo explícito

Status: accepted (brief `0002-brincadeiras-na-corrida`, descoberta confirmada em 2026-11-16).

## Context

O segundo registro de `race_state` representa um Rival e hoje sua presença determina IA, recuperação, câmera e recompensas. Reutilizá-lo para o parceiro humano sem distinguir modo faria cooperação herdar competição ou ser confundida com Sozinho.

## Decision

Adicionar modo explícito `competitive`, `solo` ou `coop`, preservando as chamadas antigas de configuração e avanço. Na Dupla reutilizar os dois registros físicos, com duas espécies e entradas humanas; concluir apenas com ambos na chegada e nenhum vencedor. Não cadastrar parceiro em `RIVALS`. Relatórios identificam modo e fatos por humano; regras de álbum excluem prêmios de competição e de Sozinho na Dupla.

Os comportamentos de câmera compartilhada, ajuda longitudinal, soma e espera vêm do brief, detalhados na spec 0002. ADR 0001 permanece válido para as regras de velocidade por pista.

## Alternatives

- Usar um novo id de Rival para o humano: mistura personalidade competitiva, ausência de IA e semântica de recompensa.
- Refazer todos os corredores como uma coleção genérica: amplia a mudança e arrisca o comportamento calibrado sem necessidade para dois humanos.

## Consequences

As decisões por modo ficam explícitas no estado, cena e validação de recompensas. Os campos antigos do segundo corpo podem continuar internos; não definem o significado de um parceiro na interface. Novos argumentos opcionais e configuração cooperativa evitam migrar os testes/callers dos modos existentes.

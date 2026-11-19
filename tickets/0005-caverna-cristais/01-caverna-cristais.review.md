# Revisão independente — Caverna dos Cristais

**Veredito:** approved, em 2026-11-19. Sem achados.

**Ticket:** `01-caverna-cristais.md`, fast path, sem spec separada.

**Intervalo revisado:** `241be027df88c7eabdad255c8a1e119031da3ea8..632b2a021244a6a60e5e8802096707d336f822d7`.

| Critério | Resultado e evidência |
|---|---|
| 1. Seleção, catálogo, relatórios e dados salvos | Passou: fontes, testes web e seleção no navegador. |
| 2. Uma volta, espécies/modos e regras anteriores | Passou: `cave_test.gd`, 72 referências e chegada real da Dupla. |
| 3. Ambiente claro, arcos, câmera e visibilidade | Passou: capturas, geometria e evidência de 250.032 projeções de câmera. |
| 4. Três encontros opcionais e lados distintos | Passou: teste focado e seis notas observadas no navegador. |
| 5. Passagem física, disparo único e dois humanos | Passou: passagem rápida, centro, repetição, Dupla e limites de áudio. |
| 6. Sem alteração de corrida, colisões ou recompensas | Passou: fatos de estado/volume no teste focado e diff. |
| 7. Pausa, retomada, reinício e troca de pista | Passou: teste focado e navegador com áudio real. |
| 8. Reuso e Compatibility/web | Passou: fontes, pacote e renderização; sem dependências ou geração paga. |
| 9. Cobertura focada e matrizes antigas preservadas | Passou: testes alterados limitados à quinta pista e suas verificações. |
| 10. Suítes e 72 referências | Passou: execução independente web/focada/referências e logs completos inspecionados. |
| 11. Versão, cache, exportação e documentação | Passou: 0.32.0, PCK de 14.809.808 bytes e fixtures ausentes da produção. |
| 12. Navegador largo/vertical, evidências e limites | Passou: seleção, largada, pausa, reinício, chegada e troca de pista. |

## Verificações

- Segurança BRANCH concluída com snapshots fixados e sanitizados. Gitleaks 8.30.1, regras padrão externas, decodificação/arquivos e comparação local com credencial conhecida: nenhum candidato ou correspondência. Nenhum vazamento confirmado ou vulnerabilidade HIGH/MEDIUM de alta confiança. Histórico Git completo não foi escaneado; limites de formatos e profundidade do scanner se aplicam.
- Padrões e critérios: nenhum achado. Árvore limpa na entrada e na saída; revisor não alterou nem commitou arquivos.
- Execuções independentes: `npm test` 31/31, `cave_test.gd` e 72 referências de `baseline_test.gd`. Evidências da suíte completa de 32 scripts Godot + 2 testes Python e da câmera final foram inspecionadas, sem repetir a suíte completa.
- Navegador de produção: Dupla em tela vertical terminou com ambos e 17 frutas; seis notas observadas; pausa/retomada, reinício, troca para Praia e ausência de rolagem horizontal confirmados.
- Web Audio real: tempo e voz preservados na suspensão, nota concluída na retomada, 20 alternâncias rápidas aprovadas; silêncio/reinício limpam vozes e pausa das outras pistas mantém o comportamento anterior. Referência técnica consultada via Context7: `/webaudio/web-audio-api`.

## Limites

Sem benchmark, aparelho físico, teste com crianças ou avaliação auditiva humana. Oito diagnósticos já documentados de descarte de materiais na antiga exploração permanecem fora deste recorte. Evidências funcionais e capturas em `art/cave-validation.md`.

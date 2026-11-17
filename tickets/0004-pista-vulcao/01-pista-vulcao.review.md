# Revisão — pista de vulcão

Status: approved. Ticket: `tickets/0004-pista-vulcao/01-pista-vulcao.md`.

Reviewed range: `46bee82a09fc4f9094d05b1ad0f3834445697510..0245b6e1cc2b5bb3d903da1844c1ef2b94bcb250`.

Revisão independente por `sdd-reviewer` em 2026-11-17, abrangendo a feature inteira de ticket único. Standards: sem achados. Spec: os nove critérios atendidos. Segurança BRANCH: sem credenciais confirmadas ou vulnerabilidades HIGH/MEDIUM de alta confiança nas mudanças.

## Evidências

- Gitleaks 8.30.1 com regras padrão externas, sem ignores locais: um commit, 28 caminhos e 76 versões/artefatos selecionados, zero achados. Comparação com variantes da credencial local relevante: zero correspondências. Histórico completo fora do escopo. Contexto sanitizado em `/tmp/dino-volcano-review-tsvr6ldk`; exportações brutas e relatório bruto removidos.
- Execuções independentes: `npm test` 28/28, `volcano_test.gd`, `baseline_test.gd` 72/72 e `collision_test.gd`, todos com exit 0. Logs `/tmp/dino-volcano-review-node.log`, `/tmp/dino-volcano-review-focus.log`, `/tmp/dino-volcano-review-baseline.log` e `/tmp/dino-volcano-review-collision.log`.
- Suíte completa do implementador conferida em `/tmp/dino-volcano-godot-release.log`: 29 scripts Godot e dois testes Python, sem erro/assert; exit 0 no handoff. Não repetida integralmente pelo revisor.
- Inspeção independente de `art/previews/volcano-desktop.png`, `volcano-coop-portrait.png` e `volcano-solo-finish.png`: lava reconhecível, caminho/frutas legíveis, dois corredores/quatro controles visíveis na vertical e resultado Sozinho correto.
- Guarda de chegada comparada aos chamadores de movimento: reconhece somente o destino final solicitado e fisicamente alcançado; projeção existente preservada nos demais casos. Nove casos físicos e regressão de barreiras passaram.
- Árvore limpa na entrada e saída da revisão. Detalhes da entrega, exportação e navegação real em `art/volcano-validation.md`.

## Limites

Sem teste em hardware físico, medição comparável de desempenho ou avaliação com crianças. Runtime JS/WASM existente reutilizado, com PCK regenerado. Scanner sujeito aos limites usuais de decoding/archive, sem engenharia reversa de assets. Uma execução inicial foi interrompida por sinal 143 sem causa comprovada; execução final completa passou.

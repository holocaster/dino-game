# 04: Entrega 0.28.0 e validação no navegador

**What to build:** entregar as cinco brincadeiras na exportação web, com documentação curta, cache consistente e evidência de que as escolhas e os dois jogadores funcionam no navegador.

**Blocked by:** 01 (Aparência com prévia e acessórios salvos), 02 (Reações, caminhos expressivos e Filhote na chegada), 03 (Dupla completa no mesmo aparelho).

**Spec:** `docs/specs/0002-brincadeiras-na-corrida.md` — R1–R16, com foco em R16 e validação integrada; Implementation Decisions e Testing Decisions. **ADRs:** `docs/adrs/0001-retorno-decrescente-so-no-vale.md`, `docs/adrs/0002-dupla-com-modo-explicito.md`.

- [ ] Versão 0.28.0 em `package.json` e todas as referências `?v=` da página, módulos, shell e exportação; teste de catálogo/cache passa. Gerar `.uid` dos scripts novos com import do Godot, quando necessário.
- [ ] Reexportar pack web a partir da implementação final usando Godot/templates do projeto; atualizar `fileSizes` da exportação e registrar tamanho real na nota/changelog. Confirmar pelo navegador que a exportação servida contém a feature final.
- [ ] Changelog em português descreve reações, caminhos, acessórios, Filhote, Dupla e limites calibrados da ajuda. README informa comandos/controles, persistência e modos com concisão, corrigindo trechos contraditórios com a entrega.
- [ ] `npm test` e `npm run test:godot` completos passam, incluindo os testes novos e os anteriores fora de escopo. Usar diretório temporário gravável para dados/logs do Godot se necessário, sem workaround no código do jogo.
- [ ] Main valida no navegador desktop e vertical: prévia, encaixe de boné/óculos/sem acessório e cores nas três espécies (idle/run); reações, efeitos dos dois lados e Filhote nas três pistas, inclusive zero/derrota. Imagens confirmam visibilidade de dino, acessórios, encontro e resultado.
- [ ] Main valida Dupla com espécies iguais/diferentes, recarga de duas aparências, cada jogador chegando primeiro, conclusão conjunta, enquadramento em curvas e espera, soma/álbum; depois volta a Rival/Sozinho para confirmar que mantêm controles/resultados.
- [ ] Main valida A/D e setas com foco na página/iframe e toque simultâneo real do protocolo de automação com dois ponteiros distintos, soltura/cancelamento independente, pausa/perda de foco/aba oculta/reinício/menu sem controles presos. Chamadas sintéticas ao comando sozinhas não demonstram multitoque da página.
- [ ] Nota curta de validação contém resultados, imagens relevantes, valores da ajuda, versão/tamanho exportado e limitações: emulação não comprova desempenho em aparelho físico nem preferência infantil. Sem geração paga, nova dependência, publicação externa, push ou merge.

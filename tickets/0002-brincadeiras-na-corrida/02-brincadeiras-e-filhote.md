# 02: Reações, caminhos expressivos e Filhote na chegada

**What to build:** brincar com reações automáticas e efeitos diferentes dos lados dos trechos de frutas e encontrar um Filhote que recebe as frutas ao terminar, mesmo com zero coleta ou derrota. Esta fatia é demonstrável em Rival e Sozinho; o ticket 03 integra a mesma apresentação aos dois humanos.

**Blocked by:** None (can start immediately).

**Spec:** `docs/specs/0002-brincadeiras-na-corrida.md` — R3, R4, R5, R14, R15; Implementation Decisions (Cena, aparência e brincadeiras); Testing Decisions (Brincadeiras). **ADRs:** `docs/adrs/0001-retorno-decrescente-so-no-vale.md`.

- [x] Pelo menos duas reações visuais distinguíveis são disparadas por passagem em elementos existentes, sem botão ou interrupção, nos três dinos. Reações são breves, não alteram corpo físico/velocidade e compõem com animação e orientação. Pausa não dispara novas reações; reinício permite repeti-las.
- [x] Ambos os lados dos trechos existentes exibem efeitos visualmente distintos ao passar. Derivar posições do layout existente sem alterar RNG, frutas/Setas, respawn, coleta ou traçado; preservar os trechos assimétricos do Vale.
- [x] Filhote usa modelo existente reduzido, fora da passagem. Na conclusão recebe visualmente a coleta e comemora com zero frutas, após vitória ou derrota, sem exigir ação extra. Resultado/ações e encontro continuam visíveis; não consumir contadores nem recompensas.
- [x] Reiniciar ou mudar de corrida limpa efeitos e sequência do Filhote sem acumular nós; pausa congela novas interações. Apresentação não depende da identidade competitiva do segundo corpo, permitindo integração com Dupla no ticket 03.
- [x] Testes de cena física percorrem os dois lados e poças, verificam efeitos/resposta e invariância da coleta/física, pausa/reset e Filhote em zero/coleta/vitória/derrota. Cobrir Floresta/Praia/Vale; `npm run test:race`, com a caracterização anterior, permanece verde.
- [x] Registrar visuais para conferência no navegador pelo Main nas três espécies/pistas. Sem novos GLBs, dependências, mídia paga ou alterações ao passeio `park`.

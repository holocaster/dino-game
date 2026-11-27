# Desempenho das cinco pistas na 0.34.6

Teste de 27/11/2026 no Moto G56 5G, Chrome 158, com a versão `3e9fce9`. A sessão anterior reduziu o PCK na 0.34.5 e incorporou na 0.34.6 o terreno indexado da Floresta, o compartilhamento de malhas de árvores na Floresta e no Vale e a redução de 60 para 49 árvores na Floresta. O teste anterior da versão final registrou 19,50 s até o primeiro controle na Floresta e 5,29 s na troca da Floresta para o Vale, em medianas de três execuções. [Registro anterior](proximas-otimizacoes.md#validação-do-pacote-web-0346)

## Abertura e troca de pista

O aparelho acessou o servidor local por USB, com gzip, cache HTTP desabilitado e rede emulada a 20 Mbit/s de download, 5 Mbit/s de upload e 70 ms de latência. O tamanho CSS da página foi de 523 × 1027, com DPR 2,0625. A abertura direta de cada pista foi medida uma vez no pacote Web publicado, com Tricerátopo e Brincalhão. O primeiro controle inclui a contagem regressiva. Nas três rodadas competitivas instrumentadas, a troca foi medida da seleção a `park-ready`.

| Pista | Montagem na abertura direta | Abertura até o primeiro controle | Trocas nas rodadas 2 e 3 | Troca na rodada 1 |
| --- | ---: | ---: | ---: | ---: |
| Floresta | 3,88 s | 20,15 s | 2,78–2,83 s | Abertura direta |
| Praia | 1,86 s | 17,95 s | 2,47 s | 7,67 s |
| Vale | 6,26 s | 22,26 s | 6,87 s | 13,03 s |
| Vulcão | 0,87 s | 16,61 s | 1,34–1,40 s | 5,17 s |
| Caverna dos Cristais | 0,82 s | 16,30 s | 1,40–1,42 s | 3,52 s |

O menu aceitou escolhas em 0,32–0,36 s. A última transferência terminou em 7,21–7,48 s e o botão habilitou em 13,22–19,09 s. As cinco aberturas transferiram 10,19 MB de WASM e 3,40 MB de PCK com gzip. Entre `godot:init` e a chegada de `park-ready`, sobram 5,04–5,73 s após descontar a montagem da pista. Esse intervalo inclui os demais custos de inicialização e entrega da mensagem.

- **Floresta e Vale.** O Vale teve a maior espera de abertura e troca. Num perfil nativo headless em processo novo, após carregar a Floresta, o Vale ainda gerou 30 malhas de árvores. A geração levou 186 ms dos 234 ms de montagem nessa execução. Na segunda visita no mesmo processo, foram zero malhas novas e a montagem levou 48 ms. Na Floresta, as 30 malhas novas levaram 187 ms dos 284 ms de montagem, e a segunda visita levou 122 ms. Esses valores isolam trabalho de montagem no desktop. [Cache de árvores](../../game/world/forest.gd#L240) · [Decoração da pista](../../game/race/race.gd#L418)
- **Praia, Vulcão e Caverna.** O mesmo perfil mediu a geração do terreno em 122 ms dos 203 ms de montagem da Praia, 80 ms dos 123 ms do Vulcão e 88 ms dos 128 ms da Caverna. Esse trabalho ocorreu em todas as visitas. A Praia ainda gerou 16 malhas novas de palmeiras na segunda visita. [Praia](../../game/world/forest.gd#L415) · [Vulcão](../../game/world/forest.gd#L548) · [Caverna](../../game/world/forest.gd#L494)
- **Troca.** Mudar de pista recarrega a cena e roda a montagem da pista escolhida. A cronometragem da troca inclui o tempo antes e depois de `_ready()`. [Seleção de corrida](../../game/race/race.gd#L551)

## Fluidez em corrida

Em cada pista e rodada, a cópia de instrumentação mediu dez segundos a partir do primeiro controle. Os tempos são intervalos entre sinais `frame_post_draw` do Godot. P95 indica o tempo abaixo do qual ficaram 95% dos intervalos de quadro na amostra.

| Pista | FPS nas rodadas 1 / 2 / 3 | P95 nas rodadas 1 / 2 / 3 |
| --- | ---: | ---: |
| Floresta | 12,7 / 40,4 / 29,7 | 104,4 / 33,7 / 41,8 ms |
| Praia | 16,9 / 44,5 / 43,3 | 82,6 / 29,4 / 29,8 ms |
| Vale | 16,4 / 40,0 / 29,8 | 93,5 / 34,4 / 43,8 ms |
| Vulcão | 17,0 / 43,6 / 43,9 | 86,3 / 31,8 / 31,1 ms |
| Caverna dos Cristais | 12,0 / 43,8 / 44,1 | 89,9 / 31,7 / 31,4 ms |

A primeira rodada sucedeu uma tentativa interrompida pela tela de bloqueio e teve desempenho atípico nas cinco pistas. A abertura da Floresta nessa rodada levou 50,36 s até o controle. A causa da variação segue em aberto. O P95 da atualização de jogo em `_physics_process` ficou entre 3,7 e 6,5 ms nas 15 janelas competitivas. Esse tempo corresponde a uma atualização. Um quadro pode incluir várias atualizações, além do restante do motor e da renderização.

### Resolução do canvas

O teste A/B/B/A manteve o mesmo tamanho CSS e usou Pteranodonte com boné contra Brincalhão. As quatro rodadas abriram uma nova página e seguiram Floresta, Vale e Caverna. Em duas rodadas, o DPR passou de 2,0625 para 1,30 por CDP. O canvas em corrida passou de 1.027 × 1.563 para 646 × 985 pixels, cerca de 60% menos pixels. Cada valor abaixo corresponde aos dez segundos iniciais de uma corrida. A rede ficou sem limitação nessa série.

| Pista | FPS original | FPS reduzido | P95 original | P95 reduzido |
| --- | ---: | ---: | ---: | ---: |
| Floresta | 39,6 / 39,6 | 29,6 / 43,9 | 35,6 / 34,0 ms | 48,0 / 33,1 ms |
| Vale | 29,8 / 40,8 | 29,7 / 44,4 | 45,0 / 34,4 ms | 49,4 / 31,1 ms |
| Caverna dos Cristais | 29,7 / 29,7 | 59,4 / 58,9 | 43,9 / 44,3 ms | 22,1 / 22,6 ms |

A Caverna ganhou fluidez nas duas rodadas com resolução reduzida. Floresta e Vale variaram entre rodadas. Esses resultados identificam sensibilidade à resolução na Caverna nesta configuração e deixam a causa da rodada lenta do jogo em aberto.

## Modos e controles

O navegador completou uma rodada adicional de dez segundos por pista em Dupla e outra em Sozinho, com pausa, retomada e volta ao menu em todas as combinações. O teste em Sozinho reutilizou o Pteranodonte com boné selecionado no fim da rodada em Dupla. Os números descrevem as duas sessões tal como foram jogadas.

| Pista | FPS em Dupla | P95 em Dupla | FPS em Sozinho | P95 em Sozinho |
| --- | ---: | ---: | ---: | ---: |
| Floresta | 35,6 | 37,3 ms | 29,8 | 47,8 ms |
| Praia | 40,2 | 33,6 ms | 29,8 | 44,1 ms |
| Vale | 37,1 | 35,0 ms | 41,1 | 34,0 ms |
| Vulcão | 40,5 | 34,2 ms | 29,7 | 46,2 ms |
| Caverna dos Cristais | 42,3 | 33,0 ms | 43,0 | 30,6 ms |

O jogador 2 respondeu ao toque na Floresta em Dupla. O jogador 1 respondeu na Caverna em Sozinho. O reinício funcionou nos dois casos. No menu da Caverna e da Floresta, selecionar Dorminhoco ou Rapidinho na mesma pista levou de 0,07 a 0,34 s até `park-ready`. O jogo confirmou a troca para o Pteranodonte, a seleção aceitou o boné e o álbum abriu.

Uma corrida competitiva completa na Caverna começou com toque no botão, chegou ao fim em 32,02 s após liberar o controle e exibiu o adesivo **Primeira volta**. As três janelas consecutivas até 94% da volta registraram 42,4, 44,2 e 44,0 FPS, com P95 de 31,3, 31,2 e 31,0 ms. A validação física das demais pistas mediu a abertura, a troca e os primeiros dez segundos em pista.

As 34 verificações de `npm test` passaram, assim como `npm run test:godot`. A suíte Godot cobre a chegada das cinco pistas e roda sem renderização.

## Otimizações da 0.34.7

Cada comparação de carregamento no Moto G56 usou a ordem A/B/B/A, com gzip, cache HTTP desabilitado, download de 20 Mbit/s, upload de 5 Mbit/s e latência de 70 ms. As tabelas mostram medianas de duas execuções por variante. As séries da Floresta e da Praia usaram Tricerátopo contra Brincalhão.

### Árvores da Floresta e do Vale

A variante B carrega as malhas compartilhadas do arquivo gerado antes do export. A biblioteca é carregada quando a Floresta ou o Vale é montado pela primeira vez. O teste comparou os atributos de todas as malhas salvas com os da geração em tempo de execução. As duas pistas usaram as malhas do arquivo.

| Marco | 0.34.6 | Com malhas salvas |
| --- | ---: | ---: |
| Montagem na abertura da Floresta | 4,09 s | 0,81 s |
| Abertura da Floresta até o controle | 20,67 s | 18,02 s |
| Montagem do Vale após a Floresta | 5,39 s | 0,28 s |
| Troca da Floresta para o Vale | 6,07 s | 1,12 s |
| Abertura direta do Vale até o controle | 21,59 s | 17,46 s |

A série de abertura direta do Vale usou Pteranodonte com boné contra Brincalhão. O PCK transferido com gzip passou de 3.400.515 para 5.137.623 bytes com a biblioteca de árvores.

### Terreno da Praia

As duas variantes incluíram a biblioteca de árvores. A malha indexada da Praia preservou a ordem dos triângulos, posições, cores e UVs. As diferenças nas normais ficaram abaixo da tolerância de 0,0001 no teste. O PCK transferiu 175.282 bytes a mais com gzip.

| Marco | Terreno procedural | Terreno pré-calculado |
| --- | ---: | ---: |
| Montagem na abertura da Praia | 1,73 s | 0,98 s |
| Abertura da Praia até o controle | 18,45 s | 17,66 s |
| Troca do Vulcão para a Praia | 1,84 s | 1,59 s |

### Custo do pacote combinado

As duas otimizações aumentaram o PCK de 3.400.515 para 5.312.905 bytes transferidos com gzip. Na abertura direta da Caverna com Pteranodonte de boné, o primeiro controle passou de 16,37 s para 17,03 s. A montagem ficou em 0,82 s na 0.34.6 e 0,81 s com as duas otimizações. Nesse cenário, o PCK maior acrescentou 0,66 s até o controle.

### Protótipo de escala 3D na Caverna

Com Pteranodonte de boné, a variante B pediu escala 3D de 0,63 no `Viewport` do Godot. Ambas as builds mantiveram as dimensões do canvas no navegador. O teste anterior com CDP havia reduzido o DPR do navegador e as dimensões do canvas.

| Escala 3D | FPS nas duas rodadas | P95 nas duas rodadas |
| --- | ---: | ---: |
| 1,00 | 43,22 / 42,66 | 31,3 / 31,3 ms |
| 0,63 | 43,11 / 43,24 | 33,6 / 31,8 ms |

A fluidez ficou semelhante nas duas escalas. A 0.34.7 conserva a escala original. [Documentação de escala 3D do Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/3d/resolution_scaling.html)

### Validação da exportação final

A 0.34.7 exportada abriu na Floresta e completou as trocas para Praia, Vulcão, Caverna e Vale, com início, pausa e retomada no Chrome do Moto G56. Nessa rodada, o primeiro controle na Floresta chegou em 17,76 s e o PCK transferiu 5.312.903 bytes com gzip. As suítes Node e Godot passaram. Os dois geradores produziram arquivos idênticos ao serem executados novamente em outra cópia do projeto.

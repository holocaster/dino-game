# Próximas otimizações para Corrida dos dinos no navegador

A versão **0.34.5**, no commit `ad6a295` da `main`, é a referência para os próximos testes. O objetivo é reduzir o tempo desde a abertura da página até o primeiro controle da corrida no **Moto G56**. Na versão atual, as escolhas do menu já ficam disponíveis enquanto o motor carrega. Trocar de rival ou modo mantém o cenário montado, e a Floresta e o Vale compartilham parte das malhas de árvores.

O [A/B do chão da Floresta](#ab-do-chão-da-floresta-no-moto-g56) reduziu a mediana até o primeiro controle em **2,62 s** no Moto G56.

## O que medimos

| Mediana de três rodadas no Moto G56 | 0.34.4 | 0.34.5 |
| --- | ---: | ---: |
| Navegação até habilitar “Vamos correr” | 29,27 s | **22,77 s** |
| Navegação até controlar a corrida na Floresta | 32,40 s | **25,92 s** |
| Selecionar Vale na Floresta até `park-ready` | 11,78 s | **8,14 s** |
| Trocar de rival no Vale até `park-ready` | 10,76 s | **0,13 s** |

As builds rodaram no Chrome do aparelho físico, servidas localmente por USB com gzip, cache HTTP desabilitado, 20 Mbit/s de download, 5 Mbit/s de upload e 70 ms de latência emulada. O tempo até o controle inclui a contagem regressiva. [Rodadas individuais e metodologia](technical.md#moto-g56-físico)

Na 0.34.5, as escolhas do menu ficaram disponíveis em **0,43 s**. O PCK transferiu **3,16 MB** e terminou aos **3,42 s**. O WASM transferiu **10,19 MB** e terminou aos **7,24 s**. Ainda passaram **15,58 s** do fim dos downloads até habilitar o botão. A marca `godot:init` chegou aos **7,41 s**, e o `_ready()` da Floresta levou **9,96 s**. Ao descontar a duração de `_ready()` do intervalo entre `godot:init` e a chegada de `park-ready` ao menu, sobraram cerca de **5 s** nessa série. Esse saldo inclui a entrega da mensagem ao navegador. O A/B abaixo mediu a entrada em `_ready()` diretamente.

Em três execuções numa cópia local com Godot headless, a cena da Floresta levou **620 ms** de mediana. O chão levou **180 ms**, e árvores e lago somaram **228 ms**. No Vale, a geração das árvores levou **199 ms**, com a malha do chão já pré-calculada. Esse perfil nativo mede a montagem sem GPU nem navegador e serve para escolher o primeiro teste no celular.

## Referências dos outros jogos

| Jogo ou estudo | O que aproveitar |
| --- | --- |
| **Turbo Tortoise, LLLL Racing e Mud Racers** | Primeira tela utilizável em **12,49 s**, **8,60 s** e **14,83 s**, respectivamente, no benchmark desktop. O Mud Racers transferiu mais que a Corrida dos dinos 0.34.3 e ainda abriu antes. |
| **Mud Racers** | A imagem da pista mudou em cerca de **0,22 s**. O marco corresponde à atualização da prévia e ajuda a desenhar um seletor que responde enquanto a pista é preparada. |
| **CGT Rocket X Racer e Voxel Routes** | Os autores testaram uma abertura em etapas para liberar a interface com menos trabalho inicial. O protótipo de CGT chegou a **5,97 s** até a cena pronta em execução local. Voxel Routes relatou **14–15 s** até o menu em outro Android físico. |

Os tempos dos outros jogos têm seus próprios marcos, aparelhos e condições de rede. Para a Corrida dos dinos, use o primeiro controle no mesmo Moto G56 como critério principal. [Benchmark dos comparáveis](../benchmark-carregamento-godot/2026-11-26_landscape.md) · [Amostras do desktop](../benchmark-carregamento-godot/medicoes.csv)

## Ordem proposta

1. **Testar o chão da Floresta pré-calculado e indexado.** Reaproveite o caminho do terreno do Vale. Compare a malha gerada com a atual, incluindo posições, normais, cores, UVs e limites. Confira a pista e as colisões no jogo. Compare com a 0.34.5 no Moto G56 e registre também quanto cresceu o PCK. [Geração da Floresta](../../game/world/forest.gd#L108) · [Gerador do Vale](../../scripts/build_valley_terrain.gd) · [Experimentos anteriores](technical.md#teste-do-terreno-pré-calculado)
2. **Testar as árvores em uma mudança separada.** A Floresta e o Vale ainda geram árvores fora da faixa de beira de pista que já compartilha malhas. Teste preparar essas malhas antes do export, preservando o material por árvore, a transparência e as colisões. Meça tanto a abertura da Floresta quanto a primeira troca para o Vale. [Árvores da Floresta](../../game/world/forest.gd#L133) · [Árvores do Vale](../../game/world/forest.gd#L447)
3. **Medir a inicialização antes da montagem da cena.** Acrescente marcas para a entrada em `_ready()`, a carga dos modelos e o primeiro quadro da pista. O catálogo usa `preload()` nos quatro modelos e os torcedores instanciam três espécies. Se os modelos pesarem, teste carregar primeiro os corredores escolhidos e introduzir pássaros e torcedores em etapas. Confira o tempo até o controle e eventuais travadas depois que a corrida começa. [Inicialização da corrida](../../game/race/race.gd#L27) · [Modelos](../../game/dinos/runner_model.gd#L3) · [Torcedores](../../game/race/race_scenery.gd#L163)
4. **Testar uma prévia imediata na troca de pista.** As opções do menu já têm miniaturas. Use a prévia da pista escolhida enquanto a cena 3D fica pronta. Registre o tempo para a prévia aparecer e o tempo até controlar a corrida. [Opções de pista](../../web/index.html#L88) · [Fluxo de seleção](../../web/game.js#L312)

O primeiro experimento foi concluído em cópias temporárias da 0.34.5. As árvores são a próxima hipótese a testar em separado.

## A/B do chão da Floresta no Moto G56

Em 27/11/2026, comparamos duas cópias da 0.34.5 (`ad6a295`). A variante A gerava o chão durante a montagem. A variante B carregava uma `ArrayMesh` indexada, salva em `.res` com compressão. Ambas receberam a mesma marca na entrada de `race._ready()`. A curva, o material do chão, as árvores e as colisões seguiram o mesmo código nas duas builds.

O teste expandiu os 55.002 índices da malha B, que usa 9.360 vértices, e comparou cada triângulo com a malha A. Posições, ordem, cores, UVs e limites coincidiram. A maior distância entre normais correspondentes foi 0,000052. Os testes de cenário da Floresta, corrida e colisões passaram na variante B. Em um piloto separado, as duas builds responderam ao toque e as capturas no aparelho mostraram o traçado, a faixa de largada e as bordas no lugar.

As rodadas usaram Chrome 158 no Moto G56 por USB, gzip, cache HTTP desabilitado, 20 Mbit/s de download, 5 Mbit/s de upload e 70 ms de latência emulada. Cada navegação começou na Floresta. O benchmark acionou o botão assim que ele habilitou e registrou o primeiro controle ao receber o estado de corrida após a contagem regressiva. A coluna de downloads marca o fim da última transferência entre PCK e WASM. O intervalo entre `godot:init` e a entrada em `_ready()` usa marcas do mesmo iframe.

| Rodada | Variante | Fim dos downloads (s) | Init até entrada em `_ready()` (s) | Duração de `_ready()` (s) | Botão habilitado (s) | Primeiro controle (s) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | A | 7,24 | 3,29 | 12,43 | 26,29 | 29,46 |
| 2 | B | 7,39 | 3,27 | 9,49 | 23,61 | 26,77 |
| 3 | B | 7,32 | 3,23 | 9,91 | 23,91 | 27,09 |
| 4 | A | 7,25 | 3,31 | 12,08 | 26,21 | 29,39 |
| 5 | A | 7,15 | 3,14 | 12,00 | 25,63 | 28,81 |
| 6 | B | 7,29 | 3,35 | 9,42 | 23,12 | 26,26 |
| **Mediana** | **A** | 7,24 | 3,29 | 12,08 | 26,21 | 29,39 |
| **Mediana** | **B** | 7,32 | 3,27 | 9,49 | 23,61 | 26,77 |

O PCK passou de 3.207.952 para 3.458.992 bytes em disco. Com gzip, os corpos transferidos passaram de 3.163.082 para 3.400.761 bytes, um aumento de **237.679 bytes (7,5%)**. O WASM transferiu 10.185.394 bytes nas seis rodadas.

A Floresta com o chão pré-calculado chegou ao primeiro controle em **26,77 s** de mediana, ante **29,39 s** da variante procedural. O ganho foi de **2,62 s (8,9%)**, com as três rodadas B abaixo das três A. A montagem em `_ready()` caiu **2,59 s** e o último download terminou **0,08 s** mais tarde. O resultado favorece incorporar a malha à corrida da Floresta nessa condição de rede. Para avaliar as árvores depois, use a versão com o chão pronto como referência. Os 25,92 s da tabela inicial pertencem à série anterior, feita em outra sessão.

## Custo das árvores e teste de copas simplificadas

Com o chão da Floresta já pré-calculado nas duas builds, medimos o tempo acumulado dentro de `SCENERY_MESHES.tree()` durante a abertura. Foram 60 chamadas em cada navegação. A variante A manteve 12 segmentos radiais e 6 anéis nas esferas das copas. A variante B usou 8 segmentos e 4 anéis. Cada árvore conservou sua posição, tamanho, material e colisão. Usamos o mesmo aparelho, rede emulada, cache HTTP desabilitado e ordem de execução do A/B anterior.

| Rodada | Variante | Geração das malhas de árvore (s) | Montagem da corrida (s) | Primeiro controle (s) |
| --- | --- | ---: | ---: | ---: |
| 1 | A | 6,09 | 6,82 | 23,35 |
| 2 | B | 7,33 | 8,01 | 25,17 |
| 3 | B | 7,44 | 8,20 | 25,44 |
| 4 | A | 10,12 | 10,80 | 28,13 |
| 5 | A | 9,36 | 10,04 | 27,30 |
| 6 | B | 7,39 | 8,17 | 25,67 |
| **Mediana** | **A** | **9,36** | **10,04** | **27,30** |
| **Mediana** | **B** | **7,39** | **8,17** | **25,44** |

A geração das árvores consumiu entre 89% e 94% da montagem nas três rodadas de referência. Com as copas simplificadas, o primeiro controle chegou 1,86 s antes na mediana, e o PCK transferiu apenas 5 bytes a mais com gzip. Os testes de cenário e colisão passaram. Nas capturas da largada, as copas simplificadas têm contornos mais angulosos.

A primeira abertura da variante A foi a mais rápida da série, e as faixas de tempo se sobrepõem. A mediana favorece simplificar as copas, mas o ganho ainda precisa de confirmação. O próximo A/B proposto é reutilizar uma malha por variante no tamanho unitário, aplicar a escala à instância visual e preservar a colisão por árvore. Compare as posições transformadas, as normais, a transparência e o primeiro controle com as copas originais.

## Reaproveitamento das malhas de árvore por variante

O A/B no mesmo Moto G56 usou o chão pré-calculado e as copas originais nas duas builds. A manteve a geração anterior. B gerou a malha em tamanho unitário uma vez por variante na Floresta e no Vale e aplicou a escala à instância visual. Cada árvore conservou seu material e sua colisão. Cada rodada começou em uma nova navegação na Floresta, nas mesmas condições de rede do experimento anterior. Após o primeiro controle, o benchmark voltou ao menu e selecionou Vale, aproveitando as malhas já geradas na Floresta. A troca termina ao receber `park-ready`.

| Rodada | Variante | Gerar árvores da Floresta (s) | Montar Floresta (s) | Primeiro controle (s) | Gerar árvores do Vale (s) | Troca para o Vale (s) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | A | 7,51 | 8,18 | 24,58 | 7,24 | 8,12 |
| 2 | B | 4,18 | 4,86 | 20,71 | 3,21 | 4,09 |
| 3 | B | 4,18 | 4,87 | 21,20 | 3,18 | 4,10 |
| 4 | A | 6,01 | 6,67 | 23,02 | 8,12 | 8,99 |
| 5 | A | 6,95 | 7,62 | 23,54 | 7,66 | 8,65 |
| 6 | B | 4,18 | 4,89 | 20,86 | 3,08 | 4,05 |
| Mediana | A | 6,95 | 7,62 | 23,54 | 7,66 | 8,65 |
| Mediana | B | 4,18 | 4,87 | 20,86 | 3,18 | 4,09 |

Na abertura da Floresta, a quantidade de malhas geradas caiu de 60 para 39. Na troca para o Vale, de 52 para 22. O primeiro controle veio 2,68 s antes na mediana e a troca para o Vale economizou 4,56 s. As três rodadas B foram mais rápidas que as três A nos dois marcos. O PCK transferido com gzip passou de 3.400.734 para 3.400.697 bytes.

A comparação percorreu os triângulos das 60 árvores da Floresta e das 70 do Vale. A distância máxima entre posições correspondentes após aplicar a escala foi inferior a 0,000001 unidade. As cores e o canal alfa coincidiram. Na Floresta, 988 de 475.200 ocorrências de vértices apresentaram diferença vetorial entre normais acima de 0,001. No Vale, foram 1.352 de 554.400. O desvio máximo foi 1,403. As capturas da largada mantiveram o contorno das copas, mas as diferenças nas normais permitem variação localizada na iluminação. Os testes de cenário e colisões passaram. Um teste com duas instâncias da mesma malha confirmou que copa e tronco de uma árvore podem desaparecer enquanto a outra permanece opaca.

Os resultados favorecem o reaproveitamento. Antes de incorporar o protótipo, vale conferir a iluminação de perto nas árvores afetadas. A troca medida parte da Floresta; abrir o jogo diretamente no Vale exige outra medição.

## Menos árvores e sombras mais claras na Floresta

Em 27/11/2026, comparamos quatro builds da Floresta no Moto G56, todas com o chão pré-calculado, as copas originais e uma malha compartilhada por variante de árvore. A usou 60 árvores, mapa de sombras direcional de 2048 × 2048 e opacidade de sombra 0,82. B manteve a iluminação de A e pulou dois de cada quatro pontos candidatos a receber árvores na beira da pista, chegando a 49 árvores. C manteve as 60 árvores e usou mapa de 1024 × 1024 com opacidade 0,60. D combinou as 49 árvores com as sombras de C. A intensidade da luz ambiente foi a mesma nas quatro builds.

Cada rodada começou em uma nova navegação, com cache HTTP desabilitado e a mesma rede emulada do A/B anterior. Durante os primeiros dez segundos de corrida automática, medimos no Godot o intervalo entre sinais de fim de desenho de quadro (`RenderingServer.frame_post_draw`). FPS é a média dessa janela. P95 é o intervalo abaixo do qual ficaram 95% dos tempos entre quadros na rodada; valores menores indicam maior regularidade. As capturas foram feitas depois dessa janela. Os testes de cenário e colisões passaram na variante D.

| Rodada | Variante | Árvores | Malhas geradas | Montagem (s) | Primeiro controle (s) | FPS | P95 entre quadros (ms) |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | A | 60 | 39 | 4,86 | 20,77 | 42,35 | 31,30 |
| 2 | B | 49 | 30 | 3,65 | 19,44 | 29,55 | 45,60 |
| 3 | C | 60 | 39 | 4,95 | 21,26 | 43,16 | 29,10 |
| 4 | D | 49 | 30 | 3,50 | 19,61 | 29,64 | 45,70 |
| 5 | D | 49 | 30 | 3,34 | 19,40 | 43,44 | 29,90 |
| 6 | C | 60 | 39 | 4,98 | 21,23 | 43,32 | 29,50 |
| 7 | B | 49 | 30 | 3,61 | 19,79 | 42,51 | 28,90 |
| 8 | A | 60 | 39 | 4,97 | 21,11 | 41,86 | 31,10 |
| 9 | C | 60 | 39 | 5,07 | 21,37 | 29,55 | 44,20 |
| 10 | A | 60 | 39 | 5,15 | 21,55 | 41,96 | 30,20 |
| 11 | D | 49 | 30 | 3,75 | 19,65 | 43,54 | 29,60 |
| 12 | B | 49 | 30 | 3,60 | 19,43 | 42,29 | 29,70 |
| Mediana | A | 60 | 39 | 4,97 | 21,11 | 41,96 | 31,10 |
| Mediana | B | 49 | 30 | 3,61 | 19,44 | 42,29 | 29,70 |
| Mediana | C | 60 | 39 | 4,98 | 21,26 | 43,16 | 29,50 |
| Mediana | D | 49 | 30 | 3,50 | 19,61 | 43,44 | 29,90 |

Com a iluminação original, retirar 11 árvores reduziu a mediana até o primeiro controle em 1,68 s (7,9%, calculados antes do arredondamento). As seis aberturas com 49 árvores terminaram antes das seis com 60. A redução do mapa e da opacidade das sombras, por si só, não acelerou a abertura. Durante a corrida, B, C e D tiveram cada uma uma rodada perto de 30 FPS e duas acima de 42 FPS. As três rodadas de A ficaram perto de 42 FPS. Com três amostras por variante e dez segundos de corrida por abertura, não há ganho consistente de fluidez demonstrado pelas sombras mais claras. A escolha favorecida para reduzir a espera é usar 49 árvores com a iluminação original.

## Validação do pacote Web 0.34.6

A 0.34.6 incorpora a configuração B do teste de densidade: chão indexado pré-calculado, malhas de árvore compartilhadas na Floresta e no Vale, 49 árvores na Floresta e iluminação original. O Moto G56 carregou o PCK final servido localmente por USB nas mesmas condições de rede e cache.

| Rodada | Primeiro controle na Floresta (s) | Floresta → Vale (s) |
| --- | ---: | ---: |
| 1 | 19,50 | 5,46 |
| 2 | 19,46 | 5,23 |
| 3 | 19,73 | 5,29 |
| **Mediana** | **19,50** | **5,29** |

Nas três rodadas, o dino respondeu ao toque e a troca de rival no Vale terminou. O corpo do PCK transferiu 3.400.515 bytes com gzip.

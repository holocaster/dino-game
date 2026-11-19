# Caverna dos Cristais — 0.32.0

Validação em 2026-11-19. Quinta pista de uma volta, nos modos Rival, Sozinho e Dupla; controles, frutas, impulsos, chegada e persistência existentes preservados.

## Cena e interação

- Paredes facetadas claras, formações centrais, três arcos altos com grandes aberturas e portal de pedra/cristais na largada. Chão bege, frutas e dinos legíveis. Pedras que atravessam a linha de visão da câmera são ocultadas; a decoração não possui colisores novos.
- Três encontros em 16%, 47% e 78% da volta. Cada lado tem sua cor e nota; o centro pode ignorar ambos. O segmento físico entre posições do corredor detecta passagens rápidas. Cada corredor ativa no máximo um lado de cada encontro por corrida, inclusive os dois humanos da Dupla.
- Pulso de 1,2 s com alteração de cor e emissão moderada, sem depender de glow. Notas senoidais de 0,28 s; seis alturas distintas e no máximo duas notas em 0,3 s. Silêncio mantém a resposta visual. Não há recompensa nova nem alteração de estado da corrida pela interação.
- Prévia, contagem e chegada não ativam cristais. Pausa congela o pulso; na Caverna também suspende o relógio Web Audio, preservando a nota para retomada. Nas outras pistas a pausa mantém o cancelamento anterior dos efeitos. Reinício limpa pulsos, ativações e vozes; troca de pista recria a cena.

## Capturas reais

| Evidência | Tela larga | Vertical |
| --- | --- | --- |
| Seleção com a quinta pista visível | [Navegador](previews/cave-browser-selection-desktop.png) | [Navegador](previews/cave-browser-selection-mobile.png) |
| Largada e portal | [Navegador](previews/cave-browser-start-desktop.png) | [Navegador](previews/cave-browser-start-mobile.png) |
| Dupla junto aos cristais | [Navegador](previews/cave-browser-crystals-desktop.png) | [Navegador](previews/cave-browser-crystals-mobile.png) |
| Chegada dos dois | [Navegador](previews/cave-browser-finish-desktop.png) | [Navegador](previews/cave-browser-finish-mobile.png) |
| Primeiro encontro, pulso dirigido | [Compatibility](previews/cave-encounter-1-desktop.png) | [Compatibility](previews/cave-encounter-1-mobile.png) |
| Segundo encontro, pulso dirigido | [Compatibility](previews/cave-encounter-2-desktop.png) | [Compatibility](previews/cave-encounter-2-mobile.png) |
| Terceiro encontro, pulso dirigido | [Compatibility](previews/cave-encounter-3-desktop.png) | [Compatibility](previews/cave-encounter-3-mobile.png) |

Também: [silêncio durante a corrida](previews/cave-browser-muted-desktop.png), [pausa](previews/cave-browser-pause-desktop.png) e [visão geral dos arcos/aberturas](previews/cave-browser-overview-desktop.png).

As corridas de navegador usam o pack de produção, Chromium/WebGL 2, em 1280 × 900 e 390 × 844. Dupla T-rex/Velociraptor terminou naturalmente com ambos: 16 frutas na larga e 17 na vertical. Conferidos os dois lados, silêncio, pausa/retomada, reinício com progresso/frutas zerados e troca para Praia em `ready`, sem rolagem horizontal. Preferências de aparência e álbum previamente salvos continuaram disponíveis.

A visão geral usa a cena real com câmera dirigida pela fixture `release_visual.gd`, caso `overview:trex:cave:none:none`, exportada somente numa cópia temporária em `/tmp/dino-cave-fixture-game`. O navegador voltou ao pack de produção, sem roteamento da fixture; `releaseFixture` ficou indefinido. Os seis pulsos dirigidos usam `cave_visual.gd`, em 1114 × 660 e 364 × 674, renderizados por Mesa/llvmpipe com Compatibility. Essas imagens não representam desempenho de aparelhos físicos.

## Verificação

- `npm test`: **31/31**, log `/tmp/dino-cave-node-full.log`. Necessária execução fora do sandbox para os subprocessos do Node/CLI; nenhuma geração paga solicitada.
- `XDG_DATA_HOME=/tmp/dino-game-godot-data npm run test:godot`: **32 scripts GDScript e 2 testes Python aprovados**, log `/tmp/dino-cave-godot-full.log`. As **72 referências Floresta/Praia** foram preservadas. Somente os oito diagnósticos antigos de descarte de materiais da exploração, [já documentados](scenery-refinement-validation.md), sem contorno ou mudança nesses testes.
- `cave_test.gd`: espécies/modos, volta fechada, geometria fora da pista, centro e ambos os lados/humanos, passagem rápida, uma resposta por encontro, isolamento das regras, pausa/retomada/reinício e chegada física; `/tmp/dino-cave-focused.log`.
- Matriz de câmera ampliada com as três espécies na Caverna: **250.032 projeções** de corpos/malhas/acessórios, telas larga/vertical, distância de 18 m, espera e chegada; `/tmp/dino-cave-camera.log`. Testes focados foram repetidos após ajustes finais de cor, posição dos cristais e altura do portal.
- Web Audio real no navegador: uma nota permaneceu viva com `currentTime` congelado durante pausa superior à sua duração; terminou depois da retomada. Silêncio eliminou a voz; reinício durante pausa seguido de retomada não deixou voz pendente. Testes Node cobrem também notas distintas, limite de sobreposição e relatórios/chegada da Dupla.
- Exportação Godot **4.7.2**, pack final **14.809.808 bytes**, tamanho anunciado conferido. JS/WASM existentes reutilizados; pacote, projeto e versões de cache em **0.32.0**. `/tmp/dino-cave-export.log`, `/tmp/dino-cave-pack-check.log` e `/tmp/dino-cave-node-focused-final.log` verificam pack final, ausência de fixtures e 16 testes focados aprovados. O exportador no sandbox registra falha de escuta TCP do editor, mas conclui o PCK com exit 0.

Referências consultadas via Context7: [emissão/cor de materiais Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_basematerial3d.html) e [suspensão/retomada do AudioContext](https://webaudio.github.io/web-audio-api/#dom-audiocontext-suspend).

Sem dependências, GLBs novos ou mídia paga. Benchmark adiado pelo usuário; sem testes com crianças ou aparelhos físicos, nem avaliação auditiva humana da mixagem.

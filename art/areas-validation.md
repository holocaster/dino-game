# Áreas conectadas — versão 0.6.0

Implementadas em 2026-11-10. [Circuito em vista geral, com árvores ocultas para avaliação](previews/areas-overview.png) · [Clareira](previews/areas-clearing.png) · [Lago](previews/areas-lake.png) · [Bosque](previews/areas-grove.png) · [Celular](../prototypes/previews/areas-mobile.png).

## Entrega

Três áreas contínuas, ligadas por uma trilha circular, sem mudança de tela ou carregamento entre elas:

- Clareira: início do passeio, cesta de frutinhas e amigo com alimentação completa.
- Margem do lago: flores, água com plantas aquáticas e pedras na margem.
- Bosque: pegadas, vegetação em tons mais escuros e árvore grande como referência.

As descobertas existentes foram distribuídas entre as áreas. Seus botões continuam levando o dino até cada atividade, e o chão permite circular livremente. A câmera acompanha o passeio e o reinício volta à clareira.

A navegação usa a união das três áreas e os corredores da trilha. A grade foi ampliada, mantendo a margem dos troncos e do lago. A vegetação fica fora das passagens; o terreno continua suavemente ondulado e o fundo de chão cobre a vista além dos limites caminháveis.

Cada árvore agrupa sua geometria numa malha e controla sua própria visibilidade. Isso substitui a atualização manual de lotes de instâncias e permite ocultar copas que encobrem o personagem, inclusive no formato vertical. As folhas rasteiras continuam numa malha única. Não há novas dependências ou assets externos.

Fontes principais: `forest.gd` para áreas, trilha e navegação; `park.json` para destinos das descobertas. A alimentação permanece na clareira, em `feeding.gd`.

## Verificações

- Cinco scripts Godot passaram: parque, personagem, floresta, alimentação e áreas.
- Circuito fechado com mais de 25 unidades de extensão, amostrado em 101 pontos caminháveis.
- Descobertas em posições caminháveis; trajetos de ida e volta entre as três áreas.
- Movimento com quadros atrasados, limites do mundo, altura do solo, acompanhamento da câmera e reinício.
- Alimentação concluída após retornar à clareira; repetição e interrupções preservadas.
- Chromium 1280 × 900: lago por clique, bosque por teclado, retorno à clareira, alimentação, celebração e reinício.
- Contexto com toque em 390 × 844: visita ao bosque, toque direto no chão e reinício, sem rolagem horizontal ou erros JavaScript.
- Capturas web conferidas novamente após a correção da vegetação que encobria o dino no bosque. Sem erros de console na verificação final.

## Desempenho e limites

Amostras nativas de dois segundos por área, em 1100 × 720, OpenGL Compatibility, GPU Intel UHD 630: clareira 57 FPS / 275 chamadas de desenho; lago 60 FPS / 187 chamadas; bosque 60 FPS / 75 chamadas. São amostras curtas, incluindo aquecimento inicial, e não garantem o desempenho do navegador.

O navegador automatizado usa SwiftShader por software. A validação funcional web não substitui medições com GPU ou testes em celulares físicos. Não foram executados testes com crianças. O terreno usa relevo suave; não há nado, saltos ou IK dos pés para terrenos acidentados. O áudio continua pendente.

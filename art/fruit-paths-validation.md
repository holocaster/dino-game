# Caminhos de frutas — 0.15.0

Item 3 das próximas melhorias, implementado em 2026-11-11. [Floresta em tela larga](previews/fruit-paths-desktop.png) · [Praia em tela vertical](previews/fruit-paths-mobile.png).

## Comportamento

As mesmas 20 frutas formam quatro trechos de escolha. Cada trecho oferece duas frutas à esquerda e duas à direita, nas mesmas posições de progresso, seguidas de uma fruta central compartilhada. Cada lado oferece três coletas possíveis por trecho, incluindo a central, e 12 ao longo da volta.

As sequências laterais variam entre 1,10 e 1,55 unidade de afastamento do centro. A distância de quatro unidades entre as frutas permite ajustar a direção e voltar ao centro mesmo com o dino mais lento para virar e o bônus máximo de velocidade. O espaço lateral impede pegar as duas alternativas permanecendo no meio.

A primeira escolha fica próxima à largada; a última termina oito unidades antes da chegada. Esse afastamento evita exibir uma fruta grande atrás dos dinos logo na largada, já que o circuito é fechado e a câmera fica atrás do personagem.

Permanecem respawn compartilhado, uma coleta por dino por fruta, teto e duração dos bônus, colisões, personagens e pistas. O rival aproveita a nova distribuição com o algoritmo existente; na simulação de uma volta com o jogador mantendo sua linha, coletou 12 frutas e variou sua trajetória.

## Implementação

- `race_state.gd:reset()`: gera os quatro trechos simétricos e reinicia os registros de coleta e respawn.
- `web/index.html`: instrução inicial convida a escolher um caminho de frutas.
- `tests/fruit_paths_test.gd`: estrutura das escolhas, igualdade de oportunidades, retorno ao centro e navegação pelas duas alternativas.
- `tests/collision_test.gd`: o cenário de coleta única isola sua fruta, pois agora há duas alternativas na mesma posição de progresso.
- `npm run test:race`: inclui o novo teste. Exportação e cache em 0.15.0.

Nenhum novo asset, dependência, controle ou camada de abstração. A cena continua criando as frutas a partir do estado da corrida.

## Validação

- `npm run test:race`: sete scripts Godot aprovados, incluindo corrida, rival, colisão, equilíbrio e seis combinações de dino/pista.
- Nos três dinos e nas duas pistas, os percursos simulados pela esquerda e pela direita completam a volta com 12 frutas e sem coletar a alternativa oposta.
- As duas alternativas do primeiro trecho foram percorridas com corpos e áreas físicos em floresta e praia: duas frutas laterais e a central coletadas em cada caso; reinício restaura todas as frutas.
- Os testes verificam que a fruta central é alcançável com a velocidade máxima e a condução de cada dino, além de preservar pausa, respawn e recuperação.
- Chromium/Playwright: percurso lateral por teclado e retorno ao centro, com três coletas, bônus correto e pausa. Layouts 1280×900 e 390×844 conferidos nas duas pistas, sem excesso de largura ou erros de console. A sobreposição inicial foi ocultada temporariamente apenas para capturar a distribuição completa na largada.

Pack web: 14.744.708 bytes; tamanho de download e referências de cache sincronizados. Sem commit ou push.

## Pendente

Avaliar com crianças e aparelhos reais se as escolhas ficam claras e o retorno ao centro é confortável. A fruta especial de recuperação do item 4 permanece para a próxima etapa.

## Posições sorteadas — 0.18.0

Cada `reset()` sorteia o início de cada trecho dentro de uma janela própria e a abertura lateral de cada par entre 1,0 e 1,55. Estrutura, simetria, recompensas e alcance continuam os mesmos; há pelo menos quatro unidades entre uma fruta central e a bifurcação seguinte, e nenhuma fruta fica nas últimas oito unidades.

- `fruit_paths_test`: 25 sorteios por dino/pista, todos dentro das regras e mais de 20 layouts distintos; percursos simulados e físicos coletam 12 e 3 frutas; frutas da cena acompanham o layout após reiniciar.
- Testes dependentes das frutas rodaram 8 a 12 vezes seguidas sem falha; `npm run test:godot` e `npm test` aprovados. Um script rodado diretamente no pack exportado confirmou layouts diferentes entre reinícios.

Pack web: 14.755.548 bytes.

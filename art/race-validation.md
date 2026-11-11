# Corrida dos dinos — 0.11.0

Passadas e sincronização refinadas em 0.11.1: [comparação e validação](gait-validation.md). Este documento registra a entrega original da corrida.

Implementada em 2026-11-10: corrida infantil sem violência, com largada em três segundos, avanço automático, uma volta e chegada. As setas controlam deslocamento lateral contínuo, limitado à pista. Vinte frutas são compartilhadas; cada fruta pertence a quem coletou primeiro e acrescenta 0,16 à sua velocidade. A velocidade inicial do jogador é 2,2 e a do amigo é 2,35. Não há cronômetro visível, ataques ou penalidades.

## Fonte e integração

- `prototypes/godot-project/race_state.gd`: circuito oval fechado, contagem, progresso dos dois corredores, lateral, coleta única, aumento de velocidade, vencedor e reinício.
- `race.gd` e `race.tscn`: personagens e animações existentes, frutas, linha quadriculada, bandeiras, áudio e ponte web. A câmera reaproveita o acompanhamento do passeio, inclui o amigo quando próximo e abre o campo de visão vertical para 64 graus. O giro continua limitado a 50 graus/s e sua aceleração a 80 graus/s².
- `forest.gd`: utiliza a curva da corrida para pintar a trilha e afastar vegetação. O oval foi deslocado três unidades para preservar a margem do lago em toda a largura da pista. O passeio anterior permanece disponível na cena `park.tscn`.
- `prototypes/index.html`, `game.js`, `game.css` e `godot-project/shell.html`: largada, progresso, frutas, controles de direção, silêncio, pausa, chegada e repetição. A ponte mantém validação de origem e janela; textos usam `textContent`.

A janela interna encaminha as setas mesmo com foco no corpo do iframe. A liberação ocorre na saída de foco; a mensagem assíncrona dessa saída não cancela uma nova tecla já pressionada na página externa. Soltar, cancelar toque, pausar e reiniciar limpam os controles. Perder o foco da janela ou sair da aba pausa a corrida; a continuação exige ação do jogador.

## Verificação executada

- **Nove testes Node aprovados** em `npm test`.
- **Oito scripts anteriores do Godot aprovados**, sem alterações nos testes existentes: parque, modelo, floresta, alimentação, áreas, áudio, câmera e companheiro. O teste da câmera foi repetido após o ajuste do ponto de acompanhamento.
- **Dois scripts de corrida aprovados**, incluídos em `npm run test:godot` e executáveis isoladamente por `npm run test:race`: contagem sem movimento, curva fechada e tangente contínua, coleta única, aumento de velocidade, limites laterais, pausa, resultado, ambos os vencedores e reinício.
- O teste da cena percorre uma volta em cada orientação, verifica relevo, enquadramento, velocidade e aceleração da câmera, espaço para os dois dinos nas bordas opostas, distância até troncos e ausência de água em toda a largura da pista.
- **Navegador Chromium/Playwright**: largada, coleta e contador, chegada com vitória do jogador e vitória do amigo em corridas distintas, repetição com posição/frutas/velocidade zeradas, pausa e continuação.
- Teclado verificado com foco na página externa e no corpo do iframe. Toque emulado via CDP verificado com pressão contínua, limite lateral, soltura e cancelamento, sem direção presa.
- Perda de foco verificada com outra página em primeiro plano e emulação de foco desativada: a contagem pausou em três e permaneceu parada ao voltar. Nesse navegador automatizado `document.hidden` permaneceu falso; ocultação real da aba deve ser conferida em aparelho físico.
- Layout verificado em 1280×900 e 390×844; em 320 pixels de largura não houve rolagem horizontal. Nenhum erro no console nas navegações verificadas.

## Prévias

[Corrida em tela larga](../prototypes/previews/race-desktop.png) · [Tela vertical](../prototypes/previews/race-mobile.png) · [Pausa](../prototypes/previews/race-pause.png) · [Chegada](../prototypes/previews/race-finish.png).

## Exportação e limites

Versão 0.11.0 em `package.json`, `project.godot` e referências de cache da página/shell. Pack web de **6.080.780 bytes**, exportado por Godot 4.7.2 com `--export-pack Web ../godot/index.pck`; shell sincronizado com o tamanho real do pack. JavaScript e WASM existentes da mesma versão do Godot foram reutilizados. A exportação completa por `--export-release` exige os templates Web, ausentes neste ambiente.

A validação automatizada usou renderização por software. Não foi feita medição representativa de desempenho em GPU, celular ou tablet. Testes com aparelhos físicos e crianças continuam pendentes, inclusive calibração de velocidade, conforto da câmera, alcance das frutas e ocultação real da aba. Nenhuma geração paga, dependência nova, commit ou push.

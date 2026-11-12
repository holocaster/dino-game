# Amigo do prado — versão 0.10.0

Implementado em 2026-11-10. [Cumprimento no navegador](previews/companion-greeting.png) · [Caminhada com toque emulado](previews/companion-mobile.png).

## Interação

Um terceiro tricerátopo passeia pelo prado das borboletas. Reutiliza a malha e as animações existentes, com escala 0,78 e material próprio em tons verdes. O amigo da alimentação permanece na clareira.

Ao se aproximar do novo amigo, ele interrompe o passeio, procura uma posição lateral e cumprimenta com a cabeça e um som suave. Em seguida acompanha o jogador por até oito segundos. Retorna antes se o jogador se afastar demais da região. Ao chegar ao prado, volta a passear. O reencontro exige que o jogador se afaste e retorne, evitando cumprimentos contínuos enquanto permanece perto.

O encontro é automático e não exige novos menus ou leitura. O botão Borboletas leva ao local. As seis descobertas e a celebração continuam independentes desse encontro. O reinício restaura o personagem em qualquer fase.

## Implementação

`companion.gd` concentra o comportamento em cinco fases: passeio, aproximação, cumprimento, acompanhamento e retorno. Seus pontos de passeio ficam próximos de (8,4; -12,6). As rotas usam a navegação existente; o movimento acompanha a altura do terreno e verifica os segmentos percorridos. Ao encontrar o jogador no caminho, o amigo preserva espaço pessoal e usa pontos laterais para contorná-lo.

A aproximação lateral tem duração limitada para não prender o encontro. As rotas de acompanhamento são revistas a cada 0,65 segundo, com alvo ao lado do jogador. O retorno começa após oito segundos, quando o amigo passa de sete unidades de sua base ou o jogador passa de nove. A reativação exige distância maior que 4,5 unidades entre os personagens, com uma pequena pausa ao retornar.

O material e a animação de cumprimento são duplicados apenas para o novo personagem, preservando os outros dinossauros. A velocidade da animação de caminhada considera o deslocamento e a escala do modelo. O cumprimento reaproveita o descanso, alterando somente a rotação da cabeça.

`park.gd` cria, avança e reinicia o personagem. Durante o encontro, a câmera enquadra os dois e a proteção das árvores cobre o par. Os parâmetros de giro lento da versão 0.9.2 foram preservados. A alimentação da clareira tem prioridade no enquadramento e nas mensagens.

A página recebe mensagens `park-companion` pela mesma ponte já validada por origem e janela do iframe. Usa `textContent` e só atualiza o texto depois de iniciar o jogo. Não há bibliotecas, serviços pagos ou mídia externa novos.

## Verificação

- `npm run test:godot`: oito scripts aprovados, incluindo parque, personagem, floresta, alimentação, áreas, áudio, câmera e o novo amigo.
- `companion_test.gd`: passeio sem o jogador, relevo, quadros atrasados, aproximação, cumprimento, acompanhamento, espaço pessoal, desvio por outras áreas, retorno, afastamento e reencontro, materiais independentes e prioridade das mensagens da alimentação.
- Reinício verificado nas cinco fases. O amigo volta à posição inicial, interrompe a animação anterior e pode ser encontrado novamente.
- A câmera manteve o teste de partida suave: 3° nos primeiros 0,25 segundo, além dos testes de clique e toque durante rotação.
- `npm test`: nove testes aprovados; sintaxe de `game.js` conferida.
- Renderização nativa: cumprimento e caminhada em dupla inspecionados em tela horizontal e em proporção vertical semelhante ao iframe móvel. A primeira conferência identificou sobreposição visual dos personagens; aproximação lateral e foco no par foram ajustados e as novas capturas conferidas.
- Chromium, 1100 × 900: visita por Borboletas; eventos de aproximação, cumprimento, acompanhamento e retorno; reinício limpando descobertas. Mensagem equivalente enviada pela janela pai foi ignorada. Seis atalhos preservados, sem erros ou avisos de console.
- Chromium com toque emulado, 390 × 844: visita ao prado, cumprimento, acionamento do mirante durante o acompanhamento, oito eventos de passos e captura com os dois dinossauros visíveis. Retorno iniciado e reinício concluído, sem erros JavaScript nem transbordamento horizontal.
- Pack web reexportado com Godot 4.7.2, identificação 0.10.0 e 6.068.692 bytes; tamanho conferido no HTML.

## Desempenho e limites

Amostra nativa de três segundos no prado, com o amigo em acompanhamento, 1100 × 720, OpenGL Compatibility e Intel UHD 630: 60 FPS e 218 chamadas de desenho. É uma observação curta, com enquadramento próprio; não mede o custo isolado do personagem nem garante fluidez em celulares.

Ainda faltam testes em aparelhos físicos, medições prolongadas no navegador com GPU e avaliação com crianças. A locomoção usa navegação e espaço pessoal, sem um sistema de colisões físicas ou simulação de multidões. O novo comportamento cobre um único amigo do prado.

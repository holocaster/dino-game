# Poças, pássaros e torcida — 0.17.0

Pedido do usuário implementado em 2026-11-11. [Floresta](previews/scenery-forest-desktop.png) · [Respingos](previews/scenery-splash-desktop.png) · [Praia em tela vertical](previews/scenery-beach-mobile.png).

## Comportamento

Cada pista recebe quatro poças rasas que acompanham o relevo. O movimento físico de qualquer corredor através da água produz oito gotas com uma trajetória curta e som de respingo. O efeito não altera velocidade, bônus ou coleta de frutas. Não há novos obstáculos ou comandos.

Oito pássaros voam em pequenos circuitos, batem as asas e cantam suavemente perto do jogador. Seis dinos das três espécies existentes ficam na lateral da pista com bandeirinhas. Eles pulam, balançam e agitam as bandeiras quando qualquer corredor se aproxima; todos comemoram ao terminar a corrida. Os modelos e as texturas dos dinos são reutilizados, sem novas gerações pagas.

Os sons de água, pássaros e torcida são curtos e usam a ponte e os controles de áudio existentes. Os gatilhos limitam repetições durante a volta. Silenciar e pausar interrompem os sons. Pausa congela gotas, aves, bandeiras e animações da torcida; reinício limpa os efeitos e permite novos gatilhos.

## Implementação

- `race_scenery.gd`: criação das poças, gotas, aves e espectadores. Malhas das poças usam `forest.point()`; os respingos verificam o segmento entre as posições físicas anteriores e atuais. Não acrescenta `CollisionObject3D`.
- `race.gd`: cria o cenário depois da pista, atualiza com as posições reais dos corredores e restaura no reinício.
- As animações dos espectadores usam processamento manual para que avanço, pausa e reinício acompanhem a corrida. As aves e os saltos usam o relógio do cenário.
- `audio.mjs`: sons sintetizados de respingo, canto e torcida. `game.js` atualiza o cache do módulo de áudio.

## Validação

- `npm run test:race`: nove scripts Godot aprovados, incluindo seis voltas de dino/pista, equilíbrio, recuperação dourada, novo cenário, rival e colisões.
- `scenery_test.gd`: nas duas pistas, verifica a geometria e o relevo das poças, ausência de colisores novos, respingos para ambos os corredores, som único por passagem, término do efeito, aves, torcida, pausa e reinício.
- `npm run test:gait`: dois scripts Godot e dois testes Python aprovados; passadas e animações dos corredores preservadas.
- `npm test`: 11 testes Node aprovados. Os dois novos testes conferem sons curtos e suaves, além de silêncio durante pausa e mute. A execução autorizada fora do sandbox permite os subprocessos exigidos pelos testes anteriores.
- Chromium/Playwright: exportação 0.17.0 em 1280×900, passagem real pela poça, sons de água, pássaros e torcida, formas visíveis e mudança de posição das aves e espectadores. Na praia em 390×844, passagem pela poça e os três sons também foram confirmados, sem rolagem horizontal. Sem erros de console. Capturas em pausa, com o painel de pausa ocultado apenas durante o registro.

Exportação web: **14.755.468 bytes**, aproximadamente 8 KB a mais que a 0.16.1. Sem dependências novas, geração paga, commit ou push.

Ainda faltam testes com crianças e aparelhos físicos, especialmente desempenho com mais personagens e clareza dos sons. A randomização das frutas continua pendente.

# Rivais, modo tranquilo e recompensas — 0.20.0

## Rivais

Escolha na abertura, enviada à cena por `select:<dino>:<pista>:<rival>`. Perfis em `RIVALS` (`race_state.gd`):

| Rival | Velocidade | Reação | Frutas ignoradas | Distração | Bom / médio / parado |
| --- | --- | --- | --- | --- | --- |
| Dorminhoco | 2,20 | 0,5 s | 35% | 50% a cada 4 s, 1,5 s mais lento (−0,8) | 93 / 66 / 53% |
| Brincalhão | 2,15 | 0,3 s | 0 | nenhuma | 91 / 51 / 13% |
| Rapidinho | 2,30 | 0,25 s | 0 | nenhuma | 70 / 19 / 2% |

Taxas de vitória do jogador em 180 corridas simuladas por linha (3 dinos × 2 pistas × 30 layouts), com robôs jogando bem, médio (metade das frutas) e parado. O Brincalhão mantém o equilíbrio aprovado na 0.19.0. Durante a distração o rival mantém o alvo, desacelera a condução lateral e a página mostra "Seu amigo parou para olhar um passarinho!". Pausa congela e reinício limpa os temporizadores.

## Modo tranquilo

`rival_id = "none"`: o rival fica oculto, sem colisão e parado; não há fruta dourada; a câmera segue só o jogador. Sem comando de direção, a assistência puxa o dino a até 60% da condução para a fruta mais próxima a até 3 unidades à frente e 1,6 de distância lateral. Com robô parado, a volta rende as 12 frutas possíveis; a direção da criança sempre tem prioridade. Ajustes: `ASSIST_RANGE`, `ASSIST_REACH`, `ASSIST_STRENGTH`.

## Recompensas

`prototypes/rewards.mjs`: 8 adesivos por volta completa (primeira volta, floresta, praia, 10 frutas, fruta dourada, passeio tranquilo, chegar antes de um amigo, vencer o Rapidinho) e 4 cores liberadas com 0/2/4/6 adesivos. Salvo em `localStorage` (`dino-race-rewards`), validado ao carregar; com armazenamento bloqueado o jogo segue sem salvar. A cor vai para a cena por `color:<id>`, validado contra `PLAYER_COLORS`.

As cores usam `dino_tint.gdshader`, que mantém a luminância da textura e aplica o tom. O tingimento por `albedo_color` multiplicava a textura laranja e deixava todas as cores marrons; comprovado por captura antes/depois.

## Validação

- `modes_test.gd`: perfis, frutas ignoradas, distração com pausa/reinício, volta solo sem rival e sem dourada, assistência que respeita a direção e o alcance, contador de douradas, rival oculto e cores na cena.
- `rewards.test.mjs`: concessão única, cores por quantidade, mensagem de prêmio, validação do salvo e armazenamento bloqueado.
- `npm run test:godot` (20 scripts + 2 Python) e `npm test` (15) aprovados; testes da corrida repetidos sem falha.
- Chromium/Playwright: volta solo completa com 12 frutas, 4 adesivos salvos e cores liberadas; corrida com Dorminhoco mostrando a distração; quatro cores do jogador comparadas na mesma cena; 1280×900 e 390×844 sem rolagem horizontal, botão de jogar visível no celular, sem erros no console.

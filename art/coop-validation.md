# Dupla — ticket 03

A configuração `select-coop:<espécie 1>:<espécie 2>:<pista>` é atômica e aceita espécies iguais. `mode` distingue Dupla, Rival e Sozinho; os comandos antigos continuam disponíveis. Dois registros/corpos existentes recebem entrada humana, atributos, aparência e contadores próprios. Só duas chegadas encerram a corrida, sem vencedor. Quem chega sai da passagem, perde a colisão e aguarda parado. O Filhote recebe a soma, inclusive zero.

## Calibração

Ajuda começa aos **6 m** e reduz suavemente o avanço longitudinal do líder até zero aos **18 m**. Há limite explícito de 18 m, sem diminuir progresso ou alterar direção lateral. A cena também limita o destino pelo progresso anterior do parceiro, preservando o limite quando uma colisão impede seu avanço. O máximo mantém alcançável o limiar de 15 m da dourada no Vale; Floresta/Praia mantêm 5 m. Vida, cooldown, margem de chegada e duração/força do Impulso dourado seguem os parâmetros anteriores de cada pista.

Nas simulações longas, cada slot liderou com 60 m/s artificiais contra a velocidade da outra espécie e entradas laterais diferentes; maior separação observada **16,6424285366 m**, com progresso sempre monotônico e separação abaixo de 18 m. A matriz de 3 × 3 espécies × 3 pistas concluiu as 27 corridas, sem IA, distração ou vencedor. Floresta/Praia continuam uma Volta por pessoa, Vale três.

Câmera da corrida usa o ponto médio real dos corpos e enquadramento adaptado à separação e proporção. Espera considera também o corpo fora da passagem; chegada inclui o Filhote. Prévia tem ângulo frontal/lateral, ajuste pelos limites reais de malhas/acessórios e rótulos dos dois jogadores, preservando seu yaw na largada. A câmera antiga e `park` não foram alterados. Giro horizontal permanece limitado a 50 graus/s.

## Evidência automatizada

- `npm test`: **26/26**, log local `/tmp/dino-ticket03-node.log`. Entradas por fonte/ponteiro, opostas, validação de modo/enums/estruturas/números finitos, totais e fatos por humano; recompensas somente com duas chegadas, cesta em 9/10 e exclusão explícita de `calm`, `first-place`, `speedy`, inclusive com campos legados inconsistentes. Catálogos dos dois menus e versões de cache conferidos. A execução restrita perdia stderr dos processos filhos; a mesma suíte passou com execução escalada, sem mudar os testes.
- `coop_state_test.gd`: matriz completa, ambos líderes, máximo/monotonicidade, ambas ordens de chegada nas três pistas, pausa/reset/troca de modo, coleta única, respawn, Voltas desencontradas, Setas sem fruta e dourada destinada a cada slot com parâmetros por pista.
- `coop_scene_test.gd`: corpos e contatos físicos reais nas três pistas; entradas independentes/nativas, opostas e fontes sobrepostas, pausa/soltura, espera de qualquer slot sem colisão, coleta comum repetida sem dupla contagem, dourada/halo para ambos e Filhote com zero/10. Reset restaura corpos/contadores e limpa entradas/apresentação.
- `coop_camera_test.gd`: **125.016 projeções** dos limites do corpo, malhas, acessórios e rótulos: três espécies, três pistas, posições ao longo de uma Volta, 18 m de separação, extremos laterais alternados, qualquer primeiro na espera e chegada; 1280×900, 390×844 e viewport de resultado 390×340. Prévia verificada em 1280×220 e 390×200. Verifica pontos atrás da câmera, limites completos e giro, não apenas foco central.
- `XDG_DATA_HOME=/tmp/dino-game-godot-data npm run test:godot`: exit 0, **28 scripts Godot e dois testes Python**, log `/tmp/dino-ticket03-godot.log`. Inclui 72 fingerprints numéricos de Floresta/Praia intactos, Vale, modos, física, cenário e animações. Após os últimos ajustes de prévia/entradas, `npm run test:race` repetido com exit 0, 18 scripts, em `/tmp/dino-ticket03-race-final.log`, mais testes afetados individuais.
- Exportação parcial Web reutiliza o runtime 4.7.2: `web/godot/index.pck`, **14.787.628 bytes**, igual a `fileSizes`; log `/tmp/dino-ticket03-export.log`. Templates Web completos continuam ausentes. Versão/cache final pertence ao ticket 04.

## Navegador pelo Main

- Duas aparências independentes preservadas após recarga. Prévia frontal/lateral móvel com acessórios legíveis em `.playwright-mcp/coop-preview-mobile-fixed.png`.
- Dois contatos reais e confiáveis do Chromium pressionaram os dois jogadores; soltar especificamente um manteve o outro sustentado. Cancelar o restante limpou tudo. Dois toques opostos do jogador 1 anularam a direção; soltar um retomou o outro. Teclado A e toque esquerdo compuseram, e soltar A preservou o toque.
- Foco no iframe: D moveu jogador 1 à direita e seta esquerda moveu jogador 2 à esquerda. Pausa limpou entradas; retomar com autorepeat da tecla ainda sustentada não as restaurou. Blur real, reinício e menu limparam ambos. A aba remota perdeu foco, mas continuou `visibilityState=visible`: não é prova de aba realmente oculta; os handlers de visibilidade existem na página e no shell.
- Ponte no navegador: seis mensagens rejeitadas sem alterar texto do DOM nem álbum salvo: origem falsa com remetente iframe; `window.postMessage` real de origem correta e remetente errado; mensagens reais do iframe com modo desconhecido, `players=[]`, fruta NaN e velocidade de jogador infinita. O payload de remetente errado tinha total coerente alterado para tornar uma aceitação indevida observável.
- `.playwright-mcp/coop-mobile-controls.png` registra ambos inteiros, controles identificados e efeitos simultâneos dos dois caminhos. Corrida natural na Floresta concluiu com os dois, 18 frutas = 11 + 7, `mode=coop` e vencedor vazio. `.playwright-mcp/coop-mobile-result.png` mostra dupla/Filhote/ações visíveis.

Imagens e logs são artefatos locais. Emulação e testes de projeção não provam desempenho em aparelho físico nem preferência infantil. A matriz visual ampliada e a versão 0.28.0 seguem no ticket 04; não há dependências, mídia ou serviços novos.

# Changelog

## 0.28.1 — 2026-11-16

- Removidos o salto e a inclinação do dino ao passar pelos trechos de frutas/Setas, conforme feedback de teste. Confetes, pétalas e balanço nas poças continuam disponíveis.
- Página, módulos e exportação web atualizados para 0.28.1. PCK reexportado: **14.787.436 bytes**.

## 0.28.0 — 2026-11-16

- Aparências independentes para dois jogadores, com prévia do dino real, cores do álbum e boné/óculos gratuitos nos três dinos; escolhas salvas no navegador sem apagar adesivos antigos.
- Reações automáticas breves: balanço na poça e salto contente nas frutas. Caminhos existentes ganham efeitos distintos à esquerda/direita, sem mudar coleta, impulso ou colisões. O Filhote recebe o total e comemora na chegada, inclusive com zero frutas ou derrota.
- **Dupla** nas três pistas, separada de Rival/Sozinho: A/D e setas, dois pares de toque simultâneo, aparências próprias, frutas compartilhadas, espera sem bloquear e resultado só após ambos chegarem. Álbum usa a soma e exclui prêmios competitivos/de Sozinho.
- Câmera enquadra os dois em tela larga/vertical. Ajuda longitudinal exclusiva da Dupla reduz avanço a partir de 6 m e para o líder no limite de 18 m, sem recuar/teletransportar nem tomar direção lateral; giro continua limitado a 50 graus/s. Separação máxima medida: 16,6424285366 m nas simulações de estresse. Modos anteriores preservam a caracterização numérica.
- Versão/cache 0.28.0 sincronizados. PCK reexportado com Godot 4.7.2: **14.787.676 bytes**; runtime WASM existente: **39.514.754 bytes**. Templates Web completos indisponíveis: atualização por `--export-pack`, com JS/WASM 4.7.2 reutilizados. Evidências e limites em [validação da entrega](art/release-0.28.0-validation.md); sem mídia paga, dependências ou serviços novos.

## 0.27.0 — 2026-11-12

- Fruta dourada mais forte no Vale, para quem está atrás conseguir alcançar: aparece a 15 u de diferença (`VALLEY_RECOVERY_GAP`, antes 30), com impulso de 3,0 (`VALLEY_RECOVERY_BOOST`, antes 2,0) por 6 s (`VALLEY_RECOVERY_DURATION`, antes 4). Vale para os dois corredores; Floresta e Praia não mudaram. Simulação no Vale (3 dinos x 20 sorteios por célula), vitória do jogador antes -> depois: médio x Rapidinho 10% -> 35%, médio x Brincalhão 48% -> 57%, parado x Brincalhão 10% -> 23%, bom x Rapidinho 77% -> 77%. A tabela de calibração da 0.25.0 vale para a regra antiga.

## 0.26.0 — 2026-11-12

- No Vale, ao cruzar a linha de chegada aparece um aviso grande no meio da tela: "Volta 2/3" e, na última, "Última volta!" em destaque. O rodapé continua mostrando "Volta N/3".
- Novo som `lap` (dois toques) a cada volta e `last-lap` refeito como fanfarra: arpejo subindo, duas notas de chamada, acorde sustentado e batidas graves (~1,5 s). 
- Seta de impulso agora dá retorno: a seta pulsa na pista, aparece "Impulso!" na tela, toca um som de vento e o rodapé avisa "Seta de impulso! Seu dino ficou mais rápido.". O relatório `park-race` ganhou o campo `arrows`.
- Desempenho: sombra do sol com 2 fatias, alcance de 40 u e mapa de 2048 px (antes 4 fatias, 100 u e 4096 px); terreno, fundo, marcadores da borda, quadriculado da largada e poças não projetam mais sombra. Numa Intel UHD 630 a 1114x655, o Vale no navegador foi de ~26 fps para 46-56 fps; nativo, o quadro ficou ~36% mais rápido nas três pistas.

## 0.25.0 — 2026-11-12

- Nova pista **Vale**, terceiro cartão em "Onde vamos brincar?": estádio com duas retas de 45 u e curvas de raio 12 u (volta de ~165 u), campo aberto com árvores longe da pista, sem novos modelos. A corrida tem três voltas; progresso, chegada, vencedor e margem final da fruta dourada valem para a corrida inteira. As frutinhas repetem o mesmo sorteio a cada volta e cada corredor pode pegá-las de novo em cada volta. Floresta e Praia continuam com uma volta.
- Retorno decrescente, só no Vale (ADR 0001): cada impulso soma `VALLEY_GAIN / (1 + bônus / VALLEY_SOFTNESS)` (0,22 e 0,6), sempre positivo e sem teto; o nível 3 chega com 8 impulsos seguidos, sem fruta dourada. Quando o impulso acaba, a velocidade volta à base a 0,28 u/s² (`VALLEY_DECAY`, contra 0,64 na Floresta e na Praia), e a direção do jogador, do rival e da ajuda do modo Sozinho cresce com a velocidade. Floresta e Praia mantêm o limite `MAX_BOOST`.
- Setas de impulso: uma por reta, do lado oposto ao par de frutinhas daquele trecho. Dão o mesmo impulso de uma frutinha, contam na sequência, valem para os dois corredores em todas as voltas e não contam como fruta. Desenhadas no chão com primitivas, com o som `pickup`.
- Rivais do Vale calibrados por simulação (`npm run sim:valley`, 3 dinos x 30 sorteios por célula) com `VALLEY_RIVALS`: Dorminhoco `miss` 0,3; Brincalhão velocidade 2,3 e `miss` 0,6; Rapidinho velocidade 2,5 e `miss` 0,65. `RIVALS` não mudou. Fruta dourada no Vale a partir de 30 u de diferença (`VALLEY_RECOVERY_GAP`; Floresta e Praia seguem com 5 u). Vitória do jogador por robô:

  | Amigo | Robô | Floresta/Praia | Vale | Volta mediana (s) | Corrida mediana (s) | Douradas por corrida (F/P, Vale) | Nível 3 no Vale | Velocidade máx. |
  |---|---|---|---|---|---|---|---|---|
  | Dorminhoco | bom | 96% | 99% | 50,9 | 148,1 | 1,2 / 8,6 | 100% | 5,05 |
  | Dorminhoco | médio | 83% | 90% | 61,1 | 184,1 | 0,7 / 2,5 | 31% | 4,13 |
  | Dorminhoco | parado | 52% | 48% | 65,9 | 197,0 | 0,3 / 1,0 | 2% | 4,27 |
  | Brincalhão | bom | 92% | 97% | 52,1 | 156,7 | 0,9 / 5,0 | 100% | 5,05 |
  | Brincalhão | médio | 57% | 51% | 61,4 | 184,7 | 0,2 / 0,9 | 36% | 4,27 |
  | Brincalhão | parado | 13% | 7% | 64,5 | 191,6 | 0,5 / 2,7 | 4% | 4,27 |
  | Rapidinho | bom | 82% | 81% | 52,2 | 155,2 | 0,3 / 2,5 | 100% | 5,05 |
  | Rapidinho | médio | 10% | 9% | 57,8 | 175,3 | 0,6 / 3,3 | 73% | 4,27 |
  | Rapidinho | parado | 2% | 0% | 57,8 | 175,7 | 1,0 / 7,0 | 14% | 4,27 |

- A linha de base medida hoje na Floresta/Praia difere da tabela de referência (93/66/53, 91/51/13, 70/19/2) em mais de 10 pontos em Dorminhoco médio e Rapidinho bom; o Vale foi calibrado contra a linha medida. Corrida mediana de 148-157 s jogando bem, 175-185 s no médio e 176-197 s parado. Velocidade máxima observada 5,05 u/s (constante `PRACTICAL_MAX_SPEED` 5,1 no teste); a câmera precisa girar no máximo 24,6°/s nas curvas, abaixo do limite de 50°/s. Problemas aceitos: até ~8 frutas douradas por corrida quando um corredor fica muito para trás (~3,5/min contra ~2,1/min na Floresta/Praia), o robô parado chega ao nível 3 em 2-14% das corridas, e a Corrida mediana dos robôs médio e parado fica em 175-197 s, um pouco acima de 3 min, para manter o nível 3 como conquista.
- Página: no Vale o rodapé mostra "Volta N/3", o título do placar vira "TRÊS VOLTAS", a entrada na última volta mostra "Última volta!" com um som curto novo (`last-lap`) e a chegada diz "Três voltas completas!". As barras de progresso cobrem a corrida inteira. A mensagem `park-race` ganhou `lap` e `laps`.
- Novo adesivo "Explorador do vale" (total de 9). A dica de "Cesta cheia" passa a ser "Pegue 10 frutinhas numa corrida"; a regra continua 10 frutinhas.
- Novos testes: `baseline_test.gd` fixa o comportamento da Floresta e da Praia (72 corridas por dino, pista, rival e robô, gravadas antes de qualquer mudança); `valley_test.gd` cobre geometria, voltas, frutinhas por volta, setas, retorno decrescente, queda lenta, direção, nível 3, fruta dourada, modo Sozinho, limite da câmera e a cena; `bots.gd` reúne os robôs bom/médio/parado. Adesivo do vale, dica da cesta e som da última volta em `rewards.test.mjs` e `audio.test.mjs`. Pack reexportado (14.771.164 bytes, 5.840 a mais que os 14.765.324 da 0.24.0).

## 0.24.0 — 2026-11-12

- Contador de sequência: cada fruta comum pega enquanto o bônus da anterior está ativo (4 s) soma em `streak`, que zera quando o bônus acaba. A fruta dourada fica fora da conta. A mensagem `park-race` ganhou `streak`.
- Página: selo "2 seguidas!", "3 seguidas!" ou "Super rápido!" (4 ou mais) com animação de entrada por 1,5 s, escondido na pausa, na chegada e ao voltar ao menu (sem animação com `prefers-reduced-motion`). A mensagem de status repete o selo.
- Teste da sequência em `race_state_test.gd`. Pack reexportado (14.765.324 bytes).

## 0.23.0 — 2026-11-12

- Velocidade visível em três níveis, pelo bônus sobre a velocidade base (`SPEED_LEVELS` 0,3 / 0,6 / 1,0 em `race_state.gd`): nível 1 (2 frutas) solta poeira nos pés; nível 2 (4 frutas) deixa um rastro na cor do dino ou na cor escolhida; nível 3 (fruta dourada) solta faíscas. Vale para o jogador e para o amigo, congela na pausa e limpa no reinício. Partículas `CPUParticles3D` sem sombra, em `game/race/speed_effects.gd`.
- A câmera abre até 8° conforme o bônus e volta ao normal no reinício.
- Página: linhas de vento na borda do jogo nos níveis 2 e 3 (paradas com `prefers-reduced-motion`), vento mais agudo a cada nível e um "whoosh" quando o nível sobe. A mensagem `park-race` ganhou `speedLevel`.
- Novo `speed_effects_test.gd`; testes de nível em `race_state_test.gd`, do vento e do "whoosh" em `audio.test.mjs`, e das cores do rastro no teste de catálogo. Pack reexportado (14.765.196 bytes).
- Corrigido: os imports de `game.js` tinham versões de cache fixas (`audio.mjs?v=0.17.0`, `rewards.mjs?v=0.20.0`). O navegador combinava o `game.js` novo com o `audio.mjs` antigo, `sound.speed()` falhava a cada mensagem e a contagem e o painel final deixavam de aparecer. Os imports seguem agora a versão do pacote, e um teste exige que todo `?v=` da página e do shell seja igual à versão do `package.json`.

## 0.22.1 — 2026-11-12

- Validação da seleção centralizada em `RaceState.can_configure()`, usada por `configure` e pela ponte web (`select:`); nova constante `TRACKS`.
- Novo `web/catalog.test.mjs`: confere que os ids de dino, pista e amigo da página, as cores de `rewards.mjs` e as cores dos amigos batem com os catálogos do Godot. Antes, uma cor ou opção nova sem par era ignorada em silêncio.
- O outro corredor passa a se chamar "rival" em todo o estado da corrida: `owner`, `winner` e `recoveryTarget` usam `"rival"` (eram `"friend"`), e `friend_taken`/`friend_splashed` viraram `rival_taken`/`rival_splashed`. `rival_id` continua sendo a personalidade. O nó `friend`, compartilhado com o passeio, foi mantido. A página exibe "Amigo" como antes.
- A corrida da floresta não monta mais a grade A\* de 21 mil células do passeio, que ela não usa.
- Formato da mensagem `park-race` documentado com o typedef `RaceReport` em `web/game.js`.
- `handoff.md` removido. Pack reexportado (14.760.696 bytes).

## 0.22.0 — 2026-11-12

- Página responsiva: a área do jogo ocupa a altura da tela (`100svh`, até 760 px) em vez de 65% fixos, sem rolagem da página em nenhum tamanho testado (320x568 a 1920x1080, retrato e paisagem).
- Menu inicial em duas colunas a partir de 651 px de largura: dino e pista à esquerda; amigo, adesivos e "Vamos correr" à direita. Antes o botão ficava escondido sob a rolagem do cartão até em 1440x900. Em telas estreitas o botão fica fixo no rodapé do cartão.
- Celular deitado (altura até 500 px): cabeçalho compacto e setas nas laterais do jogo, ao alcance dos polegares. Antes as setas ficavam abaixo da dobra e a página rolava.
- Só a página mudou; o pack Godot continua o da 0.21.0.

## 0.21.0 — 2026-11-11

- Estrutura reorganizada por contexto: projeto Godot em `game/` com `race/`, `park/`, `world/`, `dinos/` e `common/`; página em `web/`; capturas de validação em `art/previews/`.
- A corrida deixa de herdar do passeio: as duas cenas estendem `common/dino_scene.gd`, sem mudança de comportamento.
- Removidos o protótipo Phaser e a página de comparação de engines.

## 0.20.0 — 2026-11-11

- Nova escolha "Com quem vamos correr?": Dorminhoco (deixa passar frutas e para para olhar passarinhos), Brincalhão (o rival da 0.19.0) e Rapidinho (mais rápido e sem erros), cada um com sua cor. Calibrados por simulação: o jogador vence 93/66/53%, 91/51/13% e 70/19/2% jogando bem/médio/parado.
- Modo tranquilo ("Sozinho"): volta sem rival nem fruta dourada, com assistência leve que puxa o dino para frutas próximas só quando a criança não está virando.
- Recompensas: 8 adesivos ganhos ao completar voltas e 4 cores para o dino, liberadas com 0, 2, 4 e 6 adesivos. Ficam salvos no navegador; sem armazenamento disponível, o jogo funciona normalmente sem salvar.
- A cor dos dinos passa a usar um shader que preserva o padrão da pele. O tingimento anterior multiplicava a textura laranja e deixava as cores marrons; o amigo verde agora aparece verde de fato.
- Novos testes `modes_test.gd` e `rewards.test.mjs`. Correção encontrada nos testes: a assistência gerava `NaN` na lateral quando `advance()` rodava com `delta = 0` na saída da contagem.

## 0.19.0 — 2026-11-11

- Rival com velocidade base 2,15 (era 2,35) e fruta dourada a partir de cinco unidades de diferença (eram quatro). Escolha baseada em 180 corridas simuladas por combinação: com robôs jogando bem, médio e parado, o jogador vence 91% / 51% / 11% das corridas, contra 54% / 27% / 8% antes.
- Nova constante `RIVAL_SPEED`. Testes de rival, colisão e limiar da dourada passam a usar as constantes. Exportação e cache atualizados.

## 0.18.0 — 2026-11-11

- Frutas comuns sorteadas a cada nova corrida e a cada reinício: posição de cada trecho e abertura lateral de cada par (1,0 a 1,55) variam, mantendo quatro bifurcações simétricas, fruta central, alcance na velocidade máxima, no mínimo quatro unidades entre trechos e nenhuma fruta nas últimas oito unidades.
- A cena reposiciona as frutas ao reiniciar.
- `fruit_paths_test` verifica as regras em 25 sorteios por dino/pista e confere se as frutas da cena seguem o novo layout. Testes de estado, colisão e equilíbrio deixam de supor posições fixas.
- `balance_test` desliga a fruta dourada ao medir a recuperação com frutas comuns. Desde a 0.17.1 (limiar 4), o raptor que pega todas as frutas perdia para um rival sem nenhuma, que recebia douradas. Exportação e cache atualizados.

## 0.17.1 — 2026-11-11

- Fruta dourada passa a aparecer a partir de quatro unidades atrás, para qualquer corredor. Teste de limiar, documentação e exportação atualizados.

## 0.17.0 — 2026-11-11

- Quatro poças rasas por pista, acompanhando o relevo e criando respingos quando qualquer corredor atravessa a água, sem alterar a velocidade.
- Oito pássaros com voo, asas animadas e cantos suaves; seis dinos das três espécies torcem perto da corrida, pulam e agitam bandeirinhas. Todos comemoram na chegada.
- Sons de água e torcida pela ponte de áudio existente. Pausa congela os efeitos e reinício restaura a cena. Elementos decorativos não adicionam obstáculos físicos.
- Testes de geometria, terreno, respingos para ambos os corredores, sons únicos, pausa/reinício e torcida nas duas pistas; dois testes Node de áudio. Exportação e cache atualizados.

## 0.16.1 — 2026-11-11

- Bônus dourado aumentado de +1,0 para +2,0 por quatro segundos. O impulso anterior recuperava menos de 1,2 unidade contra o rival no bônus comum máximo.
- Novo teste de recuperação mede a redução real da diferença: pelo menos 4,4 unidades em 3,95 segundos, para os dois destinatários nos seis pares dino/pista, com o líder no máximo das frutas comuns.
- Frutas comuns, duração, intervalo, regras de aparição e colisões mantêm seus valores. Exportação e cache atualizados.

## 0.16.0 — 2026-11-11

- Fruta dourada para qualquer corredor seis unidades atrás: surge três unidades à frente, na sua linha, e só o destinatário pode coletá-la por contato físico.
- Bônus total de +1,0 por quatro segundos, com brilhos dourados no dino e mensagens explicativas. Frutas comuns mantêm seus próprios bônus e temporizadores.
- Uma especial por vez, cinco segundos para coletar e dez segundos entre aparições; sem novas aparições quando o líder entra nas últimas 12 unidades ou após a primeira chegada.
- Rival prioriza sua fruta dourada. Pausa congela fruta, intervalo e brilho; reinício limpa os efeitos.
- Testes de regras nos seis pares dino/pista e para ambos os destinatários, coleta física de ambos, barreira, bônus independentes, expiração, intervalo, pausa e reinício. Exportação web atualizada.

## 0.15.0 — 2026-11-11

- As 20 frutas formam quatro trechos de escolha: duas sequências laterais com duas frutas cada, seguidas de uma fruta central compartilhada.
- Caminhos simétricos com o mesmo potencial de bônus; offsets variam suavemente e há tempo para voltar ao centro mesmo na velocidade máxima.
- Testes das duas escolhas nos seis pares dino/pista, coleta física dos dois caminhos em floresta e praia e reinício sem coletas antigas. Rival continua usando as decisões existentes.
- Instrução inicial, documentação e exportação web atualizadas.

## 0.14.1 — 2026-11-11

- T-rex e velociraptor substituídos por malhas texturizadas geradas pela fal.ai/Tripo H3.1, com pele, manchas, barriga clara e olhos detalhados.
- Rigs de 12 ossos com pernas, pés, braços, cabeça e cauda; corrida com apoio calibrado e descanso. Passadas mantêm a sincronização com o deslocamento.
- Texturas 4K originais preservadas; importação 2K para a versão jogável, acompanhando a resolução do tricerátopo.
- Teste de textura, UVs, pesos, apoio e suavidade dos pés; regressão das seis combinações, colisões, rival e animação. Exportação web atualizada.

## 0.14.0 — 2026-11-11

- Seleção de tricerátopo equilibrado, T-rex mais veloz ou velociraptor mais ágil; modelos bípedes próprios, com corrida e descanso, sem novas gerações pagas.
- Floresta preservada e nova praia com circuito mais largo, terreno baixo, areia, mar, coqueiros e rochas sólidas.
- Frutas reaparecem após 1,5 segundo para o outro corredor, com uma coleta por dino por fruta em cada volta.
- Bônus de 0,16, limitado a quatro incrementos; dura quatro segundos desde a última coleta e termina gradualmente. Mesmas regras para jogador e rival.
- Retorno à seleção pela pausa ou chegada; reinício preserva dino e pista e limpa frutas e bônus. HUD considera a velocidade base escolhida.
- Testes de equilíbrio, recuperação e seis combinações, com voltas completas, animações e validação web em tela larga e vertical. Exportação web atualizada.

## 0.13.0 — 2026-11-10

- Colisões nativas entre os dois corredores, com cápsulas e deslizamento suave, sem dano ou lançamento dos personagens.
- Troncos, pedras e bordas da pista recebem corpos sólidos; frutas usam áreas de detecção física e mantêm coleta única.
- Progresso, chegada e coleta são contabilizados após o movimento permitido pelos contatos, evitando avanço invisível durante um bloqueio.
- Movimento e animações seguem os passos de física; a escala do amigo fica no modelo visual e nas dimensões do colisor.
- Rival continua um pequeno trecho após cruzar a linha para liberar a chegada do jogador.
- Testes de contato sustentado, obstáculos, varredura rápida, coleta compartilhada, bloqueio de progresso/chegada/fruta, pausa, reinício e liberação da chegada; exportação web atualizada.

## 0.12.0 — 2026-11-10

- Rival escolhe frutas à frente considerando tempo de chegada e deslocamento lateral necessário.
- Mantém o alvo enquanto disponível, procura outro após a coleta ou passagem e dá espaço ao jogador quando estão próximos.
- Reação a cada 0,3 segundo, com velocidade e aceleração lateral limitadas para evitar mudanças bruscas.
- Corpo acompanha suavemente a direção real do deslocamento; animação acompanha também a distância dos movimentos diagonais.
- Testes de decisões, estabilidade, alcance, coleta, limites, pausa, reinício, orientação e sincronização das passadas; exportação web atualizada.

## 0.11.1 — 2026-11-10

- Trajetória das patas suavizada na saída e no retorno ao chão, preservando o apoio sincronizado com o deslocamento.
- Animação própria de corrida, com pares diagonais, flexão das patas, movimento discreto do corpo, cabeça e cauda e rotação dos pés durante o avanço.
- Passada calibrada para repetir cerca de 22% menos ciclos na mesma velocidade, mantendo transição suave para o descanso.
- Ritmo da animação corrigido em quadros lentos: acompanha a distância realmente percorrida, incluindo o primeiro quadro após a contagem.
- Sons de passos ajustados à nova cadência, testes de continuidade, contato, transição e sincronização; comparação visual antes/depois e exportação web atualizada.

## 0.11.0 — 2026-11-10

- Corrida amigável de uma volta contra o amigo verde, com contagem de largada, chegada e repetição.
- Avanço automático, movimento lateral contínuo pelas setas e botões grandes para toque.
- Vinte frutas compartilhadas: cada coleta aumenta a velocidade de quem pegou.
- Circuito largo e suave, afastado do lago e dos troncos; bandeiras laterais e linha quadriculada de chegada.
- Progresso dos dois dinos, contador de frutas, pausa explícita e pausa ao sair da aba.
- Câmera inclui o amigo quando próximo, preservando giro máximo de 50 graus/s e aceleração de 80 graus/s².
- Dois novos scripts de testes, validação no navegador com teclado e toque emulado e exportação web atualizada. O passeio anterior permanece na cena `park.tscn`.

## 0.10.0 — 2026-11-10

- Novo amigo no prado, reutilizando o tricerátopo com tamanho menor e variação verde.
- Passeio por rotas curtas, aproximação lateral, cumprimento com a cabeça e acompanhamento por até oito segundos.
- Retorno ao prado ao terminar o passeio ou se afastar demais; reencontro após o jogador sair e voltar.
- Navegação pelo terreno, espaço pessoal e desvio local ao redor do jogador.
- Enquadramento dos dois durante o encontro, preservando o giro lento da câmera e a prioridade da alimentação.
- Testes de sequência, repetição, limites, materiais independentes e reinício em todas as fases.

## 0.9.2 — 2026-11-10

- Giro da câmera reduzido de 110 para 50 graus por segundo.
- Aceleração gradual, limitada a 80 graus por segundo ao quadrado, para evitar o arranque brusco ao começar a andar.
- Aproximação ao ângulo desejado mais lenta, sem ultrapassar o alvo; reinício zera a velocidade de giro.
- Teste reproduziu 27,5 graus nos primeiros 0,25 segundo da versão anterior; agora limita esse início a 4 graus.

## 0.9.1 — 2026-11-10

- Câmera deixa o deslocamento fixo no mundo e acompanha por trás da direção real da caminhada, inclusive na volta.
- Giro pelo menor caminho, limitado a 110 graus por segundo e suavizado ao alinhar.
- Direção preservada durante reações e alimentação; início e reinício orientados para a floresta.
- Vista do mirante acompanha o novo ângulo, com picos laterais reposicionados para as duas aproximações.
- Teste de regressão reproduziu a câmera no mesmo lado na ida e na volta; verificação ampliada para clique e toque durante a rotação.

## 0.9.0 — 2026-11-10

- Seis áreas conectadas, acrescentando vale de cogumelos, prado de borboletas e mirante.
- Área caminhável ampliada de 110,75 para 319,875 unidades quadradas; dois circuitos somam cerca de 80 unidades de trilha.
- Subida suave ao mirante, montanhas distantes e câmera que abre gradualmente a vista da paisagem.
- Cogumelos coloridos, flores do prado, borboletas animadas e marco de pedras no mirante.
- Seis atalhos acessíveis, organizados em duas linhas no celular; conclusão após seis descobertas.
- Testes ampliados de rotas, relevo, toque em terreno elevado, repetição e retorno para alimentar o amigo.

## 0.8.0 — 2026-11-10

- Copas com desaparecimento e retorno graduais em aproximadamente 0,29 segundo.
- Troncos preservados quando não encobrem os personagens ou ficam próximos demais da câmera.
- Área protegida ampliada durante a alimentação para manter os dois dinossauros visíveis.
- Material com transparência por pixels compatível com WebGL, mantendo uma malha por árvore.
- Testes de transição, reversão e pixels renderizados; circuito web, alimentação e toque em tela vertical conferidos.

## 0.7.0 — 2026-11-10

- Ambiente sonoro suave com vento, água próxima ao lago e pássaros no bosque.
- Passos por deslocamento real, notas nas descobertas e sons de pegar, mastigar e concluir a alimentação.
- Áudio sintetizado pela Web Audio API, sem bibliotecas ou downloads de mídia adicionais.
- Botão acessível de silêncio; reprodução após iniciar e pausa ao ocultar a aba.
- Reinício preserva a opção de silêncio e encerra efeitos anteriores.
- Testes Godot dos eventos e renderização real de áudio com OfflineAudioContext no Chromium.

## 0.6.0 — 2026-11-10

- Parque ampliado com clareira, margem do lago e bosque, conectados por trilha circular.
- Flores junto ao lago, pegadas no bosque e alimentação preservada na clareira.
- Navegação ampliada para as áreas e passagens, com retorno contínuo e sem carregar outra tela.
- Lago com plantas aquáticas e bosque marcado por árvore grande e vegetação mais escura.
- Geometria agrupada por árvore para preservar a visibilidade do personagem em tela vertical.
- Testes do circuito completo, trajetos de ida e volta, limites, câmera e alimentação após retornar.

## 0.5.0 — 2026-11-10

- Alimentação completa: buscar fruta na cesta, carregar, entregar, mastigar e reagir com corações.
- Amigo menor reutiliza o tricerátopo articulado; descoberta concluída somente após comer.
- Repetição livre e restauração da fruta ao interromper ou reiniciar em qualquer fase.
- Câmera enquadra os dois personagens durante a entrega e a mastigação.
- Corrigida ocultação de árvores cujas copas encobriam a interação perto do foco da câmera.
- Testes de sequência, conclusão, repetição, interrupção e reinício; validação web por clique, teclado e toque emulado.

## 0.4.0 — 2026-11-10

- Clareira de floresta com terreno contínuo, trilha curva, lago, pedras e vegetação.
- Câmera próxima com acompanhamento suave e enquadramento adaptado ao celular.
- Rotas que contornam lago e árvores; toques consultam a altura real do terreno.
- Árvores agrupadas para reduzir chamadas de desenho; vegetação que encobre o personagem é ocultada.
- Movimento consome os trechos da rota sem cortar obstáculos quando um quadro atrasa.
- Testes de navegação, relevo, câmera, toque e reinício; descobertas existentes preservadas.

## 0.3.0 — 2026-11-10

- Tricerátopo cartoon alaranjado como personagem principal, seguindo o conceito aprovado.
- Esqueleto de 16 ossos com quatro patas articuladas, caminhada e descanso em loop.
- Ritmo dos passos proporcional ao deslocamento; remoção do balanço que levantava o corpo inteiro.
- Testes de importação, pesos, articulação, apoio das patas, sincronização e reinício.
- Malha original, referência, parâmetros e script de rigging preservados para reprodução.

## 0.2.0 — 2026-11-09

- Primeira versão jogável em Godot como página inicial, com início e reinício sem recarregar.
- Dinossauro 3D gerado pela fal.ai, flores que abrem, pegadas animadas e um amigo nas frutinhas.
- Descobertas acessíveis por toque, clique ou botões com teclado, com repetição livre.
- Testes Godot para visitas, repetição, reinício durante animações e limites do parque.
- Comparação anterior preservada em `comparacao.html`.

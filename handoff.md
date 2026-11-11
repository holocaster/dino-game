# Handoff — Corrida dos dinos

Atualizado em 2026-11-11. Projeto: `/home/holocaster/Desktop/dino-game`. Conversa em português. Versão atual: **0.20.0**.

## Onde paramos

A versão jogável atual é **0.20.0**. Nesta sessão (todas sem commit, push ou Git):

- **0.18.0:** frutas comuns sorteadas a cada corrida e reinício, mantendo bifurcações simétricas, alcance e espaçamento. Testes que supunham posições fixas foram ajustados. O `balance_test` (raptor) já falhava desde a 0.17.1 e agora isola as frutas comuns.
- **0.19.0:** rival 2,15 e fruta dourada a partir de 5 unidades, escolhidos pelo usuário após simulação (jogador vence 91/51/11% jogando bem/médio/parado; antes 54/27/8%).
- **0.20.0:** o usuário pediu os itens 6, 7 e 8 juntos, decididos por mim e relatados no final:
  - **Rivais:** escolha "Com quem vamos correr?" com Dorminhoco (2,20, erra e se distrai), Brincalhão (o rival da 0.19.0) e Rapidinho (2,30). Calibrados por simulação: 93/66/53%, 91/51/13% e 70/19/2%.
  - **Modo tranquilo:** opção "Sozinho", sem rival nem dourada, com assistência leve para alcançar frutas quando a criança não vira. Com um robô parado, rende as 12 frutas possíveis.
  - **Recompensas:** 8 adesivos e 4 cores do dino, salvos em `localStorage`.
  - **Cores:** novo `dino_tint.gdshader`. O tingimento antigo deixava tudo marrom, e o amigo verde agora fica verde de fato.
- Detalhes e evidências em `art/modes-validation.md`. Testes: 20 scripts Godot, 2 Python e 15 Node aprovados; navegador validado em 1280×900 e 390×844. Pack: 14.759.224 bytes.

## Estado entregue

- Jogo infantil sem violência, Godot 4.7.2/GDScript, acessível pelo navegador. Uma volta contra um de três amigos (ou sozinho no modo tranquilo), avanço automático e controle lateral por teclado ou botões para toque.
- Três dinos selecionáveis: tricerátopo equilibrado, T-rex mais veloz e velociraptor mais ágil. Velocidades base: 2,20 / 2,27 / 2,13; movimento lateral: 2,40 / 2,20 / 2,70. O rival padrão (Brincalhão) tem base 2,15 (`RIVAL_SPEED`); perfis em `RIVALS`.
- Floresta e praia, com traçados e terrenos diferentes. Seleção na abertura e retorno à seleção pela pausa ou chegada; reinício preserva dino/pista.
- Os três modelos de dinossauros foram gerados pela fal.ai. O usuário rejeitou o acabamento dos bípedes procedurais da 0.14.0; eles foram substituídos na **0.14.1** por malhas texturizadas do Tripo H3.1. Fontes 4K preservadas; texturas 2K no jogo.
- Passadas articuladas e sincronizadas com o deslocamento. Câmera suave, áudio, pausa automática ao sair da aba e reinício.
- Colisões físicas entre corredores, troncos, pedras e bordas. Progresso, coleta e chegada dependem do movimento realmente permitido. O rival continua após terminar para liberar a chegada.
- Quatro poças por pista criam respingos para qualquer corredor; pássaros voam e cantam; dinos na lateral pulam e agitam bandeirinhas perto dos corredores e comemoram na chegada. Pausa congela os efeitos e reinício limpa os gatilhos.
- Sem persistência. A cena anterior de passeio permanece em `park.tscn`; a inicial é `race.tscn`.

### Frutas comuns na 0.15.0

São **20 frutas**, organizadas em quatro trechos. Cada trecho tem duas frutas à esquerda e duas à direita, com progresso equivalente, seguidas de uma fruta central compartilhada. Seguir um lado e voltar ao centro permite três coletas por trecho, 12 na volta. A última sequência termina oito unidades antes da chegada, evitando uma fruta visível atrás dos dinos já na largada.

Cada coleta concede +0,16, até +0,64 sobre a velocidade base. O bônus dura quatro segundos desde a última coleta; depois diminui gradualmente a 0,64 unidade/s. A fruta reaparece após 1,5 segundo para o outro corredor. Cada dino pode pegar cada fruta uma vez por volta; após ambos coletarem, ela fica indisponível. Pausa congela os temporizadores e reinício limpa as coletas e bônus.

O rival já busca frutas alcançáveis, mantém alvos, reconsidera alvos indisponíveis e tenta preservar espaço. Não há aceleração escondida por estar atrás. Na última simulação com o jogador mantendo sua linha, coletou 12 frutas.

## Fruta dourada — regras atuais da 0.19.0

- Com pelo menos cinco unidades de diferença (eram quatro até a 0.18.0), surge três unidades à frente de quem está atrás, na mesma linha lateral. Vale para jogador e rival; apenas o destinatário pode coletar por contato físico.
- Uma especial por vez; cinco segundos para coletar. Some também ao ser ultrapassada sem contato. O intervalo mínimo é de dez segundos entre aparições, contado desde a criação.
- Bônus **total** de +2,0 sobre a base durante quatro segundos (ajustado na 0.16.1 após o usuário relatar recuperação fraca). As frutas comuns conservam seus próprios valores e relógios: não somam acima desse teto nem prolongam o efeito dourado. Ao terminar, volta a valer o bônus comum ainda ativo.
- Cinco pontos dourados orbitam o dino beneficiado. Fruta emissiva, mensagens e HUD explicam a ajuda, sem depender de pós-processamento ou novas gerações pagas.
- O rival prioriza a própria fruta dourada. Não aparecem novas quando o líder entra nas últimas 12 unidades. A primeira chegada elimina uma fruta pendente e impede novas aparições, preservando o vencedor.
- Pausa congela duração, intervalo e brilho. Reinício limpa fruta, contatos e efeitos. A coleta dourada também conta no placar de frutas do jogador.

Pedidos futuros: completar personalidades do rival (item 6), implementar recompensas (7) e modo tranquilo (8). Folhas, pontes e arcos são possíveis expansões do item 5, sem regras aprovadas.

## Mapa técnico para retomar

- `prototypes/godot-project/race_state.gd`: regras, atributos, distribuição das frutas, bônus, respawn, IA, progresso e vencedor. `advance()` chama a resolução física antes de confirmar coleta/chegada. Frutas comuns usam `distance`, `lateral`, `owner`, `respawn`, `player_taken` e `friend_taken`. A dourada usa `recovery_fruit` separado; propriedades `speed`/`rival_speed` expõem o maior bônus ativo, preservando as velocidades comuns em `_speed`/`_rival_speed`.
- `race.gd`: cena, corpos, áreas das frutas, consultas físicas, câmera, animações, áudio e ponte web. A cena cria as frutas em `_ready()`; `fruit_nodes[index]` corresponde a `race.fruits[index]`. A dourada reutiliza um único `recovery_node`, separado das 20 frutas comuns. `_pickup_contact(-1, rival)` consulta esse corpo; visibilidade e camada de colisão acompanham o estado. Reinício desativa o nó e limpa os efeitos.
- `race_scenery.gd`: decoração e efeitos do item 5, chamada por `race.gd`. Poças são malhas seguindo `forest.point()`; respingos usam segmentos entre as posições físicas anteriores e atuais. Não há colisores novos. Aves e torcida usam tempo próprio; animações da torcida são manuais para respeitar pausa. `reset()` limpa efeitos e gatilhos de som.
- `forest.gd`: relevo, pista, árvores e colisores. Posicionamento usa `forest.point()`; limite lateral lógico é ±1,65. Corpos físicos e formas mantêm escala unitária; o tamanho visual fica no nó `Model`.
- Perfis de rival: `RIVALS` em `race_state.gd` (velocidade, reação, `miss` gravado em `fruit.rival_skip` no `reset()`, chance de distração a cada `DISTRACTION_EVERY`). Modo tranquilo: `rival_id == "none"` (`solo`), `_assist()`; `race.gd` oculta o rival e usa um caminho próprio em `_resolve_motion`. Comandos da ponte: `select:<dino>:<pista>:<rival>` e `color:<id>`; a seleção e a cor ficam em metadados da árvore (`race_selection`, `race_color`). Cores via `_tint()` e `dino_tint.gdshader`.
- `prototypes/rewards.mjs`: adesivos, cores, mensagem de prêmio e persistência validada.
- `prototypes/index.html`, `game.js`, `game.css`: seleção, controles, HUD e mensagens. A ponte valida origem/janela e usa `textContent` para textos.
- `prototypes/audio.mjs`: áudio existente, `ParkAudio`.
- `runner_model.gd`: instancia os três GLBs. A distância por ciclo dos bípedes é 0,80; a do tricerátopo é `0.52 / 0.6`. Animação e sons acompanham essas distâncias.
- `scripts/rig_triceratops.py` e `scripts/rig_bipeds.py`: reconstrução offline dos rigs. Originais, prompts e parâmetros em `art/fal/`. Importação dos bípedes em 80 amostras/s, com otimizador do AnimationPlayer desativado para preservar os apoios.

A câmera mantém limites de giro de 50 graus/s e aceleração de 80 graus/s². Esses valores resultam de um pedido anterior do usuário por mais conforto.

## Execução, testes e exportação

`npm run dev` serve `http://127.0.0.1:4173/`. Conferir se já existe servidor nessa porta. Jogar usa a exportação em `prototypes/godot/`, sem instalar Godot.

Ajuste 0.17.1: `recovery_test.gd` passou com o novo limite de quatro unidades, nos dois corredores e nas seis combinações. O próprio pack exportado também foi verificado: não gera a fruta com diferença de 3,99 e gera com exatamente 4 unidades. Exportação atualizada; a bateria completa não foi repetida nesse ajuste, e por isso a falha do `balance_test` só apareceu na 0.18.0.

Validação da 0.17.0: `npm run test:race` passou com nove scripts Godot, incluindo as seis voltas de dino/pista, recuperação dourada, novo teste de cenário, rival e colisões. `npm run test:gait` passou com dois scripts Godot e dois testes Python. `npm test` passou com 11 testes Node, incluindo os dois novos testes de áudio. `scenery_test.gd` verifica as duas pistas, terreno, geometria das poças, respingos para ambos, sons únicos, animação, pausa e reinício. Chromium/Playwright confirmou poças, pássaros e torcida na floresta em 1280×900 e na praia em 390×844, com os três sons, sem erros de console ou rolagem horizontal. Evidências em `art/scenery-validation.md`. A bateria completa do passeio não foi repetida; o passeio anterior continua em `park.tscn`.

O sandbox bloqueia `spawnSync` dos testes Node com `EPERM` e a abertura da porta HTTP. `npm test` e `npm run dev` passaram com execução autorizada fora desse bloqueio, sem alterar a ferramenta fal.ai. O teste de rival isola frutas comuns com `recovery_cooldown = INF`; cenários dourados estão em `recovery_test.gd`.

Comandos disponíveis:

```sh
npm test
npm run test:race
npm run test:gait
npm run test:godot
```

`test:godot` reúne 20 scripts Godot e dois testes Python; `npm test` tem 15 testes Node. Testes de cena física aguardam `physics_frame`; testes isolados do estado não dependem da cena.

O Godot desta sessão ficou em `/tmp/dino-tools/godot`, com `XDG_CONFIG_HOME=/tmp/dino-godot-config`, `XDG_DATA_HOME=/tmp/dino-godot-data` e `XDG_CACHE_HOME=/tmp/dino-godot-cache`. São caminhos temporários: podem desaparecer entre sessões. Para scripts npm, adicionar `/tmp/dino-tools` ao PATH se o binário ainda existir.

Sem templates Web instalados, foi usado:

```sh
godot --headless --path prototypes/godot-project --export-pack Web ../godot/index.pck
```

Reutilizar o JS/WASM Godot 4.7.2 existente. Ao exportar, sincronizar versão em `package.json`, `project.godot`, página principal, shell e página gerada; atualizar referências de cache e o tamanho real do pack em `prototypes/godot/index.html`, preservando a configuração do engine. Pack atual: **14.759.224 bytes**. Não servir a raiz do projeto, que contém `.env`; o servidor existente serve apenas `prototypes`.

## Situação dos oito itens originais

Os oito itens têm ao menos a base entregue. Não considerar as expansões opcionais como entregues.

| Item | Situação na 0.20.0 | Entregue e pendências |
| --- | --- | --- |
| 1. Dinos com personalidades | Base entregue | Tricerátopo equilibrado, T-rex mais veloz e velociraptor mais ágil, com escolha do favorito. Novos comportamentos e atributos são expansão. |
| 2. Pistas com identidade | Base entregue | Floresta e praia com traçados, terrenos e visuais próprios. Neve, atalhos e descobertas adicionais não foram implementados. |
| 3. Caminhos de frutas | Entregue | Quatro trechos com escolhas laterais equivalentes e fruta central; 20 frutas com respawn e bônus temporário. Posições sorteadas a cada corrida desde a 0.18.0. |
| 4. Recuperação visível | Entregue | Fruta dourada para ambos: aparece a partir de 5 unidades atrás, 3 à frente do destinatário, com bônus total de +2,0 por 4 segundos e brilho visível. |
| 5. Elementos divertidos | Base entregue | Quatro poças, oito pássaros e seis dinos de torcida por pista, com respingos, sons, saltos e bandeirinhas. Folhas, pontes e arcos são expansões pendentes. |
| 6. Rivais com personalidades | Entregue | Três amigos escolhidos na abertura: Dorminhoco (2,20, reação lenta, ignora ~35% das frutas e para para olhar passarinhos), Brincalhão (o equilíbrio aprovado na 0.19.0, sem mudanças) e Rapidinho (2,30, sem erros). Cada um tem cor própria. |
| 7. Recompensas por brincar | Base entregue | 8 adesivos ganhos ao completar voltas e 4 cores do dino liberadas por quantidade de adesivos (0/2/4/6), salvos no navegador (`localStorage`). Acessórios não foram feitos. |
| 8. Modo tranquilo | Entregue | Opção "Sozinho": volta sem rival nem fruta dourada, com assistência leve que puxa o dino para frutas próximas só quando a criança não está virando. |

A lista original, as evidências e o pedido posterior de randomização estão em `art/next-steps.md`. O interesse nas oito ideias não representa autorização para implementá-las todas de uma vez.

## Próxima retomada

Os oito itens originais estão entregues. Restam expansões opcionais (acessórios, neve/atalhos, folhas/pontes/arcos, novos comportamentos dos dinos) e o teste com crianças e aparelhos reais. Perguntar ao usuário o próximo passo.

## Referências e limites

Ler conforme a necessidade: `README.md`, `changelog.md`, `art/scenery-validation.md`, `art/recovery-validation.md`, `art/fruit-paths-validation.md`, `art/bipeds-validation.md`, `art/collision-validation.md`, `art/rival-validation.md`, `art/modes-validation.md` e `art/brief.md`.

Faltam avaliações com crianças e aparelhos físicos: clareza dos caminhos, conforto, dificuldade e desempenho móvel. Colisores aproximam os corpos, sem formas individuais para patas/caudas. A versão com três modelos tem download inicial maior que a anterior.

Restrições já dadas pelo usuário: simplicidade, mudanças pequenas com validação, causa demonstrada antes de corrigir defeitos, sem sudo, sem comentários desnecessários ou emojis em código/logs, e sem commit ou push sem perguntar. Não houve commit, push ou inicialização de Git nesta sessão.

Frase para retomar: **“Leia o handoff.md e vamos retomar as melhorias pendentes.”**

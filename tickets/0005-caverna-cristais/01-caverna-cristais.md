# 01: Caverna dos Cristais

**What to build:** quinta pista, Caverna dos Cristais (`cave`), de uma volta, nos modos Rival, Sozinho e Dupla. Ambiente amplo, claro e acolhedor; escolher o lado em três encontros faz cristais próximos acenderem suavemente e produzirem notas curtas. A brincadeira é opcional e usa somente os controles existentes.

**Blocked by:** None (can start immediately).

**Spec:** none (fast path). Critérios abaixo são normativos. Referência: `research/expansao-diversao-0-28/2026-11-16_decision.md`; recorte confirmado pelo usuário nesta sessão. Vocabulário em `docs/CONTEXT.md`.

- [ ] A seleção oferece Caverna dos Cristais com nome e prévia próprios; catálogo Godot e relatórios web aceitam `cave`, mantendo a rejeição de valores desconhecidos e preservando preferências/álbum salvos.
- [ ] Percurso fechado curto, com uma volta, curvas suaves, largura e controles atuais. As três espécies atuais completam Rival, Sozinho e Dupla; na Dupla a chegada continua exigindo os dois. Regras, percursos e caracterização numérica das quatro pistas anteriores permanecem iguais.
- [ ] Cenário tem paredes/arcos de pedra e cristais coloridos grandes, com teto alto/aberturas de luz e marco legível na largada/chegada. Chão, frutas e dinos permanecem visíveis em tela larga e vertical, inclusive Dupla. Geometria do cenário não bloqueia pista ou câmera; não depender de túnel fechado, escuridão ou brilho intenso para comunicar o tema.
- [ ] Três encontros separados apresentam grupos nos dois lados da pista. Passar perto de um lado causa uma resposta reconhecível de luz/cor e uma nota curta, diferente entre os lados; a ordem dos encontros permite uma pequena frase musical. Passar pelo centro pode ignorar a interação. Não há sequência obrigatória, ritmo, leitura ou botão novo.
- [ ] Gatilhos usam o movimento físico dos corredores, sem perder passagens entre frames. Cada corredor pode provocar no máximo uma resposta por encontro em cada corrida; ambos os humanos podem participar na Dupla. Luz funciona mesmo com áudio silenciado. Evitar repetição contínua e sobreposição excessiva de sons.
- [ ] A interação não altera velocidade, direção, frutas, impulso, pontuação, colocação, colisão ou condição de chegada. Cristais e rochas ficam fora da largura dirigível, sem dano, salto, queda ou susto. Não acrescentar recompensas, espécie nova ou persistência adicional.
- [ ] Respostas só são acionadas durante a corrida, não na prévia, pausa ou chegada. Pausa congela pulsos e sons; retomada continua o efeito; reinício limpa animações e libera novos gatilhos. Trocar de pista não conserva efeitos ou estado da Caverna.
- [ ] Implementação reutiliza geradores, materiais, relógio de cena e áudio/ponte existentes. Compatibility/web, sem dependências novas, geração paga, GLBs novos ou funcionalidades exclusivas de outros renderers. Desempenho/benchmark fica adiado conforme decisão do usuário.
- [ ] Teste focado cobre configuração, geometria e caminho livre, conclusão das espécies/modos, escolha de lado e centro, ambos os jogadores, passagem rápida, repetição e pausa/retomada/reinício. Testes web cobrem catálogo, relatórios/chegada da Dupla e sons curtos distintos, silêncio e pausa. Não modificar testes antigos fora do escopo; ampliar matrizes quando necessário para a quinta pista.
- [ ] `npm test` e `XDG_DATA_HOME=/tmp/dino-game-godot-data npm run test:godot` passam, preservando as 72 referências Floresta/Praia. Diagnóstico de descarte de materiais na antiga exploração, já documentado na 0.31.0, permanece fora deste recorte; não aplicar contorno nem enfraquecer testes.
- [ ] Versão 0.32.0 sincronizada em pacote, projeto e cache; exportação/PCK regenerado com Godot 4.7.2 e tamanhos anunciados corretos. README/changelog concisos e validação com evidências locais atualizados.
- [ ] Conferência no navegador da seleção, largada, interação dos dois lados, modo silencioso, pausa/retomada, reinício, chegada e troca de pista em tela larga/vertical, incluindo Dupla. Salvar capturas reais e registrar limites; não alegar teste com crianças ou aparelhos físicos.

## Integração existente

Catálogo/percurso em `game/race/race_state.gd`; terreno em `game/world/forest.gd`; integração da cena em `game/race/race.gd`; cenário e detecção de passagens em `game/race/race_scenery.gd`. Seleção em `web/index.html`/`web/game.css`; validação em `web/race-report.mjs`; áudio sintetizado em `web/audio.mjs`, por eventos `park-sound` já usados pela cena.

## Base validada

2026-11-19: versão 0.31.0, commit `3d32917`; `npm test` passou 28/28 fora do sandbox para permitir o subprocesso da CLI. `baseline_test.gd` preservou as 72 referências Floresta/Praia. Usuário autorizou commits locais desta feature, sem push.

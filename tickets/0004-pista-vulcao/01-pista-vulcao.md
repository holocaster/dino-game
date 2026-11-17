# 01: Pista de vulcão com lava

**What to build:** uma quarta pista, Vulcão, selecionável na página e jogável em Rival, Sozinho e Dupla. Cenário infantil estilizado com vulcão reconhecível, rochas vulcânicas e lava animada visível fora do caminho. Uma volta, com regras das pistas curtas existentes. Reutilizar geradores e materiais do Godot; fal.ai é opcional e não necessário ao recorte inicial.

**Blocked by:** None (can start immediately).

**Spec:** none (fast path). Os critérios abaixo são normativos. Vocabulário em `docs/CONTEXT.md`; referência de produto em `research/expansao-diversao-0-28/2026-11-16_decision.md`.

- [x] A seleção oferece Vulcão (`volcano`) com prévia e nome próprios. Catálogo Godot, validação de relatórios e fluxo web aceitam a pista nos três modos, sem afrouxar validação de valores desconhecidos.
- [x] Percurso fechado de uma volta com curvas suaves, largura e controles atuais, geração de frutas, recuperação e impulso das pistas curtas. Todas as espécies atuais podem completar Rival, Sozinho e Dupla; Dupla aguarda ambos. Sem alterar regras das três pistas anteriores.
- [x] Cenário tem um vulcão reconhecível com cratera, rochas, terreno vulcânico e lava laranja/amarela animada. Caminho, dinos e frutas têm contraste claro; lava permanece fora da área dirigível e não causa dano, queda, salto, penalidade ou interrupção da corrida. Sem erupções bruscas ou efeitos que cubram a câmera.
- [x] Animação da lava respeita pausa e reinício. Cenário funciona no renderer Compatibility/web existente, sem depender de glow, bibliotecas novas ou novos GLBs. Reutilizar materiais compartilhados e evitar efeitos caros desnecessários.
- [x] Menu, largada, pausa/retomada, reinício, chegada, troca de pista, coleta e progresso/álbum existentes continuam funcionando na nova pista. Preservar dados salvos; não adicionar novas recompensas ou sistemas de progressão neste recorte.
- [x] Um teste focado cobre configuração, geometria/segurança do caminho, conclusão nos três modos e pausa/reinício da lava; testes web demonstram aceitação de relatórios da nova pista, inclusive Dupla, e rejeição de pista inválida. Testes anteriores fora do escopo permanecem intactos, exceto matrizes/catálogos que precisam incluir a quarta pista.
- [x] `npm test` e `XDG_DATA_HOME=/tmp/dino-game-godot-data npm run test:godot` passam, incluindo as 72 referências numéricas Floresta/Praia. Registrar evidências e limites sem confundir headless com inspeção visual.
- [x] Versão 0.29.0 em pacote/projeto/cache, changelog e README concisos atualizados. Exportação web/PCK regenerada com Godot 4.7.2 e tamanhos anunciados corretos; reaproveitar JS/WASM se templates completos indisponíveis, como nas versões anteriores.
- [x] Conferência visual no navegador da seleção e de uma corrida no Vulcão em tela larga e vertical, incluindo Dupla; sem novos erros de shader/console. Preservar screenshots/evidências locais da validação. Não afirmar teste em hardware físico.

## Evidência anterior à mudança

2026-11-17: `npm test` passou 27/27; `baseline_test.gd` passou as 72 referências numéricas. Godot instalado: 4.7.2. Base da feature: branch `feature/0004-pista-vulcao`. Usuário autorizou commits locais nesta sessão; push não autorizado.

## Notas de integração

`game/race/race_state.gd` define pistas/percurso; `game/world/forest.gd` gera terreno; `game/race/race.gd` prepara ambiente e avança o cenário; `game/race/race_scenery.gd` adiciona brincadeiras/Filhote. `web/index.html` e `web/game.css` apresentam seleção; `web/race-report.mjs` contém listas explícitas de pistas para relatórios e término da Dupla. `web/rewards.mjs` usa a validação de Dupla, portanto conclusão da nova pista deve continuar premiando apenas adesivos existentes elegíveis.

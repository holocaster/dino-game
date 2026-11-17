# Vulcão — validação 0.29.0

2026-11-17. Quarta pista de uma volta, com cratera, lago e escorrimentos de lava procedural animada, terreno e rochas vulcânicas. Lava fora da área dirigível, sem dano ou alteração dos controles. O material compartilhado usa o tempo da cena, respeitando pausa e reinício, sem depender de glow ou mídia paga.

## Testes e exportação

- Novo `game/tests/volcano_test.gd`: três espécies com os três rivais, Sozinho e Dupla; percurso fechado, coleta e regras das pistas curtas; vértices de lava afastados mais de 4 m do centro do percurso; altura dos dois lados dirigíveis; pausa/retomada/reinício do material. Inclui chegada física para as três espécies nos três modos.
- Teste web novo aceita relatórios do Vulcão nos três modos, preserva recompensas existentes e rejeita pista desconhecida, voltas inválidas e Dupla incompleta. Nenhum adesivo novo ou mudança no formato salvo.
- `npm test`: 28/28, exit 0, `/tmp/dino-volcano-node-release.log`. A execução restrita reproduziu o problema de subprocesso já documentado: `scripts/fal.test.mjs` recebeu stderr vazio no comando de uso (`/tmp/dino-volcano-cli-sandbox.log`). A execução normal passou sem mudar os testes legados.
- `XDG_CONFIG_HOME=/tmp/dino-game-godot-config XDG_DATA_HOME=/tmp/dino-game-godot-data npm run test:godot`: **exit 0**, 29 scripts Godot e dois testes Python, `/tmp/dino-volcano-godot-release.log`. Inclui as 72 referências numéricas Floresta/Praia intactas, a nova chegada física nos três modos e o teste existente de obstáculos bloqueando chegada/coleta. Uma execução inicial foi interrompida por sinal 143, sem erro de teste registrado; a causa dessa interrupção não foi comprovada. Uma repetição com logs contínuos completou com exit 0 antes da correção de chegada; a execução final repete a regressão após essa correção.
- Godot 4.7.2 gerou `web/godot/index.pck`: **14.792.664 bytes**. JS/WASM existentes foram reutilizados; WASM: **39.514.754 bytes**. Exportação PCK, não regeneração completa do runtime. Log final `/tmp/dino-volcano-export.log`, sem os erros de configuração/rede da primeira tentativa restrita; configuração temporária em `/tmp`.
- Verificação do pack: versão 0.29.0, shader de lava incluído e testes/fixture visual excluídos, `/tmp/dino-volcano-pack-check.log`. Cache, versão do projeto e tamanhos reais passam nos testes web.

## Regressão de chegada física

Uma corrida Sozinho natural no navegador revelou bloqueio em progresso **0,999992950010495**, com 12 frutas e sem pausa. O teste físico reproduziu o problema com tricerátopo/Sozinho (`/tmp/dino-volcano-finish-red.log`).

Uma sonda colocou o corredor exatamente na posição final pedida: erro de posição **0 m**, comprimento **100,643226623535 m**, projeção sobre a polilinha assada **100,642517089844 m**. A projeção perdia **0,00070953369141 m** na junção do percurso, impedindo a condição de chegada, embora o movimento físico já tivesse alcançado seu destino.

`race.gd:_track_coordinates` agora conserva a coordenada final pedida somente quando o pedido alcança o comprimento total e a posição física XZ coincide com a pose final pedida. Movimento bloqueado ou posições diferentes continuam usando a projeção existente. A correção é compartilhada pelos modos e pistas, sem aumentar limiar de chegada nem atravessar obstáculos. As nove combinações espécie/modo passaram após a correção (`/tmp/dino-volcano-finish-green.log`).

## Navegador

Inspeção do pack de produção em 1280×900 e 390×844, sem fixture ou alteração de estado para as capturas. `.playwright-mcp/` guarda capturas e relatórios locais ignorados pelo Git.

- Seleção e prévia do Vulcão, início Rival e Dupla, caminho e frutas legíveis, lava/escorrimento reconhecíveis e controles de ambos visíveis na vertical. Capturas `volcano-menu-desktop.png`, `volcano-selection-portrait.png`, `volcano-final-curve-desktop.png`, `volcano-coop-desktop.png`, `volcano-coop-portrait.png`.
- Pausa, continuar e reinício pelos botões reais: relatório pausado, retomada do progresso, reinício em contagem regressiva com progresso e frutas zerados. Teclas simultâneas A e seta direita moveram os corredores para lados opostos.
- Dupla natural terminou com **16 frutas = 8 + 8**, sem vencedor. Jogador 1 chegou enquanto o jogador 2 estava em **0,97045583994** e a corrida continuou; só terminou após ambos. Painel: “O filhote recebeu 16 frutinhas e está comemorando!”. `volcano-coop-finish-portrait.png` e `volcano-browser-reports.json`.
- Troca Vulcão → Floresta → Vulcão e Sozinho preservou o álbum já salvo. Sem transbordamento horizontal na vertical e sem erros de console/shader. Evidências acima antecedem apenas a correção da projeção de chegada; cenário e controles permanecem iguais. Sozinho natural no pack corrigido terminou com **12 frutas**, progresso **1**, vencedor `player` e jogador marcado como concluído. Captura `volcano-solo-finish-final.png` e relatório `volcano-solo-final-report.json`. Nenhum erro de console no pack final (`volcano-console-final.txt`).

Imagens representativas versionadas: [Vulcão e lava na corrida](previews/volcano-desktop.png), [Dupla vertical](previews/volcano-coop-portrait.png) e [chegada Sozinho no pack corrigido](previews/volcano-solo-finish.png).

Não houve teste em aparelho físico, medição comparável de desempenho ou avaliação com crianças. Não foram usados fal.ai, novas dependências, publicação externa ou push.

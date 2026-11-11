# T-rex e velociraptor texturizados — 0.14.1

Em 2026-11-11, o usuário pediu melhorar o acabamento dos dois personagens e autorizou gerá-los pela fal.ai. As formas procedurais da 0.14.0 foram substituídas por malhas orgânicas com textura, seguindo o estilo infantil do tricerátopo.

[Quatro momentos da passada](previews/bipeds-run-poses.png) · [T-rex na floresta](../prototypes/previews/textured-trex-forest-desktop.png) · [Velociraptor na praia](../prototypes/previews/textured-raptor-beach-mobile.png).

## Arte e reprodução

| Modelo | Triângulos | Vértices | Ossos |
|---|---:|---:|---:|
| T-rex roxo | 11.404 | 7.031 | 12 |
| Velociraptor verde-água | 11.622 | 7.050 | 12 |

Gerados por `tripo3d/h3.1/text-to-3d`, com textura detalhada, sem materiais PBR adicionais. Pele, manchas, barriga clara, olhos e detalhes das patas estão nas texturas UV. As fontes GLB e JPEG 4K originais ficam preservadas; a importação do jogo limita as texturas a 2048×2048, mesma resolução do tricerátopo.

- `art/fal/trex-generation.json` e `raptor-generation.json`: prompts, parâmetros, sementes, identificadores e URLs das gerações.
- `art/fal/trex-source.glb` e `raptor-source.glb`: malhas originais, com texturas incorporadas; as prévias retornadas pela fal também estão nessa pasta.
- `scripts/rig_bipeds.py`: normaliza altura em 1,45 unidade e frente em −Z, preserva UVs/texturas e constrói os dois esqueletos e as animações. Reutiliza a trajetória suave e a solução de pernas de `rig_triceratops.py`.
- `prototypes/godot-project/assets/trex.glb` e `raptor.glb`: modelos articulados usados pelo jogo.
- `runner_model.gd`: instancia os três GLBs. O construtor procedural anterior foi removido.

Reprodução offline: `python3 scripts/rig_bipeds.py`, reimportar os assets no Godot e executar `npm run test:gait` e `npm run test:race`. Novas gerações na fal consomem créditos; jogar e reconstruir os rigs a partir dos arquivos locais não fazem chamadas à fal.

As duas primeiras solicitações foram rejeitadas pelo provedor por um limite real de 255 caracteres em `negative_prompt`, embora o catálogo informasse 1024. As solicitações corrigidas concluíram com os dois GLBs; os identificadores rejeitados e o motivo estão nos registros de geração.

## Animação e integração

Cada esqueleto articula corpo, cabeça, cauda, braços, quadris, joelhos e pés. Clips `run` de 0,8 segundo e `idle` de 3,2 segundos, em loop. As pernas alternam a meia volta; amplitude de 0,40 e apoio de 50% produzem 0,80 unidade de deslocamento por ciclo. A velocidade da animação e o áudio de passos usam essa distância, preservando a distância anterior no tricerátopo.

A calibração inicial revelou 166 vértices baixos do T-rex e 137 do velociraptor com influência do tronco. Isso esticava os pés ao levantar a perna. Os vértices das solas agora seguem exclusivamente os ossos dos pés, com mistura gradual na perna.

O ajuste de amplitude e altura do corpo limita a queda do apoio ao misturar corrida e descanso. Em 16 pontos do ciclo, a menor altura do osso do pé foi 0,05685 no T-rex e 0,05639 no velociraptor, para apoio nominal 0,07: queda inferior a 1,4 cm durante a mistura. Em corrida contínua, o teste exige apoio dentro de 2 mm e pé quase plano.

A importação mantém 80 amostras/s e desativa o otimizador apenas nos AnimationPlayers desses dois assets. O otimizador havia reduzido chaves de quadril/joelho/pé e produzido erro angular de 0,85 grau no ensaio. A configuração segue o [importador do Godot 4.7](https://github.com/godotengine/godot/blob/4.7/editor/import/3d/resource_importer_scene.cpp), que aplica `optimizer/enabled` às opções do nó de animação.

Escalas dos corpos físicos, cápsulas, regras, atributos, frutas, rival e câmera mantêm os comportamentos da 0.14.0. A alteração em `race.gd` apenas seleciona a distância da passada do modelo para animação e áudio.

## Verificação

- `npm run test:gait`: dois testes Python, animação anterior do tricerátopo e novo teste dos bípedes.
- `bipeds_test.gd`: textura real de 1K–2K, UVs, malha articulada, pesos normalizados, solas vinculadas aos pés, clips em loop, apoio, levantamento, continuidade da passada, descanso e transição em 16 pontos do ciclo.
- `npm run test:race`: estado, equilíbrio, seis combinações de personagem/pista, sincronização entre animação e deslocamento, volta completa, câmera, rival, colisões e respawn físico.
- Chromium/Playwright: T-rex na floresta e velociraptor na praia, seleção, coleta, direção por teclado, pausa, reinício com frutas/bônus zerados e visualização em 1280×900 e 390×844. Nenhum erro de console na navegação verificada.
- Prévias de quatro posições da corrida dos dois modelos renderizadas no Godot. Para as capturas da corrida pausada, a sobreposição foi ocultada temporariamente apenas durante a captura.

Exportação web 0.14.1: 14.744.612 bytes de pack, com shell, referências de cache e tamanho de download sincronizados. O primeiro pack com as texturas 4K tinha 26.072.228 bytes; a importação 2K reduziu esse tamanho e o uso de memória das texturas. Engine JavaScript/WASM existente reutilizado. Nenhuma dependência de runtime adicionada; sem commit ou push.

## Limites

Colisores continuam aproximando o volume dos corpos; caudas e patas não têm formas físicas individuais. Aparência e desempenho em aparelhos reais e com crianças permanecem pendentes. A versão tem download inicial maior que a 0.14.0 por incluir dois modelos e texturas adicionais.

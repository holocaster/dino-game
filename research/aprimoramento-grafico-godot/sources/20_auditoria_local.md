# S20 — Evidência local do projeto

- Tipo: código/configuração e inspeção de arquivos, fonte primária local.
- Autor: projeto Corrida dos dinos; inspeção em 2026-11-18.
- URL: não se aplica. Localizadores abaixo.
- Credibilidade: 5/5 para fatos inspecionados; atualidade: 5/5; viés: 1/5.

## Evidência reproduzível

- `game/project.godot:7–20`: versão do jogo 0.29.1, Compatibility, viewport 960×640, atlas de sombra direcional 2048. `godot --version`: `4.7.2.stable.official.ed1daf0bf`.
- `game/common/dino_scene.gd:18–40`: câmera perspectiva, FOV de 48/58 graus, acompanhamento e tratamento de árvores que ocultam os personagens.
- `game/race/race.gd:37–54`: fundo plano, ambiente de cor constante 0,4, luz direcional 0,6 e sombras. Não há configuração explícita de SSAO/glow/MSAA no projeto/cena inicial lidos.
- `game/world/forest.gd:95–118`, `158–183`, `224–271`, `337–430`: terreno e vegetação gerados com SurfaceTool/cores por vértice; árvores com formas primitivas mescladas; sombras desabilitadas no mesh final da árvore. Vulcão com cones/cilindros e lava por shader. A malha de terreno não recebe UVs por `set_uv` nesse construtor.
- `game/world/tree.gdshader:6–11`: descarte por pixel para transparência de copa/tronco. Substituir árvores precisa preservar a visibilidade do dino.
- `game/dinos/dino_tint.gdshader:6–9` e `game/race/race.gd:177–188`: recoloração deriva luminância do albedo e usa roughness constante. Uma futura textura de olhos/barriga/PBR não será preservada automaticamente nas cores alternativas.
- `game/dinos/runner_model.gd:3–28`: três GLBs preloaded, acessórios ligados ao osso Head e encaixes por espécie. Trocar personagem implica recalibrar rig/animações/acessórios/câmera, não só substituir arquivo.
- `game/assets/*Color*.jpg.import`: mipmaps já habilitados, limite de dimensão 2048. Gerações `art/fal/*generation.json` têm `pbr: false`.
- Leitura somente leitura dos headers/chunks JSON de GLB: tricerátopo 11.789 triângulos/1 skin/3 animações; T-rex 11.404/1/2; raptor 11.622/1/2. Cada GLB tem uma malha, um material e uma imagem. `dinosaur.glb` legado tem 7.470 triângulos e não é um dos três MODELS correntes. Essas são contagens dos arquivos, não dos objetos efetivamente desenhados nem draw calls.
- `stat` por Python: `web/godot/index.pck` 14.792.648 bytes; `index.wasm` 39.514.754; `index.js` 279.815. Soma 54.587.217 bytes = 52,06 MiB sem compressão HTTP, sem demais recursos; não é download transferido ou memória de runtime.
- `game/export_presets.cfg:13–16`: export sem threads, S3TC/BPTC habilitado e ETC2/ASTC desabilitado. Isso merece validação futura em celulares; não comprova falha atual.
- `docs/briefs/0003-portabilidade-desktop.md`: port nativo ainda futuro; menus/áudio/salvamento dependem da camada web. Não contar port completo como mero preset.

## Histórico distinto da medição atual

`art/bipeds-validation.md` registra pack de 26.072.228 bytes com texturas 4K contra 14.744.612 em 2K (redução histórica de 43,4%). Não é experimento novo nem comparação só de FPS. `art/volcano-validation.md` explicita ausência de benchmark físico. Nenhuma dessas notas prova desempenho presente.

## Inspeção visual

Foram abertas as imagens `art/previews/volcano-desktop.png`, `art/previews/release-0.28-preview-desktop.png` e `art/concepts/cartoon-park-v1.png`. São capturas históricas e um conceito estático; não são execução corrente. Nas capturas, grandes superfícies de cor, horizonte/fundo simples e repetição de formas contrastam com os personagens texturizados. Priorizar cenário/coerência é um julgamento de arte a validar, não causa de performance demonstrada.

Trecho local: “a imagem é um conceito de arte, não uma captura do jogo.” (`art/brief.md`).

## Limites

Sem execução de corrida, perfilador, benchmark em hardware, nova exportação ou testes infantis. Sem hipótese de gargalo CPU/GPU comprovada. Inspeção não autoriza modificar o jogo.

# 06 · Voxel Routes no navegador móvel

- Fonte primária de desenvolvimento, publicada em 2026-10-19 e consultada em 2026-11-26. [Devlog técnico](https://evafan1337.itch.io/voxelroutes-godot/devlog/1716367/voxel-routes-devlog-making-a-3d-voxel-tycoon-fly-in-a-phone-browser)
- Simulação 3D de logística em voxels com terreno procedural. [Jogo no navegador](https://evafan1337.itch.io/voxelroutes-godot)
- Notas de 1 a 5. Credibilidade 4, recência 5, independência 2.

> Loaded a lightweight 2D-only canvas menu first, while the 3D world generates in background slices (~5 ms per frame).

O autor usou um Infinix X6833B real com Helio G99, Android 14 e Chrome 154, com Godot 4.6.2 em Compatibility/WebGL2. Relata **35–38 s → 14–15 s** até o menu interativo e **0,39 s** para a primeira pintura HTML da versão otimizada. O cenário de demonstração com 58 caminhões saiu de uma espera superior a 3,5 min, acompanhada de travamento, para **49,2 s**. A transferência obrigatória resultante foi de **11,2 MB com Brotli**, ante 18,7 MB no cenário inicial informado.

Em uma tentativa anterior, o autor registrou que agrupar árvores e pedras reduziu as chamadas de desenho em 40% e acrescentou 6 s ao carregamento, com ganho instável durante o jogo. Isso justifica cronometrar a montagem e o desempenho em jogo ao testar agrupamento. [Devlog anterior da mesma equipe](https://evafan1337.itch.io/voxelroutes-godot/devlog/1694629/voxel-routes-017-a-week-at-war-with-the-phone-browser)

Limites. Único aparelho explicitamente identificado, com alterações simultâneas e sem protocolo de rede e cache detalhado. O cenário de demonstração é um teste de estresse de logística. A fonte serve como referência técnica de Godot Web em Android.

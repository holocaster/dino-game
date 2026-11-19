# S06 — Godot 4.7 — Optimizing 3D performance

- URL: https://docs.godotengine.org/en/4.7/tutorials/performance/optimizing_3d_performance.html
- Autor: Godot Engine contributors
- Data: Documentação 4.7; página sem data editorial exposta
- Acesso: 2026-11-18; conteúdo aberto e lido pela ferramenta web.
- Tipo: primária técnica/documentação.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5 (maior = mais viés).
- Localização: Seções Transparent objects / LOD / Instancing / Bake lighting / Animation.

> Realtime lighting, shadows (especially multiple lights), and global illumination are especially expensive.

## O que sustenta

Transparência e sobreposição exigem cuidado. LOD e visibilidade reduzem trabalho distante; instanciamento automático é exclusivo do Forward+, mas MultiMesh é alternativa manual. Luz/sombra e skinning também podem pesar. Lightmaps trocam flexibilidade por trabalho prévio.

## Limites

Não prova que o jogo atual tenha gargalo nesses pontos. Otimizar só após medir; plantas transparentes nem sempre custam menos que geometria simples.

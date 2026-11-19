# S01 — Godot 4.7 — Overview of renderers

- URL: https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html
- Autor: Godot Engine contributors
- Data: Documentação 4.7; página sem data editorial exposta
- Acesso: 2026-11-18; conteúdo aberto e lido pela ferramenta web.
- Tipo: primária técnica/documentação.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5 (maior = mais viés).
- Localização: Tabela e seções Choosing a renderer / Feature comparison.

> You are developing for web. In this case, Compatibility is the only choice.

## O que sustenta

Compatibility tem 3D, luz/sombra, probes limitados, lightmaps pré-calculados, fog de profundidade/altura, tonemapping, glow, SSAO e MSAA. Não tem VoxelGI/SDFGI/SSIL, SSR, neblina volumétrica, TAA/FSR2, Decal ou CompositorEffects. Trocar renderer pode exigir ajustes manuais de luz/materiais.

## Limites

A disponibilidade não prova custo aceitável no navegador. Não extrapolar tabela para versões antigas nem contar várias páginas Godot como organizações independentes.

# S03 — Godot 4.7 — Using Lightmap global illumination

- URL: https://docs.godotengine.org/en/4.7/tutorials/3d/global_illumination/using_lightmap_gi.html
- Autor: Godot Engine contributors
- Data: Documentação 4.7; página sem data editorial exposta
- Acesso: 2026-11-18; conteúdo aberto e lido pela ferramenta web.
- Tipo: primária técnica/documentação.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5 (maior = mais viés).
- Localização: Seções Introduction / Setting up.

> On the web platform, only rendering lightmaps that were baked on a different platform is supported.

## O que sustenta

Lightmaps são adequados a cenas estáticas, precisam de UV2 e bake prévio; não se recalculam para mudanças da cena. Podem reduzir trabalho em execução. UV2 de primitivas não vem gerado por padrão. Bake não ocorre no editor web.

## Limites

Uma pista construída em runtime precisa ser previamente materializada/congelada e preparada; não basta habilitar LightmapGI. Fonte não fornece horas de adaptação.

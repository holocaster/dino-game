# S23 — Custos de renderização e materiais

- URL: https://docs.godotengine.org/en/4.7/tutorials/performance/gpu_optimization.html
- Autor: Godot contributors; documentação 4.7; consulta: 2026-11-18.
- Tipo: documentação técnica primária.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5.

## Trecho literal

> Mobile GPUs in particular may struggle with scenes that run easily on desktop.

## O que sustenta

Drivers/API, materiais, draw calls e custo por pixel são relevantes além da contagem de polígonos. Reutilizar materiais e agrupar estáticos pode ajudar, mas agrupar excessivamente perde descarte por visibilidade. São mecanismos e orientações, não um diagnóstico do nosso jogo.

## Limites

Sem limiar universal de polígonos/draw calls; sem promessa de ganho. Esta página e outras páginas Godot pertencem à mesma origem institucional e não contam como confirmações independentes.

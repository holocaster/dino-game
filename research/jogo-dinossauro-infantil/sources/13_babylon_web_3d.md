# S13 — Babylon.js Specifications

- URL: https://www.babylonjs.com/specifications/
- Autor/editor: Babylon.js contributors.
- Tipo: primária técnica/comercial, especificação oficial.
- Consulta: 2026-11-07.
- Versão/contexto: especificação viva, sem fixar major.
- Credibilidade: alta para presença de recursos declarados.
- Recência: alta na consulta.
- Viés: alto para avaliação de qualidade; catálogo promocional.

## Evidência literal

> Transparent WebGL 1.0 / WebGL 2.0 / WebGPU support

> Complete scene graph with lights, cameras, materials, meshes, animations, audio & actions

## O que sustenta

É uma alternativa de motor 3D web com câmeras, cenas, animação, áudio, picking e colisões. A presença de WebGL além de WebGPU permite planejar uma base sem exigir WebGPU de todos os dispositivos; a escolha e o fallback precisam ser implementados/configurados, não presumidos automáticos.

## Limites

Não prova menor tamanho, melhor FPS ou menor trabalho que Godot/Unity. Editor/fluxo e programação precisam ser avaliados pela equipe. Context7: resolve `Babylon.js`, ID `/babylonjs/documentation`; a consulta sobre seleção de backend confirma que é necessário escolher/criar o motor adequado antes da cena. Não foi auditada a licença de cada componente opcional.

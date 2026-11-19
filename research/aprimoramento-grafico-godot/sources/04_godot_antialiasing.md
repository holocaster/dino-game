# S04 — Godot 4.7 — 3D antialiasing

- URL: https://docs.godotengine.org/en/4.7/tutorials/3d/3d_antialiasing.html
- Autor: Godot Engine contributors
- Data: Documentação 4.7; página sem data editorial exposta
- Acesso: 2026-11-18; conteúdo aberto e lido pela ferramenta web.
- Tipo: primária técnica/documentação.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5 (maior = mais viés).
- Localização: Seção Multisample antialiasing (MSAA).

> MSAA is very effective on geometry edges (especially at higher levels). MSAA does not introduce any blurriness whatsoever.

## O que sustenta

MSAA está disponível nos três renderers; 2x/4x são pontos de partida mais moderados que 8x. Melhora bordas geométricas, sem corrigir todos os artefatos de textura/transparência/brilho. TAA e FSR2 são Forward+.

## Limites

O custo varia com aparelho e cena; nenhum percentual/FPS é garantido. A tabela de renderers prevalece para limitações de recursos auxiliares.

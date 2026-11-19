# S05 — Godot 4.7 — Environment and post-processing

- URL: https://docs.godotengine.org/en/4.7/tutorials/3d/environment_and_post_processing.html
- Autor: Godot Engine contributors
- Data: Documentação 4.7; página sem data editorial exposta
- Acesso: 2026-11-18; conteúdo aberto e lido pela ferramenta web.
- Tipo: primária técnica/documentação.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5 (maior = mais viés).
- Localização: Seções Ambient light / SSAO / Glow.

> Since Godot 4.6, a simplified version of SSAO is available in the Compatibility renderer.

## O que sustenta

Luz ambiente constante pode dar aparência plana. Céu influencia ambiente/reflexos. Compatibility tem SSAO simplificado desde 4.6 com controles limitados, e implementação própria de glow com menos parâmetros. A falta desses efeitos em versões antigas não é evidência sobre 4.7.

## Limites

Efeitos disponíveis não são automaticamente recomendados. A direção artística e legibilidade precisam orientar ajustes; sem benchmark ou comparação visual implementada.

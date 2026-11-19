# S02 — Godot 4.7 — Exporting for the Web

- URL: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html
- Autor: Godot Engine contributors
- Data: Documentação 4.7; página sem data editorial exposta
- Acesso: 2026-11-18; conteúdo aberto e lido pela ferramenta web.
- Tipo: primária técnica/documentação.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5 (maior = mais viés).
- Localização: Seções WebGL version / Mobile considerations / Thread support.

> Godot 4 can only target WebGL 2.0 (using the Compatibility rendering method).

## O que sustenta

Web requer WebAssembly/WebGL2; Forward+/Mobile não rodam na web e a documentação não oferece backend WebGPU. Exportação sem threads privilegia compatibilidade e tem contrapartida de desempenho; nativo é apresentado como mais eficiente que web móvel. Compressão de textura desktop+mobile amplia compatibilidade e pacote.

## Limites

Sem comparação medida neste jogo. Não usar o termo Mobile renderer como sinônimo de navegador em celular.

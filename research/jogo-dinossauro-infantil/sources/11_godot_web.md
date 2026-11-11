# S11 — Exporting for the Web

- URL: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- Autor/editor: Godot Engine contributors.
- Tipo: primária técnica, documentação oficial.
- Consulta: 2026-11-07.
- Versão/contexto: documentação stable sobre Godot 4; a URL stable pode mudar.
- Credibilidade: alta para requisitos e limitações do próprio motor.
- Recência: alta na consulta; sem fixar patch.
- Viés: médio; descreve vantagens e restrições do próprio projeto.

## Evidência literal

> Projects written in C# using Godot 4 currently cannot be exported to the web.

> Godot 4 can only target WebGL 2.0

## O que sustenta

A exportação web requer WebAssembly/WebGL2 e usa o renderer Compatibility. Forward+/Mobile não são renderers web suportados nessa documentação. Exportação em uma thread existe desde 4.3 e é o padrão preferido; evita exigências de isolamento de origem da opção com threads. Há ressalvas para Safari e execução móvel, portanto um projeto GDScript pequeno continua candidato, mas precisa de validação em hardware real.

## Limites

Não generalizar a impossibilidade de C# web para todas as futuras versões. Não confundir suporte web com paridade de desempenho nativo. Não medi download, memória, FPS ou carga de cena. Context7: resolve `Godot Engine`, ID `/godotengine/godot-docs`, consulta sobre exportação web.

# Exporting for the Web — documentação Godot 4.7

- **Origem** [Godot Engine, seção sobre hospedagem](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html#serving-the-files).
- **Tipo** Documentação técnica primária, consultada em 26 de novembro de 2026.
- **Trecho** “Delivering the files with server-side compression is recommended especially for the `.pck` and `.wasm` files”.
- **Evidência** O manual diferencia o motor WebAssembly dos recursos do jogo, recomenda o MIME `application/wasm`, gzip ou Brotli conforme o servidor, e descreve o export sem threads adotado no preset da Corrida dos dinos.
- **Limite** A documentação define as fases técnicas e os requisitos de entrega. Os tempos e os bytes deste benchmark vêm da versão que cada host serviu ao Chrome.
- **Notas de 1 a 5** Credibilidade 5, recência 5, independência 4. O fornecedor mantém a documentação oficial, sem participação nas medições.

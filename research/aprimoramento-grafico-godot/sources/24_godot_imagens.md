# S24 — Importação e memória de texturas

- URL: https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_images.html
- Autor: Godot contributors; documentação 4.7; consulta: 2026-11-18.
- Tipo: documentação técnica primária.
- Credibilidade: 5/5; atualidade: 5/5; viés: 1/5.

## Trecho literal

> Images are one of the largest assets in a game. To handle them efficiently, they need to be compressed.

## O que sustenta

Importação 3D pode usar compressão de VRAM e mipmaps; estes reduzem cintilação à distância e acrescentam aproximadamente um terço de memória. O arquivo JPEG no disco e a textura usada pela GPU representam custos diferentes.

## Cálculo próprio, não benchmark

Uma imagem quadrada RGBA8 descomprimida de 2048² ocupa 16 MiB no nível base; 4096² ocupa 64 MiB. Com cadeia completa de mipmaps, aproximadamente 21,33 e 85,33 MiB. O fator quatro vale mantendo canais, formato e mipmaps. Compressão, canais empacotados, resolução efetivamente importada e suporte do aparelho mudam o custo real; não somar esses números como VRAM medida no jogo.

## Limites

Não prova que 2K é suficiente para qualquer enquadramento nem que 4K é sempre desperdício. Essa escolha depende do tamanho visível na tela e do acabamento da imagem.

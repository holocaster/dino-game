# Visibilidade das árvores — versão 0.8.0

Implementada em 2026-11-10. [Lago](previews/trees-lake.png) · [Bosque](previews/trees-grove.png) · [Bosque em tela vertical](previews/trees-mobile.png) · [Alimentação em tela vertical](previews/trees-feeding-mobile.png).

## Mudança

A versão anterior alternava imediatamente a visibilidade da árvore inteira. Agora a opacidade muda em aproximadamente 0,29 segundo, tanto para ocultar quanto para reaparecer. Mudar de direção durante a transição reverte o movimento a partir do estado atual.

Copas e troncos têm controles independentes. A copa usa a margem ampla necessária para liberar o enquadramento; o tronco só acompanha a ocultação quando está na frente dos personagens ou próximo demais da câmera. Durante a alimentação, o raio protegido inclui os dois dinossauros. Início e reinício aplicam imediatamente o estado da nova posição, sem exibir árvores indevidas durante a reposição da câmera.

Cada árvore continua em uma única malha. O canal alfa das cores dos vértices identifica copa e tronco, e `tree.gdshader` controla a cobertura por pixels com um padrão estável. O material mantém profundidade opaca, evitando ordenar as esferas das copas como superfícies misturadas. Há granulação breve durante a transição; os extremos são totalmente visível e totalmente oculto. Não há assets ou dependências adicionais.

O material usa descarte explícito de pixels: o primeiro ensaio com ALPHA_HASH_SCALE não ocultou a copa no renderizador Compatibility. O código desse renderizador não implementa o processamento de alpha hash, e a conferência visual detectou a diferença entre os parâmetros e a imagem. O teste de pixels foi adicionado para verificar o resultado renderizado.

Fontes: `forest.gd:tree()` e `reveal_character()`, `park.gd:_update_camera()` e `tree.gdshader`. [Referência dos shaders espaciais](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/spatial_shader.html) · [Renderizador Compatibility do Godot 4.7](https://github.com/godotengine/godot/blob/4.7/drivers/gles3/shaders/scene.glsl).

## Verificação

- `npm run test:godot`: seis scripts aprovados após o ajuste final.
- Floresta: opacidade intermediária, reversão antes do fim da transição, copa oculta com tronco visível, ocultação integral quando necessária, retorno à opacidade total e câmera/alvo coincidentes sem divisão por zero.
- Alimentação: o novo teste primeiro reproduziu o tronco encobrindo o par; passou após ampliar o raio protegido pela câmera. Repetição, interrupção e reinício continuam aprovados.
- Teste renderizado com OpenGL Compatibility: cobertura total, copa com zero pixels visíveis mantendo o tronco, cerca de 50% de cobertura no ponto intermediário e controle independente do tronco.
- Chromium, 1100 × 820: flores junto ao lago, pegadas no bosque, retorno e alimentação, celebração e reinício.
- Contexto Chromium com toque emulado, 390 × 844: início e visita ao bosque; após o ajuste final, alimentação completa com ambos os personagens visíveis e reinício sem descobertas marcadas. Capturas inspecionadas, sem transbordamento horizontal.
- Pack web final: 6.055.424 bytes, exportado com Godot 4.7.2, identificação 0.8.0.

O teste de pixels precisa de renderização com GPU ou software gráfico; não deve ser executado com `--headless`:

```sh
godot --path game --rendering-method gl_compatibility --audio-driver Dummy --script res://tests/tree_render_test.gd
```

## Desempenho e limites

Amostras nativas de dois segundos por área, em 1100 × 720, OpenGL Compatibility, Intel UHD 630: clareira 56 FPS / 244 chamadas de desenho; lago 60 FPS / 191 chamadas; bosque 60 FPS / 79 chamadas. São amostras curtas, incluindo aquecimento, e não garantem a fluidez em celulares. A ampliação posterior do raio durante a alimentação não muda as amostras das três áreas em exploração individual.

O navegador automatizado usa SwiftShader por software. Ainda faltam medições prolongadas no navegador com GPU, teste físico de celular e escuta do áudio em alto-falantes e fones reais. A transição por pixels pode ficar mais perceptível em telas de baixa resolução; a duração e o padrão continuam sujeitos à avaliação visual do usuário.

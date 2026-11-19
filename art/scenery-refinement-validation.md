# Acabamento das quatro pistas — 0.31.0

Revisão em 2026-11-19, seguindo a [direção cartoon aprovada](brief.md). Desempenho e testes em aparelhos físicos foram adiados pelo usuário; esta entrega verifica imagem e comportamento.

| Ambiente | Acabamento | Capturas |
| --- | --- | --- |
| Floresta | Troncos curvos com galhos, copas largas/estreitas recortadas, rochas facetadas com musgo, lago com margem e juncos | [Corrida](previews/scenery-forest-desktop.png), [vertical](previews/scenery-forest-mobile.png), [lago](previews/scenery-pond.png) |
| Praia | Palmeiras com folhas arqueadas, areia com variação suave, vegetação costeira, rochas e ilhas, mar com ondas e faixa de espuma | [Corrida](previews/scenery-beach-desktop.png), [vertical](previews/scenery-beach-mobile.png) |
| Vale | Prado com terra e grama, flores e arbustos nas bordas, árvores de silhuetas variadas e colinas distantes | [Corrida](previews/scenery-valley-desktop.png), [vertical](previews/scenery-valley-mobile.png) |
| Vulcão | Terreno de cinza e caminho de terra, rochas irregulares escuras e agrupamentos nas margens; lava existente preservada | [Corrida](previews/scenery-volcano-desktop.png), [vertical](previews/scenery-volcano-mobile.png) |

## Implementação

- `scenery_meshes.gd` constrói as árvores e as rochas. Cada árvore continua numa malha, com máscaras distintas para copa e tronco no canal alfa das cores, preservando a transição que libera a visão dos dinos. Rochas variam com a posição; a Floresta e o Vale recebem musgo.
- `forest.gd` reutiliza o material de chão nas quatro pistas e distribui a decoração fora da largura dirigível. Traçado, limites, alturas e colisores existentes permanecem iguais. A antiga cena de exploração também recebe a nova geometria, lago e margens.
- `water.gdshader` usa cores e ondas procedurais, sem imagens externas, transparência ou leitura da tela. Lago e mar recebem gradiente de margem rasa e espuma. `forest.animate()` recebe o relógio da cena e atualiza água/lava; corrida pausada congela o relógio e o reinício o zera.
- `race.gd` ajusta céu e luz ambiente por pista. Modelos dos dinos, acessórios, controles, coleta, impulsos, voltas e modos não foram alterados. As poças da corrida mantêm sua geometria e seus respingos.

## Verificação

- `npm test`: 28 testes aprovados. O teste que executa a CLI como subprocesso precisou rodar fora do sandbox; nenhum teste da fal foi alterado e nenhuma geração foi solicitada.
- `test:godot`: 31 scripts GDScript e 2 testes Python aprovados, incluindo caracterização numérica de 72 corridas Floresta/Praia, as três voltas do Vale/Vulcão, colisões, cooperação, câmera, navegação, efeitos e animações.
- Os oito scripts da antiga exploração emitem `Parameter "material" is null` ao liberar a cena no renderer sem gráficos. A reprodução mínima instancia/libera `park.tscn`; duplicar apenas a malha do companheiro numa cópia temporária elimina o diagnóstico, sem alterar testes ou regras. O comportamento é compatível com o [bug confirmado de descarte de materiais compartilhados da Godot](https://github.com/godotengine/godot/issues/85817), também relatado na 4.7.1. Nenhum contorno foi aplicado ao código de produção. As asserções passam e o diagnóstico não apareceu nas corridas renderizadas ou no navegador.
- `world_detail_test.gd`: volume da decoração fora das quatro pistas, máscaras e raio das copas, água contida no lago e pausa/retomada/reinício da animação. Integrado a `test:race`.
- `water_render_test.gd`, com OpenGL Compatibility: relógio parado produz pixels idênticos; avançá-lo altera ondas e espuma. `tree_render_test.gd`: cobertura opaca, ocultação da copa, cobertura intermediária e tronco independente aprovados.
- Chromium/WebGL2, exportação 0.31.0: escolha, início, pausa, retomada e volta ao menu nas quatro pistas, em 390 × 844, sem rolagem horizontal ou erros no console. Prévias em 1280 × 900 também inspecionadas.
- As nove capturas acima usam a cena real com dupla Tricerátopo/Velociraptor parada em 23% de uma volta, em 1114 × 660 e 364 × 674. A foto do lago usa uma câmera de inspeção. O script `scenery_visual.gd` reproduz as capturas; elas foram renderizadas com Mesa/llvmpipe e não constituem benchmark.

Para reproduzir as capturas com renderização disponível:

```sh
godot --path game --rendering-method gl_compatibility --audio-driver Dummy --script res://tests/scenery_visual.gd
```

Referências consultadas via Context7: [SurfaceTool](https://docs.godotengine.org/en/4.7/classes/class_surfacetool.html), [Quaternion](https://docs.godotengine.org/en/4.7/classes/class_quaternion.html) e [shaders espaciais](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/spatial_shader.html).

PCK exportado com Godot 4.7.2: **14.804.240 bytes**, 7.076 bytes a mais que a 0.30.0. JS/WASM existentes reutilizados; tamanho anunciado e cache sincronizados em 0.31.0.

Sem medição de FPS, carregamento ou custo de GPU, conforme solicitado. Sem assets pagos ou dependências novas.

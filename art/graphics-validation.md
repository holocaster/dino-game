# Acabamento gráfico — 0.33.0

Entrega local em 2026-11-23, seguindo a [referência cartoon aprovada](brief.md). Sem geração de mídia, novos modelos, dependências ou mudança do renderer Compatibility. Modelos, animações, regras e percursos existentes foram preservados.

## Comparação

Floresta: [antes](previews/graphics-before-forest-desktop.png) · [depois](previews/graphics-forest-desktop.png). Tela vertical: [antes](previews/graphics-before-forest-mobile.png) · [depois](previews/graphics-forest-mobile.png). Lago: [antes](previews/graphics-before-pond.png) · [depois](previews/graphics-pond.png).

As comparações usam a cena real, os mesmos corredores Tricerátopo/Velociraptor, posições em 23% da volta, câmera, dimensões e sorteio de frutas (`81173`). A água usa o relógio em 1,5 s. O antes foi renderizado de uma cópia temporária dos arquivos de `9493631`; o depois usa os arquivos desta entrega. Não são imagens conceituais.

| Pista | Paisagem, 1114 × 660 | Vertical, 364 × 674 |
| --- | --- | --- |
| Floresta | [Captura](previews/graphics-forest-desktop.png) | [Captura](previews/graphics-forest-mobile.png) |
| Praia | [Captura](previews/graphics-beach-desktop.png) | [Captura](previews/graphics-beach-mobile.png) |
| Vale | [Captura](previews/graphics-valley-desktop.png) | [Captura](previews/graphics-valley-mobile.png) |
| Vulcão | [Captura](previews/graphics-volcano-desktop.png) | [Captura](previews/graphics-volcano-mobile.png) |
| Caverna | [Captura](previews/graphics-cave-desktop.png) | [Captura](previews/graphics-cave-mobile.png) |

## Mudanças

- MSAA 2× suaviza contornos. Luz principal mais forte e ambiente equilibrado dão mais volume; sombras têm menor opacidade, suavização e alcance de 28 m, mantendo mapa de 2048 px e duas divisões.
- Copas têm volumes menores sobrepostos, alturas, rotações e cores variadas. Normais acompanham a geometria deformada, com grupos separados para copa, laterais e tampas dos galhos. A máscara que oculta copa/tronco continua independente. Material usa iluminação difusa envolvente e luz traseira nas folhas.
- Folhas baixas da Floresta têm quatro segmentos curvos e gradiente de cor, em uma única malha. Candidatos de plantio passam de 1200 para 600 para limitar a geometria; todos os vértices da vegetação na corrida ficam fora da faixa dirigível.
- Chão ganha granulação e relevo apenas no sombreamento, sem deslocar terreno ou colisão. Água ganha brilhos e linhas suaves nas margens rasas, com efeito mais discreto no mar e o mesmo relógio de pausa/reinício.

## Verificação

- `npm test`: 31 testes aprovados, incluindo versão/cache e tamanhos reais do PCK/WASM. O teste existente da CLI precisou executar fora do sandbox para permitir subprocessos; não houve solicitação de geração paga.
- `graphics_test.gd`: normais das copas/palmeiras, malha única com tamanho limitado e todos os vértices das folhas fora da pista. Integrado a `test:race`.
- Testes renderizados `tree_render_test.gd` e `water_render_test.gd` aprovados: cobertura opaca, ocultação independente, transição parcial da copa e imagens idênticas com relógio congelado; avanço do relógio altera a água.
- Os 33 scripts da suíte Godot e os dois testes Python passaram, somando a rodada inicial e as execuções restantes. As 72 referências numéricas de Floresta/Praia foram preservadas. A chamada longa terminou com SIGTERM (143) após `world_detail_test.gd`, sem falha de asserção no log; `scenery_test.gd` e os testes seguintes de brincadeiras, efeitos, modos, rival, colisões e animações passaram separadamente, sem alterar os testes existentes.
- Chromium/WebGL 2: as cinco pistas selecionadas e iniciadas em Dupla em 1280 × 900; pausa/retomada conferidas na Floresta, Praia e Vale. Vulcão e Caverna também conferidos em 390 × 844, sem rolagem horizontal. Nenhum erro no console; quatro avisos do driver sobre leitura de pixels na renderização por software.
- Capturas do navegador: [Floresta](previews/graphics-browser-forest-desktop.png), [Praia](previews/graphics-browser-beach-desktop.png), [Vale](previews/graphics-browser-valley-desktop.png), [Vulcão](previews/graphics-browser-volcano-desktop.png), [Vulcão vertical](previews/graphics-browser-volcano-mobile.png), [Caverna](previews/graphics-browser-cave-desktop.png), [Caverna vertical](previews/graphics-browser-cave-mobile.png).
- PCK regenerado com Godot 4.7.2: **14.811.760 bytes**, aumento de **1.952 bytes**. JS/WASM 4.7.2 existentes reutilizados; versão/cache 0.33.0 e tamanho anunciado sincronizados.

Para reproduzir as capturas nativas em um diretório existente:

```sh
godot --path game --rendering-method gl_compatibility --audio-driver Dummy --script res://tests/scenery_visual.gd -- /tmp/dino-graphics-after
```

## Limites

Capturas nativas usam Mesa/llvmpipe; navegador usa renderização por software. Não houve benchmark de FPS, carregamento ou GPU real, nem teste em aparelhos físicos. MSAA e materiais mais detalhados podem aumentar o custo de renderização, mesmo sem crescimento relevante do download. O conceito aprovado continua como direção artística, sem promessa de reproduzir sua qualidade de renderização.

Os oito testes da antiga exploração mantêm o diagnóstico preexistente `Parameter "material" is null` ao liberar a cena no renderer sem gráficos, já descrito na [0.31.0](scenery-refinement-validation.md). As asserções passaram; nenhum contorno foi aplicado. Execução direta autorizada, sem revisão independente. Commit e push autorizados pelo usuário após a validação.

Documentação consultada: [MSAA e seus limites](https://docs.godotengine.org/en/4.7/tutorials/3d/3d_antialiasing.html), [suavização de sombras](https://docs.godotengine.org/en/4.7/classes/class_light3d.html#class-light3d-property-shadow-blur) e [diferenças entre renderers](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html).

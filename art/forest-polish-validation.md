# Cenário da Floresta — 0.30.0

Primeiro polimento em 2026-11-19, seguindo a [direção cartoon aprovada](brief.md) e o recorte da [pesquisa gráfica](../research/aprimoramento-grafico-godot/2026-11-18_decision.md).

[Antes](previews/forest-polish-before.png) · [Depois](previews/forest-polish-after.png) · [Durante a corrida](previews/forest-polish-race-desktop.png) · [Tela vertical](previews/forest-polish-race-mobile.png).

## Mudança

Material procedural de chão com variação de cor em duas escalas e transição irregular entre terra e grama. Distância à trilha é armazenada nas coordenadas UV; a malha e a altura do terreno permanecem iguais. O material não usa imagens externas, tempo ou animação.

Arbustos, pequenas flores e pedras acompanham os dois lados da trilha, agrupados em um único MultiMesh com cores por instância e posições determinísticas. A decoração não acrescenta colisores e deixa a largura inteira da pista livre. Folhagens existentes recebem tons e comprimentos variados.

Copas variam em proporção, altura e orientação; árvores da Floresta passam a projetar sombras. A transição independente de copa/tronco continua usando o shader existente. Colinas de cores suaves completam o horizonte. A corrida na Floresta recebe céu azulado e mais luz ambiente; as outras pistas preservam sua iluminação e geometria.

O gerador também atende à antiga cena de exploração: ela recebe o acabamento do chão, árvores e bordas, com sua largura de trilha original. Nenhuma regra, modelo de dino, relevo, navegação ou colisão foi alterada.

## Validação

- `npm test`: 28 testes aprovados, incluindo versão/cache e tamanhos dos arquivos exportados.
- Cobertura de `test:godot` concluída em partes: 30 scripts GDScript e 2 testes Python aprovados. A execução contínua foi encerrada com SIGTERM durante `variety_test.gd`, sem falha de teste registrada; esse script e os restantes foram executados separadamente. Inclui as 72 corridas de caracterização Floresta/Praia, colisões, cooperação, câmera, cenários e animações.
- `forest_scenery_test.gd`: nova vegetação mantém seu volume fora da pista e do lago, não cria colisores, tem contagem limitada e não aparece nas outras três pistas. O teste também verifica altura e distância à trilha no terreno. Integrado a `test:race`.
- Testes existentes da Floresta e do cenário aprovados; transparência, navegação, poças, sons, torcida, pausa e reinício preservados.
- Chromium/WebGL2 Compatibility: material renderizado sem erros no console; prévia, corrida e enquadramento vertical inspecionados. Janela de 1280 × 900 e de 390 × 844, sem rolagem horizontal no celular emulado.
- O antes/depois usa a mesma prévia e um canvas de 1114 × 660, com o menu ocultado e a altura ampliada apenas para registrar o cenário. As capturas da corrida foram feitas em pausa, ocultando apenas o painel para enxergar o resultado.

PCK exportado com Godot 4.7.2: **14.797.164 bytes**, 4.516 bytes a mais que a versão 0.29.1. JS/WASM existentes reutilizados; versões de cache e tamanho anunciado sincronizados em 0.30.0.

Referência técnica consultada via Context7: [varyings e linguagem de shaders Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/shading_language.html).

Sem benchmark comparativo de GPU, teste em celular físico ou com crianças. Sombras de árvores e o novo material acrescentam trabalho de renderização; emulação de tela não comprova desempenho em aparelhos reais. Sem geração paga ou novas dependências.

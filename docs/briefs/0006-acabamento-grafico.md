# Acabamento gráfico — 0.33.0

Pedido: melhorar os gráficos do jogo. Base: 0.32.0, `9493631`. Em 2026-11-23 o usuário autorizou seguir diretamente, sem commits, com o acabamento cartoon proposto. Implementação e evidências em `art/graphics-validation.md`.

## Referência e diagnóstico

Manter o cartoon 3D de `art/brief.md`, usando `art/concepts/cartoon-park-v1.png` como referência de formas orgânicas, luz suave e contraste entre dinos e vegetação. O conceito não representa uma promessa de fidelidade de renderização no navegador.

As capturas `art/previews/scenery-forest-desktop.png` e `art/previews/cave-browser-crystals-desktop.png` mostram sombras com degraus visíveis, copas arredondadas repetidas, vegetação angular e grandes superfícies com pouca diferenciação de material. A base também foi executada nesta sessão, a partir de cópia temporária dos arquivos de `9493631`, com o mesmo sorteio das capturas finais.

## Recorte autorizado

1. Iluminação e imagem: avaliar suavização de contornos e filtragem de sombras disponíveis no Compatibility; equilibrar luz ambiente e luz principal para preservar volume e cores dos dinos. Comparar capturas iguais antes/depois antes de escolher os ajustes.
2. Vegetação: variar silhuetas e agrupamentos das copas, dar curvatura às folhas próximas e melhorar a transição entre terra, grama e rochas. Reutilizar os geradores existentes.
3. Materiais por ambiente: acabamento de terra/areia/cinza/pedra e água, mantendo a identidade das cinco pistas e a Caverna clara. Dinos recebem a iluminação revisada; reconstrução de modelos e animações fica fora deste recorte.
4. Validar primeiro na Floresta, depois conferir Praia, Vale, Vulcão e Caverna em paisagem e vertical, incluindo Dupla. Exportar o resultado para o navegador e atualizar versão/cache/changelog na entrega.

## Integração e limites

Pontos principais: `game/project.godot`, iluminação em `game/race/race.gd`, geradores em `game/world/scenery_meshes.gd` e `game/world/forest.gd`, shaders existentes, capturas em `game/tests/scenery_visual.gd` e `game/tests/cave_visual.gd`, exportação em `web/godot/` e referências de versão/cache na página.

Preservar percursos, colisores, controles, câmera funcional, frutas, regras, modos, acessórios e progresso salvo. Sem dependências, assets pagos ou mudança de renderer. Não usar efeitos incompatíveis com a exportação web. Evitar aumento indiscriminado de geometria e resolução de sombras; qualidade adicional pode aumentar o custo de GPU. O adiamento anterior de benchmarks permanece até nova decisão do usuário.

## Verificação

- Capturas reais antes/depois com mesmos corredores, posições, câmera e tamanho de tela; conferir leitura da pista, frutas e dinos, sombras e ocultação das copas.
- Teste focado das novas propriedades ou geometria não trivial; testes existentes de cenário, água, árvores, câmera, colisões e caracterização das corridas.
- Testes web e Godot, exportação regenerada e inspeção no navegador sem erros em tela larga e vertical.
- Registrar limites de hardware e medição; renderização por software não serve como benchmark de GPU real.

## Execução

- Direção cartoon mantida a partir da referência já aprovada e da autorização para seguir com a proposta desta sessão.
- Execução direta autorizada pelo usuário, fora do fluxo SDD e sem commits. Não houve delegação nem revisão independente nesta entrega.
- Após a validação, o usuário autorizou commit e push da entrega.
- Medições em hardware real continuam adiadas; registrar a limitação na validação.

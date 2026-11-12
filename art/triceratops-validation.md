# Tricerátopo — validação da etapa 2

Atualização em 0.11.1: caminhada suavizada e nova animação de corrida. [Comparação, causas e validação das passadas](gait-validation.md). Os valores abaixo registram a entrega original.

Implementado na versão 0.3.0 em 2026-11-10. O personagem principal segue o conceito cartoon aprovado; cenário, câmera e amigo continuam na versão anterior.

## Arquivos

- [Quatro ângulos no Godot](previews/triceratops-angles.png).
- [Caminhada](previews/triceratops-walk.gif) e [descanso](previews/triceratops-idle.gif), renderizados no Godot 4.7.2.
- [GLB com esqueleto](../game/assets/triceratops.glb), 11.789 triângulos, 7.105 vértices, 16 ossos, 1.341.680 bytes.
- [Referência em pose neutra](concepts/triceratops-bind-pose.png) e [prompt do ImageGen](concepts/triceratops-bind-pose-prompt.md).
- [Malha original](fal/triceratops-source.glb) e [parâmetros da geração](fal/triceratops-generation.json).
- [Captura desktop](previews/triceratops-game-desktop.png) e [celular emulado](previews/triceratops-game-mobile.png).

## Reprodução

`python3 scripts/rig_triceratops.py` recria o GLB a partir da malha original, usando apenas a biblioteca padrão do Python. É um rig calibrado para este modelo: quadris, joelhos e pés nas quatro patas, mais corpo, cabeça e cauda. A orientação é normalizada para frente em −Z e altura de 1,45 unidade.

Reimporte no Godot e execute `npm run test:godot`. A importação do personagem usa 80 quadros por segundo, preservando a amostragem da caminhada; a frequência padrão de 30 alterava a trajetória perto da troca de apoio. As animações são `walk` (0,8 s) e `idle` (3,2 s), ambas em loop.

A caminhada usa cinemática inversa durante a criação do asset, com apoio em 65% do ciclo, passada de 0,44 unidade e levantamento de até 0,12. No jogo, a velocidade da animação acompanha a distância realmente percorrida por quadro, inclusive quando o delta de movimento é limitado. O personagem anda a 1,2 unidade/s.

## Verificações executadas

- Importação do GLB e vínculo da malha ao esqueleto, pesos normalizados e animações em loop.
- Articulação de quadris e joelhos nas quatro patas, pés quase planos e levantamento durante o avanço.
- Em piso plano e caminhada contínua, altura de apoio dentro de 2 mm e deslocamento do pé em apoio inferior a 1 mm entre as amostras verificadas, compensado pelo movimento do personagem.
- Pés imóveis no descanso; transição para descanso em 16 pontos do ciclo. A interpolação da transição permite uma diferença vertical de até 15 mm; máximo observado de aproximadamente 12,5 mm abaixo do apoio.
- Mudança caminhada/descanso, sincronização com o deslocamento e reinício no início do descanso.
- Testes Godot existentes de visitas, repetição, reinício durante interações e limites do parque.
- Nove testes Node passando.
- Chromium desktop 1280 × 900: início, três descobertas, celebração, reinício e visita por teclado após reinício; nenhum erro de console.
- Chromium 390 × 844: sem rolagem horizontal. Contexto com toque habilitado: toque direto no cenário alcançou as flores, seguido de reinício por toque.

O pacote web foi atualizado para 0.3.0: 6.038.320 bytes, além do engine Web existente. A geometria e as texturas estão locais; jogar não faz chamadas à fal.

## Limites

O contato foi validado em piso plano. Relevo, obstáculos, câmera próxima e acompanhamento pertencem à etapa 3. A malha gerada ainda pode receber acabamento artístico após avaliação visual. Não foram executados testes em aparelhos físicos, com crianças ou medições de desempenho do futuro cenário.

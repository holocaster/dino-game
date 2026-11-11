# Direção de arte do Parque dos dinos

Em 2026-11-10, o usuário pediu uma corrida amigável: largada, uma volta, chegada, avanço automático, movimento lateral livre e frutas para aumentar a velocidade. Esse pedido substitui a exploração como atividade principal, preservando o público infantil e a ausência de violência. Implementação e evidências: [corrida 0.11.0](race-validation.md).

Em 2026-11-09, após comparar a dificuldade de produção, o usuário escolheu **cartoon 3D** para a reformulação. Essa escolha substitui a direção naturalista da opção B. [Referências pesquisadas](references/dino-survival/README.md) · [Plano de execução](redesign-plan.md).

## Direção atual

Dinossauros cartoon com formas arredondadas, silhueta reconhecível, olhos expressivos e caminhada articulada. Floresta colorida com vegetação em camadas, água, rochas e terreno orgânico. Materiais simples, cores vivas e luz suave. Proposta de câmera próxima, com acompanhamento automático e sem rotação manual obrigatória.

Conceito aprovado pelo usuário em 2026-11-09: [tricerátopo jovem alaranjado na floresta](concepts/cartoon-park-v1.png), contrastando com a vegetação verde, numa clareira com trilha e lago. [Prompt e ferramenta](concepts/cartoon-park-v1-prompt.md). Aprovação: "sim, combina". Esta é a referência visual para a implementação; a imagem é um conceito de arte, não uma captura do jogo.

Permanecem Godot + GDScript, acesso pelo navegador, público de 3–5 anos e nenhuma violência. O tom da exploração continua tranquilo.

Primeira entrega proposta: um dinossauro animado, uma clareira com trilha e lago e uma interação completa. Avaliar o personagem na câmera do jogo e o desempenho desse trecho antes de expandir o cenário.

Etapa do personagem implementada em 0.3.0: tricerátopo com quatro patas articuladas, caminhada e descanso. [Prévias e validação](triceratops-validation.md). A etapa 3 foi implementada em 0.4.0: floresta, trilha curva, lago, relevo suave, rotas com obstáculos e câmera próxima seguindo o personagem. [Validação](forest-validation.md).

Na versão 0.5.0, a alimentação é uma interação completa e repetível, com transporte da fruta, mastigação e reação do amigo menor. [Validação](feeding-validation.md). A versão 0.6.0 implementa as três áreas conectadas: clareira, margem do lago e bosque, com trilha circular e descobertas distribuídas. [Validação](areas-validation.md).

## Versão anterior

O teste anterior seguia uma direção de brinquedo com cores pastel e câmera fixa distante. Seu dinossauro foi gerado pela fal.ai e integrado à versão 0.2.0: [prévia](fal/dinosaur-preview.png) e [parâmetros](fal/dinosaur-generation.json).

O modelo tem 7.470 triângulos e aproximadamente 650 KB. É estático, sem esqueleto; o jogo aplica movimento, balanço e pequenas reações ao conjunto. Árvores e restante do parque também continuam com arte provisória. Essa versão não atende à nova direção visual.

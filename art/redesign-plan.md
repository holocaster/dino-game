# Reformulação visual do Parque dos dinos

Direção confirmada pelo usuário em 2026-11-09: **cartoon 3D**. A escolha substitui a direção naturalista da referência B após a comparação de esforço de produção. [Referências pesquisadas](references/dino-survival/README.md).

## Direção

Dinossauros com formas arredondadas, olhos expressivos, silhueta reconhecível, movimentos articulados e presença no enquadramento. Floresta cartoon com vegetação em camadas, rochas, água, caminhos curvos e terreno orgânico. Materiais simples, cores vivas e iluminação suave. Modelos e cenário próprios, com detalhe ajustado ao navegador.

Godot + GDScript, navegador, crianças de 3–5 anos e exploração sem violência continuam sendo os requisitos. A proposta de câmera é próxima, com acompanhamento automático, ângulo estável e sem exigir rotação manual. O personagem deve ganhar destaque e a composição deve preencher a tela.

## Entregas em ordem

1. **Imagem do resultado pretendido.** Mostrar um dinossauro cartoon numa clareira com trilha, pedras, vegetação e margem de lago. Primeiro conceito: tricerátopo jovem alaranjado com olhos expressivos, em contraste com a vegetação verde. Usar uma câmera próxima e ângulo compatível com a exploração. Avaliar personagem e cenário juntos antes de produzir o conjunto de assets.
2. **Um dinossauro animado.** Produzir um modelo de formas simples e cores legíveis, validar a articulação das patas e animações de caminhada e descanso, e testar sua importação no Godot. Conferir silhueta de vários ângulos, contato das patas com o chão e sincronização entre passos e deslocamento. Validar esse fluxo antes de gerar outros personagens.
3. **Um trecho jogável de floresta.** Reconstruir uma área pequena com caminho curvo, lago, rochas e vegetação. Aproximar a câmera e fazê-la acompanhar o dino suavemente. Adaptar o movimento por toque ao relevo e aos obstáculos. Aproveitar a lógica de descobertas existente.
4. **Interações completas.** Integrar flores que abrem, pegadas que levam a um encontro e alimentação visível de um amigo. Adequar interface, sons suaves e controle de áudio ao ambiente. Manter atividades repetíveis, sem punição ou leitura obrigatória.
5. **Exportação e comparação.** Mostrar antes/depois na mesma resolução. Verificar carregamento da versão correta, toque, teclado, reinício e ausência de erros. Medir tempo de carregamento, tamanho do download e fluidez; ajustar modelos, texturas e vegetação conforme os resultados no navegador.

## Primeira versão para avaliação

Um dinossauro novo com caminhada e descanso, uma clareira com trilha e água, câmera próxima acompanhando o personagem e uma interação terminada. O restante do parque será expandido depois de avaliar esse trecho.

## Proposta visual aprovada

[Conceito cartoon 3D — versão 1](concepts/cartoon-park-v1.png), gerado com ImageGen integrado e aprovado pelo usuário em 2026-11-09: "sim, combina". [Prompt completo](concepts/cartoon-park-v1-prompt.md). Tricerátopo jovem alaranjado em floresta verde, com trilha, lago e enquadramento próximo. O conceito orienta personagem, cores e composição; não comprova animações nem desempenho do jogo.

Etapas 1, 2 e 3 implementadas. A versão 0.4.0 inclui o tricerátopo articulado, uma clareira de floresta, trilha curva, lago, relevo suave, navegação ao redor dos obstáculos e câmera próxima com acompanhamento. [Validação do personagem](triceratops-validation.md) · [Validação da floresta](forest-validation.md). Na versão 0.5.0, a interação de alimentação está completa: buscar, carregar, entregar e comer a fruta, com reação visível do amigo. [Validação](feeding-validation.md). A versão 0.6.0 amplia o parque com clareira, margem do lago e bosque conectados por uma trilha circular. [Prévias e validação](areas-validation.md). A versão 0.7.0 acrescenta ambiente sonoro, passos, efeitos das interações e controle de silêncio. [Validação do áudio](audio-validation.md). A versão 0.9.0 amplia para seis áreas e dois circuitos, com vale de cogumelos, prado e subida suave até um mirante com montanhas ao fundo. [Plano](forest-expansion-plan.md) · [Validação](forest-expansion-validation.md).

## Critérios de aceitação

- A nova aparência deve seguir a proposta cartoon avaliada: personagem expressivo, cores vivas, materiais simples e profundidade no cenário.
- O dinossauro deve permanecer legível no celular, com corpo e direção do movimento reconhecíveis.
- A caminhada deve articular as patas; balanço do corpo sozinho não atende à entrega.
- O cenário deve preencher o enquadramento, substituindo a apresentação de plataforma quadrada isolada.
- Câmera e controles devem permitir explorar sem controlar manualmente o ponto de vista.
- A versão web deve preservar visitas, repetição das atividades e reinício.

## Pontos a verificar

O personagem principal tem esqueleto e animações validados; o amigo agora reutiliza o mesmo modelo com descanso e mastigação. O nível de detalhe será ajustado ao desempenho medido. Testes em aparelhos físicos e com crianças continuam pendentes.

## Refinamentos acompanhados

- **Visibilidade das árvores — anotado em 2026-11-10 a pedido do usuário.** Substituir o desaparecimento e reaparecimento bruscos por uma transição suave de transparência quando a árvore encobrir o dino ou ficar muito próxima da câmera. Avaliar ocultar apenas a copa, preservando o máximo possível da árvore. Conferir legibilidade do personagem e desempenho no navegador, em tela horizontal e vertical. Implementado na versão 0.8.0, com transição de aproximadamente 0,29 segundo, copas e troncos independentes e proteção dos dois personagens na alimentação. [Validação](tree-visibility-validation.md).

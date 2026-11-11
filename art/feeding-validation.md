# Alimentação — versão 0.5.0

Implementada em 2026-11-10. [Sequência visual](previews/feeding-sequence.jpg) · [Desktop](../prototypes/previews/feeding-desktop.png) · [Celular](../prototypes/previews/feeding-mobile.png).

## Comportamento

Ao escolher Frutinhas por toque, clique ou teclado, o tricerátopo vai até a cesta. Uma fruta sai da cesta e fica visível junto ao focinho. O personagem leva a fruta até o amigo menor, entrega e espera enquanto ele mastiga. A fruta diminui em etapas e desaparece; aparecem corações de felicidade.

A descoberta e a mensagem de conclusão são emitidas apenas depois de comer. Ao terminar a reação, a fruta reaparece na cesta, permitindo repetir. Toques repetidos em Frutinhas durante a sequência não criam interações sobrepostas. Escolher outra atividade ou reiniciar cancela a sequência e restaura a fruta, sem punição.

O amigo reutiliza o tricerátopo com esqueleto, em escala menor. A mastigação usa uma animação própria da cabeça e o consumo visual da fruta; o modelo não tem mandíbula articulada. A câmera enquadra os dois personagens na entrega e na mastigação. A regra de ocultação de árvores foi corrigida para incluir copas que avançam sobre o foco, mesmo quando o centro da árvore está além dele, e preservar uma margem lateral para os dois personagens no formato vertical, além de afastar da imagem as copas muito próximas da câmera.

Fonte: `prototypes/godot-project/feeding.gd`, integração em `park.gd` e mensagens em `prototypes/game.js`. Não há novas dependências, geração paga ou áudio nesta entrega. A área do parque não foi ampliada.

## Verificações

- Quatro scripts Godot: descobertas existentes, tricerátopo, floresta e alimentação.
- Duas alimentações completas consecutivas, fruta presa ao personagem durante o transporte, redução durante a mastigação e conclusão posterior ao consumo.
- Reinício em retirada, transporte, entrega, mastigação e felicidade; fruta, corações e animação restaurados.
- Interrupção por outra atividade nas quatro fases anteriores à conclusão; sem descoberta antecipada ou reinício involuntário da sequência.
- Ocultação das árvores verificada no renderizador nativo e no WebGL. Os lotes são atualizados em bloco e desenham somente as instâncias visíveis, com margem para os personagens e para a câmera vertical.
- Chromium 1280 × 900: sequência completa e ordem dos eventos; Frutinhas ainda não estava concluída ao começar a mastigação. Teclado inicia a sequência e reiniciar durante o transporte limpa a descoberta.
- Chromium com toque habilitado em 390 × 844: alimentação completa, reinício por toque e ausência de rolagem horizontal. Captura final conferida após a correção da árvore que encobria a cena.
- Sem erros JavaScript observados; avisos de desempenho ReadPixels do renderizador por software na automação.
- Nove testes Node passaram com acesso ao servidor HTTP local usado pelas respostas simuladas. A primeira execução no sandbox falhou e foi repetida fora dele, sem alteração dos testes.

## Limites

Sem testes em aparelhos físicos ou com crianças. A automação web usa SwiftShader por software; não foi medido desempenho prolongado com GPU no navegador. O amigo mastiga com a cabeça e não abre a mandíbula. Áudio e expansão para áreas conectadas ficam para trabalhos seguintes.

# Próximas melhorias

Na sessão de 2026-11-10, foram registradas oito sugestões. Em 2026-11-11, o usuário priorizou três dinos, duas pistas e equilíbrio das frutas antes de avançar nelas. Essa base foi entregue em [0.14.0](variety-validation.md). As ideias abaixo continuam como propostas; não representam autorização para implementar todas de uma vez.

## Situação dos oito itens

Revisão em 2026-11-11, com a versão **0.20.0**. Os oito itens têm ao menos a base entregue. Base entregue corresponde ao recorte aprovado; não inclui todas as expansões sugeridas como exemplos.

| Item | Situação na 0.20.0 | Entregue e pendências |
| --- | --- | --- |
| 1. Dinos com personalidades | Base entregue | Tricerátopo equilibrado, T-rex mais veloz e velociraptor mais ágil, com escolha do favorito. Novos comportamentos e atributos são expansão. |
| 2. Pistas com identidade | Base entregue | Floresta e praia com traçados, terrenos e visuais próprios. Neve, atalhos e descobertas adicionais não foram implementados. |
| 3. Caminhos de frutas | Entregue | Quatro trechos com escolhas laterais equivalentes e fruta central; 20 frutas com respawn e bônus temporário. Posições sorteadas a cada corrida desde a 0.18.0. |
| 4. Recuperação visível | Entregue | Fruta dourada para ambos: aparece a partir de 5 unidades atrás, 3 à frente do destinatário, com bônus total de +2,0 por 4 segundos e brilho visível. |
| 5. Elementos divertidos | Base entregue | Quatro poças, oito pássaros e seis dinos de torcida por pista, com respingos, sons, saltos e bandeirinhas. Folhas, pontes e arcos são expansões pendentes. |
| 6. Rivais com personalidades | Entregue | Três amigos escolhidos na abertura: Dorminhoco (2,20, reação lenta, ignora ~35% das frutas e para para olhar passarinhos), Brincalhão (o equilíbrio aprovado na 0.19.0, sem mudanças) e Rapidinho (2,30, sem erros). Cada um tem cor própria. |
| 7. Recompensas por brincar | Base entregue | 8 adesivos ganhos ao completar voltas e 4 cores do dino liberadas por quantidade de adesivos (0/2/4/6), salvos no navegador (`localStorage`). Acessórios não foram feitos. |
| 8. Modo tranquilo | Entregue | Opção "Sozinho": volta sem rival nem fruta dourada, com assistência leve que puxa o dino para frutas próximas só quando a criança não está virando. |

Evidências: [dinos e pistas](variety-validation.md), [modelos texturizados](bipeds-validation.md), [caminhos de frutas](fruit-paths-validation.md), [recuperação](recovery-validation.md), [poças e torcida](scenery-validation.md) e [IA do rival](rival-validation.md).

## Pedido posterior — frutas em posições aleatórias

Entregue na 0.18.0: a cada nova corrida ou reinício, sorteiam-se a posição de cada trecho e a abertura lateral de cada par. A estrutura simétrica, o alcance e o espaçamento foram mantidos. Detalhes em [caminhos de frutas](fruit-paths-validation.md).

Equilíbrio revisto na 0.19.0: rival com base 2,15 e dourada a partir de cinco unidades, decididos por simulação (ver [recuperação](recovery-validation.md)). O raptor continua o mais fraco no perfil de jogo bom (73% contra 90–100% dos outros).

Antes de ampliar conteúdo, experimentar a 0.20.0 com crianças e aparelhos físicos para calibrar aparência, velocidades, duração e reaparecimento das frutas.

## Recorte para a próxima entrega

Itens 6, 7 e 8 entregues na 0.20.0 ([evidências](modes-validation.md)). Restam expansões opcionais: acessórios (7), neve/atalhos (2), folhas/pontes/arcos (5) e novos comportamentos dos dinos (1). Prioridade sugerida: testar com crianças e aparelhos reais antes de ampliar.

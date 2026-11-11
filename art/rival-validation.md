# Rival com decisões próprias — 0.12.0

Colisões físicas e coleta por áreas adicionadas em 0.13.0: [implementação e validação](collision-validation.md). As medições abaixo registram a entrega original da IA.

Implementado em 2026-11-10: o amigo deixa de alternar entre duas posições fixas e passa a escolher frutas e conduzir sua trajetória. [Prévia em tela vertical](../prototypes/previews/rival-fruit-mobile.png).

## Comportamento

A cada 0,3 segundo, ele pode escolher uma fruta disponível até cerca de três segundos à frente. Considera o tempo de chegada, a distância lateral e a chance de o jogador chegar antes. Prefere um alvo próximo que consiga alcançar, mantém a escolha enquanto ela estiver disponível e procura outro quando a fruta é coletada ou fica para trás. Quando não há alvo, mantém a linha atual em vez de voltar automaticamente a um lado fixo.

O movimento lateral tem velocidade máxima de 1,6 unidade/s e aceleração máxima de 3,2 unidades/s². Quando os corredores estão próximos ou se aproximando, o rival tenta preservar espaço ao lado do jogador. Isso é desvio amigável, não uma barreira física: o jogador ainda pode conduzir seu dino contra o amigo.

O corpo gira gradualmente na direção do movimento real, incluindo a aproximação diagonal das frutas. O ritmo das passadas usa a distância efetiva percorrida no tempo real do quadro, preservando a correção para quadros lentos da versão anterior.

A velocidade inicial continua 2,35 e cada fruta concede o mesmo aumento de 0,16 aplicado ao jogador. O algoritmo não altera o bônus nem concede aceleração por estar atrás. A decisão é local e determinística.

## Arquivos

- `prototypes/godot-project/race_state.gd`: seleção de alvo, tempo de reação, aproximação lateral com aceleração, desvio, pausa e reinício dos novos estados.
- `race.gd`: orientação do amigo e sincronização das passadas durante deslocamentos diagonais; estado publicado inclui posição lateral e velocidade do rival para conferência.
- `tests/rival_test.gd`: casos de decisão e integração com a cena.
- `package.json`: `npm run test:rival`; os testes do rival também integram `npm run test:race` e `npm run test:godot`.

## Evidências

O teste inicial colocou uma fruta a quatro unidades de distância, no lado oposto, com o jogador afastado. A lógica anterior falhou: o rival passou sem coletar uma fruta alcançável. Com a nova decisão, ele cruza a pista gradualmente, coleta uma única vez e recebe o bônus correto.

O novo script cobre frutas coletadas, passadas e inalcançáveis, troca e estabilidade de alvo, horizonte de percepção, limites de velocidade/aceleração, espaço ao lado do jogador, pausa, reinício e volta completa. Na volta com o jogador mantendo a linha inicial, o rival coletou 16 frutas. Em um ensaio separado com o jogador buscando as frutas disponíveis, o jogador venceu com 20 coletas; o rival permanece vencível pelas regras normais.

A integração verifica o corpo voltado para a direção de deslocamento, giro gradual e passadas sincronizadas tanto em quadros de 0,05 quanto de 0,4 segundo. Pausar preserva a orientação.

**Validação executada:** 12 scripts Godot, dois testes Python de animação e nove testes Node aprovados. Chromium: versão 0.12.0 carregada, largada, coleta do rival aumentando sua velocidade de 2,35 para 2,51, mudança para o lado oposto após movimentar o jogador, pausa e layout 390×844. Na amostra observada, a posição lateral do rival variou de aproximadamente −1,25 a +1,56; sua velocidade chegou a 2,99 após quatro frutas. Nenhum erro de console na navegação conferida.

Exportação web: **6.092.220 bytes**, com shell e cache sincronizados em 0.12.0. Modelos, texturas e animações existentes foram reutilizados. Sem dependências novas, commit ou push.

A dificuldade e a percepção de naturalidade ainda precisam ser avaliadas com crianças e aparelhos físicos. A validação por software no navegador não mede desempenho móvel.

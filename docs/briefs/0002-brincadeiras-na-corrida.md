# 0002 — Brincadeiras na corrida

## Goal

Entregar os cinco itens da pesquisa de diversão como uma única feature: reações engraçadas, acessórios, escolhas expressivas de caminho, encontro com filhote na chegada e cooperação local entre duas pessoas. Preservar a corrida infantil sem violência e os modos existentes.

## Confirmed scope

O usuário confirmou em 2026-11-13 as opções recomendadas da primeira rodada de descoberta e autorizou branch e commits locais da pesquisa e desta feature. Push não foi autorizado.

- Reações engraçadas provocadas ao passar por elementos da pista, sem botão adicional, interrupção do movimento ou mudança nas regras atuais de velocidade/colisão.
- Boné e óculos opcionais, além da opção sem acessório; disponíveis desde o início, com prévia no dino e escolha salva no navegador.
- Dois lados com efeitos visuais diferentes nos trechos de frutas já existentes. Preservar as oportunidades atuais de coleta e os traçados; não transformar uma escolha expressiva em rota obrigatória para vencer.
- Filhote sempre acolhedor que recebe as frutas na chegada e comemora mesmo quando o jogador não coletou nenhuma ou não venceu.
- Dois jogadores humanos cooperando no mesmo aparelho, cada um controlando um dino. Não é disputa entre os dois nem mera alternância de corridas.
- Aplicar às três pistas e aos três dinos, com as diferenças já existentes entre Floresta/Praia e Vale preservadas. Modos atuais contra rival e Sozinho continuam disponíveis.

## Existing behavior and reuse

Referência de produto: research/diversao-corrida-dinos/2026-11-13_decision.md e fontes associadas. A ordem da pesquisa é recomendação de experimentação, não ranking científico de preferências infantis. O usuário escolheu reunir os cinco itens em uma entrega.

A base já possui dois corredores com física/coleta/efeitos separados, mas apenas um humano: race_state.advance recebe uma direção, conduz o outro por IA e encerra quando o jogador principal termina. A câmera deixa de incluir o rival distante. Recompensas e contadores são centrados no jogador principal, e o adesivo de primeiro lugar não distingue cooperação. O novo modo precisa de comportamento explícito nessas fronteiras; evitar representar parceiro humano como perfil competitivo por acidente.

Modelos existentes podem sustentar acessórios e filhote, mas encaixe dos acessórios exige calibração por espécie. Reaproveitar cenário, dinos, animações e persistência já existentes. Há precedentes de dinos em escala reduzida na torcida. A implementação exata pertence ao planejamento.

## Confirmed cooperative behavior

O usuário confirmou as propostas da segunda rodada em 2026-11-16 com “pode seguir”, após a recapitulação das decisões pendentes.

1. Câmera compartilhada, ajuda para manter a dupla próxima, frutas somadas e conclusão somente quando os dois cruzarem, sem primeiro/segundo lugar.
2. Teclado e toque no mesmo aparelho: jogador 1 com A/D, jogador 2 com setas; um par de botões de toque por jogador. Controle físico e online fora desta feature.
3. Cada pessoa escolhe espécie/cor/acessório; o primeiro aguarda na chegada sem bloquear o segundo. A dupla usa o álbum local existente e pode ganhar adesivos de participação/coleta, mas não os de vitória competitiva.

## Constraints

- Implementação sequencial com verificação por incremento e revisão independente, conforme sdd-main; nenhuma implementação paralela na mesma árvore.
- Manter segurança da ponte web, soltura de controles em pausa/perda de foco/reinício e funcionamento do toque simultâneo.
- Preservar os testes anteriores fora de escopo. Novos testes precisam demonstrar comportamento, inclusive não regressão dos modos atuais e elegibilidade correta dos adesivos.
- Atualizar versão, referências de cache e changelog na entrega, conforme as convenções existentes do projeto.
- Validar encaixe visual dos acessórios nos três dinos e comportamento nas três pistas; validar navegador antes da entrega. Teste emulado não demonstra desempenho em aparelho físico nem preferência infantil.
- Sem geração paga de mídia, dependências ou serviços externos novos necessários ao recorte aprovado.

## Out of scope

- Novas pistas, novos dinos jogáveis, economia de moedas, loja ou obrigação diária.
- Mudanças nas regras de velocidade/colisão dos modos existentes.
- Publicação externa, push ou merge em main.

## Discovery status

As duas rodadas estão confirmadas. Brief estável para planejamento; ainda não há especificação, tickets ou implementação. Próximo passo: checkpoint local dos documentos e despacho ao sdd-planner.

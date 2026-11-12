# 0001 - Pista longa (Vale)

## Goal

Uma corrida que prende a atenção por 2-3 minutos: pista longa com retas, setas de impulso e velocidade que continua subindo, sem mexer em Floresta e Praia.

## Scope

- Terceira pista **Vale**, terceiro cartão em "Onde vamos brincar?", ao lado de Floresta e Praia.
- Formato de estádio com retas compridas e curvas abertas, 3 voltas de cerca de 150-180 u cada (45-60 s por volta).
- Cenário com os geradores atuais de terreno e árvores (campo aberto, árvores afastadas da pista), sem modelos GLB novos.
- **Retorno decrescente** só no Vale: cada impulso soma menos quanto mais rápido o corredor está, sem teto fixo. Quando o impulso acaba, a velocidade cai aos poucos, mais devagar que nas outras pistas. A velocidade lateral cresce junto com a de avanço.
- **Setas de impulso**: uma por reta, no lado oposto às frutinhas daquele trecho, para o jogador escolher entre seta e fruta. Dão o mesmo impulso de uma frutinha, contam para a sequência e para o nível de velocidade, valem para os dois corredores e funcionam em todas as voltas, sem recarga.
- Rival segue a mesma regra. Cada personalidade é recalibrada por simulação para manter as taxas de vitória atuais (ex.: Brincalhão ~91/51/13% contra quem joga bem/médio/fica parado). Modo Sozinho funciona.
- Fruta dourada sem mudança de regra. A distância de 5 u pode ser ajustada se ela aparecer demais. O bloqueio dos últimos 12 u vale para o fim da corrida, não de cada volta.
- Níveis de velocidade inalterados (0,3 / 0,6 / 1,0). No Vale, o nível 3 é alcançável com uma sequência longa.
- HUD web: "Volta N/3" no rodapé (só no Vale), mensagem "Última volta!" com som curto, barra de progresso cobrindo a corrida inteira. O relatório do Godot passa a incluir `lap` e `laps`.
- Recompensas: adesivo novo "Explorador do vale" ("Corra no vale"), total 9. O texto da dica de "Cesta cheia" muda para "Pegue 10 frutinhas numa corrida", e a regra continua igual.
- Câmera: nas curvas, o giro necessário nunca chega a 50°/s, nem na maior velocidade alcançável na prática.

## Out of scope

- Mudanças de regra, equilíbrio ou visual em Floresta e Praia.
- Nível de velocidade 4 ou efeitos novos de rastro.
- Banner de volta dentro do Godot.
- Bioma ou assets novos.

## Constraints

- O pack web cresce menos de 200 KB.
- Todos os testes atuais (Godot e Node) continuam passando, e o equilíbrio de Floresta e Praia continua idêntico.
- Versão SemVer e changelog a cada entrega. Todas as `?v=` iguais à versão do `package.json`.
- Validação final no navegador (Playwright) fica com o orquestrador: os agentes não têm navegador.

## Settled decisions

Q1 3 voltas de ~150-180 u · Q2 cartão "Vale" com os geradores atuais · Q3 retorno decrescente, queda lenta, lateral acompanha, câmera abaixo de 50°/s · Q4 rival com a mesma regra e as mesmas metas de vitória, Sozinho incluído · Q5 setas: uma por reta, lado oposto às frutas, contam para a sequência · Q6 dourada sem mudança · Q7 adesivo novo · Q8 mesmos 3 níveis · Q9 sem GLB, +<200 KB, sem regressão · Q10 "Cesta cheia" conta a corrida · Q11 voltas no HUD HTML · Q12 margem final da dourada sobre a corrida inteira.

## ADR proposals

- **Retorno decrescente só no Vale**: as outras pistas mantêm o teto fixo de impulso (`MAX_BOOST`). Motivo: preservar o equilíbrio já calibrado e testado de Floresta e Praia. Alternativa rejeitada: aplicar o modelo novo em todas as pistas, o que obrigaria a recalibrar tudo. Sem esse registro, alguém pode querer "unificar" as regras.

## Open questions

- Calibração (ticket 04): o nível 3 deve ser conquista de quem escolhe caminho; o bot parado não deve chegar a ele na maioria das corridas. Corrida típica dentro de 2-3 min.
- Números exatos (soma por impulso, decaimento, comprimento das retas, raio das curvas, distância de recuperação) a calibrar por simulação no planejamento ou na implementação.

## Known issues (accepted)

- Fruta dourada aparece até ~8 vezes por Corrida no Vale quando um Corredor fica muito atrás (~3,5/min contra ~2,1/min em Floresta/Praia). Aceito como mecânica de alcance; sem cooldown próprio do Vale.
- Corrida mediana de 175-197 s para quem joga médio ou fica parado, um pouco acima de 3 min; priorizado o nível 3 como conquista.

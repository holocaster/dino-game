# Recuperação dourada — 0.16.1

Item 4 implementado em 2026-11-11. [Fruta na pista, em pausa](../prototypes/previews/recovery-fruit-desktop.png) · [Impulso e brilhos](../prototypes/previews/recovery-boost-desktop.png) · [Praia em tela vertical](../prototypes/previews/recovery-mobile.png).

## Ajuste de equilíbrio — 0.16.1

O usuário relatou que a dourada ajudava pouco. A reprodução manteve o líder no bônus comum máximo e mediu a diferença durante 3,95 segundos de efeito. O teto dourado já ultrapassava o teto comum; o problema era a vantagem pequena sobre o líder.

| Dino do jogador | Velocidade dourada anterior | Velocidade dourada atual | Distância recuperada antes | Distância recuperada agora |
| --- | --- | --- | --- | --- |
| Tricerátopo | 3,20 | 4,20 | 0,83 | 4,78 |
| T-rex | 3,27 | 4,27 | 1,11 | 5,06 |
| Velociraptor | 3,13 | 4,13 | 0,55 | 4,50 |

O líder permanece a 2,99 nesse cenário. A única regra alterada é `RECOVERY_BOOST`, de +1,0 para +2,0. Duração, frutas comuns, condições de aparição e colisões mantêm seus valores. O rival recebe o mesmo bônus quando fica atrás.

O teste de ganho em `recovery_test.gd` cobre ambos os destinatários nas seis combinações e exige recuperar ao menos 4,4 unidades em 3,95 segundos contra um líder no máximo comum. Falhou com +1,0 e passou com +2,0. As verificações auxiliares também propagam falhas ao código de saída do teste.

Na cena física, a reprodução reduziu a diferença de **7,63 para 2,87 unidades**, recuperando 4,76 unidades com jogador a 4,20 e líder a 2,99. `npm run test:race` e `npm run test:gait` passaram após o ajuste. Chromium/Playwright confirmou na exportação 0.16.1 a coleta dourada com velocidade 4,20 e base 2,20, sem erros de console. [Captura do ajuste, em pausa](../prototypes/previews/recovery-balance-desktop.png).

As capturas abaixo documentam o visual original da 0.16.0; os brilhos e a geometria não foram alterados pelo ajuste.

## Ajuste de aparição — 0.17.1

A pedido do usuário, o limiar passou de seis para quatro unidades de atraso. `recovery_test.gd` passou após atualizar o teste de fronteira: sem aparição abaixo de quatro e com aparição a partir de quatro unidades. Exportação web e cache atualizados.

## Ajuste de equilíbrio — 0.19.0

O limiar passou para cinco unidades e o rival para velocidade base 2,15. Simulação com o estado real (3 dinos × 2 pistas × 30 layouts sorteados, robôs jogando bem/médio/parado): o jogador vence 91% / 51% / 11% das corridas, contra 54% / 27% / 8% com rival 2,35 e limiar 4. Com rival 2,35, nenhum limiar levava o jogador bom acima de 60%. `npm run test:godot` e `npm test` aprovados; o pack exportado confirma rival 2,15 e limiar 5.

## Regras atuais

Qualquer corredor pelo menos cinco unidades atrás pode receber a fruta dourada. Ela aparece três unidades à frente, na mesma linha lateral, e apenas seu destinatário pode coletá-la por contato físico. Há uma única especial ativa, com cinco segundos de vida e intervalo mínimo de dez segundos entre aparições. Uma fruta ultrapassada sem contato também desaparece.

A coleta concede bônus total de +2,0 sobre a velocidade base por quatro segundos. Não soma com o bônus comum: vale o maior dos dois. Frutas comuns continuam atualizando seus próprios valores e temporizadores, sem prolongar o impulso dourado. Ao terminar o efeito especial, volta a valer o bônus comum ainda ativo. A coleta do jogador também entra no placar de frutas.

Cinco pontos dourados orbitam o dino beneficiado, e o HUD identifica o impulso. Mensagens explicam para quem apareceu a fruta. O rival prioriza sua própria especial. O visual usa a geometria existente, material emissivo e pequenos pontos sem iluminação; dispensa novas gerações de arte e pós-processamento.

Não surgem frutas especiais quando o líder entra nas últimas 12 unidades. A primeira chegada elimina a fruta pendente e bloqueia novas aparições; o vencedor registrado permanece. Pausa congela fruta, intervalo, bônus e movimento do brilho. Reinício limpa os efeitos e os contatos.

## Implementação

- `race_state.gd`: regras douradas em `_advance_recovery()`, com relógios separados. `speed` e `rival_speed` expõem a velocidade efetiva; `_speed` e `_rival_speed` preservam os bônus comuns.
- `race.gd`: reutiliza `_create_fruit()` para um único `recovery_node`, separado das 20 frutas comuns. `_pickup_contact(-1, rival)` consulta os mesmos contatos físicos. O nó desativado fica invisível e com camada de colisão zero.
- `game.js`: mensagens sobre a fruta e indicação de impulso no HUD, respeitando a validação da ponte existente.
- `tests/recovery_test.gd`: regras para ambos os corredores nos seis pares dino/pista, limite de distância, posição, coleta única, duração, bônus comum independente, expiração, intervalo, chegada, pausa e reinício. Na cena física, verifica coleta de ambos, brilho e bloqueio por barreira.
- Os testes existentes distinguem o teto comum do dourado e isolam os cenários de IA de frutas comuns. As demais verificações permanecem.

## Validação original — 0.16.0

Todos os 18 scripts Godot, dois testes Python e nove testes Node passaram, conferidos por etapas. A sequência `test:godot` revelou dois cenários que precisavam acompanhar a nova regra: teto especial de velocidade e fixture de rival distante. Depois dos ajustes, os scripts afetados passaram; colisões, passadas e bípedes foram verificados em seguida.

O sandbox bloqueava a criação de subprocessos do teste Node com `EPERM`, deixando vazia a saída esperada da CLI. `npm test` passou com execução autorizada fora dessa restrição. A ferramenta de geração de arte e seus testes não foram alterados; suas chamadas pagas continuam simuladas.

Chromium/Playwright verificou a exportação real em 1280×900: aparição para o jogador, coleta, velocidade 3,2 com base 2,2, brilho e mensagens. Em 390×844, verificou seleção de velociraptor/praia, largada, pausa e retomada, sem rolagem horizontal. Sem erros de console. As capturas acima foram inspecionadas. Para registrar a fruta antes da coleta, a corrida foi pausada e o painel de pausa foi ocultado apenas durante a captura.

Exportação `prototypes/godot/index.pck`: **14.747.796 bytes**, com cache e versão 0.16.0 sincronizados. Não houve instalação de dependências, geração paga, commit ou push.

Ainda falta avaliar clareza, equilíbrio e desempenho com crianças e aparelhos físicos. A ajuda reduz a diferença; não garante vitória.

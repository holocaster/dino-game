# Carregamento de corridas Godot no navegador

Em 26 de novembro de 2026, a Corrida dos dinos em produção levou **20,31 s** até habilitar o menu. O comparável visual mais próximo, Turbo Tortoise, mostrou o botão inicial em **12,49 s**. A seleção Floresta → Vale na produção teve mediana de **3,26 s** nesse mesmo perfil. A versão pública servia o PCK da **0.34.3**. A **0.34.4** local usa outro perfil nos testes anteriores. [Build publicada](sources/04_corrida-dos-dinos.md) · [Amostras](medicoes.csv) · [Estudo local anterior](../desempenho-troca-de-pistas/technical.md)

## Primeira tela utilizável

| Jogo | Mediana | Três tempos em ordem de execução | WASM + PCK pela rede |
| --- | ---: | --- | ---: |
| [LLLL Racing](sources/03_llll-racing.md) | **8,60 s** | 9,05 / 8,60 / 8,42 s | 13,70 MB |
| [Turbo Tortoise](sources/01_turbo-tortoise.md) | **12,49 s** | 12,54 / 12,49 / 12,49 s | 25,06 MB |
| [Mud Racers](sources/02_mud-racers.md) | **14,83 s** | 14,93 / 14,83 / 14,80 s | 32,60 MB |
| [Corrida dos dinos 0.34.3](sources/04_corrida-dos-dinos.md) | **20,31 s** | 21,90 / 20,31 / 19,89 s | 27,95 MB |

Chrome 158 headless em Linux, Core i7-8750H, renderização por software SwiftShader, 960 × 600, 20 Mbit/s de download, 5 Mbit/s de upload e latência emulada de 70 ms. CPU sem desaceleração. Três contextos novos por título, cache HTTP desabilitado e service workers bloqueados. A ordem dos jogos foi alternada. O teste dos três comparáveis começou no HTML do embed publicado no itch.io. Para a Corrida dos dinos, começou na página pública, que por si carrega o iframe do motor.

O fim foi o botão inicial habilitado na página da Corrida dos dinos ou o fim do carregador do Godot, com o menu ou o botão inicial confirmados em captura de cada build. A contagem inclui navegação, transferência e inicialização até esse ponto. Os MB são decimais e somam os bytes codificados informados pela rede do Chrome para WASM e PCK, incluindo pequena sobrecarga de protocolo. Todos os pedidos medidos responderam 200 e com gzip nessa amostra. O total da página também inclui HTML, JavaScript, imagens e outros arquivos. [Amostras e URLs exatas](medicoes.csv) · [Export Web do Godot](sources/09_godot-export-web.md)

O piloto de Speedorama ficou fora da tabela. O fim do carregador padrão revelou uma tela preta com a indicação “POWER”, cujo estado interativo não foi confirmado. A terceira tentativa atingiu o limite de 35 s na navegação. Esse caso mostra como o evento de fim do carregador do motor pode anteceder o menu observado. [Speedorama](sources/10_speedorama.md)

## Troca de circuito

| Jogo e ação | Tempo observado | Marco final |
| --- | ---: | --- |
| Corrida dos dinos, Floresta → Vale | **3,26 s** de mediana, 3,21–3,29 s em três trocas | Novo `park-ready` para o Vale no menu 3D |
| Mud Racers, Horseshoe Run → Arrowhead | **0,22 s** | Primeiro quadro capturado com a nova imagem e o nome do circuito |
| Mud Racers, “Race” em Arrowhead | **0,57 s** | Primeiro quadro capturado com a pista e a contagem regressiva |

Mud Racers tem corrida com visão de cima. As duas ações foram observadas uma vez em uma gravação do Chrome. A prévia anterior ainda aparecia em 73 ms e a nova já aparecia em 223 ms. Após “Race”, o seletor ainda aparecia em 48 ms e a pista já aparecia em 565 ms. O “GO!” aparece por volta de 3,7 s após o clique. O valor de 0,57 s representa a pista visível e inclui a precisão do primeiro quadro amostrado. O fluxo demonstra que é possível atualizar a prévia antes de carregar a corrida, com um custo visual e técnico diferente da prévia 3D da Corrida dos dinos. [Mud Racers](sources/02_mud-racers.md) · [Protocolo independente de lançamento e fase](sources/08_waiting-to-play.md)

## O que os dados sustentam

1. **A abertura pública demora mais nesta amostra.** A Corrida dos dinos ficou de 5,5 a 11,7 s atrás das medianas dos três comparáveis. As faixas das doze execuções não se sobrepõem entre a Corrida dos dinos e os comparáveis.
2. **O tamanho transferido explica parte da espera.** Mud Racers transferiu cerca de 4,6 MB a mais de WASM e PCK e abriu o menu cerca de 5,5 s antes. O resultado justifica medir separadamente o fim do download, a inicialização do WASM e a construção da Floresta. O tempo ganho por cada etapa ainda precisa de um teste isolado. [Fases de carregamento](sources/07_crazygames.md) · [Caso CGT Rocket X Racer](sources/05_cgt-rocket-x.md)
3. **A comparação de troca 3D equivalente fica em aberto.** Mud Racers atualiza uma imagem em aproximadamente 0,22 s e monta a pista depois do clique para correr. É um padrão de interface observado. Os dados não estimam quanto o Vale demoraria se migrasse para esse fluxo.

Como referência publicada, CGT Rocket X Racer mediu **10,34 s até a interface** e **11,20 s até estar jogável** em uma build local do Godot 4.7.2, Chrome com SwiftShader e sem limitação de rede. Um protótipo local com abertura em etapas chegou a **5,97 s até estar jogável**. Em um Android físico, o autor de Voxel Routes informou **14–15 s até o menu** após reduzir o conteúdo inicial e adiar a construção do mundo. O CrazyGames cita **menos de 10 s** para títulos de destaque e usa o início da partida como término operacional. São marcos, jogos e ambientes separados. [CGT](sources/05_cgt-rocket-x.md) · [Voxel Routes](sources/06_voxel-routes.md) · [CrazyGames](sources/11_crazygames-basic-launch.md)

## Teste contra explicações alternativas

- **O término mede a mesma coisa?** Os marcos principais representam um controle inicial visível ou habilitado. Turbo Tortoise ainda tem etapas após START. A transferência, o primeiro quadro, o menu e o controle da corrida devem continuar em colunas separadas.
- **A hospedagem pode explicar a diferença?** Sim. Os três comparáveis principais usam hosts do itch.io. A Corrida dos dinos usa servidor próprio. O perfil de rede reproduz a limitação do cliente, e as origens continuam independentes. Comparar o mesmo PCK servindo por hosts diferentes isolaria essa parte.
- **O computador explica os tempos absolutos?** A GPU por software torna a execução repetível neste perfil e pode aumentar a espera de cenas gráficas. O estudo acadêmico observa efeitos de CPU e GPU e distingue abrir o jogo de carregar a fase. Vale repetir no telefone alvo antes de estabelecer uma meta de produção. [Estudo FDG](sources/08_waiting-to-play.md)
- **O que mudaria a decisão?** Um traço que mostre a maior parte dos 20 s na transferência priorizaria distribuição e compressão. Uma parcela grande entre o download e o menu priorizaria uma cena inicial menor e a construção das pistas fora do caminho inicial. A primeira ação é instrumentar esses marcos e medir a build atual no Moto G56. A próxima referência de desktop é aproximar a abertura dos 12–15 s observados em Turbo Tortoise e Mud Racers.

[Plano](plan.md) · [Índice de fontes](sources.csv) · [Como atualizar](refresh_targets.md)

# Spec 0002 — Brincadeiras na corrida

Brief: `docs/briefs/0002-brincadeiras-na-corrida.md`. Vocabulário: `docs/CONTEXT.md`. ADRs: `0001-retorno-decrescente-so-no-vale` e `0002-dupla-com-modo-explicito`.

## Problem Statement

A corrida oferece coleta e rivais, mas faltam brincadeiras expressivas e uma forma de duas pessoas participarem juntas no mesmo aparelho. O segundo corredor atual é um Rival: sua IA, câmera, chegada e recompensas não servem como contrato para um parceiro humano.

## Solution

Adicionar acessórios gratuitos com prévia, reações automáticas divertidas, efeitos diferentes nos lados dos trechos de frutas e um Filhote acolhedor na chegada. Acrescentar o modo **Dupla**: dois humanos controlam dinos próprios, compartilham câmera e frutas e concluem a corrida juntos. Manter Rival e Sozinho disponíveis nas três pistas.

## Requirements

- **R1 — Acessórios.** Sem acessório, boné e óculos estão disponíveis desde o início para os três dinos. A escolha é exclusivamente visual: não altera atributos, coleta, corpos físicos ou colisões.
- **R2 — Aparência.** Cada jogador escolhe espécie, cor e acessório e vê uma prévia legível no próprio dino antes de iniciar. As duas aparências ficam salvas no navegador; cores continuam sujeitas ao álbum local existente. Dados antigos, inválidos ou armazenamento indisponível recebem padrões seguros sem impedir jogar; os adesivos anteriores são preservados.
- **R3 — Reações.** Passar por elementos existentes da pista provoca pelo menos duas reações visuais distinguíveis, por exemplo um balanço brincalhão na poça e um movimento contente em um trecho de frutas. São automáticas, breves, repetíveis após reinício e não interrompem movimento, exigem botão, mudam velocidade ou alteram colisões. Funcionam com os três dinos e nos três modos.
- **R4 — Caminhos expressivos.** Os dois lados dos trechos existentes têm efeitos visuais distintos e perceptíveis ao atravessar. Não mover frutas, Setas de impulso ou traçados nem alterar quantidades, respawn, oportunidades de coleta ou vantagens atuais. No Vale, preservar a escolha já existente entre frutas e Seta. Nenhum efeito visual impõe um lado para concluir ou vencer.
- **R5 — Filhote.** Ao concluir qualquer corrida, o Filhote recebe visualmente as frutas e comemora, inclusive com zero frutas e após perder para o Rival. Na Dupla recebe o total ao concluir os dois. O encontro e o resultado ficam visíveis juntos e mantêm as ações de repetir ou escolher outra corrida. Não há nova tarefa obrigatória de alimentação nem consumo dos adesivos/frutas usados no resultado.
- **R6 — Dupla selecionável.** Dupla é uma opção própria, separada de Rival e Sozinho. Dois humanos correm simultaneamente com aparências independentes, inclusive a mesma espécie, nas três pistas. O segundo humano usa os atributos de sua espécie e não recebe personalidade, distração ou decisões de IA do Rival.
- **R7 — Teclado e toque.** Na Dupla, A/D controlam jogador 1 e setas esquerda/direita controlam jogador 2; existem dois pares identificados de botões de toque, utilizáveis ao mesmo tempo. Nos modos atuais as setas e o par atual continuam funcionando. Funciona com foco na página ou no iframe, sem processar a mesma tecla duas vezes.
- **R8 — Soltura independente.** Cada ponteiro controla somente seu botão/jogador. Soltar ou cancelar um toque não solta o outro jogador nem outro ponteiro ainda pressionado. Pausa, perda de foco/visibilidade, reinício e retorno ao menu limpam todos os controles; retomar não restaura teclas/toques antigos. Direções opostas simultâneas do mesmo jogador se anulam.
- **R9 — Câmera e ajuda.** A câmera da Dupla mantém os dois dinos inteiros visíveis em retas, curvas, trocas de lado e chegada, em tela larga e vertical. Uma ajuda exclusiva da Dupla limita a separação longitudinal reduzindo/parando suavemente o avanço de quem está à frente; não teletransporta, recua ou toma a direção lateral de ninguém. Limiares finitos e uma separação máxima verificável são calibrados e registrados, compatíveis com o enquadramento. Preservar o limite de giro de câmera existente de 50 graus/s e não aplicar a câmera que abandona o Rival distante ao parceiro.
- **R10 — Coleta compartilhada.** Manter registros de coleta/Impulso por corredor e apresentar a soma das frutas da Dupla, incluindo frutas douradas efetivamente coletadas por cada um. Uma coleta física conta uma única vez; reaparição e coleta por corredor/Volta seguem a regra atual. Frutinhas/Setas dão Impulso a quem as atravessa; Setas não contam como frutas. A Fruta dourada continua direcionada a quem ficou para trás, com os parâmetros de cada pista, sem depender de um vencedor competitivo.
- **R11 — Chegada dos dois.** O primeiro a concluir aguarda visivelmente sem bloquear o parceiro. A corrida continua até ambos concluírem; não há primeiro/segundo lugar ou vencedor. Floresta/Praia permanecem uma Volta e Vale três por pessoa. O HUD identifica jogadores, progresso e Volta de cada um, total de frutas e quem está aguardando, sem linguagem de Rival ou vitória entre a Dupla.
- **R12 — Álbum.** Somente após os dois concluírem, a Dupla pode ganhar os adesivos existentes de participação/pista e coleta, usando os totais; não pode ganhar `first-place`, `speedy` ou `calm`. Não criar adesivos ou álbum novo. Atribuição ocorre uma vez por corrida concluída; repetição de relatório não duplica recompensa. Rival e Sozinho mantêm suas elegibilidades atuais.
- **R13 — Ponte validada.** Comandos de configuração, aparência e controle validam jogador, catálogos e estado antes de alterar a corrida. Configuração de espécie/pista/modo durante corrida é rejeitada. A página mantém a verificação de origem e iframe remetente e valida modo, estrutura e números dos novos relatórios antes de renderizar ou premiar. Rejeitar payload malformado, identificador desconhecido, NaN e infinito sem alteração parcial.
- **R14 — Ciclo de vida.** Pausa congela avanço e novas reações/coletas; reinício restaura contagem, frutas, chegadas e efeitos temporários dos dois, preservando aparências. Voltar ao menu permite mudar modo sem deixar estado da Dupla em Rival/Sozinho ou vice-versa. Filhote e efeitos não acumulam instâncias a cada reinício.
- **R15 — Compatibilidade.** Preservar regras de velocidade/colisão, equilíbrio, recuperação, sequências, Setas e diferenças das três pistas nos modos atuais, conforme ADR 0001. Preservar testes anteriores fora do escopo e a caracterização numérica existente de Floresta/Praia. Alterações visuais aprovadas em R1–R5 são intencionais.
- **R16 — Entrega.** Entregar versão minor **0.28.0**, exportação web atualizada, tamanhos de pack e todas as referências `?v=` consistentes, changelog em português e README conciso. Sem mídia paga, novos serviços ou dependências. Validar Godot/Node e navegador, incluindo toque simultâneo, prévias e acessórios nos três dinos e efeitos/chegada nas três pistas. Registrar limites da emulação: não prova desempenho físico nem preferência infantil.

## User Stories

1. Como criança, quero escolher e rever a aparência do meu dino para reconhecê-lo e brincar com boné ou óculos (R1, R2).
2. Como criança, quero provocar reações e efeitos diferentes escolhendo meu caminho sem complicar os controles (R3, R4).
3. Como criança, quero que o Filhote acolha minhas frutas mesmo quando não ganho ou não pego nenhuma (R5).
4. Como integrante da Dupla, quero controlar meu dino ao mesmo tempo que outra pessoa no mesmo aparelho e continuar vendo os dois (R6–R9).
5. Como integrante da Dupla, quero juntar nossas frutas e esperar por quem ainda está correndo, sem disputar posição (R10–R12).
6. Como responsável, quero pausar, reiniciar ou mudar de modo sem controles presos, perder o álbum ou alterar as corridas existentes (R13–R16).

## Implementation Decisions

### Estado da corrida e contrato da Dupla

- Manter `race_state` como autoridade das regras. Adicionar modo explícito `competitive`, `solo` ou `coop`; não incluir parceiro em `RIVALS`. `configure(dino, circuit, rival)` mantém assinatura/comportamento e infere os modos antigos; uma configuração cooperativa recebe duas espécies e pista. Validar tudo antes de mutar. `solo` deixa de significar apenas `rival_id == "none"`.
- Ampliar `advance(delta, steering = 0, partner_steering = 0)` com o terceiro argumento opcional. Reutilizar os dois registros/corpos existentes e acrescentar os contadores necessários ao segundo humano, sem reescrever toda a corrida como um framework genérico de corredores. Defaults, ordem de sorteios e caminho numérico dos modos antigos continuam compatíveis.
- Na Dupla, o segundo registro usa velocidade/condução da espécie selecionada, recebe entrada humana e não passa por `_steer_rival`. Concentrar ajuda longitudinal, conclusão conjunta e coleta no estado; a cena resolve movimento/contato físico como hoje. Preservar as regras por pista, inclusive quando um jogador muda de Volta antes do outro.
- Ajuda por dois limiares: acima do limiar suave reduzir o avanço do líder; no máximo impedir avanço adicional até o parceiro aproximar. Progresso nunca diminui. Os valores são calibração técnica do ticket 03; registrar valores e evidência de enquadramento, não inventar novos modos de dificuldade.
- Ao concluir individualmente, retirar o corpo da passagem ou sua colisão com o parceiro e posicionar o dino em espera junto à chegada. A ajuda e a câmera consideram esse estado. `stage = finished` exige duas chegadas; `winner` permanece vazio na Dupla, inclusive quando concluem no mesmo passo.

### Cena, aparência e brincadeiras

- Reutilizar `runner_model`, modelos existentes, animações e malhas primitivas. Acessórios acompanham o osso `Head`, com encaixe calibrado por espécie e `BoneAttachment3D` sem sobrescrever pose. Não alterar GLBs/rigs nem adicionar formas físicas aos acessórios. Acessório pode ser argumento opcional do criador, preservando chamadas atuais. Evitar aplicar o shader de tintura de pele às novas malhas dos acessórios.
- Reutilizar a persistência local e os catálogos atuais: acrescentar preferências de duas aparências com validação/fallback e migração da cor atual, sem apagar o álbum. A representação interna fica a cargo da implementação; manter a API de recompensas compatível para os consumidores existentes. Persistência de aparências não depende de ganhar adesivo, além das restrições já existentes de cor.
- Expor no menu uma área visível de prévia do dino real, reutilizando a cena antes da largada; em Dupla identificar ambos. Ajustar layout do menu/resultado para que prévia e encontro não fiquem encobertos. Não exigir novo asset, renderizador externo ou tela de personalização separada.
- Concentrar reações/caminhos no cenário de corrida e na apresentação do modelo. Observar cruzamentos de poças e trechos derivados do layout já criado; não consumir o RNG do estado para decoração. Usar transformações visuais abaixo do corpo físico e compor com animação, encaixe de acessório e orientação existentes. Efeitos dos lados diferem visualmente; são apenas decoração/resposta à passagem.
- Criar o Filhote a partir de modelo existente reduzido, fora da faixa de colisão. Ao evento de conclusão mostrar recepção das frutas (total na Dupla), aceno/comemoração também com zero; reinício limpa a sequência. O Filhote não passa a ser outro corredor nem altera o resultado.
- A câmera cooperativa enquadra os dois corpos, com foco compartilhado e distância/enquadramento adaptados à separação e proporção da tela. Não modificar a câmera dos modos anteriores nem o passeio `park` para obter esse comportamento.

### Página, ponte e recompensas

- Acrescentar opção Dupla e seleção de aparência por jogador. Nos modos atuais manter comandos `select:<dino>:<track>:<rival>` e controle existentes. Introduzir comando cooperativo atômico com pista e duas espécies e comandos de aparência/entrada identificados por jogador; aceitar apenas slots 1/2, enums conhecidos e estados permitidos. A página e o shell do iframe roteiam as teclas igualmente; Godot nativo recebe o mesmo mapeamento.
- Rastrear ponteiros ativos por jogador/direção, removendo somente o ponteiro liberado. Compor teclado e toque para não soltar uma direção ainda sustentada por outra fonte. `release`, pausa, reinício e menu limpam as duas pessoas e as fontes. Não depender de um único booleano compartilhado de toque.
- Estender `park-race` com `mode` explícito e fatos por humano em `players`: espécie, progresso, Volta, frutas, douradas, velocidade/base e chegada. Dupla tem dois registros; modos atuais têm um. Manter campos legados para compatibilidade; `fruit` e `golden` representam totais da Dupla, e o jogador principal nos modos anteriores. Campos de progresso do segundo corpo continuam disponíveis, sem chamar o parceiro de Rival na interface.
- Validar relatório por modo, limites/enums e números finitos. A função de recompensa aceita relatórios antigos sem `mode` inferindo seus modos antigos, mas um relatório `coop` explicitamente exclui todos os adesivos de competição e o de Sozinho, mesmo se receber `winner`/`rival` inconsistentes. A página só chama atribuição ao concluir a condição válida do modo.

## Testing Decisions

- Testar comportamento pelas interfaces públicas existentes de `race_state` (`configure`, configuração cooperativa, `reset`, `start`, `advance`, `sample` e fatos observáveis), pelos comandos/relatórios da cena, pelos exports de persistência/recompensas e pelo navegador. Usar sementes fixas e expectativas independentes das fórmulas; não testar nomes de helpers, constantes isoladas ou só a presença de código.
- Prior art: `baseline_test`, `modes_test`, `fruit_paths_test`, `collision_test`, `valley_test`, `scenery_test`, testes de recompensas e catálogo web. Manter testes antigos passando; ampliar testes de catálogo/contrato somente quando o contrato mudou intencionalmente. Novos scripts de verificação entram nos comandos npm apropriados.
- **Aparência:** testar os três dinos com cada acessório, ausência de alteração física/atributos, animação sem desencaixe, prévia, recarga das duas preferências, migração, valores inválidos, cores bloqueadas e storage que lança erro. Inspeção de imagem no navegador confirma encaixe: teste estrutural de osso sozinho não basta.
- **Brincadeiras:** cruzar ambos os lados e poças em cenas físicas, observar efeitos distintos e reação breve sem mudar resultado numérico, pausa/reset, Filhote após corrida com zero/coleta e vitória/derrota, sem alterar frutas/setas/colisões. Rodar nas três pistas; combinar com os três dinos na verificação visual.
- **Dupla:** testar entradas opostas/independentes e ausência de IA; matriz 3 espécies x 3 espécies x 3 pistas para configuração/atributos/conclusão, com cenários dirigidos para coleta dos dois, respawn, dourada para cada slot, Setas, Voltas desencontradas, total e ausência de vencedor. Testar separação máxima em corridas longas com entradas/velocidades diferentes, pausa/reset e troca de modo. Teste físico confirma espera sem bloquear, especialmente se jogador 2 chegar antes do jogador 1.
- **Câmera:** projetar limites visuais dos dois dinos na viewport durante corrida/curvas/espera nos tamanhos 1280x900 e 390x844; testar máximo de separação calibrado e giro limitado. Complementar com imagens no navegador, sem concluir que uma asserção de foco central prova visibilidade.
- **Web/álbum:** testar coop sem prêmio competitivo mesmo com campos legados de vitória, limites de soma (9/10 frutas), ambos concluídos e transição de modo. No navegador usar teclas com foco na página e iframe, dois ponteiros simultâneos, soltura/cancelamento independente e perda de foco/pausa/reinício sem direção presa. Injetar mensagens falsas/malformadas e confirmar rejeição.
- Validar cada incremento com os testes afetados e `npm run test:race` quando mudar o caminho compartilhado. Na entrega executar `npm test` e `npm run test:godot` completos, verificar pack exportado e fazer a validação de navegador pelo Main após o implementer. Registrar evidências e limites em nota curta de validação.

## Out of Scope

Online, controle físico, disputa entre humanos, alternância de corridas, novos dinos/pistas/GLBs, loja/moedas/obrigações diárias, adesivos novos, alterações de física/equilíbrio dos modos atuais, geração paga de mídia, novos serviços/dependências, publicação externa, push ou merge em main.

## Further Notes

Não há pergunta de produto pendente. Encaixes, formas visuais e limiares da ajuda são calibrações técnicas dentro dos comportamentos aprovados. A sequência é incremental e estritamente sequencial: aparência; brincadeiras; integração completa da Dupla; entrega. Nenhum ticket autoriza push ou merge.

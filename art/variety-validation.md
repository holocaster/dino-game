# Três dinos, duas pistas e equilíbrio — 0.14.0

Atualização em 0.14.1: T-rex e velociraptor agora usam malhas texturizadas geradas pela fal.ai e esqueletos próprios. [Validação dos novos modelos](bipeds-validation.md). A descrição dos modelos procedurais abaixo registra a entrega original.

Entrega de 2026-11-11, autorizada como prioridade antes das oito expansões propostas na sessão anterior. O usuário escolheu tricerátopo, T-rex e velociraptor, com floresta e praia. [Seleção](previews/variety-selection-desktop.png) · [Celular](previews/variety-selection-mobile.png) · [T-rex na praia](previews/variety-trex-beach.png) · [Velociraptor](previews/variety-raptor-beach-mobile.png).

## Dinossauros e pistas

| Dino | Velocidade base | Movimento lateral |
|---|---:|---:|
| Tricerátopo | 2,20 | 2,40 |
| T-rex | 2,27 | 2,20 |
| Velociraptor | 2,13 | 2,70 |

Unidades do jogo por segundo. Diferenças pequenas preservam a escolha pelo favorito. O amigo verde conserva velocidade base 2,35, decisões e colisões anteriores.

O tricerátopo reutiliza o modelo articulado existente. T-rex roxo e velociraptor verde-água têm modelos procedurais distintos: cabeça e corpo mais largos no primeiro; focinho estreito, corpo fino, braços e cauda mais compridos no segundo. Pernas articuladas usam trajetória suavizada e solução geométrica de joelho/tornozelo, mantendo o apoio e a passada sincronizados ao deslocamento. Cabeça e cauda se movem discretamente; descanso e transição de animação são preservados. Não foram usados serviços pagos ou novas dependências.

A floresta conserva seu circuito e relevo. A praia tem curva elíptica de raios 15×11, em comparação com 13×14 na floresta, terreno baixo, areia, mar e coqueiros. Bordas e largada acompanham a curva selecionada; palmeiras e pedras mantêm colisores. A cena antiga de passeio continua acessível pelo editor.

## Frutas e recuperação

Cada fruta concede +0,16, até +0,64 sobre a base do corredor. Cada coleta renova quatro segundos de duração; depois, o bônus diminui a 0,64 unidade/s até a velocidade base. O teto e a duração são iguais para os dois corredores. O HUD calcula a porcentagem sobre a base do dino escolhido.

Após uma coleta, a fruta fica indisponível por 1,5 segundo e reaparece para quem ainda não a pegou. Cada corredor recebe um bônus por fruta por volta. Depois das duas coletas, ela permanece indisponível. Isso impede ganhar bônus repetidos parado no mesmo lugar e preserva a regra de um dono por coleta física.

Pausa congela duração e respawn; reinício limpa os dois temporizadores e todas as coletas, preservando seleção. A pausa e a chegada oferecem retorno à seleção. Valores desconhecidos ou comandos de troca durante a corrida são rejeitados; recarregar a página restaura a seleção inicial, sem persistência.

Recuperação depende das escolhas: não há aceleração escondida por estar atrás. No ensaio isolado em que o líder começa oito unidades à frente, passa pelas primeiras frutas e depois mantém uma linha sem frutas, os três dinos conseguem coletar as frutas reaparecidas e vencer. Isso verifica a possibilidade de recuperação quando o líder deixa oportunidades; não garante vitória contra um rival que aproveita bem as frutas.

## Validação

- 15 scripts Godot, dois testes Python e nove testes Node aprovados.
- `balance_test.gd`: teto, duração, reaparecimento compartilhado, coleta por corredor, pausa, reinício, configurações inválidas e recuperação com os três dinos.
- `variety_test.gd`: volta completa nas seis combinações; pista sem troncos no trajeto, terreno acima da água, altura dos pés, animações, teto de velocidade e retorno ao menu.
- Testes anteriores de corrida, colisão, rival, câmera, áudio, passeio e passadas preservados; o teste do rival contabiliza coletas pelos registros permanentes, pois as frutas agora reaparecem.
- O teste físico também confirma o jogador coletando uma fruta e o rival, vindo atrás, coletando a mesma após reaparecer; os dois registros são preservados e o objeto visual some após a segunda coleta.
- Chromium/Playwright: troca real de cena e seleção, T-rex e velociraptor na praia, coleta, cálculo do HUD, teclado, botão lateral e toque emulado por CDP, pausa que congela progresso e bônus, retorno à seleção e reinício. Layouts 1280×900 e 390×844 conferidos, sem excesso de largura; nenhum erro de console na navegação verificada. No ensaio de toque, a posição lateral mudou de −0,90 para −0,16.

O pack web tem 6.107.204 bytes e carrega com cache e metadados de tamanho em 0.14.0. JavaScript/WASM Godot 4.7.2 existentes reutilizados. A exportação foi feita com `--export-pack`, sem instalar templates. Sem commit ou push.

## Limites

Os dois modelos novos usam formas simples, sem texturas ou malha esculpida; precisam de avaliação visual junto ao tricerátopo existente. Colisores continuam aproximando o corpo, sem formas individuais em caudas e patas. Dificuldade, tempos dos bônus, naturalidade e desempenho móvel precisam de avaliação com crianças e aparelhos reais. O navegador automatizado usa renderização por software.

As oito expansões permanecem em [próximas melhorias](next-steps.md); apenas sua base de variedade foi entregue nesta etapa.

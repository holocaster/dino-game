# Personagem voador — 0.34.1

Em 2026-11-24 o usuário confirmou voo baixo automático e autorizou uma geração pelo fal.ai e implementação direta, sem commits. O pteranodonte está disponível gratuitamente nos dois jogadores, nas cinco pistas e nos modos Rival, Sozinho e Dupla.

## Modelo e integração

- Uma geração pelo Tripo H3.1 produziu o modelo utilizado: 11.846 triângulos, 7.320 vértices e textura 2K. [Origem e parâmetros](fal/pteranodon-generation.json), [prévia original](fal/pteranodon-preview.png).
- `scripts/rig_pteranodon.py` prepara dez ossos e dois ciclos: voo durante a corrida e flutuação na prévia/chegada. Tronco horizontal, cabeça alinhada, cauda para trás e pernas recolhidas; as asas compensam a inclinação do tronco para continuar batendo para cima/baixo. A geometria fica acima do chão; o corpo físico permanece na pista. Batida das asas limitada a 1,6×, independentemente do impulso.
- Atributos iguais aos do tricerátopo. Coleta, colisões, percursos, impulsos e chegada mantêm suas regras. Cores e acessórios usam os mecanismos existentes; o boné e os óculos acompanham a cabeça. O rótulo da Dupla fica acima da crista.
- O voador não produz passos ou poeira no chão. O rastro acompanha sua altura visual. Seleção em duas colunas para os quatro personagens, armazenamento e relatórios aceitam a nova espécie.

## Capturas reais

As capturas nativas foram produzidas por `game/tests/flight_visual.gd`, em OpenGL Compatibility, com o mesmo estado para as cinco pistas. As duas fases abaixo mostram a deformação das asas; não são conceitos gerados.

| Vista | Evidência |
|---|---|
| Asas levantadas / abaixadas | [Levantadas](previews/flight-wing-0.225.png) · [Abaixadas](previews/flight-wing-0.675.png) |
| Postura lateral | [Asas levantadas](previews/flight-side-0.225.png) · [Asas abaixadas](previews/flight-side-0.675.png) |
| Postura vertical anterior | [Antes da correção](previews/flight-posture-before.png) |
| Boné, óculos, cor e rótulos | [Prévia da Dupla](previews/flight-preview-accessories.png) |
| Floresta | [1114 × 660](previews/flight-forest-desktop.png) · [364 × 674](previews/flight-forest-mobile.png) |
| Praia | [1114 × 660](previews/flight-beach-desktop.png) · [364 × 674](previews/flight-beach-mobile.png) |
| Vale | [1114 × 660](previews/flight-valley-desktop.png) · [364 × 674](previews/flight-valley-mobile.png) |
| Vulcão | [1114 × 660](previews/flight-volcano-desktop.png) · [364 × 674](previews/flight-volcano-mobile.png) |
| Caverna | [1114 × 660](previews/flight-cave-desktop.png) · [364 × 674](previews/flight-cave-mobile.png) |
| Seleção no navegador | [1280 × 900](previews/flight-browser-selection-desktop.png) · [390 × 844](previews/flight-browser-selection-mobile.png) |
| Corrida no navegador | [Dupla](previews/flight-browser-coop-desktop.png) · [Sozinho na Caverna](previews/flight-browser-solo-mobile.png) |

## Correção de postura — 0.34.1

O usuário apontou voo em pé e pernas abrindo. A primeira animação mantinha o tronco com somente cerca de 6° de inclinação, e o cálculo de pesos das asas usava apenas a distância lateral: também atingia os pés. O teste de regressão, executado antes da correção, terminou com código 1 e registrou alinhamento do tronco com o avanço de `0.100` (exigido acima de `0.95`) e 488 influências das asas em vértices abaixo de 0,8 m (exigido zero).

O primeiro ajuste isolou os pés das asas: o mesmo teste registrou zero influências indevidas e continuou falhando na postura. A correção seguinte colocou o tronco na horizontal e acrescentou ossos próprios às pernas e à cauda, mantendo cabeça e asas com orientação adequada. A vista lateral foi usada para separar a cauda dos pesos das pernas. O modelo e a textura originais foram reutilizados; nenhuma geração adicional ou crédito do fal.ai foi necessário.

`flight_test.gd` agora verifica, nas duas animações e durante toda a batida, alinhamento horizontal do tronco, pés recolhidos atrás do corpo e sem variação lateral causada pelas asas, além de altura e deformação das asas. Capturas nativas nas cinco pistas foram atualizadas, incluindo as duas vistas laterais. Passaram os testes focados `flight_test.gd`, `appearance_test.gd`, `coop_camera_test.gd` e `collision_test.gd`, a reconstrução byte a byte do rig e os 33 testes Node. Exportação/cache 0.34.1 atualizados. No navegador, Dupla em 1280 × 900 e Sozinho na Caverna em 390 × 844 renderizaram o modelo corrigido; houve coleta real de fruta no Sozinho, pausa e ausência de rolagem horizontal. A suíte ampla abaixo corresponde à entrega inicial 0.34.0.

## Verificação da entrega inicial — 0.34.0

- `npm test`: 33 testes Node, incluindo persistência do voador nos dois jogadores, relatórios/recompensas, catálogo, versões e tamanho real do PCK. O teste antigo que inicia o CLI fal.ai recebeu `EPERM` no sandbox; a mesma suíte passou fora dele, com respostas simuladas e sem geração paga.
- Scripts de `npm run test:godot` executados em partes: comandos longos foram encerrados com sinal 143, e os scripts pendentes foram executados separadamente. A lista inclui os 34 scripts Godot e os dois testes Python existentes; o teste de voo pode ser repetido com `npm run test:flight`.
- `flight_test.gd`: pesos normalizados, geometria deformada das duas asas nos ciclos de voo/flutuação, altura acima de 0,35 m, coleta pelo corpo físico dos dois jogadores em todas as pistas, pausa real da animação, reinício, limite de frequência, ausência de passos e poeira.
- `appearance_test.gd` percorre as quatro espécies e três acessórios. `coop_camera_test.gd` inclui o voador nas cinco pistas, ambos os líderes, separação de 18 m, chegada e telas largas/verticais; as verificações de corpo, malha, acessórios e rótulos passaram.
- Os 72 resultados históricos da Floresta/Praia permaneceram idênticos. O teste de baseline agora enumera explicitamente as três espécies existentes quando esses resultados foram registrados; os valores esperados foram preservados.
- O rig foi reconstruído e comparado byte a byte com o GLB entregue. A exportação foi atualizada com `--export-pack`, reutilizando o runtime Web 4.7.2 existente; PCK, versão 0.34.0, cache e `fileSizes` sincronizados.
- Chromium/WebGL 2: seleção dos dois voadores, Rival/Sozinho/Dupla, direção por teclado, pausa/retomada, reinício, troca de pista, aparências preservadas após recarregar, telas 1280 × 900 e 390 × 844 sem rolagem horizontal. Sem erros no console; quatro avisos de leitura de pixels do driver na primeira carga.

## Limites

Sem voo livre, controle de altura ou vantagem sobre obstáculos: o voo é uma representação visual sobre a física atual. As asas podem se cruzar visualmente quando os corredores estão próximos; não são colisores adicionais.

Não houve revisão independente nem benchmark em hardware real ou aparelho móvel físico. Capturas e emulação comprovam apresentação e comportamento nos ambientes utilizados, não desempenho em todos os dispositivos. Os oito testes da exploração antiga mantêm o diagnóstico preexistente de descarte de materiais no renderer sem gráficos, documentado na [0.33.0](graphics-validation.md); as asserções passaram. Nenhum contorno foi aplicado ao jogo.

# Personagem voador

## Objetivo e decisão confirmada

Adicionar um pterossauro selecionável para diferenciar os personagens. Em 2026-11-24 o usuário confirmou voo baixo automático pela pista, asas animadas e os mesmos controles de esquerda/direita.

## Avaliação de arte

Não há modelo alado em `game/assets/` nem no catálogo de `game/dinos/runner_model.gd`. Os três personagens atuais usam GLBs texturizados; os registros em `art/fal/` mostram geração pelo Tripo e rigs preparados localmente.

O fal.ai não é requisito técnico: Godot permite geometria e animação locais. Para manter o acabamento orgânico e texturizado dos personagens atuais, a proposta é gerar um pterossauro com asas abertas pelo fal.ai e preparar seu rig/animações localmente. O catálogo consultado em 2026-11-24 lista `tripo3d/h3.1/text-to-3d`, já usado no projeto. Nenhuma geração foi solicitada e nenhum crédito foi consumido nesta avaliação. A topologia e a separação das asas precisam de inspeção antes do rig; o gerador não garante um personagem animável pronto.

## Proposta de integração

1. Modelo com corpo, cabeça e asas reconhecíveis, animação de voo e flutuação discreta. Preservar a interface de animação do catálogo e acessórios ligados à cabeça.
2. Adicionar a espécie na seleção dos dois jogadores, aparências salvas, validação de relatórios, atributos e cores de rastro. Velocidade inicial proposta igual à do tricerátopo, sem vantagem por voar.
3. Elevar a representação visual mantendo a trajetória e o corpo físico existentes. A coleta usa contato físico em `race.gd`; subir o corpo inteiro pode impedir frutas e mudar colisões. Conferir asas, câmera, rótulos da Dupla e obstáculos nas cinco pistas.
4. Validar voo, pausa, reinício, troca de aparência, frutas, colisões e Dupla. Executar os testes existentes pertinentes e acrescentar verificação focada do novo rig/voo e da aceitação da espécie nos relatórios.
5. Regenerar a exportação web e sincronizar versão/cache/changelog na entrega.

Pontos principais: `game/dinos/runner_model.gd`, novo modelo/rig, `game/race/race.gd`, `game/race/race_state.gd`, `game/race/speed_effects.gd`, `web/appearance.mjs`, `web/race-report.mjs`, `web/index.html`, `web/game.js`, `web/game.css`, testes e exportação.

## Fora do recorte

Voo livre, controle de altura, atalhos aéreos e novas pistas. Manter as regras atuais de frutas, impulsos, chegada e cooperação.

## Execução autorizada

Em 2026-11-24 o usuário autorizou a geração pelo fal.ai e a implementação direta, sem commits, fora do fluxo SDD. Uma geração produziu o modelo utilizado; origem e parâmetros estão em `art/fal/pteranodon-generation.json`. O rig local tem dez ossos, animações de voo/flutuação e altura visual acima do corpo físico.

Entrega inicial na versão 0.34.0; postura horizontal corrigida na 0.34.1, com seleção dos dois jogadores, aparências, relatórios, efeitos e exportação integrados. Verificações e capturas estão em `art/flight-validation.md`. Sem revisão independente ou medição em hardware real.

Após a validação da 0.34.1, o usuário autorizou commit e push da entrega.

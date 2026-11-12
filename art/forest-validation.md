# Floresta — etapa 3

Implementada em 0.4.0 em 2026-11-10. [Desktop](previews/forest-desktop.png) · [Celular](previews/forest-mobile.png).

## Entrega

Terreno contínuo com ondulações suaves, trilha curva, lago com margem de pedras, árvores e vegetação em camadas. A câmera em perspectiva acompanha o personagem com suavização exponencial, mantém o ângulo e adapta o campo de visão ao formato da tela. Árvores entre câmera e personagem são ocultadas para preservar a visibilidade.

O toque consulta a superfície de altura do terreno. Uma grade AStarGrid2D calcula rotas, com margem para o corpo do personagem ao redor do lago e dos troncos. Trechos com linha livre são unidos para evitar zigue-zague. Toques em obstáculos escolhem um ponto caminhável próximo. O personagem segue a altura do solo, e quadros atrasados consomem os trechos da rota em ordem, preservando os obstáculos. As três descobertas, repetição, teclado e reinício foram mantidos.

Fonte do cenário e navegação: `game/forest.gd`. Integração e câmera: `park.gd`. As árvores e pedras usam MultiMesh; as folhas rasteiras usam uma malha única. Não há novas dependências ou chamadas externas para jogar.

## Verificações

- `npm run test:godot`: interações existentes, esqueleto/animações e cenário.
- Rotas até as descobertas e destinos em lados diferentes do lago, incluindo alvos dentro do lago e de troncos; posição sempre caminhável e sobre o terreno.
- Quadros de 50 e 450 ms, toque projetado no terreno, acompanhamento da câmera, enquadramento vertical e reinício limpando a rota.
- Chromium 1280 × 900: três descobertas, celebração e reinício; teclado também verificado após redimensionar para 390 × 844.
- Contexto com toque habilitado em 390 × 844: início, visita às flores e reinício por toque; sem rolagem horizontal.
- Sem erros de console na verificação web final.
- `npm test`: nove testes Node.

## Desempenho e limites

A amostra nativa de três segundos em 1100 × 720 registrou 60 FPS e 148 chamadas de desenho na GPU Intel UHD 630, usando OpenGL Compatibility. É uma observação curta no estado inicial, não uma garantia de desempenho no parque inteiro.

O Chromium automatizado usa ANGLE/SwiftShader, por software. A primeira versão do cenário mediu cerca de 440 ms por quadro nesse ambiente. As árvores foram agrupadas e o avanço por rota foi corrigido antes de repetir as visitas com sucesso. Não foi obtida uma medição final de FPS web com GPU. O primeiro teste mobile, concorrendo com outra cena web, excedeu o tempo limite; a repetição isolada passou.

O relevo é suave e o personagem acompanha sua altura; não há IK dos pés em tempo real para degraus ou terrenos acidentados. A água é visual, sem nado. A vegetação usa geometria simples, ainda sujeita a avaliação artística. Faltam testes em aparelhos físicos, com crianças e medições prolongadas no navegador com GPU. Alimentação visível do amigo e áudio pertencem à etapa 4.

# Colisões suaves — 0.13.0

Implementadas em 2026-11-10: contato entre os corredores, obstáculos sólidos e coleta física de frutas. [Contato em tela larga](previews/collision-contact-desktop.png) · [Tela vertical](previews/collision-contact-mobile.png) · [Rival coletando frutas](previews/collision-race-mobile.png).

## Implementação

Os corredores usam `CharacterBody3D` com cápsulas horizontais e movimento por `move_and_collide()`. Até três contatos são resolvidos por passo, projetando o movimento restante ao longo da superfície. O contato não causa dano, impulso de lançamento ou queda. A altura continua acompanhando o perfil matemático do terreno; o deslocamento e a animação dos dois corredores são atualizados nos passos de física.

O corpo físico e sua forma mantêm escala unitária. O amigo conserva o tamanho visual 0,86 no nó `Model`, e sua cápsula recebe dimensões proporcionalmente menores. Isso segue a orientação do Godot de dimensionar a forma e o visual separadamente, preservando o corpo físico sem escala. [Documentação de escala e física](https://docs.godotengine.org/en/4.7/tutorials/physics/troubleshooting_physics_issues.html).

Troncos e pedras recebem `StaticBody3D`; as bordas físicas acompanham os marcadores existentes da pista. Frutas usam `Area3D` com esfera de detecção. Após mover os dois corpos, duas consultas de forma obtêm os contatos reais com as áreas. Isso evita depender das listas de sobreposição, que só são atualizadas no passo de física. [Consulta de formas](https://docs.godotengine.org/en/4.7/classes/class_physicsdirectspacestate3d.html#class-physicsdirectspacestate3d-method-intersect-shape).

A posição física é reprojetada no circuito antes de contabilizar progresso, vencedor e coleta. O estado lógico mantém a simulação isolada usada nos testes de decisões; na cena, os callbacks de movimento e contato fornecem as posições permitidas e as frutas realmente alcançadas. Uma fruta continua concedendo apenas um bônus, mesmo quando os dois corredores a alcançam no mesmo passo.

O rival percorre um pequeno trecho depois de terminar, liberando a linha de chegada sem desativar seu colisor. O corpo visual acompanha a direção efetiva do movimento, inclusive ao deslizar durante um contato. Pausa preserva a posição e reinício limpa contatos, progresso, frutas e estados da IA.

## Arquivos

- `game/race.gd`: corpos, formas, deslizamento, bordas, áreas de coleta, consultas, projeção, passos de física, animações e liberação da chegada.
- `race_state.gd`: resolução física antes das regras de progresso/coleta e verificação de chegada pela posição alcançada.
- `forest.gd`: colisores dos troncos e pedras da corrida. A cena anterior de passeio mantém seu comportamento.
- `tests/collision_test.gd`: contato sustentado, obstáculos, coleta, bloqueios, pausa, reinício e chegada.
- Testes existentes da corrida, rival e animação adaptados ao ciclo de física e à escala do nó visual; os oito scripts anteriores permanecem sem alterações.

## Verificação

O teste inicial reproduziu os dois corredores se atravessando ao segurar a direção contra o outro na borda: distância mínima entre os centros de aproximadamente **0,027**. Com os corpos físicos, o mesmo cenário manteve aproximadamente **0,905**, com avanço dos dois e sem interpenetração significativa das cápsulas. As consultas de sobreposição do teste descontam 1,5 cm da forma para não tratar a tolerância de contato como penetração.

O novo script também verifica:

- Formas sem escala e tamanho visual preservado; bloqueio por tronco real mesmo com varredura de cinco unidades.
- Fruta alcançada simultaneamente pelos dois: um proprietário, um bônus e retirada visual.
- Barreira antes da chegada: posição bloqueada não gera progresso invisível, chegada, vencedor ou coleta da fruta atrás dela, inclusive com quadros de 0,4 segundo.
- Altura do terreno, limites da pista, pausa e reinício sem contato ou pontuação antigos.
- Rival terminado na mesma linha do jogador: continua além da chegada, permanece sólido e permite que o jogador termine.

**13 scripts Godot, dois testes Python e nove testes Node aprovados.** Os testes da cena aguardam passos de física para sincronizar a inserção e o movimento dos corpos no espaço; a leitura lateral admite até 2 mm de erro numérico da reprojeção da curva. A volta completa continua sendo verificada em tela larga e vertical, com os limites de giro e aceleração da câmera.

Chromium/Playwright: carregamento da 0.13.0, largada, aproximação lateral por teclado, coleta do jogador e do rival, toque emulado, soltura, pausa e reinício com posição/frutas/velocidade zeradas. Na conferência final, o rival recebeu dois bônus físicos e chegou a 2,67 de velocidade. Nenhum erro no console na navegação verificada.

## Exportação e limites

Pack web de **6.097.196 bytes**, com shell, tamanho de download e referências de cache sincronizados em 0.13.0. Engine JavaScript/WASM Godot 4.7.2 e arte existentes reutilizados. Sem novas dependências, commit ou push.

As cápsulas aproximam o volume dos corpos; chifres, caudas e patas não têm colisores individuais. O piso continua usando o perfil de altura existente, sem gravidade ou quedas. Naturalidade do contato e desempenho em celulares/tablets ainda precisam ser calibrados em aparelhos físicos e com crianças; o navegador automatizado usa renderização por software.

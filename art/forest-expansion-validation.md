# Expansão da floresta — versão 0.9.0

Implementada em 2026-11-10. Direção confirmada pelo usuário: trilhas suaves até um mirante, com montanhas ao fundo.

[Vale de cogumelos](previews/expansion-mushrooms.png) · [Prado de borboletas](previews/expansion-meadow.png) · [Mirante](previews/expansion-lookout.png) · [Tela vertical](previews/expansion-mobile.png).

## Entrega

As três áreas anteriores permanecem: clareira com alimentação, margem do lago com flores e bosque com pegadas. O novo circuito acrescenta:

- Vale de cogumelos em (-11, -8), com vegetação em tons mais escuros e cogumelos coloridos.
- Prado de borboletas em (6, -12), com flores e três borboletas animadas.
- Mirante em (0, -20), com marco de pedras, subida gradual e montanhas no horizonte. A câmera abre suavemente a vista ao se aproximar e retoma o enquadramento habitual ao sair.

Há seis descobertas repetíveis, acessíveis pelo chão, por clique/toque nos lugares e pelos seis atalhos da interface. Os atalhos ficam em duas linhas no celular. A celebração exige seis descobertas, e o reinício limpa todas elas e retorna à clareira. Sons e transição independente de copa e tronco foram preservados; o vale também recebe os pássaros do bosque.

As montanhas são parte da paisagem distante. A trilha leva ao mirante, sem saltos, escalada ou obstáculos verticais. As partes claras dos picos se unem à base sem sobreposição de superfícies, evitando a cintilação encontrada no primeiro ensaio.

## Dimensão e navegação

Mesma grade de 0,25 unidade por célula para a comparação:

| Medida | Versão 0.8.0 | Versão 0.9.0 |
| --- | ---: | ---: |
| Áreas | 3 | 6 |
| Células caminháveis | 1.772 | 5.118 |
| Área caminhável, em unidades quadradas | 110,75 | 319,875 |
| Circuitos fechados | 1 | 2 |
| Soma dos comprimentos das curvas de trilha | 28,65 | 80,06 |
| Árvores | 27 | 40 |

A área caminhável cresceu aproximadamente 2,89 vezes. A soma das curvas inclui seus trechos de ligação, sem representar uma medição exclusiva de segmentos compartilhados. A grade foi ampliada para cobrir o circuito, e destinos em células livres são consultados diretamente antes da busca pela célula mais próxima. O terreno acompanha o relevo durante o deslocamento. O mirante fica mais de 1,8 unidade acima do início; o teste limita a variação de altura por eixo a 0,4 unidade por unidade horizontal nas células caminháveis.

Fontes: `forest.gd`, `park.gd`, `park.json` e os atalhos em `web/index.html`/`game.css`. Sem bibliotecas, serviços pagos ou assets externos novos. Pack final de 6.060.448 bytes, exportado com Godot 4.7.2 e identificação 0.9.0.

## Verificação

- `npm test`: nove testes aprovados.
- `npm run test:godot`: seis scripts aprovados, incluindo todas as seis descobertas, repetição, reinício, alimentação e transição das árvores.
- Teste de áreas ampliado: dois circuitos fechados amostrados em 201 pontos cada; mais de 2,5 vezes a área caminhável anterior; seis áreas; trajetos de ida e volta nos dois sentidos; segmentos livres; personagem sobre o relevo; inclinação limitada e alimentação após retornar à clareira.
- Toque projetado no chão do mirante, em formato vertical, alcança a posição correta apesar da elevação e da câmera aberta.
- Chromium, 1100 × 900: flores, pegadas, alimentação, cogumelos, borboletas e mirante visitados em sequência. Mirante acionado por teclado. Celebração oculta após três descobertas e visível depois das seis; reinício limpou todas. Console sem erros ou avisos.
- Interface em 320, 390, 768 e 1100 pixels: seis atalhos, sem transbordamento horizontal.
- Chromium com toque emulado, 390 × 844: início, visita ao mirante, caminhada por toque direto no terreno elevado e reinício. Eventos de passos confirmaram movimento após o toque; descobertas foram limpas, sem erros JavaScript ou transbordamento horizontal.
- Capturas web das três novas áreas e do formato vertical inspecionadas. Vista dos picos também conferida com renderização nativa após remover a sobreposição.

## Desempenho e limites

Amostras nativas de dois segundos, em 1100 × 720, OpenGL Compatibility, GPU Intel UHD 630: vale de cogumelos 54 FPS / 114 chamadas de desenho; prado 56 FPS / 233 chamadas; mirante final 61 FPS / 64 chamadas. São amostras curtas, com aquecimento, e não uma garantia para todos os percursos ou aparelhos. O navegador automatizado usa SwiftShader por software e serve à verificação funcional.

Ainda faltam testes em celulares físicos, medições prolongadas no navegador com GPU e avaliação com crianças. A caminhada acompanha a altura do chão, sem IK dos pés em tempo real; as trilhas usam relevo suave. A intensidade percebida do áudio continua dependendo de conferência em alto-falantes e fones reais.

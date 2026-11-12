# Passadas suavizadas — 0.11.1

Pedido de 2026-11-10: reduzir a aparência robótica das passadas na corrida. [Comparação animada antes/depois](previews/triceratops-run-before-after.gif), renderizada no Godot na mesma velocidade de deslocamento de 2,2 unidades/s.

## Causas reproduzidas

1. A trajetória original passava de apoio linear para avanço suavizado com velocidade zero nas extremidades. A velocidade longitudinal da pata saltava aproximadamente **0,846 unidade/s** ao levantar e pousar. O teste `python3 scripts/rig_triceratops_test.py` falhou na curva original e passa na ajustada.
2. A corrida reutilizava a caminhada curta acelerada. Na largada, isso produzia **3,25 ciclos/s**, ou cerca de 13 apoios individuais/s. A nova corrida usa passada própria e pares diagonais, com **2,54 ciclos/s** na mesma velocidade: redução de aproximadamente 22% na calibração final.
3. Em quadros lentos, o movimento limitava o delta a 0,1 segundo, mas a animação continuava no tempo real do quadro. O teste reproduziu **0,22 unidade de avanço contra 0,88 equivalente na animação** num quadro de 0,4 segundo. Agora o ritmo usa distância percorrida dividida pelo tempo real do quadro, incluindo a saída da contagem.

## Alterações

- `scripts/rig_triceratops.py`: curva de avanço com continuidade de velocidade e aceleração nas transições, levantamento arredondado e apoio linear preservado. A mudança beneficia também a caminhada do passeio anterior.
- Novo clip `run`: passada de 0,52, apoio em 60% do ciclo de 0,8 segundo, alternância de pares diagonais, flexão das patas, oscilação vertical de 2,4 cm, balanço discreto do corpo e movimento da cabeça/cauda. Os pés giram durante o avanço e ficam planos no apoio.
- `game/race.gd`: utiliza o clip de corrida nos dois personagens, compensando a escala do amigo; sincroniza a reprodução com a distância efetiva em cada quadro.
- `park.gd`: a função de áudio aceita o comprimento de passo; a corrida usa um som por apoio de par diagonal, mantendo o valor anterior no passeio.
- GLB regenerado com os mesmos 16 ossos, malha e textura. Sem chamadas a serviços de geração ou dependências adicionais.

A primeira amplitude de corrida foi reduzida após o teste mostrar afundamento dos pés na mistura com o descanso. A calibração final preserva a transição e não depende de uma correção visual de altura aplicada no jogo.

## Validação

- **Dois testes Python**: continuidade da velocidade ao levantar/pousar, inclusive na emenda do loop, e imobilidade do pé em apoio após compensar o deslocamento. Verificados para caminhada e corrida.
- **Onze scripts Godot aprovados**: os oito anteriores, os dois da corrida e `tests/gait_test.gd`. A suíte completa passou; após a correção de quadros lentos, os testes da corrida e das passadas foram repetidos.
- Novo teste Godot verifica contato no apoio com tolerância de 2 mm, alcance da passada, levantamento e rotação dos pés, as duas escalas de personagem, cadência, pausa, sons e transição para descanso em 16 pontos do ciclo. A menor altura do osso do pé durante as misturas foi **0,0515**, contra 0,07 no repouso; esse teste admite até 2 cm de diferença durante a mistura.
- O teste de quadro lento falhou antes da correção e passou depois: a distância equivalente da animação coincide com o avanço de 0,22 unidade.
- **Nove testes Node aprovados**.
- Comparação de 48 quadros antes/depois em renderização nativa OpenGL Compatibility, usando Intel UHD 630. Câmera, iluminação e velocidade de deslocamento equivalentes.
- Navegador Chromium: carregamento da versão 0.11.1, contagem, corrida, coleta de fruta e pausa. Nenhum erro no console na navegação final. A conferência funcional do navegador usa renderização por software e não serve como medição de fluidez em aparelhos físicos.

## Exportação e reprodução

`python3 scripts/rig_triceratops.py` regenera o GLB. Depois, reimporte no Godot 4.7.2 e execute `npm run test:gait`; `npm run test:godot` inclui essa verificação. A importação mantém 80 amostras/s. Pack web atualizado: **6.090.220 bytes**, com o tamanho real no shell e cache 0.11.1 em todos os pontos de entrada.

A comparação mostra um trecho de 1,6 segundo repetido; a emenda do GIF não corresponde ao loop do clip. Os loops das animações são contínuos e são verificados separadamente.

Calibração com crianças e aparelhos físicos continua pendente. Não foi medido desempenho móvel. Nenhum commit ou push.

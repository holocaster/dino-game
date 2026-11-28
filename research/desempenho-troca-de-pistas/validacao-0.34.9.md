# Desempenho depois da 0.34.8

As medições usaram o Chrome no Moto G56 conectado por USB. Os testes de abertura usaram gzip, 20/5 Mbit/s, 70 ms de latência e cache HTTP desabilitado. A contagem de shaders cobre os primeiros dez segundos após a largada com Tricerátopo contra Brincalhão. Cada A/B/B/A tem duas rodadas por variante.

## Shaders durante a corrida

O primeiro programa apareceu 46–47 ms após a primeira emissão de poeira de aceleração na Floresta, Praia e Caverna. Na Floresta era só a especialização instanciada do material sem iluminação. Praia e Caverna carregavam também as quatro variantes padrão desse shader. A corrida passou a desenhar uma instância desse material em um viewport auxiliar de 16 × 16, uma vez por sessão Web, antes de liberar o botão de jogar. [Compilação de shaders no Godot Compatibility](https://github.com/godotengine/godot-docs/blob/4.7/tutorials/performance/pipeline_compilations.rst)

| Praia, A/B/B/A | 0.34.8 | Com preparação |
| --- | ---: | ---: |
| Programas durante a corrida | 5 / 5 | 0 / 0 |
| Primeiro quadro | 2,60 s | 2,84 s |
| Até `park-ready` | 14,91 s | 15,13 s |
| Até o primeiro controle | 18,15 s | 18,36 s |

A mudança traz cerca de 0,24 s para o primeiro quadro. A janela entre os cinco links tardios da referência durou cerca de 0,25 s e as consultas WebGL bloquearam a renderização nesse intervalo. O P95 foi de 22,6 ms nas duas rodadas de referência e de 22,6 / 33,5 ms nas rodadas com preparação.

Em uma rodada adicional de cada build, o maior intervalo entre quadros baixou de 318,2 para 33,6 ms na Praia e de 301,6 para 45 ms na Caverna. A exportação final registrou zero compilações tardias nas duas pistas.

## Variantes no primeiro quadro

A Floresta registrou 44 programas na referência. Os shaders sem iluminação do chão ao fundo e da poeira já compartilham as variantes padrão. O primeiro uso instanciado da poeira requisitava só a especialização extra. O renderer Compatibility inicializa as variantes padrão em conjunto, incluindo instancing e profundidade, quando cria a versão do shader. As opções de cor por vértice, emissão e faces duplas aparecem em materiais com comportamentos visuais distintos. A redução dessas variantes ficou em aberto. [Inicialização no Godot 4.7.2](https://github.com/godotengine/godot/blob/4.7.2-stable/drivers/gles3/shader_gles3.cpp#L649-L665)

## Carga dos modelos

O protótipo carregou os dinos sob demanda e guardou as cenas já carregadas. Na Caverna com Tricerátopo, a etapa até `race.gd` caiu de 1,10 s para 0,49 s. A montagem cresceu de 0,76 s para 1,31 s. O tempo até `park-ready` ficou em 13,91 s com os preloads e 13,98 s com o protótipo. O protótipo foi descartado porque a variação entre rodadas superou a diferença entre variantes. Fora da Caverna, a torcida já usa Tricerátopo, T-rex e Velociraptor durante a montagem.

Em cargas individuais do protótipo, o Tricerátopo levou 190–230 ms, o T-rex 186 ms, o Velociraptor 160 ms e o Pteranodonte 90 ms. Os três primeiros apareceram na Floresta; o Pteranodonte foi medido em uma abertura da Caverna com essa espécie selecionada.

## Inicialização do motor

O trace da Floresta mostrou 2,25 s entre `godot:init` e o autoload. Na amostragem do Chrome, 1,75 s aparecem em funções WebAssembly sem símbolos e 0,22 s nas chamadas WebGL instrumentadas. Criação de contexto e extensões, entre outras chamadas, ocupam o restante. Os símbolos da build Web seriam necessários para atribuir o custo restante a funções específicas do motor.

## Leituras de buffers na montagem

Cada chamada a `SceneryMeshes.rock()` criava a mesma esfera e lia seus três buffers. As pedras agora reutilizam os dados dessa esfera em CPU. A comparação dos arrays completos retornou igualdade em dez combinações de semente e musgo. Na Praia, a maior parte das leituras restantes vem da geração das palmeiras, que usa `surface_get_arrays()` também. [Leitura de malhas no Godot 4.7.2](https://github.com/godotengine/godot/blob/4.7.2-stable/drivers/gles3/storage/mesh_storage.cpp#L549-L596)

| Pista | Leituras antes → depois | Tempo nas leituras |
| --- | ---: | ---: |
| Caverna, A/B/B/A | 189 → 3 | 102 → 2 ms |
| Floresta, uma rodada de cada | 72 → 3 | 55 → 6 ms |
| Praia, uma rodada de cada | 489 → 435 | 242 → 229 ms |

## Fluidez do Vale

O Vale desenhou mais geometria mesmo com menos chamadas que a Floresta. A carga de geometria é candidata a um teste de redução de custo. Os números são medianas dos primeiros dez segundos e incluem os passes do renderer. [Contadores do Godot](https://github.com/godotengine/godot-docs/blob/4.7/classes/class_performance.rst)

| Pista | Chamadas de desenho por quadro | Primitivas por quadro |
| --- | ---: | ---: |
| Floresta | 162 | 270.544 |
| Praia | 140 | 172.146 |
| Vale | 126 | 288.990 |
| Vulcão | 118 | 130.220 |
| Caverna | 110 | 86.933 |

## Prévia na troca de pista

O menu reaproveita a miniatura da pista escolhida na área do 3D enquanto a cena é montada. No A/B/B/A da troca Floresta → Caverna, a prévia já estava desenhada no segundo quadro após a escolha, em 70–82 ms. O controle chegou em 4,90–5,01 s nas duas rodadas da referência e em 4,79–4,80 s nas duas rodadas com a prévia. O teste verifica o feedback imediato e inclui o tempo da contagem regressiva.

## Exportação final

O PCK da 0.34.9 transferiu 5.313.938 bytes com gzip, 998 bytes a mais que a 0.34.8. O Chrome do Moto G56 abriu as cinco pistas e verificou o início da corrida, pausa, retomada e volta ao menu em cada uma. A prévia da Caverna também foi conferida em uma captura do aparelho.

A suíte Godot e os 34 testes Node passaram. Em reexecuções dentro do sandbox, o teste do CLI FAL perdeu o `stderr` do subprocesso. O mesmo ocorreu com os arquivos da 0.34.8 e com uma chamada mínima de `spawnSync`. A suíte Node final passou fora do sandbox.

## Primeira e segunda visita com cache HTTP

Foram três duplas de visitas consecutivas à exportação final da 0.34.9 no Chrome do Moto G56, na Floresta com Tricerátopo contra Brincalhão. O servidor local usou gzip e `Cache-Control: public, max-age=600` nos arquivos estáticos. O cache ficou habilitado nas seis visitas. Cada dupla começou com uma URL inédita e repetiu o endereço em uma nova aba. A rede simulada foi de 20/5 Mbit/s com 70 ms de latência.

| Da abertura até | Primeira visita | Segunda visita | Diferença das medianas |
| --- | ---: | ---: | ---: |
| Liberar **Vamos correr** | 16,25 s | 7,84 s | −8,41 s |
| Primeiro controle, após a contagem | 19,42 s | 10,99 s | −8,43 s |

Os tempos até o controle foram 19,20 / 19,54 / 19,42 s na primeira visita e 10,86 / 11,01 / 10,99 s na segunda. Nas três segundas visitas, o Chrome reutilizou cerca de 15,5 MB comprimidos do WebAssembly e do PCK, com zero bytes transferidos para esses dois arquivos. Entre `godot:init` e a liberação do botão, a mediana foi de 7,14 s na primeira visita e de 6,98 s na segunda. Do clique ao controle foram cerca de 3,1 s nas duas condições.

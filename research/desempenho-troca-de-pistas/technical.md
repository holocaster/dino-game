# Desempenho na troca de pistas no Godot Web

Godot local `4.7.2.stable.official.ed1daf0bf`, renderer Compatibility e preset Web com `variant/thread_support=false`. As referências apontam para a documentação 4.7 e para o código da tag `4.7.2-stable`. [Configuração do projeto](../../game/project.godot#L15), [preset Web](../../game/export_presets.cfg#L11), [release 4.7.2](https://github.com/godotengine/godot/releases/tag/4.7.2-stable).

## Onde está o trabalho

Ao trocar a pista ou o rival, `configureRace()` envia `select` ou `select-coop`. O Godot chama `reload_current_scene()`, carrega o `PackedScene` pelo caminho e instancia uma árvore nova. O `_ready()` recria o terreno, os corredores, as frutas, as bordas físicas e o cenário antes de emitir `park-ready`. A inicialização da cena roda na thread principal. [Menu Web](../../web/game.js#L261), [seleção da corrida](../../game/race/race.gd#L544), [montagem da corrida](../../game/race/race.gd#L79), [SceneTree 4.7.2](https://github.com/godotengine/godot/blob/4.7.2-stable/scene/main/scene_tree.cpp#L1558-L1628).

O chão emite seis vértices por célula. Para gravar a distância da pista no primeiro componente da UV, `distance_to_trail()` chama `Curve2D.get_closest_point()`, que percorre todos os segmentos da curva já amostrada. A Floresta consulta uma vez por posição da grade. O Vale faz 57.600 consultas só no chão, embora a grade tenha 9.801 posições distintas. A geometria do chão depende do circuito, com a mesma curva para corrida solo, contra rival e em dupla. [Consulta da distância](../../game/world/forest.gd#L57), [Floresta](../../game/world/forest.gd#L106), [Vale](../../game/world/forest.gd#L441), [curvas da corrida](../../game/race/race_state.gd#L152), [Curve2D 4.7.2](https://github.com/godotengine/godot/blob/4.7.2-stable/scene/resources/curve.cpp#L1018-L1052).

## Teste do terreno pré-calculado

Em um protótipo, somente o chão foi trocado por `ArrayMesh` binário `.res` com `ResourceSaver.FLAG_COMPRESS`. A malha manteve a representação sem índices e as demais etapas de montagem continuaram procedurais. O SHA-256 dos arrays brutos de `surface_get_arrays(0)`, que incluem posições, normais, cores e UV, coincidiu nas cinco pistas e nas repetições de Floresta e Vale.

| Pista | Cena pronta no Godot headless, procedural | Cena pronta no Godot headless, `.res` |
| --- | ---: | ---: |
| Floresta | 779 ms | 646 ms |
| Praia | 468 ms | 109 ms |
| Vale | 1.354 ms | 660 ms |
| Vulcão | 309 ms | 54 ms |
| Caverna | 316 ms | 49 ms |

Com as cinco malhas, o PCK local passou de 16.587.176 para 18.398.436 bytes, um acréscimo de 1,73 MiB. Aplicar o mesmo gzip nível 9 aos dois pacotes deixou uma diferença de 1,59 MiB. A malha binária do Vale, isolada, pesa 488.224 bytes (0,47 MiB). Com o export atual, `Engine.startGame()` espera o PCK principal antes de iniciar o jogo. [Boot do projeto](../../game/shell.html#L44), [loader Web 4.7.2](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/web/js/engine/engine.js#L185-L198), [documentação de export Web](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html#serving-the-files).

O teste headless mediu `instantiate()` e `add_child()`, sem GPU, rede ou envio de eventos JavaScript. No Chrome local, medi da mudança da opção no menu até `park-ready` com renderização por software e desaceleração de CPU de 4×. As duas variantes seguiram a mesma sequência, começando pela Floresta. Nenhuma delas pediu recursos pela rede durante as trocas medidas.

| Pista selecionada | 0.34.2 | Protótipo com terreno pré-calculado | 0.34.3 com reaproveitamento de distâncias |
| --- | ---: | ---: | ---: |
| Vale | 14,78 s | 9,31 s | 10,58 s |
| Praia | 5,58 s | 2,89 s | 3,39 s |
| Vulcão | 3,74 s | 2,11 s | 2,52 s |
| Caverna | 3,07 s | 1,66 s | 1,80 s |
| Floresta | 9,85 s | 8,61 s | 9,92 s |
| Vale, segunda visita | 14,72 s | 8,41 s | 10,48 s |

Os três testes Web rodaram no mesmo ambiente e não representam uma medição no Moto G56. A 0.34.3 aumentou o PCK em 352 bytes; os hashes das cinco malhas continuaram iguais. Mudar apenas o modo no Vale também reconstruiu a cena na 0.34.2 e levou cerca de 14 s. Se isso for um problema no aparelho, vale medir separadamente o reaproveitamento do cenário ao mudar de modo.

## Teste reaproveitando os cálculos da Floresta

Estender às quatro pistas a tabela temporária de distâncias por posição preservou os hashes das malhas. Na rodada headless com o código aplicado, o Vale passou de 1.392 para 772 ms na primeira visita e de 1.329 para 723 ms na segunda. A Praia passou de 448 para 199 ms, o Vulcão de 339 para 158 ms e a Caverna de 306 para 118 ms. A 0.34.3 incorpora essa mudança sem adicionar arquivos de malha ao PCK. [Montagem do terreno da Praia](../../game/world/forest.gd#L399).

Em um teste adicional, indexar as cinco malhas já geradas reduziu o total dos arquivos `.res` para 930.133 bytes (0,89 MiB). A ordem e as posições dos vértices expandidos, as cores, as UVs e os limites ficaram iguais. Algumas normais variaram em até 0,000058 após a conversão. Os tempos de troca da tabela medem as malhas sem indexação. Esse formato menor ainda precisa de validação visual.

## Opções em ordem de adoção

1. **Reutilizar a distância por posição nas outras quatro pistas.** Aplicado na 0.34.3. A abordagem da Floresta reaproveita o cálculo exato entre triângulos vizinhos, conserva a malha e mantém o tamanho dos assets. Esse ajuste ainda calcula a distância uma vez por posição a cada troca. Comparar clique até `park-ready` no Moto G56 antes de adotar arquivos adicionais.
2. **Salvar a malha antes do export, começando pelo Vale.** A `ArrayMesh` lida do `.res` já traz os dados do terreno, poupando as buscas de distância e a geração das normais em runtime. Carregar a malha só quando a pista for selecionada. O renderer ainda precisa criar os buffers de GPU na primeira carga. Vale testar `SurfaceTool.index()` depois de `generate_normals()` e antes de `commit()` para reduzir vértices repetidos. Na versão 4.7.2, o método agrupa vértices pelos atributos e gera os índices na sequência original. Para validar, expandir os índices e comparar posições, normais, cores, UV, ordem dos triângulos e bounds, além do tamanho transferido e do tempo até o primeiro quadro. Manter curva e altura disponíveis para a movimentação e as colisões. [ResourceSaver 4.7](https://docs.godotengine.org/en/4.7/classes/class_resourcesaver.html#class-resourcesaver-constant-flag-compress), [igualdade de vértices](https://github.com/godotengine/godot/blob/4.7.2-stable/scene/resources/surface_tool.cpp#L74-L127), [indexação](https://github.com/godotengine/godot/blob/4.7.2-stable/scene/resources/surface_tool.cpp#L701-L725), [carregamento da malha](https://github.com/godotengine/godot/blob/4.7.2-stable/scene/resources/mesh.cpp#L1553-L1566), [buffers no Compatibility](https://github.com/godotengine/godot/blob/4.7.2-stable/drivers/gles3/storage/mesh_storage.cpp#L196-L224), [movimento e bordas no jogo](../../game/race/race.gd#L213).
3. **Se o custo restante for montar elementos estáticos, ampliar o reaproveitamento.** Guardar referências a malhas imutáveis pode acelerar visitas repetidas ao custo de memória. A Godot só mantém um recurso em cache enquanto existe alguma referência. Pré-gerar um `PackedScene` para decoração ou bordas evita refazer a lógica de geração, mas cada instância ainda cria nós e registra colisões. Manter a corrida, as entradas, os efeitos e os materiais animados com estado por partida. O `PackedScene` atual só representa a cena base, e instanciá-lo de novo executa o `_ready()` quando entra na árvore. [Cache de recursos](https://docs.godotengine.org/en/4.7/classes/class_resource.html#description), [PackedScene](https://docs.godotengine.org/en/4.7/classes/class_packedscene.html#class-packedscene-method-instantiate), [reset da corrida](../../game/race/race.gd#L433).

## Limites do export atual

`ResourceLoader.load_threaded_request()` encaminha o carregamento ao `WorkerThreadPool`. Na versão 4.7.2, o motor inicia o pool com zero workers em builds sem threads e executa essas tarefas na thread que chamou o método. Habilitar threads no Web exige contexto seguro e isolamento entre origens. Distribuir trabalho entre quadros pode manter a interface responsiva, com o mesmo total de cálculos. [ResourceLoader 4.7.2](https://github.com/godotengine/godot/blob/4.7.2-stable/core/io/resource_loader.cpp#L646-L648), [inicialização do pool](https://github.com/godotengine/godot/blob/4.7.2-stable/main/main.cpp#L2014-L2026), [execução sem workers](https://github.com/godotengine/godot/blob/4.7.2-stable/core/object/worker_thread_pool.cpp#L204-L216), [requisitos de hospedagem](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html#serving-the-files).

O Shader Baker atende aos renderers Forward+ e Mobile. Se houver atraso medido entre `park-ready` e a primeira imagem no Compatibility, a documentação sugere renderizar os materiais e efeitos relevantes por pelo menos um quadro durante o carregamento. Durante a troca, isso desloca o custo da primeira renderização para o período de espera. [Compilação de shaders](https://docs.godotengine.org/en/4.7/tutorials/performance/pipeline_compilations.html).

Separar as pistas em PCKs adicionais permitiria reduzir o download inicial e passaria parte do custo para a primeira visita a cada pista. A Godot monta esses arquivos em runtime com `ProjectSettings.load_resource_pack()`. Antes de adotar esse fluxo, comparar o tamanho transferido das malhas indexadas e o tempo de abertura com o PCK único. [PCKs adicionais](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_pcks.html#opening-pck-or-zip-files-at-runtime).

## Vale e aviso de carregamento na 0.34.4

O Vale usa a malha binária do terreno, gerada a partir da mesma curva e dos mesmos cálculos do código procedimental. O teste do Vale compara posições, normais, cores e UVs com a versão gerada em tempo de execução. O PCK cresceu de 16.587.528 para 17.075.752 bytes, cerca de 477 KiB no download inicial. [Gerador](../../scripts/build_valley_terrain.gd), [comparação da malha](../../game/tests/valley_test.gd#L416).

Com Chrome local, perfil Pixel 7, renderização por software e desaceleração de CPU de 4×, a primeira troca de Floresta para Vale levou de 11,7 a 12,5 s em duas execuções da 0.34.3. Um protótipo com só a malha pronta levou 10,5 s, e a 0.34.4 com o aviso levou 11,4 s. A medição começa na seleção e termina em `park-ready`. O aviso fica visível por pelo menos um quadro antes de o navegador enviar o comando ao Godot. Essas medições representam o navegador local emulado.

O perfil headless da 0.34.4 mediu cerca de 522 ms nas árvores decorativas do Vale em duas visitas. O portal levou cerca de 1 ms e os marcadores da borda, de 15 a 16 ms. A próxima otimização a testar é reutilizar a geometria das árvores de beira de pista pela combinação de variante, tamanho e tipo, preservando a transparência e a colisão de cada instância. [Decoração da corrida](../../game/race/race.gd#L405), [geração da malha das árvores](../../game/world/scenery_meshes.gd#L31).

## Abertura e troca de pista na 0.34.5

O PCK Web passou de **17.075.752** para **3.207.904 bytes**. Excluir o modelo antigo e sua textura baixou o pacote para **14.648.912 bytes**. A compressão com qualidade 0,90 nas quatro texturas jogáveis manteve os limites de resolução do import. As imagens originais continuam disponíveis. [Preset Web](../../game/export_presets.cfg), [modelos jogáveis](../../game/dinos/runner_model.gd).

| Mediana de três execuções locais por versão | 0.34.4 | 0.34.5 |
| --- | ---: | ---: |
| Navegação até habilitar “Vamos correr” | 18,05 s | 12,93 s |
| Escolher Vale na Floresta até `park-ready` | 3,45 s | 2,76 s |
| Escolher Rapidinho no Vale até `park-ready` | 3,32 s | 0,82 s |

As duas builds foram servidas no mesmo servidor HTTP local com gzip. O Chrome 158 headless usou SwiftShader, 960 × 600, cache frio, download de 20 Mbit/s, upload de 5 Mbit/s e latência emulada de 70 ms. Na 0.34.5, as escolhas estavam disponíveis em **0,26 s** de mediana. O PCK terminou de baixar em **3,01 s** e o WASM, em **6,04 s**. A inicialização do WASM terminou em **6,12 s** e a montagem da Floresta em `_ready()` consumiu **1,76 s**. Esses valores são medianas de marcos que podem se sobrepor. O benchmark público da 0.34.3 e o Moto G56 usam ambientes diferentes.

Para repetir, leia as entradas `resource` no Performance Timeline do iframe e alinhe seu `timeOrigin` com o da página. O iframe marca `godot:init`. A página marca `race:menu`, `race:play-ready`, `race:start` e `race:control-ready`. A mensagem `park-ready` informa a pista, o rival e a duração da montagem em `setupMs`. [Carregador Web](../../game/shell.html), [menu](../../web/game.js), [cena da corrida](../../game/race/race.gd).

O teste no Chrome conferiu capturas dos quatro dinos nas duas builds. Ao escolher Vale, Dupla e Velociraptor durante o download, o primeiro e único `park-ready` chegou com a configuração escolhida. A tecla A mudou a posição lateral do jogador 1 depois que o controle foi liberado.

Em outra série, o navegador acionou “Vamos correr” assim que o botão foi habilitado na Floresta. A contagem regressiva foi incluída no tempo até o controle. Foram três execuções por variante no mesmo perfil local.

| Variante | Tempo até habilitar o botão | Tempo desde a navegação até o controle |
| --- | ---: | ---: |
| 0.34.4 | 18,58 s | 33,08 s |
| 0.34.4 sem o dino antigo | 17,24 s | |
| 0.34.5 | 11,87 s | 26,96 s |

As três aberturas da variante sem o dino antigo foram 19,24 s, 16,55 s e 17,24 s. Houve sobreposição com a faixa de 17,70–18,89 s da 0.34.4 original. A 0.34.5 teve três aberturas entre 11,83 e 11,88 s nessa série.

## Moto G56 físico

Em 27 de novembro de 2026, o Moto G56 5G rodou as duas builds locais via USB no Chrome 158.0.8127.42 e Android 16. A área da página em retrato mediu 523 × 1027 px CSS, com DPR 2,0625. O servidor local usou gzip e o navegador limitou o download a 20 Mbit/s, o upload a 5 Mbit/s e emulou 70 ms de latência. O cache HTTP ficou desabilitado na aba de teste. Cada rodada começou com uma nova navegação. O botão foi acionado assim que habilitou, e o tempo até o controle inclui a contagem regressiva. Cada troca foi cronometrada da alteração da opção até o respectivo `park-ready`.

| Rodada | Build | Até “Vamos correr” | Até o controle | Floresta → Vale | Rival no Vale |
| --- | --- | ---: | ---: | ---: | ---: |
| 1 | 0.34.4 | 29,27 s | 32,40 s | 7,78 s | 8,99 s |
| 2 | 0.34.5 | 22,88 s | 26,05 s | 8,95 s | 0,13 s |
| 3 | 0.34.5 | 22,77 s | 25,92 s | 8,14 s | 0,15 s |
| 4 | 0.34.4 | 29,69 s | 32,86 s | 11,94 s | 11,45 s |
| 5 | 0.34.4 | 28,89 s | 32,03 s | 11,78 s | 10,76 s |
| 6 | 0.34.5 | 21,84 s | 25,00 s | 8,13 s | 0,07 s |
| **Mediana** | **0.34.4** | **29,27 s** | **32,40 s** | **11,78 s** | **10,76 s** |
| **Mediana** | **0.34.5** | **22,77 s** | **25,92 s** | **8,14 s** | **0,13 s** |

Na 0.34.5, as escolhas ficaram disponíveis em mediana aos **0,43 s**. O PCK transferido caiu de 16,62 MB para 3,16 MB, e a mediana até o fim do último download passou de 13,25 s para 7,24 s. A espera do último download até o botão foi semelhante nas duas builds, com medianas de 15,73 s e 15,58 s. Na 0.34.5, a marca `godot:init` chegou aos 7,41 s, e a montagem da Floresta em `_ready()` consumiu 9,96 s de mediana. A primeira troca para o Vale ainda consumiu cerca de 8 s, com sobreposição entre as faixas observadas.

No piloto da 0.34.5, manter pressionado o controle esquerdo por toque moveu o dino para a esquerda. O Godot registrou nas duas builds a conversão de texturas RGBAFloat para RGBAHalf no aparelho. As seis rodadas completaram os fluxos medidos.

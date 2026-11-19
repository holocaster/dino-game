# Plano de pesquisa: gráficos e próximos jogos

Data: 2026-11-18. Gênero: decisão; profundidade média. Escopo autorizado: pesquisa documental, inspeção do projeto e imagens existentes. Sem alteração do jogo, geração paga, instalação, commit ou publicação.

## Decisão

Quanto esforço e desembolso faz sentido investir para melhorar a apresentação da Corrida dos dinos preservando o navegador, e quais novos jogos poderiam aproveitar essa base depois? A meta não pressupõe realismo nem troca de engine. Público infantil de 3–5 anos e prioridade web vêm dos documentos atuais; não são novas escolhas do usuário.

## Hipóteses falsificáveis

- H1: o projeto já usa geometria/câmera 3D; o visual percebido depende mais da arte, composição e iluminação do que da classificação 2.5D. Refutar se os recursos centrais forem sprites ou houver bloqueio técnico que obrigue reescrita.
- H2: um recorte estilizado pode melhorar mantendo Compatibility/web. Confirmar apenas viabilidade documental; ganho visual/desempenho exigem comparação implementada em aparelhos reais.
- H3: subir resolução de texturas ou habilitar efeitos indiscriminadamente entrega retorno menor que um conjunto coerente de materiais, cenário e animação. Refutar por comparação local controlada; não confundir recomendação com experimento já realizado.
- H4: novos jogos com câmera controlada e interação curta reaproveitam mais a base que mundo aberto/plataforma 3D livre. Verificar dependências locais e referências de produtos; demanda comercial permanece não demonstrada.

## Trabalho anterior

Ler README, configuração Godot/exportação, materiais/shaders/câmera, validações de arte e pesquisas de 2026-11-07, 13 e 16. Não reapresentar recursos entregues como novidades. Separar jogo corrente de conceitos aprovados e capturas históricas.

## Canais e responsabilidades

- Orquestrador: auditoria local somente leitura, Context7 Godot, matriz de esforço/custo com premissas explícitas, síntese e verificação.
- Agente em paralelo A: documentação oficial de renderização/web e exemplos reais de Godot; limites e contraprovas. Escreve somente sources/01–09 e technical.md.
- Agente em paralelo B: pipeline/ativos/licenças/preços públicos e candidatos a novos jogos; fontes primárias, contrapontos. Escreve somente sources/10–19 e opportunities.md.
- Web search/open, Context7 e shell disponíveis. HTML público suficiente; não procurar nem exibir chaves, não consumir APIs pagas. Fal.ai e bibliotecas de assets serão pesquisadas publicamente, sem geração nem compra.

## Fontes e triangulação

Cada fonte aceita terá arquivo próprio, URL, autoria/data quando acessível, trecho literal de até 25 palavras por página, escores 1–5 de credibilidade/atualidade/viés (5 = mais viés), limite de inferência. Fontes técnicas: primárias oficiais. Documentação da mesma organização não conta como três origens independentes. Teses estratégicas precisam de três fontes independentes de tipos distintos; quando não houver, marcar evidência insuficiente. Fatos locais e estimativas de engenharia serão identificados separadamente.

## Oposição e riscos

Buscar: Compatibility sem GI/efeitos; texturas maiores não melhoram arte; gargalos de CPU/draw calls/overdraw; modelos IA exigem reparo/rig; jogos nativos bonitos não comprovam qualidade web; materiais novos podem quebrar recoloração; luz baked e terreno procedural; gráficos não comprovam diversão nem vendas. Custos em R$ serão cenários de horas × taxa hipotética, nunca cotação de mercado. Preços em moeda estrangeira não serão convertidos sem câmbio consultado; itens sem preço verificável ficam sem cotação.

## Critério de encerramento

Base local rastreável; documentação atual do renderer consultada; exemplos reais com plataforma explícita; caminhos incremental/estilizado/reforma comparados com horas, custos, dependências e incerteza; contraposição documentada; fontes arquivadas individualmente; ideias de jogos rotuladas como hipóteses; links locais e índice verificados. Sem benchmark, promessa de FPS ou preferência infantil inventados.

## Encerramento

- 2026-11-18: corpus encerrado em 21 páginas externas + auditoria local, com 22 fichas e índice. Documentação consultada em 4.7 via Context7/web; Godot local 4.7.2 conferida.
- Dois levantamentos paralelos e duas leituras adversariais independentes da síntese não apontaram problema material. Orquestrador reabriu amostras de renderer, produto, asset e preço, além do artigo e estudo que leu diretamente.
- Verificação documental passou: IDs/índice/escores, fichas citadas, citações curtas, links locais, somas de horas/bytes e espaços finais. Hipóteses de ganho e performance permanecem indeterminadas.
- Somente arquivos novos nesta pasta; sem alteração do jogo, testes de runtime, benchmark, mídia gerada, gasto, commit ou push.

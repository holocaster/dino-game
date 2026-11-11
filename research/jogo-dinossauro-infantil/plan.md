# Plano de pesquisa: jogo de dinossauro infantil

Data: 2026-11-07. Profundidade: média. Gênero: decisão comparativa.

## Decisão

Escolher tecnologia e formato para um jogo de dinossauro sem violência, para crianças de 3 a 5 anos, distribuído primeiro por um link no navegador. Não implementar o jogo nesta pesquisa.

O diretório foi inspecionado: não há código, documentação ou pesquisa anterior disponível, apenas diretórios de integração. Não existe stack ou versão instalada que condicione a escolha.

## Hipóteses falsificáveis

- H1: uma exploração pequena, com câmera e objetivos simples, atende melhor à proposta de brincar sem pressão do que uma corrida obrigatoriamente cronometrada. Seria enfraquecida por evidência de dificuldade de orientação/controle ou preferência consistente das crianças por corrida. A preferência final exige teste com crianças.
- H2: Phaser com TypeScript é uma boa escolha inicial se o jogo puder ser 2D e web; seria rejeitada se os requisitos essenciais exigirem 3D, recursos incompatíveis ou suporte inadequado ao dispositivo alvo.
- H3: Godot ou outro motor 3D passa a ser justificável se 3D for requisito; limitações reais de exportação e desempenho web podem invalidar essa opção.
- H4: um mundo aberto amplo traz escopo que não é necessário para validar a proposta; seria enfraquecida se uma mecânica indispensável depender desse tamanho/liberdade.

## Comparação

Formatos: corrida (distinguir runner automático de corrida com direção), exploração em mundo aberto e exploração em mapa pequeno. Tecnologias: Phaser, Godot, Unity e Babylon.js/Three.js como alternativas web 3D. Critérios: adequação etária, controle/câmera, experiência sem violência, desempenho e acesso web, escopo de produção, licença/custos e possibilidade de evolução. Não atribuir notas numéricas ou prazos sem medição.

## Fontes e canais

- Context7 para documentação atual dos motores/bibliotecas; conferir páginas oficiais na web para as referências finais.
- Fontes primárias para limitações técnicas e preços/licenças; pesquisas acadêmicas e trabalhos originais de organizações de infância para desenvolvimento e design.
- Páginas originais de jogos apenas como exemplos, sem inferir eficácia pedagógica ou adequação automática.
- Não ler chaves, arquivos de credenciais ou ambientes secretos: web pública e Context7 são suficientes. Canais disponíveis: busca/fetch web, Context7, filesystem. Não há necessidade de API paga, transcrições ou scraping autenticado.

## Trabalho paralelo e propriedade

- Pesquisador técnico: fontes 10–29 e memorando técnico; somente esses arquivos.
- Pesquisador de infância/design: fontes 30–49 e memorando de design; somente esses arquivos.
- Orquestrador: fontes 01–09 e 50–69, plano, índice CSV, achados, relatório e atualização.

Os pesquisadores trabalham no mesmo diretório e não devem sobrescrever alterações alheias. Cada fonte recebe arquivo separado com URL, data de consulta, tipo, trechos curtos literais, credibilidade/recência/viés e limites. Trechos citados no conjunto de entregáveis respeitam o limite de 25 palavras por página.

## Contestação obrigatória

Buscar: vantagens de corrida com um botão para pré-escolares; problemas de exploração livre e câmeras 3D; limites de Phaser; compatibilidade móvel e exportação web de Godot/Unity; condições em que uma equipe experiente deve manter seu motor. Não confundir uma inferência de engenharia com resultado experimental. Triangular cada tese principal com pelo menos três fontes independentes e de tipos diferentes; quando impossível, declarar evidência insuficiente.

## Riscos e lacunas

- Desconhecidos: 2D versus 3D, dispositivos reais, orçamento, experiência da equipe e preferências das crianças.
- Navegador em tablet não garante desempenho ou suporte homogêneo.
- Motor não determina violência: mecânicas, som, arte e consequências precisam ser avaliados.
- Não prometer benefícios cognitivos, segurança clínica ou preferência universal.
- Políticas comerciais/documentação podem mudar; registrar consulta e alvos de atualização.

## Critérios de parada e verificação

Encerrar quando houver comparação defensável de formato e stack, evidência contrária considerada, fontes verificadas e lacunas explícitas. Preferir 12–20 fontes úteis, sem preencher quota com fontes redundantes. Registrar recomendação condicional e um protótipo mínimo para validar as hipóteses, sem construir código ou estimar prazo fictício. Validar links locais, correspondência do índice e presença de evidência em cada fonte.

## Histórico

- 2026-11-07: escopo confirmado pelo usuário: 3–5 anos e navegador por link; pesquisa iniciada.
- 2026-11-07: concluídas duas frentes paralelas e busca adversarial; 19 fontes úteis preservadas. Memorandos intermediários incorporados ao relatório e removidos para evitar duplicação.
- 2026-11-07: acrescentada NAEYC como orientação institucional; não atribuir a ela prova experimental de gênero. Índice mantém avaliações qualitativas ou escalas 1–5 conforme cada fonte; em escalas numéricas, viés maior significa maior risco. Não são notas de motores.
- 2026-11-07: fontes centrais reabertas pelo orquestrador; relato e comparação revisados criticamente pelas duas frentes, sem correções pendentes. Validação automática: 19 URLs únicas no índice e nos respectivos arquivos, evidência literal presente, até 25 palavras citadas por fonte e 36 links locais válidos.
- 2026-11-07: limitações finais: sem protótipo, benchmark ou teste com crianças; 2D e preferência de autoria permanecem decisões para implementação. H1/H4 são inferências; não foi comprovada superioridade universal de formato ou motor.
- 2026-11-07: pergunta adicional sobre 2.5D respondida por extensão curta inline, com Context7 e duas fontes técnicas novas (21 no total). Registrado delta sobre isometria 2D em Phaser e cena 3D/híbrida com câmera fixa em Godot. Não houve escolha final de estilo; índice e links validados.

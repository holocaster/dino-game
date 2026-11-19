# Insumos: arte, custo de aquisição e ideias futuras

Pesquisa em 2026-11-18. Este documento alimenta a síntese principal; não autoriza implementação ou compras. Fontes S10–S17 foram abertas. Preços são instantâneos públicos e não cotações de produção.

## O que dá para comprar ou reutilizar

| Candidato | Aquisição observada | Possível encaixe | Trabalho que continua existindo |
|---|---|---|---|
| Kenney Nature Kit [S10](sources/10_kenney_nature.md) | Gratuito, CC0; 330 arquivos 3D | Base simples de vegetação/rochas | Selecionar silhuetas, harmonizar cores/escala, substituir geração atual, validar câmera e desempenho |
| Quaternius Ultimate Stylized Nature [S11](sources/11_quaternius_nature.md) | Gratuito, CC0; 63 modelos, glTF, texturas e mapas normais | Candidato a cenário mais rico preservando cartoon | Avaliar densidade, materiais, vento, sombra e correspondência com dinos |
| Poly Haven [S12](sources/12_poly_haven.md) | Assets CC0 | Materiais e ambiente de iluminação escolhidos seletivamente | Adaptar estética e orçamento de textura; não despejar fotorealismo no cenário cartoon |
| KayKit Forest [S13](sources/13_kaykit_forest.md) | Free; EXTRA US$9.99; SOURCE US$14.99 | Um conjunto de cenário coerente, com atlas de gradientes | Direção de arte, composição, conversão/importação e integração; preços não pagam esse trabalho |
| Tripo H3.1 image-to-3d [S14](sources/14_fal_tripo_preco.md) | US$0.20–0.40 base por tentativa, adicionais declarados | Testar um modelo candidato no pipeline que já existe | Seleção/rejeições, reparo, UV, rig, animação, cores, acessórios e validação |

Não é necessário gastar muito com licença para testar uma floresta mais bem composta. Essa conclusão usa três criadores independentes (Kenney, Quaternius, Kay); ainda é apenas evidência comercial primária, não triangulação de tipos diversos nem prova de melhoria perceptiva. O valor no jogo permanece uma hipótese até comparar um trecho.

Uma textura 2K ruim continua ruim ao ampliar para 4K. Isso é julgamento de arte; S13 demonstra somente que um pack estilizado real pode basear o acabamento num atlas 1024². Não demonstra superioridade universal do low-poly nem substitui medição de memória. Recomendo escolher uma família principal de assets e adaptar o restante, em vez de misturar livremente catálogos. Ganho e economia exatos não foram medidos.

### Custo que o preço por geração esconde

O projeto já registra geração rejeitada por postura bípede no tricerátopo e scripts próprios de rig em `art/fal/triceratops-generation.json`, `scripts/rig_triceratops.py` e `scripts/rig_bipeds.py`. Logo, o próprio histórico local prova que gerar malha não encerra o trabalho. Não extrapolar a partir de uma rejeição uma taxa de falha estatística.

Pelo preço de S14, dez tentativas standard seriam US$3.00 apenas de inferência image-to-3d. Isso ilustra a diferença entre custo de máquina e horas de acabamento; não é promessa de obter dez personagens úteis por esse valor. Sem preço verificado do artista/escopo, nenhuma cotação de mão de obra é sustentada por essas fontes.

## Novos jogos: shortlist para a etapa seguinte

O usuário pediu ideias posteriormente. Esta é uma lista inicial, sem estudo de demanda ou compromisso de público além da hipótese atual de 3–5 anos. Nenhum nome ou combinação abaixo é apresentado como inovação inédita. Não se presume que o novo jogo deva usar dinossauros; eles são uma forma de testar maior reaproveitamento.

| Ideia nova de produto | Núcleo jogável e primeiro recorte | Reuso real possível | Trabalho novo e risco | Dificuldade relativa |
|---|---|---|---|---|
| **Amigos do Parque** | Cuidar de um dino: escolher fruta, oferecer água e brincar com um objeto; um personagem/clareira | `game/park/feeding.gd`, `companion.gd`, modelos/animações/cenário | O legado de alimentação já existe; o produto novo precisa loop e reações próprias, sem fome/punição diária. Novos gestos, fluxo e toque | Menor dentre candidatos, com auditoria da cena antiga antes |
| **Fotossafári dos Dinos** | Passeio guiado que para em três pontos; tocar para fotografar uma reação e montar álbum | Cenários, câmera acompanhada, dinos, sons, padrão do álbum atual | Enquadramento assistido, eventos, captura/registro; imagem grande/persistência precisa orçamento. Sem exigir mira precisa | Baixa a média |
| **Pequenos Paleontólogos** | Escovar três peças grandes numa bancada e encaixá-las numa silhueta; descobrir o dino animado | Apresentação dos dinos, sons e controles web | Escavação/drag-and-drop assistido, modelo de ossos e tolerância de encaixe; não é corrida reskinnada | Média |
| **Jardim de Brincar** | Plantar em três canteiros grandes e regar; planta cresce e atrai um visitante | Vegetação/cenário, dinos visitantes, recoloração e feedback | Estados visuais de crescimento e manipulação clara; evitar simulação de ecossistema, economia e espera real | Média |
| **Ajuda aos Amigos** | Três encontros leves: devolver fruta, abrir passagem e acompanhar filhote até casa | Câmera controlada, companheiro, terreno e animação de caminhada | Estados e navegação fora da pista, clareza de objetivo, novos gestos. Sem ferimentos/perseguição; risco de expandir para aventura grande | Média a alta |

Referências de existência: Sago Mini Dinosaurs oferece exploração/escavação [S15](sources/15_sago_dinosaurs.md); Yateland oferece resgate [S16](sources/16_yateland_rescue.md). Não são provas de preferência pelos nossos recortes. Fotossafári e jardim são propostas de produto derivadas dos recursos locais, com evidência externa insuficiente neste recorte. A ordem é julgamento de escopo, não ranking de mercado.

Separar os produtos dos recursos já entregues: fruta, Filhote, aparência, álbum e Dupla já estão na corrida; a cena antiga de parque também já contém alimentação e descobertas. Apenas reativar essas cenas não constitui por si um jogo novo bem resolvido. Novidade precisaria vir de intenção clara e interação principal diferente.

## Contestação e limites

1. **Por que melhorar gráficos se a brincadeira ainda não foi observada?** A motivação do usuário basta para investigar apresentação, mas não para prometer retenção. S17 reforça observar agência/competência, sem testar diretamente o público de 3–5 ou a nossa arte.
2. **O pacote barato resolve sozinho?** Não. Ele limita aquisição, enquanto importação, estilo, câmera e performance permanecem. Um pack bonito na vitrine pode destoar dos personagens e exigir mais ajuste que geometria simples própria.
3. **IA torna a arte praticamente grátis?** Só parte do cálculo. O histórico local já contém rejeição e rig artesanal; geração a centavos não representa todo o pipeline.
4. **Novo jogo deve ser 3D livre?** Não há evidência dessa necessidade. A base beneficia câmera controlada; um novo movimento livre exige avaliar navegação e interação, sobretudo no toque. A ideia de maior reuso é hipótese de arquitetura, não medição de tempo.

Não fiz downloads, importações, benchmarks, geração, compras ou teste com crianças; não auditei termos completos nem solicitei cotação profissional. As ideias e a economia de trabalho ainda precisam de recorte e validação.

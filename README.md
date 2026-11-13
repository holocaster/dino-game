# Corrida dos dinos

Corrida infantil em **Godot + GDScript**, sem violência: uma volta contra o amigo verdinho, avanço automático e frutas que dão impulso temporário. Na versão **0.27.0**, você escolhe entre três amigos com personalidades diferentes ou um passeio tranquilo sozinho, e ganha adesivos e cores para o seu dino. Há poças com respingos, pássaros e dinos torcendo com bandeirinhas. Uma fruta dourada ajuda quem ficar para trás. Quanto mais rápido o dino, mais ele solta poeira, rastro colorido e faíscas. Escolha tricerátopo, T-rex ou velociraptor, na floresta, na praia ou no vale, uma pista longa de três voltas.

Execute `npm run dev` e abra [o jogo](http://127.0.0.1:4173). A exportação web está incluída; jogar não exige instalar Godot ou dependências.

- Escolha seu dino, a pista e com quem correr; toque em **Vamos correr** para iniciar a contagem.
- Amigos: **Dorminhoco** se distrai com passarinhos, **Brincalhão** corre na medida e **Rapidinho** é um desafio. **Sozinho** é um passeio tranquilo, sem rival e com uma ajudinha para alcançar frutas.
- Cada volta pode render adesivos; juntar adesivos libera novas cores para o dino. O progresso fica salvo neste navegador.
- Segure as setas esquerda/direita do teclado ou os botões da página para mudar de lado livremente.
- Os dinos deslizam ao encostar; troncos, pedras e bordas da pista bloqueiam a passagem.
- Encoste nas frutas para acelerar por alguns segundos, com limite de bônus na floresta e na praia. Elas reaparecem para o outro corredor; cada dino coleta cada fruta uma vez por volta.
- Quatro trechos oferecem duas sequências equivalentes, que se encontram numa fruta central. Escolha um lado e volte ao centro para completar a sequência. As posições são sorteadas a cada corrida.
- Quem ficar cinco unidades atrás pode encontrar uma fruta dourada na sua linha: impulso maior por quatro segundos e brilhos ao redor do dino. Vale para os dois corredores. No vale ela aparece a quinze unidades e é mais forte: impulso maior por seis segundos.
- Atravesse poças para fazer respingos; pássaros voam e cantam, e dinos na lateral pulam e agitam bandeirinhas para os corredores.
- No vale, cada fruta ou seta de impulso acelera um pouco menos que a anterior, sem limite, e a velocidade cai devagar. Cada reta tem uma seta do lado oposto às frutas; ao passar por ela aparece "Impulso!". O rodapé mostra "Volta N/3"; ao cruzar a linha de chegada aparece um aviso grande da volta, e a última volta tem fanfarra própria.
- Use pausa ou reinício no topo. Sair da aba pausa a corrida; toque em **Continuar** ao voltar.
- Ao completar a volta, os dois comemoram. Corra de novo ou escolha outro dino e pista; essa escolha também está disponível na pausa. Não há persistência.

[Rivais, modo tranquilo e recompensas](art/modes-validation.md) · [Poças e torcida](art/scenery-validation.md) · [Fruta dourada](art/recovery-validation.md) · [Caminhos de frutas](art/fruit-paths-validation.md) · [Modelos e texturas](art/bipeds-validation.md) · [Próximas melhorias](art/next-steps.md) · [Colisões](art/collision-validation.md) · [Changelog](changelog.md).

## Desenvolvimento

Projeto Godot em `game/` (cena inicial `race/race.tscn`); página e exportação web em `web/`. Pastas do projeto Godot, por contexto:

- `race/`: regras da corrida (`race_state.gd`), cena, cenário da pista.
- `park/`: passeio de exploração anterior (`park.tscn`), aberto pelo editor.
- `world/`: terreno, árvores e temas floresta/praia/vale.
- `dinos/`: carregamento dos modelos (em `assets/`) e shader de cor.
- `common/`: base das duas cenas (câmera, malhas simples, sons de passos, ponte com a página).

Use **Godot 4.7.2** no PATH, com os templates Web correspondentes para exportar:

```sh
npm test
npm run test:godot
godot --headless --path game --export-release Web
```

`npm test` executa 20 testes Node. `npm run test:godot` executa 23 scripts Godot e dois testes Python. `npm run test:race` verifica perfis de rival, modo tranquilo, cores, poças, pássaros, torcida, recuperação dourada, caminhos de frutas, equilíbrio, seis combinações de dino/pista, comportamento fixo da floresta e da praia, regras do vale, corrida, rival e colisões; `npm run sim:valley` mede o equilíbrio do vale (demorado); `test:collision`, `test:rival` e `test:gait` permitem verificações específicas. Toque emulado não substitui testes em aparelhos físicos ou com crianças.

## Arte

Os três modelos foram gerados pela fal.ai. `python3 scripts/rig_triceratops.py` recria o rig do tricerátopo; `python3 scripts/rig_bipeds.py`, os rigs de T-rex e velociraptor. Fontes e parâmetros ficam em `art/fal/`; as texturas usadas no jogo têm 2K. `npm run fal -- MODELO entrada.json` exige Node.js 24+ e `FAL_KEY` em `.env`; gerações consomem créditos.

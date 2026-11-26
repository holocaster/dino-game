# Corrida dos dinos

Corrida infantil em **Godot + GDScript**, versão **0.34.3**: tricerátopo, T-rex, velociraptor e pteranodonte na Floresta, Praia, Vale, Vulcão ou Caverna dos Cristais. Cristais respondem com luz e notas curtas opcionais na Caverna. Avanço automático, frutas e Setas de impulso, poças, caminhos com efeitos diferentes e um Filhote que comemora na chegada, mesmo sem frutas.

Execute `npm run dev` e abra [o jogo](http://127.0.0.1:4173). A exportação web está incluída; jogar não exige Godot nem instalar dependências.

- Escolha espécie, cor e acessório gratuito (sem acessório, boné ou óculos), confira a prévia e toque em **Vamos correr**.
- O pteranodonte voa baixo automaticamente, com asas animadas e os mesmos controles, frutas e colisões dos outros personagens.
- **Rival:** Dorminhoco se distrai, Brincalhão corre na medida e Rapidinho desafia. **Sozinho:** passeio sem rival, com ajuda para alcançar frutas. Use setas esquerda/direita ou os botões de toque.
- **Dupla:** dois humanos no mesmo aparelho, inclusive da mesma espécie. Jogador 1 usa **A/D**, jogador 2 usa **setas**; no toque, cada um tem seu par identificado. Frutas são somadas; quem chega espera o outro, sem vencedor. A ajuda reduz o avanço do líder a partir de 6 m e o limita a 18 m de separação.
- Vulcão tem cratera, lago e escorrimento de lava animada fora do caminho, sem dano ou penalidade.
- Floresta/Praia têm uma volta; Vale/Vulcão têm três por pessoa. No Vale, impulsos têm retorno decrescente. Frutas reaparecem para o outro corredor, uma coleta por dino/volta. A dourada ajuda quem está atrás; Setas dão impulso sem contar fruta.
- Corridas concluídas rendem adesivos e liberam cores. Dupla recebe participação/coleta, sem prêmios competitivos ou de Sozinho. Álbum e duas aparências ficam salvos neste navegador; a corrida em andamento não fica salva.
- Use pausa/reinício no topo ou escolha outra corrida na pausa/chegada. Perder o foco ou ocultar a aba limpa os controles e pausa; toque em **Continuar** ao voltar.

[Personagem voador](art/flight-validation.md) · [Acabamento gráfico e antes/depois](art/graphics-validation.md) · [Caverna dos Cristais](art/cave-validation.md) · [Calibração da Dupla](art/coop-validation.md) · [Changelog](changelog.md).

Feature futura: [versões nativas para Windows, Linux e macOS](docs/briefs/0003-portabilidade-desktop.md).

## Desenvolvimento

Projeto em `game/`, cena inicial `race/race.tscn`; página e exportação em `web/`. Use **Godot 4.7.2** no PATH:

```sh
npm test
XDG_DATA_HOME=/tmp/dino-game-godot-data npm run test:godot
godot --headless --path game --export-release Web
```

A suíte cobre Node, regras/física/câmera/cenário/animações no Godot e rigs em Python. `npm run test:race`, `test:collision`, `test:rival`, `test:gait` e `test:flight` permitem verificações específicas; `npm run sim:valley` mede equilíbrio (demorado).

A exportação completa exige templates Web 4.7.2. Nesta entrega, `godot --headless --path game --export-pack Web ../web/godot/index.pck` atualizou apenas o PCK, reutilizando JS/WASM 4.7.2 existentes; mantenha `fileSizes` e todos os `?v=` sincronizados com `package.json`. Emulação não comprova desempenho físico nem preferência infantil.

## Arte

Modelos gerados pela fal.ai; fontes/parâmetros em `art/fal/`, texturas importadas em até 2K. `python3 scripts/rig_triceratops.py` recria o rig do tricerátopo; `python3 scripts/rig_bipeds.py`, os bípedes; `python3 scripts/rig_pteranodon.py`, o voador. `npm run fal -- MODELO entrada.json` exige Node.js 24+ e `FAL_KEY` em `.env`; gerações consomem créditos.

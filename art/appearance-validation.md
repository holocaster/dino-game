# Aparência — ticket 01

Persistência de dois slots em `dino-race-appearances`; álbum e API de recompensas preservados. A cor antiga migra para o primeiro slot quando ainda não há preferências. Espécie e acessório são gratuitos; cores respeitam os adesivos. O slot 2 fica salvo e recebe comandos, com interface prevista no ticket 03.

Prévia usa o próprio modelo da corrida, no iframe acima do menu rolável. `appearance:<1|2>:<species>:<color>:<none|cap|glasses>` valida toda a mensagem antes de mutar; countdown/corrida, inclusive pausados, rejeitam a nova configuração de aparência. `select` antigo mantém sua validação de estado; `color` mantém a troca puramente visual durante corrida, conforme o contrato legado.

## Encaixes a conferir pelo Main

Todos ligados a `Head` por `BoneAttachment3D`, sem sobrescrever pose. Coordenadas locais ao osso, na escala original do modelo:

| Espécie | Boné (x,y,z) | Óculos (x,y,z) | Largura dos óculos |
| --- | --- | --- | --- |
| Tricerátopo | 0, 0.26, -0.32 | 0, 0.07, -0.49 | 0.52 |
| T-rex | 0, 0.52, -0.13 | 0, 0.38, -0.18 | 0.51 |
| Velociraptor | 0, 0.51, -0.21 | 0, 0.47, -0.23 | 0.47 |

Os encaixes dos óculos de T-rex/velociraptor foram recalibrados na entrega 0.28.0 após inspeção ampliada: as lentes estavam adiantadas no focinho. A posição foi elevada/recuada conforme os olhos no GLB existente; bonés, tricerátopo e larguras ficaram preservados. Main confirmou as duas prévias corrigidas no navegador: [T-rex](previews/release-0.28-glasses-trex.png) e [velociraptor](previews/release-0.28-glasses-raptor.png).

Conferir as nove combinações em idle/prévia e run, frente/lateral, com cor natural e uma cor liberada: boné sobre a cabeça sem atravessar chifres/crista; lentes diante dos olhos, hastes junto às laterais; materiais vermelho/amarelo/azul preservados ao trocar a cor. Confirmar que o acessório continua encaixado após pausa, reinício, menu e recarga. Conferir menu/prévia em 1280×900 e 390×844.

A inspeção de navegador e a calibração final dos encaixes são do Main; existência do nó não é prova visual. Teste Godot amostra transformações reais de idle/run e verifica que a transformação do acessório acompanha a pose animada de Head, além de invariância física, tintura e validação de comandos.

Exportação parcial por `--export-pack Web`: runtime JS/WASM 4.7.2 existente reutilizado, tamanho do pack sincronizado em `web/godot/index.html`. Templates Web completos ausentes. Sem geração paga nem dependências novas.

## Evidência incremental

- `npm test`: 23/23 testes Node passaram, incluindo salvar/carregar duas aparências, migração, álbum preservado, cores bloqueadas, enums desconhecidos, JSON corrompido e storage indisponível. Catálogos de espécie/acessório/cor e versões de cache conferidos entre página e Godot.
- `appearance_test.gd`: nove combinações de modelo, amostras reais de animação idle/run, ausência de corpos adicionais, corpo/atributos/layout de frutas preservados, acessórios sem shader de pele, dois slots e comandos inválidos/ativos rejeitados.
- A suíte anterior revelou que `color` muda o rastro durante a corrida. Esse contrato foi preservado sem alterar o teste; `speed_effects_test.gd` voltou a passar.
- Main inspecionou as seis capturas `.playwright-mcp/appearance-{triceratops|trex|raptor}-{cap|glasses}.png`: bonés sobre a cabeça; lentes e hastes reconhecíveis junto à cabeça/focinho; vermelho/amarelo e lentes escuras preservados na pele azul. `.playwright-mcp/appearance-mobile.png` em 390×844 mostra tricerátopo inteiro com óculos e menu rolável, sem overflow horizontal. Recarga real preservou espécie/acessório.
- Na validação local, CSS e PCK antigos persistiram no cache após recarga comum. Main confirmou a causa carregando assets com query temporária somente no navegador. O bump de versão definitivo permanece no ticket 04.
- Main verificou o ciclo em 390×844: largada com óculos, pausa/menu preservando a aparência; opção sem acessório removeu as malhas (`appearance-mobile-none.png`); boné permaneceu após largada/reinício/pausa/menu. `appearance-mobile-run.png` mostra a haste dos óculos durante corrida vista de trás. As capturas são artefatos locais ignorados; a matriz visual ampliada de corrida faz parte da validação final da feature.
- `XDG_DATA_HOME=/tmp/dino-game-godot-data npm run test:godot`: passou completo, exit 0, 24 scripts Godot e dois testes Python; inclui 72 fingerprints numéricos de Floresta/Praia, Vale, catálogo/modos, corrida física, colisões, câmera e animações. Log local `/tmp/dino-ticket01-godot.log` sem erros/asserts.
- Pack final de 14.776.300 bytes conferido contra `fileSizes`; `git diff --check` sem problemas. Export parcial completou com exit 0; o sandbox bloqueou somente a escuta de rede do editor, sem impedir gerar o pack.

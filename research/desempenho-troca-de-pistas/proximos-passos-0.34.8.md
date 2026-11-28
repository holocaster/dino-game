# Próximos passos depois da 0.34.8

As medições e os resultados desses passos estão no [relatório da 0.34.9](validacao-0.34.9.md).

A 0.34.8 desligou o depth prepass no navegador. A abertura da Floresta no Moto G56 ainda leva cerca de 15 s até `park-ready` e 18 s até o primeiro controle. Os números abaixo vêm de [Depth prepass no navegador na 0.34.8](auditoria-0.34.6.md#depth-prepass-no-navegador-na-0348). Cada item deve ser medido antes de qualquer mudança e comparado em A/B/B/A no aparelho.

## Onde está o tempo hoje

| Etapa da abertura da Floresta | Duração | O que ocupa |
| --- | ---: | --- |
| Download do WASM | até ~7,8 s | 10,19 MB com gzip. O PCK termina antes, em ~5,1 s |
| `godot:init` até o autoload | ~2,2 s | Setup do motor. Inclui 0,36 s de compilação de shaders internos |
| Autoload até `race.gd` `_init()` | ~1,05 s | Carga de `race.tscn` e dos `preload()`, incluindo os quatro GLB |
| `_ready()` | ~0,75 s | Montagem da pista |
| Primeiro quadro | ~2,9 s | Compilação de 44 programas de shader e trabalho de CPU do Godot |

## Ordem proposta

1. **Eliminar a compilação de shaders durante a corrida.** Entre 1 e 6 programas ainda compilam nos dez segundos após a contagem. A Praia e a Caverna registraram 5 cada. Cada programa custa cerca de 40 ms no aparelho e pode causar travadas pontuais. Registre o `shaderSource` desses programas para identificar os materiais, como respingo, partículas, fruta dourada ou comemoração. Depois teste desenhá-los uma vez antes de `park-ready`. Confirme que o primeiro quadro não cresce mais do que a corrida ganha.
2. **Reduzir as variantes de shader do primeiro quadro.** A Floresta usa 9 shaders de material e compila até 5 variantes de cada: base, depth e sombra, com e sem instancing. Candidatos:
   - unificar `StandardMaterial3D` que diferem só em flags, como dois materiais `unshaded`, vertex color e `cull_disabled`;
   - verificar se todo material precisa da variante com instancing;
   - desligar a projeção de sombra em decoração pequena, que remove as variantes de sombra. Isso muda o visual e precisa de aprovação.
3. **Medir a carga de `race.tscn`.** O passo leva ~1,05 s. Separe o custo de cada `preload()` de `runner_model.gd`, que carrega os quatro dinos, e dos torcedores. Se os modelos dominarem, teste carregar primeiro as espécies escolhidas. Este é o item 3 de [Próximas otimizações](proximas-otimizacoes.md#ordem-proposta).
4. **Investigar o setup do motor.** O passo leva ~2,2 s, e só 0,36 s dele está explicado. Use um trace de performance do Chrome no aparelho antes de propor mudanças.
5. **Verificar a leitura de buffers em `_ready()`.** São 72 chamadas `getBufferSubData`, num total de 58 ms. No Compatibility, ler arrays de malha força leitura da GPU. Encontre o chamador. É um ganho pequeno e barato se for trivial.
6. **Investigar a fluidez do Vale.** O Vale ficou em 43,6 FPS, contra 50 a 57 nas outras pistas. Compare a contagem de draw calls e de vértices por pista.
7. **Testar uma prévia imediata na troca de pista.** Este é o item 4 de [Próximas otimizações](proximas-otimizacoes.md#ordem-proposta). Ele melhora a percepção da espera e não muda o tempo até o controle.

## Como medir

As marcas usadas na 0.34.8 ficam fora do repositório, numa cópia do jogo:

- um autoload com `_init()` chamando `performance.mark('godot:autoload', {detail: Time.get_ticks_msec()})`;
- marcas em `race.gd` para `_init()`, entrada e saída de `_ready()` e `RenderingServer.frame_post_draw`;
- `performance.mark('godot:started')` no `then` de `engine.startGame()`.

O runner Playwright conecta ao Chrome do aparelho por CDP, na porta 9236, e aplica 20/5 Mbit/s com 70 ms de latência e cache desabilitado. No iframe, ele envolve `WebGL2RenderingContext.prototype` para cronometrar `getShaderParameter`, `getProgramParameter` e `linkProgram` em cada etapa. O FPS vem de dez segundos de `requestAnimationFrame` no iframe após a contagem.

O runner também precisa pedir `navigator.wakeLock`. Sem isso, o celular bloqueia a tela durante a série, e o jogo pausa na contagem.

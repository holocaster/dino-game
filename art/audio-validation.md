# Áudio — versão 0.7.0

Implementado em 2026-11-10. Sons estilizados sintetizados pela Web Audio API, sem arquivos de mídia, dependências novas ou serviços pagos. Ambiente de vento leve, água conforme a distância do lago, pássaros no bosque, passos, flores, pegadas e alimentação.

A página cria um único AudioContext depois de tocar em “Vamos passear”. O ganho principal começa em 0,22. O alto-falante liga/silencia, com rótulo acessível e estado pressionado. Reiniciar encerra os efeitos anteriores e preserva a opção de silêncio. Ocultar a aba suspende o contexto e cancela os efeitos; retornar retoma o ambiente sem acumular ações. Falha de áudio permite continuar jogando e tentar novamente pelo botão.

Godot envia eventos de deslocamento e interação à página. Os passos usam distância percorrida, sem som parado ou rajadas após quadros lentos. As quatro mordidas acompanham a mastigação e a redução da fruta; a recompensa toca depois da alimentação. O driver Dummy do Godot continua intencional: o áudio pertence à página web, e não à exportação nativa.

## Verificação

- `npm test`: 9 testes aprovados.
- `npm run test:godot`: 6 scripts aprovados, incluindo `tests/audio_test.gd`: repouso, passos, descobertas, pegar fruta, quatro mordidas, recompensa, proximidade do ambiente e interrupção por reinício.
- `web/audio.test.mjs`: renderização real com OfflineAudioContext no Chromium. Todos os seis efeitos, água e pássaros acrescentaram sinal ao ambiente; fontes concluídas foram liberadas. Amostras finitas, pico máximo observado próximo de 0,024, sem saturação. Silêncio e pausa zeraram a saída depois da transição; reinício cancelou efeitos e reativação restaurou o sinal.
- Na exportação web: nenhum AudioContext antes de iniciar; silêncio antes do início preservado; alimentação emitiu 1 evento de pegar, 4 mordidas e 1 recompensa; reinício manteve um único contexto e a opção de silêncio.
- Eventos de visibilidade simulados suspenderam e retomaram o contexto real, preservando o silêncio. Ausência de AudioContext simulada não bloqueou o jogo; restaurar a API e tocar no alto-falante recuperou o áudio.
- Interface conferida em 320, 390 e 1180 pixels, sem transbordamento horizontal. [Celular, 320 px](audio-mobile.png) · [Desktop](audio-desktop.png). Console sem erros ou avisos.
- Pack web reexportado com Godot 4.7.2 e identificação 0.7.0, com 6.054.424 bytes.

Para repetir a renderização, execute `npm run dev`, abra o jogo e use o console do navegador:

```js
await (await import('/audio.test.mjs')).runAudioChecks()
```

## Limites

A síntese e os controles foram verificados no Chromium automatizado. A intensidade percebida e o timbre ainda precisam ser ouvidos em alto-falantes e fones reais, inclusive em celulares. Safari/iOS e testes com crianças não foram realizados. A versão nativa do Godot permanece sem áudio.

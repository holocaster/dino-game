# Plano do benchmark Web em Godot

A decisão é identificar quanto a Corrida dos dinos pode reduzir a espera inicial e quais jogos dão uma referência para troca de pista. O comparativo usa jogos públicos de corrida 3D feitos em Godot, com prioridade para arte estilizada, seleção de pista e controle simples. A produção serve de referência do jogo. Resultados locais anteriores ficam com suas condições de medição originais.

## Hipóteses

1. A espera até a primeira tela utilizável da Corrida dos dinos em produção excede a mediana dos comparáveis prospectados sob as mesmas condições.
2. Um jogo que transfere menos bytes de motor e conteúdo pode mesmo assim demorar mais para apresentar a primeira tela utilizável. Um par invertido na amostra é evidência a favor.
3. Pelo menos um comparável com seleção de pista demonstra uma transição visivelmente mais rápida sob a mesma configuração de teste.

## Método e corte

- Confirmar motor, modalidade e disponibilidade em páginas dos autores. Usar os jogos publicados para a cronometragem e manter benchmarks publicados com outros métodos como contexto.
- Medir do pedido do HTML do jogo (embed no itch.io) à primeira tela do jogo que exibe menu utilizável ou corrida. A página de catálogo e a decisão do usuário de clicar em Run game ficam fora do intervalo.
- Medir a transferência do WASM e do pacote separadamente. Usar o mesmo navegador, perfil de rede, resolução e renderizador em todas as amostras principais. Abrir um contexto com cache vazio para cada execução e alternar títulos.
- Validar o marco final por captura de tela. Usar mudanças de pista para as quais o início e o fim possam ser identificados, e registrar separadamente as transições que exigem iniciar partida.
- Buscar benchmarks publicados, implementações com carregamento incomum e documentos da plataforma sobre o que significa uma abertura jogável.
- Encerrar com três comparáveis jogáveis ou identificar os bloqueios por título. Diferenças de escopo, servidor, CDN, FPS e marcos finais limitam a extrapolação. Repetir quando houver nova versão ou a ordem dos jogos depender de uma única execução.

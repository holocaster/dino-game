# Dino Race

Jogo infantil de corrida de dinossauros: o jogador escolhe dino, pista e rival numa página web e corre numa cena Godot embutida.

## Language

### Corrida

**Corrida**:
Uma partida do início (contagem regressiva) até a chegada de um dos corredores.
_Avoid_: partida, jogo

**Pista**:
O circuito fechado onde a corrida acontece: Floresta, Praia ou Vale.
_Avoid_: mapa, fase, circuito

**Vale**:
Pista longa em formato de estádio, com retas compridas e curvas abertas, corrida em várias voltas.
_Avoid_: estádio, grande circuito, pista longa

**Volta**:
Uma passagem completa pela pista; Floresta e Praia têm uma volta, o Vale tem três.
_Avoid_: lap

**Corredor**:
Quem disputa a corrida: o dino do jogador ou o rival.
_Avoid_: piloto, competidor

**Rival**:
O dino controlado pelo jogo, com uma personalidade (Dorminhoco, Brincalhão, Rapidinho); ausente no modo Sozinho.
_Avoid_: amigo, oponente, bot, friend

### Velocidade

**Impulso**:
Aumento temporário de velocidade ganho ao pegar uma frutinha ou passar numa seta de impulso.
_Avoid_: boost, turbo

**Frutinha**:
Fruta comum na pista que dá impulso ao corredor que a pega primeiro.
_Avoid_: item, power-up

**Fruta dourada**:
Fruta que aparece só à frente de quem ficou para trás e dá um impulso forte.
_Avoid_: fruta de recuperação, recovery

**Seta de impulso**:
Marca no chão das retas do Vale que dá o mesmo impulso de uma frutinha a quem passa por cima.
_Avoid_: boost pad, acelerador

**Sequência**:
Quantas frutinhas ou setas o jogador pegou seguidas sem deixar o impulso acabar.
_Avoid_: combo, streak

**Nível de velocidade**:
Faixa (0 a 3) do quanto o corredor está acima da sua velocidade base, mostrada pelo rastro.
_Avoid_: tier

**Retorno decrescente**:
Regra do Vale em que cada impulso soma menos quanto mais rápido o corredor já está, sem teto fixo.
_Avoid_: sem limite, velocidade infinita

### Recompensas

**Acessório**:
Elemento visual opcional usado pelo dino, como boné ou óculos, sem alterar seus atributos.
_Avoid_: equipamento, upgrade

**Adesivo**:
Conquista guardada no navegador ao terminar uma corrida que cumpre sua condição.
_Avoid_: troféu, medalha, conquista

**Cor**:
Pintura do dino liberada pela quantidade de adesivos.
_Avoid_: skin

## Decisions

- Velocidade com retorno decrescente vale só no Vale; Floresta e Praia mantêm o teto fixo de impulso (ADR proposto no brief 0001).
- Nenhum modelo GLB novo para pistas: cenário gerado por código com os geradores existentes.
- Toda versão `?v=` dos arquivos web acompanha a versão do `package.json` (garantido por teste).

# 07 · CrazyGames e o marco de abertura

- Documentação primária da plataforma, sem data de publicação indicada, consultada em 2026-11-26. [Getting to the First Frame](https://docs.crazygames.com/resources/getting-to-the-first-frame/)
- Notas de 1 a 5. Credibilidade 5, recência 4, independência 4.

> On CrazyGames, we track first-load time and size up to the moment your game calls the SDK gameplayStart method.

A plataforma descreve `gameplayStart` como o início de uma atividade real, como um tutorial jogável. Distingue a transferência de arquivos, o início da engine, o processamento de recursos e o código de inicialização. Esses marcos ajudam a explicar por que ver o canvas ou terminar o download pode anteceder uma experiência utilizável em segundos.

Limites. É uma definição operacional da plataforma, com o marco sinalizado pelo código de cada jogo. A página não fornece uma distribuição de tempos para corridas 3D em Godot. O benchmark local observa a primeira tela utilizável e, onde possível, o início da corrida, sem pressupor equivalência entre esses dois eventos.

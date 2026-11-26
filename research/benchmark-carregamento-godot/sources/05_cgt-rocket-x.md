# 05 · CGT Rocket X Racer

- Fonte primária de desenvolvimento, publicada em 2026-10-28 e consultada em 2026-11-26. [Experimento de carregamento do autor](https://dev.to/cgtrocketx_dev/our-godot-web-build-drew-its-first-frame-at-15-s-but-showed-a-usable-screen-at-103-s-heres-14lj)
- Corrida arcade 3D com mudanças de faixa e voo, para desktop no navegador. [Página do desenvolvedor](https://cgtmonster.itch.io/cgt-rocket-x-racer)
- Notas de 1 a 5. Credibilidade 4, recência 5, independência 3.

> A first visit used an empty profile, and a repeat visit used the same profile with cache.

O estudo usou Godot 4.7.2, export WebGL sem threads, Chrome 156 headless em Linux com 8 vCPUs e renderização SwiftShader. Os arquivos vieram de servidor local em loopback, sem limitação de rede. Foram três execuções por variante, com medianas contadas desde a navegação.

| Build | Primeiro quadro WebGL | Interface utilizável | Cena pronta segundo o autor |
| --- | ---: | ---: | ---: |
| A, versão pública no momento do experimento, cache frio | 1,527 s | 10,344 s | 11,196 s |
| A, visita repetida | 1,047 s | 9,768 s | 10,612 s |
| B, só retira a sobreposição quando a cena fica pronta, cache frio | 1,527 s | 5,444 s | 8,002 s |
| C, também usa um menu inicial e pacote principal separado, cache frio | 1,646 s | 1,647 s | 5,972 s |

O marco do autor combina a cena iniciada, o conteúdo carregado e a remoção da sobreposição. Ele ocorre antes do menu final ou da primeira entrada na corrida. Os builds B e C ainda eram experimentos locais quando o artigo saiu. A versão C registrou uma pausa de 1,2 s entre a interface visível e a cena pronta. Na exportação sem threads testada, `load_threaded_request()` levou 413 ms para retornar, em mediana.

Limites. Estudo publicado pela própria equipe, com amostra pequena e uma configuração. A rede pública, o dispositivo móvel e a troca de pista exigem medições próprias.

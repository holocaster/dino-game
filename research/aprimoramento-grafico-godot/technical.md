# Parecer técnico e referências 3D

Data: 2026-11-18. Pesquisa documental; nenhum teste de desempenho ou mudança executados. Fontes S01–S09 em `sources/`. Documentação aberta na versão **4.7**, compatível com a família declarada localmente; isso não certifica o executável/template 4.7.2 instalado.

## Limite verdadeiro

O projeto já usa `Camera3D`, `MeshInstance3D`, terreno de malha e luz com sombra. Logo, enquadramento/controle limitado não impedem arte 3D melhor. É uma observação do código local, não argumento de marketing da engine: `game/race/race.gd:37`, `game/common/dino_scene.gd:20`, `game/world/forest.gd:113`.

A restrição da distribuição atual é **navegador + Compatibility**. A Godot 4.7 não disponibiliza Forward+/Mobile na web; trocar uma configuração não transporta o renderer avançado ao browser. [S01](sources/01_godot_renderers.md), [S02](sources/02_godot_web.md).

| Técnica | Compatibility 4.7 | Consequência neste projeto |
| --- | --- | --- |
| Luz direcional e sombras | Disponíveis; já usadas | Melhorar direção/contraste e alcance antes de multiplicar luzes |
| MSAA 2x/4x | Disponível | Candidato para bordas; medir antes de adotar [S04](sources/04_godot_antialiasing.md) |
| SSAO | Simplificado, desde 4.6 | Possível teste de contato/volume; não assumir ausência histórica [S05](sources/05_godot_environment.md) |
| Glow | Implementação reduzida própria | Possível para lava/fruta; não equivale a todos os controles Forward+ [S05](sources/05_godot_environment.md) |
| Fog de profundidade/altura, céu e tonemapping | Disponíveis | Podem organizar profundidade/paleta [S01](sources/01_godot_renderers.md) |
| LightmapGI | Renderiza lightmap pré-calculado | Exige UV2, bake externo e geometria estável [S03](sources/03_godot_lightmap.md) |
| SDFGI/VoxelGI, SSR, neblina volumétrica, TAA/FSR2, Decal | Ausentes neste renderer | Evitar usá-los como base de promessa web [S01](sources/01_godot_renderers.md) |

## Dependências ocultas de uma melhoria

1. O shader `game/dinos/dino_tint.gdshader:7` converte a textura para luminância e aplica a cor escolhida, com rugosidade fixa. Adicionar mapas detalhados ao GLB não garante que apareçam nos dinos recoloridos: é preciso revisar e validar a rota `_tint` em `race.gd:178`, mantendo as cores e diferenças entre jogadores. Isso é leitura local, não teste visual.
2. O chão usa cores de vértice, geradas por código. Textura de terra não entra por simples troca de arquivo; será preciso definir UV/triplanar ou material compatível com a geração. Lightmap é etapa adicional de produção, não primeiro ajuste gratuito.
3. Vegetação densa pode aumentar geometria, chamadas de desenho e transparência. MultiMesh/LOD são alternativas quando houver medição que justifique; instanciamento automático de Forward+ não deve ser presumido no Compatibility. [S06](sources/06_godot_performance.md).

## Referências concretas

- [DOGWALK](https://blenderstudio.itch.io/dogwalk): Blender/Godot, materiais com aspecto de papel e volume artesanal. Mostra quanto a identidade artística importa. A página oferece **Windows/macOS/Linux**, sem apresentar build HTML5. [S07](sources/07_dogwalk.md).
- [Pingo Adventure](https://orb-square.itch.io/pingo-adventure): 3D cartoon, vegetação responsiva e física com personalidade; página do autor identifica Godot. **Windows/Linux**. Referência de acabamento, não de custo local. [S08](sources/08_pingo_adventure.md).
- [TailQuest Defense](https://store.steampowered.com/app/824090/TailQuest_Defense/): cenário colorido e coop; ferramentas declaradas incluem Godot/Blender. **Windows/Linux**, requisitos de placa dedicada; portanto não é prova de equivalência em web móvel. [S09](sources/09_tailquest.md).

Esses produtos sustentam a existência de apresentações 3D variadas na engine. Não demonstram que um ajuste de configuração reproduza o resultado, que a equipe tenha orçamento semelhante, nem que o produto atual rode assim em celulares.

## Contraprova e confiança

Há suporte técnico para um recorte estilizado no Compatibility, mas a tese de que uma determinada combinação entrega melhor retorno permanece **inferência de engenharia, com evidência insuficiente de comparação local**. Se a aparência desejada depender de GI dinâmica, SSR e DOF, versão nativa/Forward+ vira outra opção de produto com nova validação. Se puder ser alcançada com formas, texturas de baixa frequência, luz e animação, trocar engine não é pré-requisito.

Não baixei jogos nem executei benchmarks; disponibilidade documental não garante FPS, aparência ou estabilidade em aparelhos reais.

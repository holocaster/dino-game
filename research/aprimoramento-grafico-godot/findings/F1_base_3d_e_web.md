# F1 — A base já é 3D; web é a restrição de renderer

Fato local: Camera3D em perspectiva, malhas com textura/skin e luz com sombra. Não há conversão estrutural de sprites para 3D a estimar. [S20](../sources/20_auditoria_local.md).

Documentação 4.7: export web usa Compatibility/WebGL2; recursos de Forward+ não se tornam disponíveis no navegador por troca de configuração. [S01](../sources/01_godot_renderers.md), [S02](../sources/02_godot_web.md). SSAO simplificado/glow/MSAA estão disponíveis, contrariando fontes antigas. [S04](../sources/04_godot_antialiasing.md), [S05](../sources/05_godot_environment.md).

Confiança alta nesses fatos; indeterminada no ganho perceptivo e performance de qualquer proposta. Jogos nativos [S07–S09](../technical.md) não validam equivalência web.

# Revisão 04 — Entrega 0.28.0

status: approved
ticket: "04"
reviewed_range: c2039c384e13fcbfc5b7157a777a8952b562c5af..6eef890021b5f33d2a5ce2b20b3422a8aca718d3

## Resultado

Standards: sem achados. Spec: oito critérios e R1–R16 sustentados pelas revisões anteriores, evidência integrada e verificações independentes. Sem bloqueios. Revisão independente por `sdd-reviewer`.

## Evidências

- Árvore limpa na entrada/saída; diff/log e 511 arquivos sanitizados correspondem às árvores Git do intervalo. Nenhuma edição ou commit pelo revisor.
- Segurança BRANCH concluída: Gitleaks 8.30.1 com checksum oficial e executável conferidos; 73 artefatos selecionados (46.407.443 bytes), incluindo mensagem, versões alteradas, snapshots base/head e diff/log. Regras externas padrão, ignores do repositório desativados, decode 3/archive 2 e varreduras adicionais dos contextos. Sem vazamentos confirmados, correspondências privadas de credenciais locais ou vulnerabilidades HIGH/MEDIUM de alta confiança. Artefatos brutos removidos; contexto sanitizado em `/tmp/dino-review04`. Histórico completo não solicitado.
- Logs finais conferidos: Node 27/27 e suíte completa Godot, incluindo 72 fingerprints preservados e 125.016 projeções de câmera. Catálogo/cache/exportação no snapshot exato passou independentemente em cinco testes.
- Pack final verificado independentemente: versão 0.28.0, encaixes corrigidos dos óculos, dimensões das pétalas e ausência da fixture visual. PCK 14.787.676 bytes e WASM 39.514.754 bytes correspondem à configuração.
- Sete imagens versionadas inspecionadas, com encaixes, efeitos pequenos, zero frutas e derrota. Evidência RED/GREEN da regressão das pétalas conferida. Main completou matriz de navegador com corridas normais e cenas dirigidas identificadas, controles simultâneos e recarga final do pack de produção.
- `git diff --check` passou. Correções pequenas, baseadas nas causas demonstradas.

## Limites

Pack reutiliza runtime Godot 4.7.2 existente porque os templates Web completos não estão disponíveis. Ocultação real pelo sistema operacional não reproduzida; handler validado por evento emulado e perda real de foco verificada separadamente. Desempenho físico e preferências infantis não verificados. O revisor usou imagens/evidências Main, sem repetir a sessão interativa do navegador.

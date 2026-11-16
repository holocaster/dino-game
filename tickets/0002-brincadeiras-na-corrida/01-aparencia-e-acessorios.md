# 01: Aparência com prévia e acessórios salvos

**What to build:** escolher o dino, sua cor e sem acessório/boné/óculos, ver a escolha no próprio dino antes de correr e recuperá-la ao abrir o navegador novamente. Esta primeira fatia funciona nos modos atuais; o ticket 03 expõe a segunda aparência na Dupla.

**Blocked by:** None (can start immediately).

**Spec:** `docs/specs/0002-brincadeiras-na-corrida.md` — R1, R2, R13, R14, R15; Implementation Decisions (Cena, aparência e brincadeiras; Página, ponte e recompensas); Testing Decisions (Aparência). **ADRs:** `docs/adrs/0001-retorno-decrescente-so-no-vale.md`.

- [ ] Sem acessório, boné e óculos disponíveis desde o início nas três espécies; aparência não altera atributos, coleta ou formas físicas. Acessório acompanha a cabeça em idle/run, com encaixe por espécie e sem receber indevidamente a tintura da pele.
- [ ] Menu oferece prévia visível do dino real e atualiza espécie/cor/acessório antes da largada. As escolhas continuam na corrida, após pausa/reinício e ao retornar ao menu.
- [ ] Persistir aparências de dois slots com validação; migrar a cor já salva do jogador 1, preservar álbum e restrições de cor, recuperar padrões seguros para preferências desconhecidas ou storage indisponível. O segundo slot será usado pela interface da Dupla no ticket 03.
- [ ] Comandos de aparência validam slot/enum e não aceitam espécie/pista inválida ou configuração de corrida em andamento. Preservar comandos antigos e validação de origem/remetente da ponte.
- [ ] Testes de persistência demonstram salvar/carregar, migração, cores bloqueadas, dados corrompidos e storage que lança erro. Testes Godot cobrem os três dinos e acessórios, animação e invariância física; testes existentes afetados passam, incluindo catálogo e modos.
- [ ] Registrar encaixes a conferir visualmente pelo Main no navegador; não considerar apenas a existência de um nó como evidência suficiente da aparência. Não alterar regras de velocidade ou testes numéricos fora do escopo.

---
id: GT-0145
title: "Higiene do hub: ponteiros, grafia da issue e o molde que não pede o par"
status: active
type: documentation
achado_origem: "Censo de acervo da GT-0144 (#627) — divisão em três decidida pelo Sergio em 12/09/2026"
auditor_origem: "Tomás Ticket (censo), divisão recomendada por Jarvis no Step 09 (PR #632)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/633"
grupo_execucao: G1
depende_de: []
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [acervo-de-tasks]
related_adrs: []
guarda_chuva: "GT-0144 — o censo, o método e a evidência vivem lá e não são copiados aqui"
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0145-higiene-do-hub.md"
---

# GT-0145 — higiene do hub: ponteiros, grafia da issue e o molde que não pede o par

## ⚠️ Não executável em janela de nuvem
Praticamente tudo aqui escreve em `sergio-essencislabs/essencis-squads`, **outro repositório**,
alcançável só desta máquina por caminho absoluto (`C:\Software\ClaudeCode\squads\guardian\`, link
para `C:\Software\EssencisSquads\squads\guardian\`). Uma janela que só tem o GeoCloudAI clonado
**não consegue fazer nenhum dos três critérios desta task**. Despachar para nuvem é despachar para
um bloqueio.

## Contexto
Uma das três em que a GT-0144 (#627) foi dividida. A divisão não é de tamanho, é mecânica:
`grupo_execucao` é **um** campo em **uma** task, e a `dispatcher` lê o campo por task — roteamento
interno a uma GT, em Etapas, é roteamento que o despachante não enxerga.

**O censo, o método e a evidência estão na GT-0144 e não são copiados aqui.** Duplicá-los em três
arquivos é criar três cópias para divergirem — que é o defeito que a própria GT-0144 documenta.

Esta é a costura sem dependência nenhuma: **corre desde o primeiro minuto**, em paralelo com a
GT-0146 (Grupo A).

## Achado original
Três defeitos, todos no mesmo front-matter e nos mesmos arquivos do hub — é por isso que vêm
juntos. Separá-los agendaria conflito da task consigo mesma.

**1. Ponteiros `contraparte:` (CA-05).** Nove apontam para arquivo inexistente; cinco mais são
absolutos que resolvem; um (`GT-0052`) aponta para o próprio hub em vez do produto. **Quinze
campos**, dos quais só nove aparecem como quebrados.

**2. Duas grafias do campo de issue (CA-10).** `issue_url:` em 59 arquivos, `issue: NNN` em 23 —
dos quais 6 já convertidos no PR #3 do hub, restam **17**. Varredura por `issue_url` lê os 17 como
não promovidos, e eles estão.

**3. O `_template.md` do hub não tem `contraparte:` (CA-09).** Termina em `related_adrs: []`. Todas
as GTs carregam o campo à mão, e quem copiar o molde começa sem ele.

O CA-09 é o que faz esta task ser **porta**, e não só faxina: a GT-0147 (Grupo B) vai criar 31
arquivos de hub, e criá-los a partir de um molde que não pede `contraparte:` é fabricar o Grupo B
de novo, à mão. **A GT-0147 só entra quando o CA-09 fechar.**

## Objetivo
O front-matter do hub volta a ser legível por varredura: ponteiro que resolve, em caminho
relativo, com a grafia que o molde declara — e o molde passa a pedir o ponteiro.

## Fora de escopo
- Não criar par nenhum. Criar é Grupo A (GT-0146) e Grupo B (GT-0147).
- Não preencher buraco de numeração.
- Não renomear arquivo nenhum (ver a decisão de nomenclatura na GT-0147).

## Comportamento atual
15 campos `contraparte:` defeituosos, 17 arquivos com a grafia antiga do campo de issue, e um
molde que não pede o ponteiro.

## Comportamento esperado
Zero ponteiros quebrados, zero caminhos absolutos, uma só grafia do campo de issue, e o molde
pedindo `contraparte:`.

## Regras de negócio
- RN-01: converter `issue: NNN` para `issue_url:` é mecânico — o número já está lá. **Não inventar
  URL para arquivo sem número.**
- RN-02: caminho relativo sempre; `C:/Software/...` não resolve em janela de nuvem.
- RN-03: nenhum número reaproveitado, nenhum buraco preenchido.

## Critérios de aceitação
Herdados da GT-0144 com o texto completo — **a numeração original foi preservada de propósito**,
para que o rastro entre as duas seja legível sem tradução.

- [ ] **CA-05** (da GT-0144): nenhum `contraparte:` do hub aponta para arquivo inexistente, **e
      nenhum usa caminho absoluto**. São duas cláusulas de alcances diferentes e a caixa só fecha
      com as duas:

      | Cláusula | Quantos |
      |---|---|
      | não aponta para arquivo inexistente | **9** — GT-0044, 0049, 0050, 0051, 0118, 0119, 0120, 0121, 0122 |
      | não usa caminho absoluto | **14** — os 9 acima + GT-0043, 0045, 0046, 0047, 0048 |

      Mais a décima de classe diferente: **`GT-0052` aponta para o próprio hub**
      (`C:\Software\EssencisSquads\squads\guardian\tasks\active\GT-0052-...`), não para o produto —
      ponteiro virado para o lado errado do par. **Total: 15 campos.**

      É possível consertar os nove, marcar a caixa e deixar cinco para trás cumprindo a letra da
      primeira cláusula e não da segunda. Os cinco resolvem hoje e ainda assim precisam virar
      relativos, pela razão que esta task já dá.

      **Conferir com o método, não com a lista** — lista envelhece, comando não: normalizar cada
      `contraparte:` e testar contra `git ls-tree -r --name-only <rev-do-produto> .agents/tasks`,
      com as **duas pontas ancoradas em commit**. Falso positivo legítimo: GT recém-cunhada cujo
      par ainda está em branch não mesclada aparece quebrada e não está.

- [ ] **CA-10** (da GT-0144): uma só grafia do campo de issue. Restam **17**: GT-0040-0043,
      0045-0052 e GT-0118-0122. Conversão mecânica, o número já está lá.

- [ ] **CA-09** (da GT-0144): o `_template.md` do hub passa a trazer `contraparte: ""`. O
      `_template.md` do produto deve ser conferido no mesmo passo. **Este critério é a porta da
      GT-0147** — avise quando fechar.

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum. Não há código.
### Integrações
`squads/guardian/tasks/` e `squads/guardian/tasks/_template.md`, no repositório do squad.
### Segurança
Indireto: boa parte dos arquivos com ponteiro quebrado são achados de permissão.

## Plano de implementação
- [ ] Etapa 1 — CA-09 primeiro, porque destrava a GT-0147. É um campo num arquivo.
- [ ] Etapa 2 — CA-05, as 15 correções, conferindo pelo método e não pela lista.
- [ ] Etapa 3 — CA-10, os 17 restantes.

## Estratégia de testes
- [ ] Unitários / Integração / E2E: N/A — não há código.
- [ ] Manual: varredura final com **controle positivo** — rodar a mesma consulta sem o filtro
      restritivo e confirmar que ela devolve algo. Vazio só vale como resposta depois disso.

## Riscos e rollback
- **Risco:** marcar o CA-05 com a primeira cláusula cumprida e a segunda não. A tabela existe por
  isso.
- **Risco:** inventar `issue_url` para arquivo sem número no CA-10. RN-01 veta.
- **Rollback:** tudo é markdown; reverter é um revert.

## Registro de execução
### Alterações realizadas
Pendente — cunhada em 12/09/2026, não executada.
### Arquivos principais
Pendente.
### Decisões
Pendente.
### Divergências
Nenhuma.
### Pendências
`grupo_execucao` vazio: é do Step 09.

## Validação
Pendente. Os números vêm do censo da GT-0144 (#627), medido em 12/09/2026 com as duas pontas
ancoradas em commit — hub em `8867236` + `7a8fdb2`, produto em `d75d0bdf`. O hub tinha **82**
arquivos naquele instante e tem **85** em `b99055f`; a contagem envelhece, o método de conferir
não. Reancore antes de recontar.

## Handoff
Sem dependência de entrada — corre desde o primeiro minuto, em paralelo com a GT-0146.
**Tem dependente:** a GT-0147 espera o CA-09.
LLML: não consultada (branch de integração, não `main`).

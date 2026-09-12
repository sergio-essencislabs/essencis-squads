---
id: GT-0146
title: "Grupo A: as 39 GTs do hub sem par no produto"
status: active
type: documentation
achado_origem: "Censo de acervo da GT-0144 (#627) — divisão em três decidida pelo Sergio em 12/09/2026"
auditor_origem: "Tomás Ticket (censo), divisão recomendada por Jarvis no Step 09 (PR #632)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/634"
grupo_execucao: ""
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [acervo-de-tasks]
related_adrs: []
guarda_chuva: "GT-0144 — o censo, o método e a evidência vivem lá e não são copiados aqui"
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0146-grupo-a-as-39-sem-par.md"
---

# GT-0146 — Grupo A: as 39 GTs do hub sem par no produto

## ⚠️ Não executável em janela de nuvem
O CA-07 lê o histórico deste repositório, mas o CA-01 e o CA-03 **escrevem no hub**
(`sergio-essencislabs/essencis-squads`), alcançável só desta máquina por caminho absoluto
`C:\Software\ClaudeCode\squads\guardian\`. Uma janela só com o GeoCloudAI clonado consegue rodar o
portão e trava logo depois.

## Contexto
Uma das três em que a GT-0144 (#627) foi dividida — divisão mecânica: `grupo_execucao` é um campo
em uma task, e a `dispatcher` lê o campo por task, não lê Etapas.

**O censo, o método e a evidência estão na GT-0144 e não são copiados aqui.**

Esta costura **não depende de outra task** e corre desde o primeiro minuto, em paralelo com a
GT-0145. A dependência dela é **interna**: o CA-07 é portão do CA-01.

## Achado original
`GT-0001` a `GT-0039` existem no hub e **não têm par** em `.agents/tasks/` do produto. Nenhuma das
39 tem sequer o campo `contraparte:` — não é ponteiro quebrado, o campo nunca existiu. O conjunto
foi conferido por **igualdade**, não por contagem: os 39 sem campo são exatamente GT-0001..GT-0039.

**Hipótese registrada como hipótese:** são anteriores à TASK-060, que versionou `.agents/tasks/`.
Sustentam-na: `.agents/tasks/` aparece pela primeira vez em 2026-09-09, commit `8e10d774`
(TASK-060); o corte é exato em 0039/0040 (GT-0037/38/39 de 08/09 sem o campo, GT-0040/41 de 09/09
com); e os dois commits logo após o da TASK-060 são GT-0040 e GT-0041.

## O CA-07 é portão, não trabalho — e muda o que as outras duas caixas significam
Dois `git log` e um parágrafo. **Abrir janela própria para ele custa mais do que ele.** Mas o
resultado dele decide qual trabalho o CA-01 é:

| Resultado do CA-07 | O que o CA-01 vira |
|---|---|
| **Confirmada** — nada foi apagado | escrever, em cada uma das 39, que o par nunca existiu porque o mecanismo não existia |
| **Refutada** — houve deleção na faixa | **recuperar arquivo do histórico**, que é outra tarefa, com outro custo e outro risco |

Por isso: **primeiro ato da janela, resultado publicado antes de qualquer um dos 39 ser escrito.**
Se sair refutada, pare e devolva para a Vision em vez de improvisar a recuperação.

## Objetivo
Cada uma das 39 alcançável dos dois lados, ou com a ausência justificada por escrito no hub.

## Fora de escopo
- Grupo B (as 31 só no produto) — é a GT-0147.
- Higiene do front-matter do hub — é a GT-0145.
- Reabrir ou reavaliar mérito técnico de qualquer das 39. É reconciliação de registro.
- Preencher buraco de numeração.

## Comportamento atual
39 GTs de hub sem par e sem o campo que apontaria para ele.

## Comportamento esperado
Par criado, ou ausência justificada — e, nos dois casos, `contraparte:` coerente.

## Regras de negócio
- RN-01: **criar o lado que falta a partir do que existe, nunca inventar conteúdo.** GT sem
  informação suficiente recebe um arquivo mínimo que diz isso, em vez de um arquivo plausível.
  Arquivo fabricado é pior que a ausência: a ausência é visível, a fabricação não.
- RN-02: severidade e `created_at` originais preservados no lado novo.
- RN-03: nenhum número reaproveitado, nenhum buraco preenchido.
- RN-04: o CA-07 é publicado antes de o primeiro par ser escrito.

## Critérios de aceitação
Numeração original da GT-0144 preservada, para o rastro ser legível sem tradução.

- [ ] **CA-07** (portão): a hipótese é confirmada ou refutada por varredura de arquivos removidos,
      e o resultado fica escrito **antes** do CA-01. Comando já corrigido:

      ```bash
      MSYS_NO_PATHCONV=1 git log --oneline --diff-filter=D --all -- '*GT-00*'
      ```

      **E o controle positivo, obrigatório antes de acreditar em qualquer zero:**

      ```bash
      MSYS_NO_PATHCONV=1 git log --oneline --all -- '*GT-00*'   # tem de devolver > 0
      ```

      A redação original deste critério trazia `-- '.agents/tasks/GT-00*'`, que **não alcança
      subpasta** e devolve `0` mesmo sem o filtro — não dizia "nada foi apagado", dizia "não
      olhei". Um comando de verificação que pode falhar em silêncio tem de provar que enxerga
      antes de o vazio dele valer.

      **Resultado parcial já obtido:** a varredura corrigida acha **uma** deleção, `b8cafe8e`, que
      removeu `.agents/tasks/backlog/GT-0043-rqd-real.md` ao movê-lo para `completed/`. **Fora da
      faixa 0001-0039** — não refuta, e serve de controle de que a peneira enxerga.

- [ ] **CA-01**: as 39 têm par no produto, ou uma linha escrita no arquivo do hub dizendo por que
      não têm. O texto depende do CA-07 (ver a tabela acima).

- [ ] **CA-03** (escopo Grupo A): `contraparte:` correta **nos dois sentidos** em tudo que for
      reconciliado, em caminho relativo — nunca `C:/...`.

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum.
### Integrações
`squads/guardian/tasks/` no hub e, se houver par a criar, `.agents/tasks/` do produto.
### Segurança
Nenhum direto.

## Plano de implementação
- [ ] Etapa 1 — CA-07, com o controle positivo, e publicar o resultado. **Portão.**
- [ ] Etapa 2 — se confirmada: escrever a justificativa nas 39 (CA-01) e o `contraparte:` (CA-03).
- [ ] Etapa 2' — se refutada: **parar e devolver para a Vision.** Recuperar arquivo do histórico é
      outra tarefa, não a continuação desta.

## Estratégia de testes
- [ ] Unitários / Integração / E2E: N/A — não há código.
- [ ] Manual: varredura final confirmando que toda GT de 0001 a 0039 tem par ou justificativa, e
      que nenhum `contraparte:` novo aponta para arquivo inexistente.

## Riscos e rollback
- **Risco principal:** inventar conteúdo para as 39. RN-01 existe por isso.
- **Risco:** tratar o CA-07 como formalidade, rodar o comando sem controle positivo e escrever
  "confirmada" em cima de um zero cego. Foi exatamente o que a revisão pegou na GT-0144.
- **Rollback:** markdown; um revert.

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
Pendente. Os números vêm do censo da GT-0144, com as duas pontas ancoradas em commit.

## Handoff
Sem dependência de entrada — corre em paralelo com a GT-0145. Dependência **interna**: CA-07 antes
de CA-01.
LLML: não consultada (branch de integração, não `main`).

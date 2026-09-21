---
id: GT-0142
title: "CI de build e teste (conversão da TASK-061)"
status: completed
type: tech-debt
achado_origem: "TASK-061 — achado durante a execução da GT-0132 (PR #600), não veio de run de auditoria"
auditor_origem: "Conversão de TASK-061 (orquestrador bootstrap-*) por despacho da Vision, opção B aprovada pelo Sergio"
severidade: alta
produto: GeoCloudAI
camada: cross-cutting
run_origem: "N/A — conversão de TASK existente, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/622"
grupo_execucao: ""
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [infra, api, web]
related_adrs: []
task_de_origem: "GeoCloudAI/.agents/tasks/backlog/TASK-061-ci-de-build-e-teste.md"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0142-ci-de-build-e-teste.md"
---

# GT-0142 — CI de build e teste (conversão da TASK-061)

## Contexto
Conversão da **TASK-061** em GT, opção B, escolhida explicitamente pelo Sergio e despachada pela
Vision em 12/09/2026.

O número **não** é reaproveitado: `TASK-NNN` pertence ao orquestrador `bootstrap-*` e `GT-NNNN`
ao Guardian, sequências separadas por decisão registrada em `.agents/tasks/README.md`
(TASK-060, 09/09/2026) — *"prefixo distinto torna impossível"* a colisão. O rastro fica nos dois
sentidos: `task_de_origem` aponta a TASK, e a TASK recebe nota apontando esta GT.

**A maior parte do trabalho já está feita.** O CI entrou pelos PRs #603/#609/#610 e #607. Esta GT
nasce com cinco dos sete critérios cumpridos e dois em aberto — e é por isso que ela existe como
GT em vez de ser arquivada: os dois que faltam não têm dono enquanto o registro não estiver no
hub.

## Achado original
Transcrito com fidelidade da TASK-061, sem rebaixar a severidade original (`alta`):

> Durante a GT-0132 (PR #600) fui verificar o CI do PR antes de considerá-lo pronto. Não havia
> nenhum: `get_check_runs` e `get_status` no head do PR voltaram `total_count: 0`. A causa é
> simples — **o repositório não tem `.github/` nenhum**.

Três consequências registradas na TASK: nada barra um PR vermelho; o ambiente de teste não era
reprodutível; e a suíte de banco não roda em Linux sem `lower_case_table_names=1` — *"o
conhecimento necessário para rodar a suíte existe só na cabeça de quem já a rodou"*.

## Estado real conferido em 12/09/2026
Conferido contra a branch de integração `feature/fix/refactor-08_09-11_09` (`4cea0a87`) e contra
a execução de CI **34698146569**, verde nessa mesma branch:

| Evidência | Onde |
|---|---|
| Workflow existe, dispara em `push` e `pull_request` | `.github/workflows/ci.yml:38-45` |
| Build da solução em Release | `.github/workflows/ci.yml:78-79` |
| Os três projetos de teste estão em `api/Back.sln` | `Back.UnitTests`, `Back.IntegrationTests`, `Back.ApiTests` |
| `lower_case_table_names=1` conferido, e o job cai sem ele | `.github/workflows/ci.yml:67-70` |
| Front com `npm ci` + `npm run build` (e ainda `npm test`) | `.github/workflows/ci.yml:104-135` |

Resultado da execução 34698146569:
```
Back.UnitTests          Failed: 0, Passed: 509, Skipped:  0, Total: 509
Back.IntegrationTests   Failed: 0, Passed:  91, Skipped:  0, Total:  91
Back.ApiTests           Failed: 0, Passed: 196, Skipped: 78, Total: 274
```
Os 78 pulados são `Back.ApiTests.Campaign.*`, que se pulam sozinhos por falta das três variáveis
de campanha — o mesmo motivo que a TASK-061 previu, não falta de ambiente.

## Objetivo
Fechar os dois critérios que sobraram: a prova de que o check fica vermelho, e a página de
documentação da suíte local.

## Fora de escopo
- Deploy, release, publicação de imagem.
- Cobertura mínima como gate.
- Reescrever o baseline de schema para ser case-consistent (segue como pendência própria).

## Comportamento atual
CI roda e é verde. Falta a prova do vermelho e falta a documentação.

## Comportamento esperado
Um PR com teste quebrado de propósito mostra check vermelho de forma verificada, e a armadilha do
`lower_case_table_names` está escrita em `docs/`, não só no cabeçalho do workflow.

## Regras de negócio
- RN-01: o CI roda a suíte **inteira** — os três projetos.
- RN-02: nenhum teste é pulado, desabilitado ou ignorado só para o CI ficar verde.
- RN-03: o ambiente é descrito em arquivo versionado.

## Critérios de aceitação
- [x] CA-01: existe workflow em `.github/workflows/` disparado em `push` e `pull_request` —
      `ci.yml:38-45`.
- [x] CA-02: o workflow compila `api/Back.sln` com 0 erros — `ci.yml:78-79`, run 34698146569.
- [x] CA-03: o workflow roda os três projetos de teste e falha o check se qualquer teste falhar —
      `dotnet test api/Back.sln` (`ci.yml:81-82`) cobre os três projetos da solução.
- [x] CA-04: MySQL com `lower_case_table_names=1`, `DATABASE_URL` chegando aos testes, e os
      testes de banco passando sem serem pulados — 91/91 em `Back.IntegrationTests`, run
      34698146569. **Nota de divergência:** o schema chega pelas migrations
      (`api/tests/Back.IntegrationTests/Fixtures/IntegrationCollection.cs:29-31`,
      `ApplyPendingMigrations`), **não** pelo baseline aplicado a um banco de origem, que é o
      mecanismo que a TASK-061 descreveu. O critério observável está cumprido; a descrição do
      mecanismo na TASK está desatualizada.
- [ ] CA-05: um PR com teste quebrado de propósito mostra check vermelho (verificado uma vez, e
      revertido) — **em aberto: não há evidência de que isso tenha sido feito.** Todas as
      execuções conferidas estão verdes, o que prova o caminho feliz e não o de falha.
- [x] CA-06: o front tem `npm ci` + build no CI — `ci.yml:120-123`; o workflow vai além e roda
      `npm test` com `ChromeHeadlessCI` (`ci.yml:125-135`).
- [ ] CA-07: `docs/` com página de "como rodar a suíte localmente", incluindo a armadilha do
      `lower_case_table_names` — **em aberto: não existe.** `docs/quality/README.md:21` traz só o
      comando `dotnet test Back.sln`, sem ambiente e sem a armadilha; `docs/setup-local.md:39` cita
      uma baseline de 257/31/332 que não corresponde mais ao que a suíte tem hoje (509/91/274).

## Impacto técnico
### Backend
Nenhuma mudança de código de produção.
### Frontend
Nenhuma.
### Banco de dados
Nenhuma. Ver a nota do CA-04 sobre a origem do schema no CI.
### Integrações
`.github/workflows/ci.yml` e `docs/`.
### Segurança
Credencial do MySQL do CI é efêmera e de serviço.

## Plano de implementação
- [x] Etapa 1 — workflow mínimo com build e testes. Feito (#607).
- [x] Etapa 2 — MySQL, `lower_case_table_names=1` e `DATABASE_URL`. Feito.
- [x] Etapa 3 — job do front. Feito.
- [ ] Etapa 4 — quebrar um teste de propósito num PR de rascunho, confirmar o vermelho, reverter
      (CA-05).
- [x] Etapa 5 — `scripts/cloud/provision-env.sh` criado e verificado (#610).
- [ ] Etapa 6 — documentar em `docs/` (CA-07), incluindo corrigir a baseline defasada de
      `docs/setup-local.md:39`. **Atenção ao terceiro número:** o `332 specs` da linha atual é do
      **frontend** (Karma), não do `Back.ApiTests`. Trocar por `509/91/274` poria um número de
      backend sob o rótulo "specs", sumiria com o número do frontend num parágrafo que manda subir
      os dois, e esconderia que 78 dos 274 são pulados. A baseline correta tem quatro números:
      **`509 unit / 91 integration / 196 de 274 api (78 skipped) / 561 specs`** (run 34701237492).
      Desambiguado por contagem histórica: em `f3d33580`, quando a linha nasceu, o frontend tinha
      329 `it(` e o `Back.ApiTests` tinha 12 `[Fact]/[Theory]`. Achado do Rui na revisão do #628.
      **Titularidade desta linha é desta GT.** Até 12/09/2026 ela era compartilhada com o CA-06 da
      GT-0144 (#627), sob a regra "quem chegar primeiro resolve e marca nos dois lugares" — e essa
      regra **era ela própria o risco que o parágrafo nomeava**: duas tasks com direito ao mesmo
      arquivo e nenhuma com o dever. Ao dividir a GT-0144 em três (GT-0145/0146/0147), o CA-06 não
      foi para nenhuma delas: ficou aqui, com dono único.
      **✅ Cumprido pelo PR #629 (`79b42190`)**, que criou `docs/quality/rodar-a-suite-localmente.md`
      e deixou a linha do `docs/setup-local.md` com os quatro números, acrescentando a ressalva de
      que são suítes diferentes e não se somam. A titularidade funcionou: nada voltou como
      divergência.

      > **Divergência de par, para a Vision:** o #629 moveu a GT-0142 para `completed/` **no
      > produto** e este arquivo do hub continua em `active/`, com os CA-05/CA-07 ainda `- [ ]`.
      > Os dois lados do par se contradizem — é bug de processo pelo `.agents/tasks/README.md`.
      > Não corrijo aqui porque a entrega é do #629 e marcar critério alheio exige que o dono o
      > faça; fica registrado onde o próximo leitor tropece.

## Estratégia de testes
- [x] Unitários: N/A — é infraestrutura.
- [x] Integração: o CI verde na suíte completa é a evidência — run 34698146569.
- [x] E2E: N/A.
- [ ] Manual: CA-05, o PR de rascunho com teste quebrado — não executado.

## Riscos e rollback
- **Risco:** ligar o CI e descobrir algo já vermelho, criando a tentação de pular teste para
  destravar. A RN-02 existe por isso. Hoje o risco está medido: a suíte está verde.
- **Rollback:** apagar o workflow. Nenhum código de produção é tocado.

## Registro de execução
### Alterações realizadas
Esta GT é conversão de registro, não implementação. O trabalho do CI foi feito pelos PRs
#603/#607/#609/#610, fora desta task. O Registro do que ainda falta (CA-05 e CA-07) vai na
contraparte.
### Arquivos principais
`.github/workflows/ci.yml`, `scripts/cloud/setup-cloud-env.sh`, `scripts/cloud/provision-env.sh`.
### Decisões
Converter a TASK-061 em GT com número novo, e não reaproveitar o 061 — prefixo distinto é o que
impede colisão entre as duas sequências (`.agents/tasks/README.md`).
### Divergências
O CA-04 está cumprido por um mecanismo diferente do que a TASK-061 descreveu: o schema do CI vem
de `ApplyPendingMigrations`, não do baseline. Registrado no próprio critério.
### Pendências
1. **O baseline de schema é case-inconsistente com o código.** `lower_case_table_names=1` é
   contorno, não conserto. Herdada da TASK-061 e ainda sem dono.
2. `grupo_execucao` vazio de propósito (Step 09).

## Validação
Execução de CI 34698146569, branch `feature/fix/refactor-08_09-11_09`, commit `4cea0a87`:
509 + 91 + 196 aprovados, 0 falhas, 78 pulados (campanha, por desenho).

## Handoff
Cunhada e promovida no mesmo despacho. Fica `active` — não `completed` — porque CA-05 e CA-07
seguem abertos. A TASK-061 de origem recebe nota apontando para cá.
LLML: não consultada (branch de integração, não `main`).

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido, inclusive os criterios que o hub ainda marcava abertos.** CA-05 (prova do vermelho):
runs de CI verificados - 34702980937 @ 1e7f103d = failure (o teste quebrado de proposito),
34703354254 @ d5fce25c (revert) = success. CA-07 (documentacao): docs/quality/rodar-a-suite-localmente.md
existe em origin/main, ligada de dois READMEs; docs/setup-local.md traz a baseline de quatro
numeros correta. Contraparte produto em completed/: 7/7 CAs [x], Registro preenchido. TASK-061
marcada "Convertida em GT-0142". Issue #622 continua OPEN apesar do merge.

Evidencia completa no relatorio da reconciliacao GT-0156.

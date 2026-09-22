---
id: GT-0143
title: "Provisionamento do CI usa o script que sai zero (conversão da TASK-062)"
status: completed
type: tech-debt
achado_origem: "TASK-062 — revisão do CI logo após mesclar a #607, não veio de run de auditoria"
auditor_origem: "Conversão de TASK-062 (orquestrador bootstrap-*) por despacho da Vision, opção B aprovada pelo Sergio"
severidade: media
produto: GeoCloudAI
camada: cross-cutting
run_origem: "N/A — conversão de TASK existente, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/623"
grupo_execucao: ""
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [infra]
related_adrs: []
task_de_origem: "GeoCloudAI/.agents/tasks/backlog/TASK-062-ci-gatilho-feat-e-script-que-falha-alto.md"
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0143-provisionamento-do-ci-que-falha-alto.md"
---

# GT-0143 — o provisionamento do CI usa o script que sai zero (conversão da TASK-062)

## Contexto
Conversão da **TASK-062** em GT, opção B, escolhida pelo Sergio e despachada pela Vision em
12/09/2026. Número novo, pelo mesmo motivo da GT-0142: as duas sequências não se cruzam
(`.agents/tasks/README.md`, TASK-060). Rastro nos dois sentidos.

A TASK-062 tinha duas metades. **A primeira já foi resolvida** — o gatilho `feat/**`. Sobra a
segunda.

**A severidade original é `alta` na TASK-062, e esta GT registra `media`.** Isso não é
rebaixamento do achado: a própria TASK-062 declara que a metade `alta` (o gatilho que ia parar de
cobrir a branch semanal a partir de 14/09) *"foi resolvida no mesmo dia, antes de entrar em
vigor"*, e classifica a metade remanescente como **"severidade média"** no próprio corpo. O que
esta GT herda é a metade média; a metade alta não existe mais.

## Achado original
Transcrito da TASK-062, seção "2. O provisionamento usa o script que sai zero ao falhar":

> O passo de ambiente chama `scripts/cloud/setup-cloud-env.sh`. Esse script **sempre sai com
> zero**, por desenho: ele foi escrito para o campo "Setup script" do ambiente web, onde sair
> diferente de zero impede a sessão de iniciar.
>
> Em CI o contrato é o oposto. Hoje isso está compensado pelo passo "Conferir o ambiente" [...]
> então **não há defeito ativo**. O que há é uma rede única: se o script falhar de um jeito que a
> conferência não cobre, o job segue verde.

Conferido em 12/09/2026 na branch `feature/fix/refactor-08_09-11_09` (`4cea0a87`):

- `.github/workflows/ci.yml:63` ainda chama `sudo -E bash scripts/cloud/setup-cloud-env.sh`.
- `scripts/cloud/provision-env.sh` existe desde a #610, com o contrato certo para CI.
- O passo "Conferir o ambiente" (`ci.yml:65-76`) está lá e derruba o job sem .NET 9, sem MySQL ou
  com `lower_case_table_names` diferente de 1 — a rede única continua sendo a única.
- O diff pronto está no commit local `5cbb84b0`, na branch **local** `ci/usar-provision-env`.
  `git ls-remote --heads origin 'ci/*'` não retorna nada: **nunca foi empurrado**, exatamente como
  a TASK-062 registrou.

## Objetivo
Mover a falha de provisionamento para o ponto onde ela acontece, mantendo a conferência como
segunda rede.

## Fora de escopo
Não mexer nos dois scripts em si. Eles ficam como estão, separados por nome e com contratos
opostos — ver `docs/processo/guardian.md` e o cabeçalho de cada arquivo.

## Comportamento atual
Provisionamento que falha fora do que a conferência cobre produz job verde.

## Comportamento esperado
Provisionamento que falha derruba o job no próprio passo de provisionamento.

## Regras de negócio
- RN-01: o gatilho de push acompanha o padrão de branch vigente. Mudar o prefixo da branch sem
  mudar o gatilho é reabrir a GT-0142 em silêncio.
- RN-02: o `pull_request:` continua **sem filtro de base**, pela justificativa escrita no próprio
  workflow (`ci.yml:39-43`): PR empilhada sobre outra PR tem base fora do padrão e estrearia sem
  nunca ter rodado.

## Critérios de aceitação
- [x] CA-01: `push:` inclui `'feat/**'` além de `main` e `'feature/**'` — aplicado pelo Sergio em
      11/09/2026 pela interface web (commit `ff375252`), porque o push por CLI esbarra no escopo
      `workflow`. Conferido em `ci.yml:41-45`.
- [ ] CA-02: o passo de provisionamento chama `scripts/cloud/provision-env.sh --skip-verify` —
      **aberto:** `ci.yml:63` ainda chama `setup-cloud-env.sh`.
- [ ] CA-03: o passo recebe `GEOCLOUD_DB_NAME`, `GEOCLOUD_DB_USER` e `GEOCLOUD_DB_PASS`
      explícitos, batendo com o `DATABASE_URL` do passo seguinte — **aberto:** o padrão do script é
      `geo`/`geopass` e o workflow monta `geocloud`/`geocloud` (`ci.yml:61`).
- [x] CA-04: o passo "Conferir o ambiente" permanece como segunda rede — `ci.yml:65-76`.
- [x] CA-05: um push na branch semanal do sprint corrente produz execução de CI visível — run
      **34698146569** em `feature/fix/refactor-08_09-11_09`. **Ressalva:** isso exercita o padrão
      `feature/**`; o padrão `feat/**` do CA-01 só passa a ser exercitado de fato a partir do
      sprint de 14/09, e vale reconferir na primeira push daquela branch.

## Impacto técnico
### Backend
N/A.
### Frontend
N/A.
### Banco de dados
N/A.
### Integrações
`.github/workflows/ci.yml`, um arquivo.
### Segurança
Nenhum. Nenhuma credencial entra no workflow: o banco do CI é efêmero e as três variáveis são
nomes locais do runner.

## Bloqueio conhecido — herdado da TASK-062 e ainda de pé
O push de qualquer alteração em `.github/workflows/` é recusado:
```
refusing to allow an OAuth App to create or update workflow
`.github/workflows/ci.yml` without `workflow` scope
```
A conta ativa `sergio-essencislabs` tem `delete_repo, gist, project, read:org, repo` — **sem
`workflow`**. Reconferido em 12/09/2026 por `gh auth status`: os escopos continuam os mesmos.

Hipótese não confirmada (da TASK-062): política de OAuth App na organização `Essencis-Labs`
exigindo aprovação de owner. Verificável em
`github.com/organizations/Essencis-Labs/settings/oauth_application_policy`.

**Não usar a conta `smendesj` para contornar** — é pessoal, e o repositório tem hook de pré-push
exigindo autor `*@essencislabs.com`.

Enquanto o escopo não existir, a edição pela interface web não passa por essa restrição — foi
assim que o CA-01 entrou.

## Plano de implementação
- [x] Etapa 1 — acrescentar `'feat/**'` ao gatilho (CA-01, `ff375252`).
- [ ] Etapa 2 — aplicar o diff de `5cbb84b0` (CA-02 a CA-04), pela interface web enquanto o escopo
      `workflow` não existir na conta corporativa.
- [ ] Etapa 3 — reconferir o CA-05 na primeira push da branch `feat/fix/refactor-14_09-18_09`.

## Estratégia de testes
- [ ] Unitários: N/A.
- [ ] Integração: N/A.
- [ ] E2E: N/A.
- [ ] Manual: após aplicar, empurrar um commit na branch semanal e confirmar execução na aba
      Actions. É o único teste possível — nenhum teste de código alcança configuração de gatilho.

## Riscos e rollback
Um arquivo, reversível por revert. O risco de **não** fazer é a rede única continuar única.

## Registro de execução
### Alterações realizadas
Conversão de registro. O CA-01 foi aplicado fora desta task (`ff375252`). O Registro do restante
vai na contraparte.
### Arquivos principais
`.github/workflows/ci.yml`.
### Decisões
Registrar `media` e não `alta`, porque a metade `alta` da TASK-062 (o gatilho) já foi resolvida e
a metade remanescente é classificada como média pela própria TASK. Nenhuma severidade foi
rebaixada.
### Divergências
Nenhuma.
### Pendências
- O diff de `5cbb84b0` está numa branch **local** que nunca foi empurrada. Se a máquina que a
  contém for perdida, o trabalho se perde — vale empurrá-la sob outro nome (sem tocar
  `.github/`) ou reaplicar o diff à mão.
- `grupo_execucao` vazio de propósito (Step 09).

## Validação
Pendente para CA-02/CA-03. CA-01, CA-04 e CA-05 validados por leitura de `ci.yml` em `4cea0a87` e
pela run 34698146569.

## Handoff
Cunhada e promovida no mesmo despacho. Fica `active`. Depende do escopo `workflow` na conta
corporativa, ou de edição pela interface web. A TASK-062 de origem recebe nota apontando para cá.
LLML: não consultada (branch de integração, não `main`).

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido.** Commits `c566b559` (PR #631) + `b4df2270` (PR #643), em main. Codigo:
`.github/workflows/ci.yml:126` (provision-env.sh --skip-verify), :116-118 (variaveis de banco),
:128-151 (checagem de lower_case_table_names). Prova de execucao real: run 34711724092 @
ed3d4f1f = success. Contraparte produto em completed/: 5/5 CAs [x], Registro preenchido
(inclui achado de seguranca sobre a trava do datadir). TASK-062 marcada "Convertida em GT-0143".
Issue #623 continua OPEN apesar do merge. Residuos de CI ja tem GT propria no Open do hub:
GT-0154 e GT-0155 (pareamento por numero com o produto aposentado em 2026-09-22, GT-0714 Fase 2 --
o lado produto virou GT-0668/GT-0673).

Evidencia completa no relatorio da reconciliacao GT-0156.

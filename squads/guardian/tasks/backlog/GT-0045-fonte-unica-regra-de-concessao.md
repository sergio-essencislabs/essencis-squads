---
id: GT-0045
title: "Fonte única da regra de concessão de módulo: predicado triplicado, abstrações com zero uso em produção"
status: backlog
type: tech-debt
achado_origem: "TD-04, TD-05, TD-06, TD-07, TD-12"
auditor_origem: "Dante Débito"
severidade: "media"
produto: "GeoCloudAI"
camada: "backend"
run_origem: "auditoria ad-hoc de Dante Débito sobre o código de modularização (TASK-055/056/057), 2026-09-09 — sem run de pipeline; achados aprovados pelo dono do produto para correção na branch feature/fix/refactor-08_09-11_09"
issue_url: ""
grupo_execucao: ""
contraparte: "C:\\Software\\GeoCloud\\GeoCloudAI\\.agents\\tasks\\backlog\\GT-0045-fonte-unica-regra-de-concessao.md"
owner: ""
created_at: 2026-09-09
updated_at: 2026-09-09
affected_modules: ["Back.API", "Back.Application", "Back.Domain", "Back.Persistence", "Back.UnitTests"]
related_adrs: ["ADR-003"]
---

# GT-0045 — Fonte única da regra de concessão

## Contexto

Segunda frente da auditoria ad-hoc de Dante Débito sobre a modularização (TASK-055/056/057). Cinco
achados que compartilham um único padrão: **a regra de "quando um módulo concede acesso" existe em
vários lugares ao mesmo tempo, e as abstrações criadas para ser a fonte única não são usadas em
produção — só em teste.**

O sintoma não é um bug hoje. É que qualquer mudança futura na regra exige encontrar todas as
cópias, e uma delas vai ficar para trás — e a suíte de testes vai continuar verde, porque os testes
exercitam a abstração que ninguém chama.

Aprovado pelo dono do produto para correção na branch `feature/fix/refactor-08_09-11_09`.

## Achado original

### TD-04 (média) — o predicado de concessão está literal 3 vezes

`am.status IN ('active','trial') AND (am.endDate IS NULL OR am.endDate > NOW())` aparece literal em
`ModuleRepository.cs:45-46`, `:76-77` e `:109-111`, com as strings `'active'` e `'trial'` escritas à
mão em cada uma.

`AccountModuleStatus.Grants` (`Back.Domain/Classes/AccountModule.cs`) tem **zero usos em `src/`** —
os únicos 3 usos estão em `ModuleStatusTests`. A constante existe, é testada, e nenhum código de
produção a chama. A própria linha `ModuleRepository.cs:66` traz o comentário
"ver AccountModuleStatus.Grants" ao lado de uma cópia literal da regra.

### TD-05 (média) — `GetCapabilities` documenta um comportamento e implementa outro; os predicados divergem

`IModuleService.GetCapabilities` **documenta** que resolve pelo `IPermissionService` e que respeita o
perfil e o bypass de `isSystemAdmin`. A implementação (`ModuleService.cs:129`) deliberadamente não
usa — e há um comentário longo explicando por quê (chave de capacidade descreve o que a conta
contratou, não o que o perfil concede; ADR-003).

O problema não é a decisão, é que os predicados divergem:

- `PermissionService.cs:227` nega **só o que está mapeado e não concedido**;
- `ModuleService.cs:134` concede **só o que está em `GrantedKeys`**.

Para uma chave **não mapeada** a nenhum módulo, o backend permite e a UI esconde. As duas respostas
estão certas segundo o próprio predicado, e discordam.

`ModuleGateDecision.Denies()` existe justamente para ser a fonte única desse predicado, e tem
**11 usos, todos em teste**.

### TD-06 (média) — as 4 chaves de capacidade escritas à mão

`ModuleService.cs:104-107`:

```csharp
private static readonly string[] CapabilityKeys =
{
    "viewer.singleView", "viewer.multiView", "viewer.coreView", "viewer.view3D"
};
```

Duplica o que a migration `M20260908223605` já grava no banco — três vezes no `Up`, uma no `Down`.
`GetAllModuleMappedKeys` existe e já é carregado via `_gate`.

### TD-07 (média) — sobrecarga de `GetGrantedFunctionalityKeys` sem chamador em produção

`GetGrantedFunctionalityKeys(accountId)`, de um argumento: **zero chamadores em `src/`**, 5 em teste
de integração. É a sobrecarga de 2 argumentos com `coreOnly=false`. Duas das três cópias do
predicado do TD-04 estão nessas duas sobrecargas.

### TD-12 (baixa) — regra de negócio no SQL, e o arquivo declara a regra oposta duas vezes

`ModuleRepository.cs:45-46` (o alias `GrantsNow`) e `:166` (`ORDER BY m.isCore ASC LIMIT 1` — escolha
**comercial** de qual módulo oferecer ao usuário) põem regra de negócio no SQL, o que
`.claude/rules/global.md` proíbe ("Repository aplicando regra de negócio").

E o mesmo arquivo **declara a regra oposta duas vezes**: `:67-69` ("A REGRA de quando aplicar o
recorte vive no serviço (TASK-056), não aqui — ver a nota sobre não esconder a decisão dentro do
SQL") e `:100-102`. A leitura do arquivo é contraditória: dois comentários dizem que a decisão não
mora no SQL, e duas construções ali perto são exatamente decisão no SQL.

**Atenção ao implementar** — isto é o ponto que mais importa desta task: `GrantsNow` foi movido para
o SQL **de propósito** na TASK-057, para corrigir uma comparação entre dois relógios (o do banco e o
do processo). Reverter para C# reintroduz aquele bug. A correção aqui é **tornar a leitura
coerente**, não mover a lógica de volta.

## Objetivo

A regra de concessão de módulo ter uma fonte única e localizável, e as abstrações que existem para
sê-la serem efetivamente chamadas por código de produção — não só por teste.

## Fora de escopo

- Mover `GrantsNow` de volta para C#. Explicitamente vedado: reintroduz o bug de comparação entre
  relógios corrigido na TASK-057.
- Reverter a decisão de `GetCapabilities` não usar `IPermissionService` (ADR-003). O TD-05 pede
  alinhar documentação e predicado, não trocar a decisão.
- Correções de comportamento do fluxo de módulo (`startTrial`, respostas de erro) — GT-0044.
- Cobertura, fuso horário e custo — GT-0046.

## Comportamento atual

- Três cópias literais do predicado de concessão no SQL, com `'active'`/`'trial'` à mão.
- `AccountModuleStatus.Grants`: 0 usos em `src/`, 3 em teste.
- `ModuleGateDecision.Denies()`: 11 usos, todos em teste.
- Chave não mapeada: backend permite (`PermissionService.cs:227`), UI esconde (`ModuleService.cs:134`).
- 4 chaves de capacidade escritas à mão, duplicando a migration.
- `GetGrantedFunctionalityKeys(accountId)`: 0 chamadores em `src/`, 5 em teste.
- `ModuleRepository.cs` afirma duas vezes que a regra não mora no SQL, e a põe no SQL duas vezes.

## Comportamento esperado

- Uma definição do predicado de concessão, referenciada pelas três consultas.
- `AccountModuleStatus.Grants` e `ModuleGateDecision.Denies()` chamados por produção, ou removidos
  com registro do motivo — abstração testada e nunca chamada é pior que ausência de abstração,
  porque dá a impressão de cobertura.
- Um único predicado decidindo o caso da chave não mapeada, com a escolha registrada.
- As chaves de capacidade derivadas do que está no banco.
- Sobrecarga sem chamador em produção removida, ou o chamador identificado.
- `ModuleRepository.cs` sem contradição entre o que os comentários afirmam e o que o SQL faz.

## Regras de negócio

- RN-01: chave de capacidade descreve o que a **conta contratou**, não o que o **perfil do usuário**
  concede (ADR-003) — a divergência do TD-05 se resolve alinhando a documentação e escolhendo um
  predicado, nunca desfazendo esta regra.
- RN-02: para chave **não mapeada** a nenhum módulo, backend e UI têm de dar a mesma resposta. Qual
  das duas respostas é a certa é decisão de produto e precisa ser registrada.
- RN-03: `GrantsNow` continua avaliado pelo relógio do banco (TASK-057).
- RN-04: `ORDER BY m.isCore ASC LIMIT 1` codifica "se a chave está em dois módulos, oferecer o pago,
  porque o Core toda conta já tem". A regra permanece; o que muda é onde ela está declarada.

## Critérios de aceitação

- [ ] CA-01: o predicado de concessão tem uma definição única, e as três consultas
      (`ModuleRepository.cs:45-46, 76-77, 109-111`) a referenciam em vez de repeti-la.
- [ ] CA-02: `'active'` e `'trial'` não aparecem mais escritos à mão no SQL — vêm de
      `AccountModuleStatus`.
- [ ] CA-03: `AccountModuleStatus.Grants` tem pelo menos um uso em `src/`, ou foi removido com o
      motivo registrado na task.
- [ ] CA-04: `ModuleGateDecision.Denies()` tem pelo menos um uso em `src/`, ou foi removido com o
      motivo registrado.
- [ ] CA-05: a documentação de `IModuleService.GetCapabilities` descreve o que a implementação faz —
      sem menção a `IPermissionService`, perfil ou bypass de `isSystemAdmin` se ela não os usa.
- [ ] CA-06: chave não mapeada produz a mesma resposta no backend (`PermissionService.cs:227`) e na
      UI (`ModuleService.cs:134`), com a escolha registrada em `.agents/decisions/`.
- [ ] CA-07: teste cobrindo especificamente a chave não mapeada nos dois caminhos.
- [ ] CA-08: as 4 chaves de capacidade derivam do que está no banco (via `GetAllModuleMappedKeys` ou
      equivalente), não de um array literal em `ModuleService.cs:104-107`.
- [ ] CA-09: `GetGrantedFunctionalityKeys(accountId)` de 1 argumento removida da interface e da
      implementação, com os 5 testes de integração migrados para a sobrecarga de 2 argumentos — ou
      um chamador de produção identificado e registrado.
- [ ] CA-10: `ModuleRepository.cs` sem contradição: ou os comentários de `:67-69` e `:100-102` são
      reescritos para descrever o que de fato acontece, ou a decisão sai do SQL onde isso é possível
      **sem** mover `GrantsNow`.
- [ ] CA-11: `GrantsNow` continua avaliado no SQL, pelo relógio do banco. Teste ou nota de validação
      comprovando que a comparação entre relógios não voltou.

## Impacto técnico

### Backend
`ModuleRepository`: predicado consolidado, strings de status vindas do domínio.
`ModuleService`: chaves de capacidade derivadas do banco; predicado alinhado com `PermissionService`.
`IModuleService` / `IModuleRepository`: documentação corrigida, sobrecarga sem uso removida.
Cuidado com `.claude/rules/global.md`: a consolidação não pode fazer o Service montar SQL, nem o
Repository ler claim.

### Frontend
Muda se e somente se CA-06 decidir que a resposta certa é a do backend (permitir chave não mapeada) —
aí a UI passa a desenhar controles que hoje esconde. Decisão de produto, a registrar antes do código.

### Banco de dados
Nenhuma migration. `M20260908223605` continua sendo a fonte das chaves; o que muda é o backend passar
a lê-la em vez de duplicá-la.

### Integrações
Nenhuma.

### Segurança
CA-06 é decisão de autorização: se a resposta escolhida for "permitir chave não mapeada", ela precisa
passar pelo auditor de permissão (`geocloud-permission-auditor`) antes do merge, e por
`api/docs/system/permission-rules.md`.

## Plano de implementação

- [ ] Etapa 1: decidir e registrar em `.agents/decisions/` a resposta para chave não mapeada (CA-06).
      Bloqueia as etapas de código do TD-05.
- [ ] Etapa 2: consolidar o predicado e as strings de status (TD-04), preservando `GrantsNow` no SQL.
- [ ] Etapa 3: derivar as chaves de capacidade do banco (TD-06).
- [ ] Etapa 4: alinhar documentação e predicado de `GetCapabilities` (TD-05).
- [ ] Etapa 5: remover a sobrecarga de 1 argumento e migrar os 5 testes (TD-07).
- [ ] Etapa 6: reescrever os comentários contraditórios de `ModuleRepository.cs` (TD-12).
- [ ] Etapa 7: dar uso em produção a `Grants` e `Denies()`, ou removê-los com registro.

## Estratégia de testes

- [ ] Unitários: chave não mapeada nos dois caminhos; predicado consolidado; chaves de capacidade
      derivadas do banco.
- [ ] Integração: as três consultas do predicado consolidado contra o schema real, incluindo
      `endDate` nulo, futuro e passado — é o que prova que a consolidação não mudou a semântica.
- [ ] E2E: N/A.
- [ ] Manual: `GrantsNow` para um vínculo cujo `endDate` está a segundos de vencer — o caso que a
      TASK-057 corrigiu e que a consolidação pode reintroduzir.

## Riscos e rollback

Risco principal: consolidar o predicado e, no caminho, mover `GrantsNow` de volta para C#. Isso
reintroduz o bug de comparação entre dois relógios que a TASK-057 corrigiu — e é um bug que a suíte
verde não pega, porque só aparece quando os relógios divergem. CA-11 existe para barrar isso.

Risco secundário: CA-06 escolher "permitir chave não mapeada" e abrir acesso a capacidade que a
conta não contratou. Por isso a decisão passa pelo auditor de permissão antes do código.

Rollback: cada etapa é independente e reversível isoladamente. A Etapa 1 é decisão, não código, e
não tem rollback — tem revisão.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação
Comandos e resultados reais — nunca uma caixa marcada sem evidência ao lado.

## Handoff
Aguardando promoção — ver `squads/guardian/tasks/backlog/`. Nenhuma issue criada: o Gate de
Promoção não aconteceu nesta etapa.

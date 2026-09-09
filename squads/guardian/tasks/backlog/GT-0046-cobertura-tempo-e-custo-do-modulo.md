---
id: GT-0046
title: "Cobertura, tempo e custo do fluxo de módulo: GetByAccount sem prova, hora local em conexão UTC, 6 consultas por chamada"
status: backlog
type: tech-debt
achado_origem: "TD-02, TD-03, TD-09, TD-10, TD-11"
auditor_origem: "Dante Débito"
severidade: "media"
severidade_itens: "TD-02 alta, TD-03 alta, TD-09 media, TD-10 media, TD-11 baixa — a severidade da frente é media por agrupamento do dono do produto; NENHUM item foi rebaixado, TD-02 e TD-03 permanecem alta"
produto: "GeoCloudAI"
camada: "backend"
run_origem: "auditoria ad-hoc de Dante Débito sobre o código de modularização (TASK-055/056/057), 2026-09-09 — sem run de pipeline; achados aprovados pelo dono do produto para correção na branch feature/fix/refactor-08_09-11_09"
issue_url: ""
grupo_execucao: ""
contraparte: "C:\\Software\\GeoCloud\\GeoCloudAI\\.agents\\tasks\\backlog\\GT-0046-cobertura-tempo-e-custo-do-modulo.md"
owner: ""
created_at: 2026-09-09
updated_at: 2026-09-09
affected_modules: ["Back.API", "Back.Application", "Back.Persistence", "Back.IntegrationTests"]
related_adrs: []
---

# GT-0046 — Cobertura, tempo e custo do fluxo de módulo

## Contexto

Terceira frente da auditoria ad-hoc de Dante Débito sobre a modularização (TASK-055/056/057). Cinco
achados que não são erros de lógica na leitura do código — são **ausência de prova** (TD-02),
**valor de tempo atravessando sem conversão** (TD-03), e **custo por requisição** (TD-09, TD-10,
TD-11).

Dois deles são de severidade alta. O TD-02 é o mais desconfortável: Dante reconstruiu as três
construções Dapper mais frágeis do repositório e **não achou defeito**. O achado é a ausência de
prova — a mesma forma do defeito de `users.password_hash`, que também passou revisão de leitura
antes de aparecer em produção.

Aprovado pelo dono do produto para correção na branch `feature/fix/refactor-08_09-11_09`.

## Achado original

### TD-02 (alta) — `GetByAccount` é a única consulta do módulo sem nenhuma execução contra banco real

`ModuleRepository.cs:39-59`. Concentra as três construções Dapper mais frágeis do arquivo, e cada
uma delas é a **única** do seu tipo no repositório:

- único **multi-map** com `splitOn: "id"` sobre 16 colunas — e **duas** dessas colunas se chamam
  `id` (`am.id` e `m.id`);
- única **coluna nova** (`trialStartedAt`);
- único **alias calculado** (`GrantsNow`, `BIGINT` do MySQL mapeado para `bool` em C#).

Se qualquer uma silenciar, `Grants` vem `false` e `Modules` vem vazio **para todos** — sem log, sem
exceção, com a suíte de testes verde.

Dante reconstruiu as três e **não achou defeito**. O achado é a ausência de prova, na mesma forma do
defeito de `users.password_hash`.

### TD-03 (alta) — hora local em conexão declarada UTC; o valor continua atravessando

`ModuleRepository` é o **único** repositório que grava hora local: `NOW()` / `NOW(6)`, **10
ocorrências**, numa conexão configurada com `DateTimeKind=Utc`
(`MySqlConnectionString.ApplySafeDefaults`). O resto do repositório usa `DateTime.UtcNow` ou
`UTC_TIMESTAMP(6)`.

A correção do `GrantsNow` na TASK-057 resolveu a **comparação** (comparar dois relógios). O **valor**
continua atravessando: `ModuleController.cs:264` grava na `userlog`

```csharp
$"Trial started for module {dto.ModuleCode}, ends at {result.EndsAt:u}"
```

O formato `:u` põe sufixo `Z` num instante que não é UTC — o registro de auditoria afirma um fuso
que o valor não tem.

### TD-09 (média) — `GetCapabilities` faz 6 consultas por chamada, uma repetida, uma inútil, e contorna o cache

- 6 consultas por chamada;
- `GetBillingStatus` chamado **duas vezes**: `ModuleService.cs:113` e de novo dentro de
  `ModuleAccessGate.cs:54`;
- `GetAllModuleMappedKeys` — o catálogo inteiro de chaves do produto — é carregado e **nunca lido**;
- contorna o cache `modgate:{userId}` que o `PermissionService` mantém.

### TD-10 (média) — invalidação sequencial dentro da requisição do cliente, e usuário inativo incluído

`InvalidateAccount` (`ModuleService.cs:217-224`) faz **3 `RemoveAsync` por usuário**, sequencialmente,
dentro da requisição de `startTrial` — que é disparada pelo cliente final, na tela, e cujo tempo de
resposta ele sente.

`GetUserIdsByAccount` não filtra usuário inativo, apesar de `IModuleRepository` documentar
"usuários **ativos**".

### TD-11 (baixa) — `registered: true` afirmado sobre um `void` que pode falhar em silêncio

`purchaseIntent` responde `registered: true` com base em `_userLogService.Register`, que é `void`,
apenas **enfileira**, e tem **3 saídas silenciosas no flush**. A resposta afirma um fato que não foi
verificado.

Além disso o detalhe é truncado em 200 caracteres, com `dto.Note` livre entrando depois de ~90
caracteres de prefixo — ou seja, uma nota do cliente com mais de ~110 caracteres perde o final sem
aviso.

## Objetivo

1. `GetByAccount` ter prova de execução contra banco real, cobrindo as três construções frágeis.
2. Nenhum valor de tempo do módulo afirmar um fuso que não tem.
3. `GetCapabilities` não repetir consulta, não carregar o que não lê, e não contornar o cache.
4. `startTrial` não pagar invalidação sequencial no tempo de resposta do cliente.
5. `registered` refletir um fato verificado, ou deixar de ser afirmado.

## Fora de escopo

- Reescrever `GetByAccount` para não usar multi-map. O achado é ausência de prova, não defeito
  encontrado — a correção é **testar**, não refatorar às cegas.
- Padronizar `NOW()` → UTC nos outros repositórios: `ModuleRepository` é o único com o problema.
- Refatorar `UserLogService` além do necessário para o TD-11.
- Comportamento do fluxo (`startTrial` degradando contrato, respostas de erro) — GT-0044.
- Fonte única da regra de concessão — GT-0045.

## Comportamento atual

- `GetByAccount`: nenhuma execução contra banco real. Falha silenciosa de mapeamento produziria
  `Grants=false` e `Modules` vazio para todos, com suíte verde.
- 10 `NOW()`/`NOW(6)` em conexão `DateTimeKind=Utc`; `userlog` grava `{EndsAt:u}`, com `Z` num
  instante que não é UTC.
- `GetCapabilities`: 6 consultas, `GetBillingStatus` duas vezes, catálogo carregado e não lido, cache
  `modgate:{userId}` contornado.
- `InvalidateAccount`: 3 `RemoveAsync` por usuário, sequenciais, dentro da requisição do cliente;
  usuários inativos incluídos contra a própria documentação.
- `purchaseIntent`: `registered: true` sobre um `void` com 3 saídas silenciosas; detalhe truncado em
  200 chars, `dto.Note` cortada sem aviso.

## Comportamento esperado

- Teste de integração exercitando `GetByAccount` contra o schema real, que falharia se o multi-map,
  a coluna nova, ou o alias calculado quebrassem.
- Instante gravado e instante formatado no mesmo fuso, com o sufixo dizendo a verdade.
- `GetCapabilities` sem consulta repetida, sem carga inútil, aproveitando o cache existente.
- Invalidação fora do caminho crítico da resposta ao cliente, restrita a usuários ativos.
- `registered` verificado, ou removido da resposta.

## Regras de negócio

- RN-01: `IModuleRepository` documenta "usuários ativos" em `GetUserIdsByAccount`. A implementação
  tem de cumprir o que a interface promete — ou a documentação muda, com o motivo registrado.
- RN-02: registro de auditoria (`userlog`) não pode afirmar fuso que o valor não tem. É evidência
  usada depois para reconstruir o que aconteceu e quando.
- RN-03: `registered` na resposta de `purchaseIntent` é afirmação ao cliente — só pode ser `true` se
  verificado.

## Critérios de aceitação

- [ ] CA-01: teste de integração executando `GetByAccount` contra o schema real, com conta que tem
      módulo Core e não-Core, `endDate` nulo e futuro, e `trialStartedAt` preenchido e nulo.
- [ ] CA-02: o teste de CA-01 assere `Grants`/`GrantsNow` **e** `Module` populado — o multi-map com
      duas colunas `id` e o alias `BIGINT`→`bool` só se provam por asserção sobre valor, não por
      "não lançou exceção".
- [ ] CA-03: as 10 ocorrências de `NOW()`/`NOW(6)` em `ModuleRepository` são resolvidas —
      padronizadas para UTC — **ou** a decisão de mantê-las é registrada com a conversão explícita
      no ponto de leitura.
- [ ] CA-04: `ModuleController.cs:264` não grava mais `Z` num instante que não é UTC. O `userlog`
      registra o instante no fuso que ele declara.
- [ ] CA-05: `GetBillingStatus` é chamado uma vez por `GetCapabilities` — a duplicação entre
      `ModuleService.cs:113` e `ModuleAccessGate.cs:54` deixa de existir.
- [ ] CA-06: `GetAllModuleMappedKeys` não é mais carregado sem ser lido em `GetCapabilities` — ou
      passa a ser lido (ver CA-08 da GT-0045), ou deixa de ser carregado.
- [ ] CA-07: `GetCapabilities` aproveita o cache `modgate:{userId}` do `PermissionService`, ou o
      motivo de não aproveitar está registrado.
- [ ] CA-08: `InvalidateAccount` não faz N×3 `RemoveAsync` sequenciais dentro da requisição de
      `startTrial` — invalidação em lote, paralela, ou fora do caminho de resposta.
- [ ] CA-09: `GetUserIdsByAccount` filtra usuário inativo, cumprindo o que `IModuleRepository`
      documenta — ou a documentação é corrigida com o motivo.
- [ ] CA-10: `purchaseIntent` só responde `registered: true` sobre um fato verificado; se
      `_userLogService.Register` continua `void` e enfileirando, o campo sai da resposta ou muda de
      semântica declaradamente.
- [ ] CA-11: `dto.Note` não é truncada em silêncio — validação de tamanho na entrada, ou o truncamento
      preserva a nota e não o prefixo.
- [ ] CA-12: nenhuma das correções de custo (CA-05 a CA-08) altera **quais** capacidades são
      concedidas. Teste comparando o resultado de `GetCapabilities` antes e depois.

## Impacto técnico

### Backend
`ModuleRepository`: `NOW()` → UTC (ou conversão explícita registrada); filtro de usuário ativo.
`ModuleService`: `GetCapabilities` sem consulta repetida e sem carga inútil; `InvalidateAccount` fora
do caminho crítico.
`ModuleController`: formatação de instante no `userlog`; `registered` e truncamento de `Note`.

### Frontend
Nenhum contrato novo, exceto se CA-10 retirar `registered` da resposta de `purchaseIntent` — nesse
caso, verificar quem consome o campo na tela.

### Banco de dados
Nenhuma migration. TD-03 é conversão na aplicação, não mudança de tipo de coluna. **Atenção**: dados
já gravados por `NOW()` local permanecem no fuso local — a correção não os reescreve, e isso precisa
ficar registrado (ver Riscos).

### Integrações
Nenhuma.

### Segurança
Indireto: `userlog` é a trilha de auditoria. Instante com fuso errado degrada a capacidade de
reconstruir o que aconteceu — o que importa exatamente num registro de início de teste comercial.

## Plano de implementação

- [ ] Etapa 1 (TD-02): teste de integração de `GetByAccount` contra o schema real, com asserção
      sobre valor. É a primeira etapa de propósito: sem ela, nenhuma das outras mudanças no
      repositório tem rede.
- [ ] Etapa 2 (TD-03): padronizar as 10 ocorrências de `NOW()` e corrigir `{EndsAt:u}`.
- [ ] Etapa 3 (TD-09): remover a chamada duplicada de `GetBillingStatus` e a carga não lida.
- [ ] Etapa 4 (TD-09): aproveitar o cache `modgate:{userId}`, ou registrar por que não.
- [ ] Etapa 5 (TD-10): invalidação em lote/fora do caminho crítico; filtro de usuário ativo.
- [ ] Etapa 6 (TD-11): `registered` verificado ou removido; truncamento de `Note` resolvido.

## Estratégia de testes

- [ ] Unitários: `GetCapabilities` com o número de chamadas ao repositório asserido (é o que impede a
      duplicação de voltar); truncamento de `Note`.
- [ ] Integração: `GetByAccount` contra o schema real (CA-01/CA-02) — o núcleo desta task;
      `GetUserIdsByAccount` com usuário inativo na conta.
- [ ] E2E: N/A.
- [ ] Manual: `startTrial` em conta com muitos usuários, medindo o tempo de resposta antes e depois
      da Etapa 5; e conferência do instante gravado na `userlog` contra o relógio real.

## Riscos e rollback

Risco 1 — o mais sutil: padronizar `NOW()` para UTC muda o **valor** gravado, mas os registros
**já existentes** continuam no fuso local. Comparações entre linhas antigas e novas ficam
inconsistentes até o dado antigo ser tratado. Isso precisa ser decidido e registrado antes da Etapa
2, não descoberto depois.

Risco 2: as correções de custo (Etapas 3 a 5) mexem em quem resolve a concessão. Se uma delas mudar
**quais** capacidades são concedidas, o cliente perde ou ganha acesso sem que ninguém tenha
decidido. CA-12 existe para pegar isso.

Risco 3: mover a invalidação para fora do caminho de resposta reintroduz a janela que a TASK-057
fechou de propósito (CA-02 daquela task: o usuário que acabou de aceitar o teste veria a mesma tela
de oferta). A correção do TD-10 precisa reduzir o custo **sem** reabrir essa janela.

Rollback: a Etapa 1 é aditiva (só teste) e não tem risco. As demais são reversíveis isoladamente.

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

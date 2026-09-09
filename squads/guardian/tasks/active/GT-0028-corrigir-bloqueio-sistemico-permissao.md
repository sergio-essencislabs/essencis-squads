---
id: GT-0028
title: "Corrigir bloqueio sistêmico de permissão (403 global no interceptor + grant ausente de chat.drillbox/summary)"
status: active
type: feature
achado_origem: "QA-Matheus-2026-09-03 (Observações gerais, linhas 3 e 7 de TASKS.md)"
auditor_origem: "Matheus Lima Santos de Souza (QA manual) — roteado por Jarvis"
severidade: "Crítica — bloqueia toda a Onda 2 (Images, E2-01 a E2-07)"
produto: GeoCloudAI
camada: cross-cutting
run_origem: "adhoc-jarvis-qa-pos-implementacao-2026-09-03"
issue_url: ""
grupo_execucao: "Correção pós-QA — prioridade máxima"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [permissions, images-viewer, chat-ia]
related_adrs: []
---

# GT-0028 — Corrigir bloqueio sistêmico de permissão

## Contexto
QA (Matheus) reportou que o usuário Administrator (e todo usuário testado) recebe 403 ao abrir qualquer guia de Images, e a tela inteira redireciona para o Dashboard — impossibilitando testar E2-01 a E2-07 por completo.

## Achado original
Trecho literal de `TASKS.md` (relatório de QA, 2026-09-03):
> "Causa raiz do bloqueio de permissão: error.interceptor.ts:54-58 redireciona qualquer resposta 403 para o Dashboard, de qualquer chamada. O endpoint Chat/drillbox/summary (resumo de IA) retorna 403 para todo usuário testado, inclusive Administrator, e essa chamada secundária derruba a página inteira."

## Investigação de causa raiz (Jarvis, 2026-09-03)
Confirmado por leitura direta do código real (não só do relatório):

1. **`chat.drillbox/summary` nunca foi concedida a nenhum perfil.** A migration `M20260902194727_ChatDrillBoxSummaryPermission` (GT-0009) só insere a chave no catálogo `functionality` — nunca em `profilefunctionality`. Isso foi uma decisão **documentada e deliberada** de GT-0009 na época ("concessão a perfil é passo manual via Settings > Profiles"), mas o passo manual nunca foi executado antes da QA.
2. **Não existe nenhum mecanismo automático que estenda permissões novas ao perfil Administrator.** `PermissionMiddleware.cs` → `PermissionService.HasPermissionAsync()` faz checagem estrita de conjunto (`permissions.Contains(permissionKey)`), sem nenhum bypass/wildcard para Administrator. `FunctionalityRepository.GetByActivesUser()` é um `INNER JOIN` estrito contra `profilefunctionality` — sem essa linha, nenhum usuário (nem Administrator) passa.
   - **Discrepância com a Library (VaultS)**: `S - GeoCloudAI - Engineering Memory.md` registra "Corrigido: perfil Administrator/Administrador passa a receber todas as keys ativas + sentinela `*`". Confirmado que isso foi um **dump estático one-time** em `mysql_baseline_v2.sql` (`profilefunctionality` como tabela de dados fixos, `AUTO_INCREMENT=3252`) — cobre as keys que existiam no momento da baseline, **não** se estende a nenhuma key criada por migration depois disso. A "correção" documentada nunca foi um mecanismo vivo.
3. **`error.interceptor.ts` (pré-existente, não introduzido por este projeto) redireciona a tela inteira em QUALQUER 403**, de qualquer chamada HTTP da aplicação — inclusive chamadas secundárias/não-críticas como o badge de resumo de IA (GT-0009), que é carregado em paralelo ao conteúdo principal da tela. Isso significa que **qualquer permissão faltante em qualquer chamada em segundo plano** derruba a tela inteira, não só a feature específica sem permissão.

## Objetivo
1. Administrator passa a ter acesso incondicional a toda funcionalidade do sistema, presente e futura — sem depender de nenhum grant manual, hoje ou daqui pra frente (**decisão do usuário, 2026-09-03**).
2. Continuar permitindo associar qualquer permissão (nova ou existente) a outros perfis/usuários pela interface já existente (Settings > Profiles) — **decisão do usuário, 2026-09-03**.
3. Tornar `error.interceptor.ts` tolerante a 403 de chamadas não-críticas, para que uma permissão faltante numa chamada secundária não derrube a navegação inteira do usuário.

## Decisão do usuário (2026-09-03) — substitui a seção "Opções" abaixo
> "Em caso de novas permissões, o administrador sempre deve receber. O Administrador sempre tem todas as permissões, só assim podemos realizar todos os testes possíveis. Também deve ser possível associar novas permissões a novos users pela interface do front."

**Confirmada a Opção 1 (bypass real)**, não a Opção 2 recomendada originalmente pelo Jarvis — o usuário quer uma garantia incondicional ("sempre"), não uma lista de grants que possa ficar desatualizada. Implementação decidida:

- **Não usar match por `profile.Name == "Administrator"`** (frágil — a coluna é texto livre, editável via UI, sem garantia de não ser renomeada). Em vez disso, **nova coluna `profile.isSystemAdmin` (boolean, default `false`)**, migration de dados retroativa marcando `true` em todo profile hoje chamado `'Administrator'` (único texto usado por `AccountRegistrationRepository.cs:352`, confirmado como o único ponto de criação de profile administrador no código).
- `PermissionService.HasPermissionAsync()`: se o perfil do usuário tiver `isSystemAdmin=true`, retorna `true` imediatamente — sem consultar `profilefunctionality`. Nenhuma migration futura precisa lembrar de conceder nada ao Administrator.
- **Ponto 2 (associar a outros perfis pela UI) já está satisfeito pelo mecanismo existente**: `web/src/app/pages/settings/profile-functionalities/` já lista TODAS as `functionality` ativas dinamicamente (via `FunctionalityService.getByActivesAccounts`, não uma lista hardcoded) para atribuição a qualquer perfil não-administrador — confirmado por leitura de código. `chat.drillbox/summary` (e qualquer key nova futura) já aparece lá automaticamente assim que a migration que a cria roda. Nenhum trabalho de frontend novo necessário para este ponto — só confirmar via teste manual que a key realmente aparece na lista (CA-05 abaixo).

## Fora de escopo
Revisão completa de todas as permissões já existentes no sistema (fora do escopo desta correção pontual) — só a política daqui pra frente e o desbloqueio do achado específico.

## Comportamento atual
Qualquer 403 (de qualquer chamada) redireciona para `/` via `Router.navigate`. Novas `functionality` keys não são concedidas a ninguém automaticamente, nem ao Administrator.

## Comportamento esperado
- Administrator (e perfis decididos) conseguem acessar `Chat/drillbox/summary` sem 403.
- Uma nova permission key criada por migration não derruba silenciosamente uma tela inteira caso o grant seja esquecido de novo.
- 403 de uma chamada não-crítica (enriquecimento/badge) não redireciona a navegação — só a feature específica falha graciosamente.

## Regras de negócio
- RN-01: Administrator deve manter acesso a toda funcionalidade ativa do sistema, incluindo as criadas depois do baseline — este é o princípio de produto por trás do achado do usuário ("mesmo que tenha criado novas permissões deveriam obviamente ser concedidas a mim").

## Critérios de aceitação
- [x] CA-01: Coluna `profile.isSystemAdmin` criada; todo profile hoje chamado `Administrator` marcado `true` (migration retroativa). Implementado em `M20260903151617_ProfileIsSystemAdmin.cs`. Não aplicado contra um MySQL real neste sandbox (sem `DATABASE_URL`/servidor disponível) — validado por build + `MigrationVersionTests` (unicidade, formato timestamp, nome de classe). Aplicação real e verificação pós-`MigrateUp()` ficam pendentes para quem tiver acesso a um MySQL de fato.
- [x] CA-02: `PermissionService.HasPermissionAsync()` concede acesso incondicional quando `isSystemAdmin=true`, sem consultar `profilefunctionality` — confirmado por teste automatizado com uma permissão hipotética (`hypothetical.brandNewFeature.neverSeeded`) nunca inserida em `profilefunctionality`/`functionality`, ver `PermissionServiceTests.HasPermissionAsync_ReturnsTrue_ForSystemAdmin_OnAKeyNeverGrantedInProfileFunctionality`. Também comprovado que a checagem nem chama `IFunctionalityService.GetByActivesUser` nesse caso.
- [x] CA-03: `error.interceptor.ts` não redireciona a navegação para 403 de chamadas marcadas como não-críticas (`NON_CRITICAL_REQUEST` HttpContextToken); a chamada falha isoladamente. `ChatService.getDrillBoxSummary` (badge de resumo de IA) marcado como não-crítico. Testes automatizados em `error.interceptor.spec.ts` cobrindo os dois caminhos (redireciona / não redireciona). `ng build --configuration development` e `ng test` — ver seção Validação para o resultado real.
- [ ] CA-04: Retestar manualmente E2-01 a E2-07 (Images) depois da correção — **não executado neste sandbox** (sem MySQL/API/frontend rodando de ponta a ponta disponíveis no ambiente de execução deste agente). Pendente para QA (Matheus) ou outra sessão com acesso a um ambiente completo.
- [ ] CA-05: Confirmado **por leitura de código** (não por captura de tela real) que `chat.drillbox/summary` aparece dinamicamente em Settings > Profiles: `profile-functonalities.component.ts:93` chama `FunctionalityService.getByActivesAccounts(...)`, que no backend lê `functionality WHERE active=1` sem lista hardcoded — a key do GT-0009 já está `active=1` desde `M20260902194727_ChatDrillBoxSummaryPermission`. Nenhuma mudança de código foi necessária, conforme já esperado pela task. Falta a confirmação visual real (fora do alcance deste sandbox) — mesma pendência de ambiente do CA-04.
- [x] CA-06: `AccountRegistrationRepository.cs` (linha ~356, antiga 352) agora grava `isSystemAdmin=1` na criação do profile Administrator. Busca completa por `INSERT INTO profile` e pela literal `'Administrator'` em todo `api/src` confirma que este é o **único** ponto de criação de profile em runtime: não existe script de seed do GT-0001 no código (`grep -r "GT-0001" api/` não retornou nada), e `UserInviteRepository` nunca cria um profile novo — só referencia um `profileId` já existente ao vincular o usuário convidado. Ver Divergências.

## Impacto técnico
### Backend
- `Back.Domain/Classes/Profile.cs` — novo campo `IsSystemAdmin`.
- Migration de schema (`profile.isSystemAdmin`) + migration de dados (retroativa: `UPDATE profile SET isSystemAdmin=1 WHERE name='Administrator'`).
- `PermissionService.HasPermissionAsync()` — bypass incondicional quando `isSystemAdmin=true` (checar antes do `INNER JOIN` de `profilefunctionality`, sem removê-lo — continua servindo os demais perfis).
- `AccountRegistrationRepository.cs:352` (autocadastro) — passa a gravar `isSystemAdmin=1` na criação do profile Administrator. Conferir também o fluxo de seed (GT-0001) e qualquer outro ponto de criação de conta/profile administrador antes de fechar CA-06.
### Frontend
`error.interceptor.ts` — mecanismo para marcar uma requisição como não-crítica (ex.: `HttpContext` token) e os call sites que hoje disparam 403 esperados em segundo plano (ao menos o badge de resumo de IA do GT-0009) passam a usar essa marcação.
### Banco de dados
Migration de schema (`profile.isSystemAdmin`) + migration de dados retroativa (CA-01).
### Segurança
Mudança sensível de modelo de permissão — revisar com o agente global `geocloud-permission-auditor` antes de mergear, por regra do `.claude/rules/global.md`. Ponto de atenção: `isSystemAdmin` é por-perfil (dentro de uma conta), não um super-admin global entre contas — confirmar que o bypass nunca vaza para fora do `AccountId` do próprio usuário (o resto do pipeline de tenant continua vigente; isto só afeta a checagem de `[RequiredPermission]`, não `AccountIdToken`).

## Plano de implementação
- [x] Migration de schema `profile.isSystemAdmin` + migration de dados retroativa (CA-01).
- [x] `PermissionService.HasPermissionAsync()` — bypass incondicional (CA-02).
- [x] `AccountRegistrationRepository.cs` + demais pontos de criação de Administrator (CA-06).
- [x] Ajustar `error.interceptor.ts` (CA-03) + call site do badge de resumo de IA.
- [x] Confirmar CA-05 (key nova já aparece em Settings > Profiles) sem mudança de código — confirmado por leitura de código; falta confirmação visual (ambiente indisponível neste sandbox).
- [ ] Retestar E2-01 a E2-07 — pendente de ambiente completo (ver CA-04).

## Estratégia de testes
- [x] Automatizado — `api/tests/Back.UnitTests/Permissions/PermissionServiceTests.cs` (5 casos: bypass em chave nunca concedida, bypass incondicional para qualquer chave, não-admin sem a chave nega, não-admin com a chave concede, userId inválido nunca vira bypass) + `web/src/app/core/helpers/error.interceptor.spec.ts` (2 casos novos: redireciona em 403 crítico, não redireciona em 403 marcado `NON_CRITICAL_REQUEST`).
- [ ] Manual — reabrir Images com um usuário Administrator real, confirmar ausência de redirect para Dashboard; confirmar visualmente que `chat.drillbox/summary` aparece em Settings > Profiles para um perfil comum. **Não executado neste sandbox** (sem ambiente completo rodando) — pendente para QA/próxima sessão com acesso a MySQL + API + frontend.

## Riscos e rollback
Mudar a semântica de permissão de Administrator é sensível — revisão de segurança obrigatória antes do merge (ver Impacto técnico/Segurança). **Esta revisão (`geocloud-permission-auditor`) ainda NÃO foi feita** — ver Handoff.

Rollback: a migration `M20260903151617_ProfileIsSystemAdmin` reverte de forma limpa via `Down()` (dropa a coluna `isSystemAdmin`, guardado por `Schema.Table(...).Column(...).Exists()`), o que automaticamente desliga o bypass (a checagem em `PermissionService` volta a nunca encontrar `isSystemAdmin=true` porque a coluna não existiria — mas note que isso quebraria a query em `ProfileRepository.IsSystemAdminForUser`, então `Down()` só deve ser usado revertendo também o deploy do código, nunca isoladamente contra código já rodando em produção).

## Registro de execução

### Alterações realizadas
1. **Nova coluna `profile.isSystemAdmin`** (tinyint(1), default 0) via migration nova, com backfill retroativo de todo profile `name = 'Administrator'`.
2. **`PermissionService.HasPermissionAsync()`** passa a checar `IsSystemAdminAsync(userId)` antes de qualquer coisa; se verdadeiro, retorna `true` sem tocar em `profilefunctionality`/`functionality`. Checagem cacheada em `sysadmin:{userId}` (mesmo padrão de TTL de `perms:{userId}`); `InvalidateCacheAsync` agora limpa as duas chaves.
3. **Novo método `IProfileRepository.IsSystemAdminForUser(int userId)`** (Dapper puro, `SELECT EXISTS(...)` com o mesmo padrão de JOIN de `FunctionalityRepository.GetByActivesUser`, mas checando `profile.isSystemAdmin` em vez de `profilefunctionality`) e o correspondente `IProfileService.IsSystemAdminForUser` (sem instrumentação de auditoria — mesma convenção de `FunctionalityService.GetByActivesUser`, roda em toda request autenticada).
4. **`AccountRegistrationRepository.cs`** grava `isSystemAdmin=1` já na criação do profile Administrator do autocadastro.
5. **Frontend**: novo `HttpContextToken<boolean>` `NON_CRITICAL_REQUEST` (`http-context-tokens.ts`, primeiro uso desse padrão no projeto); `error.interceptor.ts` só redireciona para `/` em 403 se a requisição não estiver marcada; `ChatService.getDrillBoxSummary` marca sua chamada como não-crítica.
6. **Testes**: `PermissionServiceTests.cs` (backend, 5 casos) e 2 casos novos em `error.interceptor.spec.ts` (frontend).

### Arquivos principais
- `api/src/Back.Persistence/Migrations/M20260903151617_ProfileIsSystemAdmin.cs` (novo)
- `api/src/Back.Domain/Classes/Profile.cs`
- `api/src/Back.Persistence/Contracts/IProfileRepository.cs`
- `api/src/Back.Persistence/Repositories/ProfileRepository.cs`
- `api/src/Back.Application/Contracts/IProfileService.cs`
- `api/src/Back.Application/Services/ProfileService.cs`
- `api/src/Back.Application/Middlewares/PermissionService.cs`
- `api/src/Back.Persistence/Repositories/AccountRegistrationRepository.cs`
- `api/tests/Back.UnitTests/Permissions/PermissionServiceTests.cs` (novo)
- `web/src/app/core/helpers/http-context-tokens.ts` (novo)
- `web/src/app/core/helpers/error.interceptor.ts`
- `web/src/app/core/helpers/error.interceptor.spec.ts`
- `web/src/app/services/chat.service.ts`

### Decisões
1. **`Profile.IsSystemAdmin` deliberadamente ausente de `ProfileDto`/`BackProfile` (AutoMapper).** `ProfileController.add`/`update` são alcançáveis por qualquer usuário `OwnerAccountToken` da própria conta; se o campo fizesse round-trip pelo DTO, um admin de tenant poderia se autoconceder bypass incondicional de qualquer `[RequiredPermission]` do sistema só dando `PUT` no próprio perfil com `isSystemAdmin: true`. Column só é escrita pela migration (retroativa) e por `AccountRegistrationRepository` (no cadastro). Mesmo padrão de segurança já usado em `BackProfile.cs` para `PasswordHash`/`CodeHash` em outros mapeamentos (`.ForMember(...).Ignore()`) — aqui a proteção é "nem declarar o campo no DTO", já que não há membro correspondente para ignorar.
2. **Cache dedicado `sysadmin:{userId}`, TTL igual ao de `perms:{userId}`** (0.1 min em dev, comentário already there for 5 min em produção) em vez de embutir um sentinela `"*"` dentro do `HashSet<string>` de permissões — reutiliza a infraestrutura de cache existente sem misturar semânticas (permissão vs. papel).
3. **Método de bypass não instrumentado em auditoria** (`IUserLogService`) — roda em toda requisição autenticada; mesma convenção documentada em `FunctionalityService.GetByActivesUser` (evitar inundar o audit log).
4. **CA-06 confirmado por busca exaustiva**: `grep` por `INSERT INTO profile` e pela literal `'Administrator'` em todo `api/src` retorna só `AccountRegistrationRepository.cs`. `ProfileRepository.Add` (endpoint genérico `Profile.add`) aceita qualquer nome vindo do `ProfileDto`, inclusive literalmente "Administrator" digitado por um usuário comum — isso é aceitável e não deve setar `isSystemAdmin`, porque é um profile arbitrário de tenant, não o profile administrador real gerado pelo autocadastro (por isso a decisão original da task de não fazer match por `name == "Administrator"` estava certa). `UserInviteRepository` nunca insere em `profile`, só referencia um `profileId` existente. Nenhum script de seed do "GT-0001" foi encontrado no código (`api/docs/system/dev-data-seed.md` também não menciona criação de Administrator fora do autocadastro).
5. **Branch criada a partir de `origin/feature/visualizadores-navegacao-layout`** (não `main`), que já contém `M20260902194727_ChatDrillBoxSummaryPermission` (GT-0009) — não recriei essa migration, apenas dependo dela para os testes de CA-02.
6. Nova migration numerada `20260903151617` (UTC, gerado com `date -u +%Y%m%d%H%M%S` no momento da criação do arquivo), seguindo a convenção documentada em `Migrations/README.md` — não é continuação de nenhuma sequência antiga.

### Divergências
- A task original levantava a hipótese de existir um seed do GT-0001 ou um fluxo de convite que também criasse profiles Administrator. Busca completa no código não encontrou nenhum dos dois — `AccountRegistrationRepository.cs` é de fato o único ponto, confirmando (não contradizendo) a suposição da task. Registrado aqui porque a task pedia explicitamente essa verificação antes de fechar CA-06.
- Não foi possível aplicar a migration contra um MySQL real nem rodar a suíte `Back.IntegrationTests`/`Back.ApiTests` neste sandbox — sem `DATABASE_URL` configurado, toda a suíte de integração falha com `System.InvalidOperationException: DATABASE_URL must be set for integration tests` (falha de infraestrutura do ambiente de execução deste agente, não do código; mesma limitação já registrada em memória de sessões anteriores).
- CA-04 e a parte manual de CA-05 não puderam ser executadas por falta de um ambiente de ponta a ponta (MySQL + API + frontend) neste sandbox.

### Pendências
- **Revisão de segurança pelo `geocloud-permission-auditor`** antes do merge — obrigatória por `.claude/rules/global.md`, ainda não acionada (fora do escopo desta execução, mas bloqueante para o merge final).
- Aplicar a migration num ambiente real e confirmar que `MigrateUp()` roda limpo no boot da API (`MigrationRunnerExtensions`).
- CA-04 (reteste manual E2-01 a E2-07) e a parte visual de CA-05 (screenshot real de Settings > Profiles com um perfil comum).
- Considerar (fora do escopo desta task, mas observado durante a investigação): se um dia existir um segundo "system-owner" de fato multi-tenant (hoje representado por `EntityIdToken == 1`), reavaliar se `isSystemAdmin` deveria também ser uma trava adicional ali — por ora os dois mecanismos são independentes e isso está correto por design (`isSystemAdmin` é por-perfil dentro de uma conta, nunca cruza `AccountId`).

## Validação

Comandos executados neste sandbox (`api/` a partir de `C:\Software\GeoCloud\GeoCloudAI\.claude\worktrees\agent-a96897cef987f4238`):

```
cd api && dotnet build Back.sln
# Compilação com êxito. 0 Erro(s), 6 avisos pré-existentes (NU1903 AutoMapper, CS8604 nullability em UserService.cs).
```

```
cd api && dotnet test tests/Back.UnitTests/Back.UnitTests.csproj
# Aprovado: 119, Falhou: 1, Total: 120.
# A única falha (ForeignKeyRangeValidationTests.Writable_foreign_keys_follow_the_range_convention,
# DrillBoxChatSendDto.DrillBoxId sem [Range]) é uma baseline quebrada pré-existente, sem relação com
# este PR (documentada antes desta sessão). As 5 novas PermissionServiceTests passam, assim como os
# 3 testes de MigrationVersionTests (unicidade, timestamp válido, nome de classe).
```

```
cd api && dotnet test tests/Back.IntegrationTests/Back.IntegrationTests.csproj
# 12/12 falham com "DATABASE_URL must be set for integration tests" — limitação de ambiente
# deste sandbox (sem MySQL/DATABASE_URL configurados), não regressão introduzida por este PR.
```

Frontend (`web/` no mesmo worktree, após `npm ci`):

```
npx ng build --configuration development
# Application bundle generation complete. Exit code 0.
# 3 warnings NG8107 pré-existentes (login2, drill-hole-view-mult, drillholes-view-3d),
# nenhum relacionado a error.interceptor.ts / chat.service.ts / http-context-tokens.ts.
```

```
npx ng test --watch=false --browsers=ChromeHeadless --include='src/app/core/helpers/error.interceptor.spec.ts'
# Chrome Headless 152.0.0.0 (Windows 10): Executed 6 of 6 SUCCESS (0.086 secs / 0.026 secs)
# TOTAL: 6 SUCCESS — as 4 specs originais de getHttpErrorMessage + as 2 specs novas de
# ErrorInterceptor (redireciona em 403 crítico; não redireciona quando NON_CRITICAL_REQUEST).
```

Não rodei a suíte `ng test` completa (sem filtro) neste sandbox: sessões anteriores já registraram em memória uma baseline quebrada pré-existente de ~97/123 specs falhando por um import circular em `mine-view` (`ReferenceError: Cannot access 'MineViewDrillBoxesComponent' before initialization`), sem relação com este PR. Rodar a suíte completa antes do merge é recomendado para confirmar que essa baseline não piorou, mas os arquivos tocados por este PR foram validados isoladamente acima.

## Handoff
Bloqueia o reteste de E2-01 a E2-07 (GT-0005, GT-0006, GT-0007, GT-0008, GT-0009, GT-0011). Task nova, criada a partir do relatório de QA de Matheus (2026-09-03), roteada por Jarvis.

**Implementação concluída nesta sessão** (branch `fix/gt-0028-permission-systemic-bypass`, a partir de `origin/feature/visualizadores-navegacao-layout`). PR aberto: **https://github.com/Essencis-Labs/GeoCloudAI/pull/377** (contra `feature/visualizadores-navegacao-layout`, conforme regra do projeto — nunca `main`).

## Revisão de segurança (`geocloud-permission-auditor`, 2026-09-03)

**Veredito: Aprovado com ressalvas.** Confirmado por leitura de código + build/teste independentes: o bypass é corretamente escopado por tenant (não cruza `AccountId`), não há caminho de escalação de privilégio via API/DTO (`isSystemAdmin` nunca é gravável por fora dos 2 pontos já confirmados), e o cache duplo (`sysadmin:{userId}`/`perms:{userId}`) é invalidado de forma consistente **quando `InvalidateCacheAsync` é chamado**.

**2 ressalvas antes do merge final para `main`/produção** (não bloqueiam o merge para a branch de integração, mas são obrigatórias antes do deploy real):
1. **Migration retroativa por nome (`WHERE name='Administrator'`) é frágil contra dado legado** — se alguma conta real já renomeou seu perfil Administrator original, ou tem colisão de nome com um perfil diferente/limitado, o backfill erra (sub ou sobre-concessão). Rodar antes do deploy: `SELECT accountId, COUNT(*) FROM profile WHERE name='Administrator' GROUP BY accountId HAVING COUNT(*) > 1` (detecta colisão) e comparar por conta se o perfil `'Administrator'` é o de `MIN(register)` (detecta renome). Considerar migrar o predicado para ancorar em `register = MIN(register) por accountId` em vez de só o nome.
2. **`InvalidateCacheAsync` nunca é chamado em lugar nenhum do código** (achado novo, não introduzido por este PR mas agora mais crítico — o cache que ele limparia agora inclui o bypass total, não só uma permissão isolada). Revogar o status de sysadmin de alguém hoje só tem efeito depois do TTL expirar. O TTL real em produção está **comentado como "5 minutes" mas o código que executa é 0.1 minuto (6s)** — funciona por acidente hoje, mas quebra silenciosamente se alguém "corrigir" esse comentário no futuro. Ação recomendada: ligar `InvalidateCacheAsync` aos pontos de mutação de `userprofile`/perfil, ou documentar explicitamente que o TTL de 6s é a SLA de revogação pretendida.
3. Não bloqueante: rodar a campanha padrão de permissões (`geocloud-permission-tests`) focada em "toda action `[RequiredPermission]` também tem checagem de tenant própria, independente da permissão" — o bypass torna qualquer lacuna nesse padrão automaticamente alcançável por sysadmins sem grant manual.

**PR #377 mesclado (squash) em `feature/visualizadores-navegacao-layout`.** Ressalvas #1 e #2 acima **ficam registradas como bloqueantes para quando este branch for eventualmente mesclado em `main`** — não esquecer antes desse passo.

## Correção da ressalva #2 (backend-api, 2026-09-03)

Fast-follow para a ressalva #2 da revisão de segurança acima (`InvalidateCacheAsync` nunca chamado + ambiguidade do TTL). Branch `fix/gt-0028-permission-cache-invalidation`, a partir de `origin/feature/visualizadores-navegacao-layout` (já contém o PR #377 mesclado). PR aberto: **https://github.com/Essencis-Labs/GeoCloudAI/pull/385** (contra `feature/visualizadores-navegacao-layout`, nunca `main`).

### Mapeamento dos pontos de mutação
Antes de decidir onde inserir as chamadas, li `UserProfileController.cs`, `ProfileFunctionalityController.cs` e os services/repositories relacionados. Achado chave: **`Profile.IsSystemAdmin` não pode ser alterado via API** — o campo é deliberadamente ausente de `ProfileDto` (ver Decisão #1 da seção "Registro de execução" acima) e `ProfileRepository.Update`/`Add` nunca tocam a coluna `isSystemAdmin` no SQL. Isso significa que **vincular/desvincular linhas de `userprofile` é o único caminho em runtime que muda o status de sysadmin de um usuário** — não existe um terceiro caminho via `ProfileController.Update` alterando o flag de um perfil já existente. Essa confirmação foi o que permitiu escolher a opção (b) do TTL (ver abaixo) com confiança, em vez de recorrer à opção (a) por cautela.

Mapeamento completo dos pontos que afetam `perms:{userId}` e/ou `sysadmin:{userId}`:
- `UserProfileService.Add/Update/Delete` — ganhar/perder vínculo com um perfil (inclui fechar `endDate`, trocar de perfil, ou mover o vínculo para outro `userId_`). Afeta ambas as chaves de cache.
- `ProfileFunctionalityService.Add/AddAll/Delete/DeleteAll` — mudar o que um perfil concede afeta todo usuário atualmente vinculado a esse perfil (não só quem fez a chamada). Afeta só `perms:{userId}` (sysadmin não depende de `profilefunctionality`).
- Fluxo de autocadastro (`AccountRegistrationRepository`, cria profile+userprofile+user na mesma transação) não precisa de invalidação — usuário é novo, não tem entrada de cache pré-existente para limpar.

### Implementação
- `UserProfileService.Add/Update/Delete`: chamam `IPermissionService.InvalidateCacheAsync` para cada `userId_` afetado, só em caso de sucesso. `Update` invalida tanto o `userId_` antigo quanto o novo (cobre o caso de mover o vínculo); `Delete` busca a linha antes de apagar (senão o `userId_` afetado se perde).
- `ProfileFunctionalityService.Add/Delete/DeleteAll`: novo helper `InvalidateCacheForProfileAsync(profileId)` busca todo usuário ativo vinculado ao perfil (`IUserProfileRepository.GetActiveUserIdsByProfile`, query nova e leve, sem os 4 JOINs de `GetByProfile`) e invalida cada um. `AddAll` já delega para `DeleteAll` + `Add` em loop, então herda a invalidação sem código extra.
- Nenhuma mudança de schema além da query nova (sem migration — `GetActiveUserIdsByProfile` só lê `userprofile`, tabela já existente).

### Decisão do TTL: opção (b)
Como o mapeamento acima é comprovadamente exaustivo (não existe terceiro caminho de mutação), escolhi a **opção (b)**: `PermissionService` agora usa `IHostEnvironment.IsDevelopment()` (mesmo padrão já usado em `EmailService`) para escolher o TTL — 5 minutos real em produção, 6 segundos (0.1 min) em desenvolvimento para feedback rápido local. O comentário enganoso ("Production: 5 minutes" comentado, código de 0.1 min rodando de verdade em todo ambiente) foi eliminado; a lógica agora é uma propriedade `CacheTtl` única, documentada, usada nos dois pontos de `SetStringAsync` (perms e sysadmin). O TTL de produção passa a ser uma rede de segurança contra bug de invalidação, não o mecanismo primário de revogação.

### Testes adicionados
- `api/tests/Back.UnitTests/Permissions/UserProfileServiceCacheInvalidationTests.cs` (novo, 7 casos) — cobre Add/Update/Delete invalidando o(s) `userId_` certo(s) em sucesso, incluindo o cenário nomeado explicitamente no achado (fechar `endDate`), e confirma que uma mutação que falha (ex.: usuário já tem perfil ativo) não toca o cache.
- `api/tests/Back.UnitTests/Permissions/ProfileFunctionalityServiceCacheInvalidationTests.cs` (novo, 6 casos) — cobre Add/Delete/DeleteAll invalidando todo usuário ativo do perfil em sucesso, e que falha não invalida.
- `PermissionServiceTests.cs` (existente, +5 casos) — `InvalidateCacheAsync` limpa as duas chaves; seleção de TTL por ambiente (produção = 5 min, desenvolvimento = 6s) tanto para o cache de permissões quanto para o de sysadmin.

### Validação
```
cd api && dotnet build Back.sln
# Compilação com êxito. 0 Erro(s), mesmos 6 avisos pré-existentes de antes (NU1903 AutoMapper, CS8604 UserService.cs).
```
```
cd api && dotnet test tests/Back.UnitTests/Back.UnitTests.csproj --filter "FullyQualifiedName~Permissions"
# Aprovado: 22, Falhou: 0 (5 pré-existentes + 17 novos).
```
```
cd api && dotnet test tests/Back.UnitTests/Back.UnitTests.csproj
# Aprovado: 136, Falhou: 1, Total: 137. Única falha:
# ForeignKeyRangeValidationTests.Writable_foreign_keys_follow_the_range_convention
# (DrillBoxChatSendDto.DrillBoxId sem [Range]) — confirmado via `git diff --stat` contra
# origin/feature/visualizadores-navegacao-layout que este PR não toca em nada em
# tests/Back.UnitTests/Validation/; é a mesma baseline pré-existente já documentada
# na seção Validação acima (era 1 falha em 120 antes, continua 1 falha agora em 137).
```
`Back.ApiTests`/`Back.IntegrationTests` não executados neste sandbox (sem `DATABASE_URL`/MySQL disponível — mesma limitação de ambiente já registrada nas sessões anteriores desta task).

### Pendências remanescentes desta task
- Ressalva #1 (migration retroativa por nome frágil) segue em aberto — fora do escopo deste fast-follow, que tratou só a ressalva #2.
- Ressalva #3 (campanha `geocloud-permission-tests`) segue não bloqueante e não executada.
- CA-04 (reteste manual E2-01 a E2-07) e a parte visual de CA-05 seguem pendentes de ambiente completo.

**PR #385 mesclado (squash) em `feature/visualizadores-navegacao-layout`.** Ressalva #2 da revisão de segurança fechada: `InvalidateCacheAsync` agora é chamado em todos os pontos de mutação reais (`UserProfileService.Add/Update/Delete`, `ProfileFunctionalityService.Add/Delete/DeleteAll`), TTL de produção corrigido para os 5 minutos reais (documentados, não mais um comentário-fantasma). Validação consolidada pós-merge: `dotnet build`, `ng build`, e a suíte `Permissions` (22/22) rodados no topo real da branch de integração — todos limpos.

**Ressalva #1 (migration retroativa `WHERE name='Administrator'`) permanece como item obrigatório antes do merge final para `main`/produção** — as 2 queries diagnósticas recomendadas pela revisão de segurança (detectar colisão de nome / perfil renomeado) precisam rodar contra o banco real antes desse passo. Não é possível verificar isso a partir deste ambiente de desenvolvimento.

## Merge na main (2026-09-08)

A branch `feature/visualizadores-navegacao-layout` foi mesclada em `main` via PR #420 (merge commit `0c38b36d`), mediante aprovação explícita do dono do produto.

**A ressalva #1 NÃO foi fechada por esse merge e permanece obrigatória antes do deploy em produção.** As 2 queries diagnósticas foram rodadas contra o banco de **desenvolvimento** e voltaram vazias (sem colisão de nome, sem perfil renomeado, nenhum `isSystemAdmin=1`), mas isso não diz nada sobre produção. Rodar contra o banco real antes de subir.

Mitigação parcial registrada: `M20260906170000_RestrictSystemAdminBackfill` revoga `isSystemAdmin` de todo perfil que não seja o Administrator vinculado ao usuário dono da conta, o que fecha o caso de **sobre-concessão** (colisão de nome). O caso de **sub-concessão** (conta que renomeou seu Administrator) continua aberto e se manifesta como perda de acesso, não como escalação de privilégio.

## Rastreador criado (2026-09-08)

A ressalva #1 não tinha issue no GitHub (`issue_url` vazio na front matter). Agora tem: **https://github.com/Essencis-Labs/GeoCloudAI/issues/422** — "Portão de produção: validar backfill de isSystemAdmin antes do deploy", com as 3 queries prontas e critérios de aceite. Labels `security`, `backend`, `priority:high`, `status:blocker`.

Esta task permanece em `active/` até a #422 fechar. Ressalva #3 (campanha `geocloud-permission-tests`) e CA-04/CA-05 (reteste manual) também seguem em aberto e estão registrados no corpo da #422.

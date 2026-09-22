---
id: GT-0046
title: "Cobertura, tempo e custo do fluxo de módulo: GetByAccount sem prova, hora local em conexão UTC, 6 consultas por chamada"
status: completed
type: tech-debt
severidade: media
severidade_itens: "TD-02 alta, TD-03 alta, TD-09 media, TD-10 media, TD-11 baixa — a severidade da frente e media por agrupamento do dono do produto; NENHUM item foi rebaixado, TD-02 e TD-03 permanecem alta"
owner: Sergio
created_at: 2026-09-09
updated_at: 2026-09-09
origem: "TD-02, TD-03, TD-09, TD-10, TD-11 — auditoria ad-hoc de Dante Débito sobre TASK-055/056/057 (2026-09-09)"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0046-cobertura-tempo-e-custo-do-modulo.md"
branch: feature/fix/refactor-08_09-11_09
affected_modules: ["Back.API", "Back.Application", "Back.Persistence", "Back.IntegrationTests"]
related_use_cases: []
related_adrs: ["ADR-006", "ADR-007"]
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/452"
sprint: 08/09-11/09/2026
---

# GT-0046 — Cobertura, tempo e custo do fluxo de módulo

## Contexto

Auditoria ad-hoc de Dante Débito sobre a modularização (TASK-055/056/057). Cinco achados que não são
erro de lógica na leitura do código: são **ausência de prova** (TD-02), **valor de tempo
atravessando sem conversão** (TD-03), e **custo por requisição** (TD-09, TD-10, TD-11). Dois são de
severidade alta.

O TD-02 é o mais desconfortável da auditoria: Dante reconstruiu as três construções Dapper mais
frágeis do repositório e **não achou defeito**. O achado é a ausência de prova — mesma forma do
defeito de `users.password_hash`, que também passou revisão de leitura antes de aparecer.

Aprovado pelo dono do produto para correção na branch `feature/fix/refactor-08_09-11_09`.

## Problema

### TD-02 (alta) — `GetByAccount` é a única consulta do módulo sem execução contra banco real

`ModuleRepository.cs:39-59`. Concentra as três construções Dapper mais frágeis do arquivo, cada uma
**única** do seu tipo no repositório:

- único **multi-map** com `splitOn: "id"` sobre 16 colunas — e **duas** se chamam `id` (`am.id` e
  `m.id`);
- única **coluna nova** (`trialStartedAt`);
- único **alias calculado** (`GrantsNow`, `BIGINT` do MySQL mapeado para `bool` em C#).

Se qualquer uma silenciar, `Grants` vem `false` e `Modules` vem vazio **para todos** — sem log, sem
exceção, com a suíte verde.

Dante reconstruiu as três e **não achou defeito**. O achado é a ausência de prova.

### TD-03 (alta) — hora local em conexão declarada UTC; o valor continua atravessando

`ModuleRepository` é o **único** repositório que grava hora local: `NOW()`/`NOW(6)`, **10
ocorrências**, numa conexão com `DateTimeKind=Utc`
(`MySqlConnectionString.ApplySafeDefaults`). O resto do repositório usa `DateTime.UtcNow` ou
`UTC_TIMESTAMP(6)`.

A correção do `GrantsNow` na TASK-057 resolveu a **comparação**. O **valor** continua atravessando:
`ModuleController.cs:264` grava na `userlog`

```csharp
$"Trial started for module {dto.ModuleCode}, ends at {result.EndsAt:u}"
```

O formato `:u` põe sufixo `Z` num instante que não é UTC — a trilha de auditoria afirma um fuso que
o valor não tem.

### TD-09 (média) — 6 consultas por chamada, uma repetida, uma inútil, e o cache contornado

- `GetCapabilities` faz 6 consultas por chamada;
- `GetBillingStatus` chamado **duas vezes**: `ModuleService.cs:113` e de novo dentro de
  `ModuleAccessGate.cs:54`;
- `GetAllModuleMappedKeys` — catálogo inteiro de chaves do produto — carregado e **nunca lido**;
- contorna o cache `modgate:{userId}` que o `PermissionService` mantém.

### TD-10 (média) — invalidação sequencial no tempo de resposta do cliente, com usuário inativo

`InvalidateAccount` (`ModuleService.cs:217-224`) faz **3 `RemoveAsync` por usuário**,
sequencialmente, dentro da requisição de `startTrial` — que o cliente final dispara na tela e cujo
tempo de resposta ele sente.

`GetUserIdsByAccount` não filtra usuário inativo, apesar de `IModuleRepository` documentar
"usuários **ativos**".

### TD-11 (baixa) — `registered: true` afirmado sobre um `void` que falha em silêncio

`purchaseIntent` responde `registered: true` com base em `_userLogService.Register`, que é `void`,
apenas **enfileira**, e tem **3 saídas silenciosas no flush**. A resposta afirma um fato não
verificado.

O detalhe é truncado em 200 caracteres, com `dto.Note` livre entrando depois de ~90 de prefixo — uma
nota do cliente com mais de ~110 caracteres perde o final sem aviso.

## Objetivo

1. `GetByAccount` com prova de execução contra banco real, cobrindo as três construções frágeis.
2. Nenhum valor de tempo do módulo afirmando um fuso que não tem.
3. `GetCapabilities` sem consulta repetida, sem carga não lida, sem contornar o cache.
4. `startTrial` sem invalidação sequencial no tempo de resposta do cliente.
5. `registered` refletindo fato verificado, ou deixando de ser afirmado.

## Fora de escopo

- **Reescrever `GetByAccount` para não usar multi-map.** O achado é ausência de prova, não defeito
  encontrado — a correção é testar, não refatorar às cegas.
- Padronizar `NOW()` nos outros repositórios: `ModuleRepository` é o único com o problema.
- Refatorar `UserLogService` além do necessário para o TD-11.
- Comportamento do fluxo (`startTrial` degradando contrato, respostas de erro) — GT-0044.
- Fonte única da regra de concessão — GT-0045.

## Comportamento atual

- `GetByAccount`: nenhuma execução contra banco real; falha silenciosa de mapeamento produziria
  `Grants=false` e `Modules` vazio para todos, com suíte verde.
- 10 `NOW()`/`NOW(6)` em conexão `DateTimeKind=Utc`; `userlog` grava `{EndsAt:u}` com `Z` num
  instante que não é UTC.
- `GetCapabilities`: 6 consultas, `GetBillingStatus` duas vezes, catálogo carregado e não lido, cache
  `modgate:{userId}` contornado.
- `InvalidateAccount`: 3 `RemoveAsync` por usuário, sequenciais, na requisição do cliente; inativos
  incluídos contra a documentação da interface.
- `purchaseIntent`: `registered: true` sobre `void` com 3 saídas silenciosas; `dto.Note` cortada sem
  aviso.

## Comportamento esperado

- Teste de integração exercitando `GetByAccount` contra o schema real, que falharia se o multi-map,
  a coluna nova ou o alias calculado quebrassem.
- Instante gravado e instante formatado no mesmo fuso, com o sufixo dizendo a verdade.
- `GetCapabilities` sem repetição, sem carga inútil, aproveitando o cache existente.
- Invalidação fora do caminho crítico, restrita a usuários ativos.
- `registered` verificado, ou fora da resposta.

## Regras de negócio

- RN-01: `IModuleRepository` documenta "usuários ativos" em `GetUserIdsByAccount`. A implementação
  cumpre o que a interface promete — ou a documentação muda, com motivo registrado.
- RN-02: `userlog` é trilha de auditoria e não pode afirmar fuso que o valor não tem. É a evidência
  usada depois para reconstruir o que aconteceu e quando — aqui, o início de um teste comercial.
- RN-03: `registered` em `purchaseIntent` é afirmação ao cliente; só pode ser `true` se verificado.
- RN-04 (preexistente, preservada): o efeito de `startTrial` vale **na hora** (RN-05 da TASK-056 /
  CA-02 da TASK-057). Reduzir o custo da invalidação não pode reabrir a janela em que o usuário que
  acabou de aceitar o teste vê a tela de oferta de novo.

## Critérios de aceitação

- [x] CA-01: teste de integração executando `GetByAccount` contra o schema real, com conta que tem
      módulo Core e não-Core, `endDate` nulo e futuro, `trialStartedAt` preenchido e nulo.
- [x] CA-02: o teste de CA-01 assere `Grants`/`GrantsNow` **e** `Module` populado — o multi-map com
      duas colunas `id` e o alias `BIGINT`→`bool` só se provam por asserção sobre valor, nunca por
      "não lançou exceção".
- [x] CA-03: as 10 ocorrências de `NOW()`/`NOW(6)` em `ModuleRepository` resolvidas — padronizadas
      para UTC — **ou** a decisão de mantê-las registrada, com conversão explícita no ponto de
      leitura.
- [x] CA-04: `ModuleController.cs:264` não grava mais `Z` num instante que não é UTC.
- [x] CA-05: `GetBillingStatus` chamado uma vez por `GetCapabilities` — a duplicação entre
      `ModuleService.cs:113` e `ModuleAccessGate.cs:54` deixa de existir.
- [x] CA-06: `GetAllModuleMappedKeys` não é mais carregado sem ser lido — ou passa a ser lido (ver
      CA-08 da GT-0045), ou deixa de ser carregado.
- [x] CA-07: `GetCapabilities` aproveita o cache `modgate:{userId}`, ou o motivo de não aproveitar
      está registrado.
- [x] CA-08: `InvalidateAccount` não faz N×3 `RemoveAsync` sequenciais dentro da requisição de
      `startTrial` — em lote, paralelo, ou fora do caminho de resposta, **sem** reabrir a janela da
      RN-04.
- [x] CA-09: `GetUserIdsByAccount` filtra usuário inativo, cumprindo o que `IModuleRepository`
      documenta — ou a documentação é corrigida com o motivo.
- [x] CA-10: `purchaseIntent` só responde `registered: true` sobre fato verificado; se
      `_userLogService.Register` continua `void` e enfileirando, o campo sai da resposta ou muda de
      semântica declaradamente.
- [x] CA-11: `dto.Note` não é truncada em silêncio — validação de tamanho na entrada, ou truncamento
      que preserva a nota e não o prefixo.
- [x] CA-12: nenhuma correção de custo (CA-05 a CA-08) altera **quais** capacidades são concedidas.
      Teste comparando o resultado de `GetCapabilities` antes e depois.

## Impacto técnico

### Backend
`ModuleRepository`: `NOW()` → UTC (ou conversão explícita registrada); filtro de usuário ativo.
`ModuleService`: `GetCapabilities` sem repetição nem carga inútil; `InvalidateAccount` fora do
caminho crítico.
`ModuleController`: formatação do instante no `userlog`; `registered` e truncamento de `Note`.

### Frontend
Nenhum contrato novo, exceto se CA-10 retirar `registered` da resposta de `purchaseIntent` — nesse
caso, verificar quem consome o campo na tela.

### Banco de dados
Nenhuma migration. TD-03 é conversão na aplicação, não mudança de tipo de coluna. **Atenção**: os
dados já gravados por `NOW()` local permanecem no fuso local — a correção não os reescreve, e isso
precisa ser decidido e registrado (ver Riscos).

### Integrações
Nenhuma.

### Segurança
Indireto: `userlog` é a trilha de auditoria. Instante com fuso errado degrada a capacidade de
reconstruir o que aconteceu.

## Plano de implementação

- [x] Etapa 1 (TD-02): teste de integração de `GetByAccount` contra o schema real, com asserção sobre
      valor. Primeira de propósito: sem ela, nenhuma mudança seguinte no repositório tem rede.
- [x] Etapa 2 (TD-03): decidir e registrar o tratamento dos dados já gravados; padronizar as 10
      ocorrências de `NOW()`; corrigir `{EndsAt:u}`.
- [x] Etapa 3 (TD-09): remover a chamada duplicada de `GetBillingStatus` e a carga não lida.
- [x] Etapa 4 (TD-09): aproveitar o cache `modgate:{userId}`, ou registrar por que não.
- [x] Etapa 5 (TD-10): invalidação em lote/fora do caminho crítico; filtro de usuário ativo.
- [x] Etapa 6 (TD-11): `registered` verificado ou removido; truncamento de `Note` resolvido.

## Estratégia de testes

- [x] Unitários: `GetCapabilities` com o número de chamadas ao repositório asserido (é o que impede a
      duplicação de voltar); truncamento de `Note`.
- [x] Integração: `GetByAccount` contra o schema real (CA-01/CA-02) — o núcleo desta task;
      `GetUserIdsByAccount` com usuário inativo na conta.
- [x] E2E: N/A.
- [x] Manual: `startTrial` em conta com muitos usuários, medindo o tempo de resposta antes e depois da
      Etapa 5, e confirmando que o acesso aparece imediatamente (RN-04); conferência do instante
      gravado na `userlog` contra o relógio real.

## Riscos e rollback

Risco 1 — o mais sutil: padronizar `NOW()` para UTC muda o **valor** gravado, mas os registros **já
existentes** ficam no fuso local. Comparações entre linhas antigas e novas ficam inconsistentes até o
dado antigo ser tratado. Decidir antes da Etapa 2, não descobrir depois.

Risco 2: as correções de custo (Etapas 3 a 5) mexem em quem resolve a concessão. Se uma delas mudar
**quais** capacidades são concedidas, o cliente perde ou ganha acesso sem ninguém ter decidido.
CA-12 existe para pegar isso.

Risco 3: mover a invalidação para fora do caminho de resposta reintroduz a janela que a TASK-057
fechou de propósito — o usuário que acabou de aceitar o teste veria a tela de oferta outra vez. A
correção do TD-10 reduz o custo **sem** reabrir essa janela (RN-04).

Rollback: a Etapa 1 é aditiva (só teste) e sem risco. As demais são reversíveis isoladamente.

## Registro de execução

### Alterações realizadas

**TD-02 — a prova que faltava.** `ModuleGetByAccountTests`, seis testes, todos sobre **valor**:
"não lançou exceção" não prova nenhuma das três construções frágeis. O corte do multi-map é
verificado contra os ids reais lidos do banco, com uma asserção extra garantindo que o cenário não é
degenerado (se `accountmodule.id == module.id`, trocar um pelo outro passaria despercebido). O alias
`BIGINT`→`bool` é exercitado nos **dois** sentidos — só `true` passaria com um campo nunca lido, só
`false` passaria com o padrão de `bool`. E `trialStartedAt` é conferido preenchido **e** nulo,
porque o nulo também é informação.

**TD-03 — a conversão de relógio.** As nove ocorrências de SQL viraram `UTC_TIMESTAMP(6)`, e o
predicado de vigência compara com `UTC_TIMESTAMP()`. Migração `M20260909171226` converte o
histórico; a data de corte é `VersionInfo.AppliedOn`, por ambiente. Decisão em **ADR-006**.

**TD-09 — de sete consultas para duas no caminho quente.** `GetCapabilities` pede a decisão ao
`IPermissionService`, que é o dono do cache `modgate:`, em vez de resolver o portão direto. O estado
comercial sai da própria decisão. `ModuleService` deixou de injetar `IModuleAccessGate`: contornar o
cache passou a ser impossível por construção, não por disciplina.

**TD-10 — invalidação concorrente, e ainda aguardada.** `Task.WhenAll` no lugar do laço sequencial.
O que **não** foi feito é a parte que importa: soltar em segundo plano seria a redução óbvia e
reabriria a janela que a TASK-057 fechou. Há teste que falha se alguém trocar por fire-and-forget.

**TD-11 — parar de afirmar, e um limite que cabe.** `registered` saiu da resposta (**ADR-007**), e o
limite de `Note` caiu de 500 para 100 — o que sobra dos 200 caracteres do detalhe da `userlog`
depois do prefixo, travado por teste.

### Arquivos principais
- `api/tests/Back.IntegrationTests/Repositories/ModuleGetByAccountTests.cs` (novo) — TD-02.
- `api/src/Back.Persistence/Migrations/M20260909171226_AccountModuleTimesToUtc.cs` (novo) — TD-03.
- `api/tests/Back.IntegrationTests/Repositories/ModuleTimeConversionTests.cs` (novo) — prova da migração.
- `api/src/Back.Persistence/Repositories/ModuleRepository.cs` e `Data/AccountModuleGrantSql.cs` — UTC.
- `api/src/Back.Application/Middlewares/{IPermissionService,PermissionService}.cs` — `GetModuleDecisionAsync`.
- `api/src/Back.Application/Services/ModuleService.cs` — cache, e `IModuleAccessGate` fora.
- `api/src/Back.API/Controllers/ModuleController.cs` — `registered` fora, `{EndsAt:u}` verdadeiro.
- `api/tests/Back.UnitTests/Permissions/ModuleCapabilitiesCostTests.cs` (novo) — CA-05 a CA-12.
- `.agents/decisions/006-*.md`, `007-*.md`.

### Decisões

1. **Converter o histórico, e não só dali para a frente** — decisão do dono do produto. Não
   converter deixaria linha antiga e nova três horas desalinhadas na mesma coluna, e a regra de
   vigência ficaria errada para quem entrou antes.
2. **A documentação de `GetUserIdsByAccount` foi corrigida, não a consulta** (CA-09). "Usuário
   ativo" não existe no schema: `users` tem `blocked`, que conta tentativas de login falhas — é
   bloqueio de autenticação, não estado de cadastro. Filtrar por ele seria implementar um conceito
   diferente com o nome do prometido. E errar para mais é seguro aqui: limpar a chave de um usuário
   bloqueado custa um `RemoveAsync` inútil; deixar de limpar a de quem volta dentro do TTL lhe daria
   a permissão antiga, que é o defeito da GT-0028.
3. **`registered` removido em vez de verificado.** Verificar exigiria `FlushAsync` no meio da ação,
   invertendo a ADR-001 — que decidiu de propósito que a auditoria nunca influencia a resposta.
4. **O predicado continua em SQL mesmo sem a causa original.** Com um relógio só, comparar em C#
   voltou a ser possível; mas a consulta de chaves precisa do predicado num `WHERE`, sobre linhas
   que nunca chegam à aplicação.

### Divergências

- **A CA-11 da GT-0045 foi reescrita, não mantida.** Ela provava que o banco considerava vigente um
  vínculo que `DateTime.UtcNow` já dava por vencido — dependia de os dois relógios **discordarem**,
  que é exatamente o que esta task eliminou. Insistir nela seria manter um teste que só passa
  enquanto o defeito existir. O que sobrevive é a igualdade: a coluna e o predicado usam a mesma
  função de tempo, e o processo concorda com o banco.
- **A CA-06 já estava cumprida pela GT-0045.** `GetAllModuleMappedKeys` deixou de ser carga não lida
  quando `GetCapabilities` passou a usar `Denies()`, que consulta `ModuleMappedKeys`.
- **O limite de `Note` mudou de valor, não só de comportamento** (500 → 100). O 500 era uma promessa
  que a `userlog` não podia cumprir.

### Pendências

Nenhuma de código.

**Uma correção factual, feita no mesmo dia.** Este registro afirmava que a suíte de integração *não
roda migrations*. É falso, e o erro foi meu: li `MySqlTestDatabase`, vi o dump do banco de
desenvolvimento sendo restaurado, e parei ali — sem abrir `IntegrationCollection.cs`, onde
`IntegrationDbFixture` chama `provider.ApplyPendingMigrations(configuration)` logo em seguida
(`IntegrationCollection.cs:31`). A migração `M20260909171226` **foi** executada pelos 46 testes.

Descoberto ao investigar por que um teste da GT-0047 falhava numa asserção que eu esperava trivial:
o banco de teste já estava no estado **pós**-migração. Corrigido aqui, na ADR-006 e no comentário de
`ModuleTimeConversionTests`.

O que continua valendo, e é o motivo de o teste existir: aplicar a migração prova que ela **roda**,
não que está **certa**. Deslocamento exato, nulo preservado e simetria da ida e volta não são
observáveis num `UPDATE` sem `WHERE` sobre o dump de um desenvolvedor.

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
cd web && ng test
```

```
Back.UnitTests          276 aprovados   (eram 269)
Back.IntegrationTests    46 aprovados   (eram 37)
web (Karma)             332 aprovados   (inalterado)
```

**A falha que valeu por medição.** A primeira versão do teste do alias calculado escrevia `endDate`
com `UTC_TIMESTAMP(6)` enquanto o predicado ainda comparava com `NOW()` local — e falhou: num
servidor em UTC-3, "UTC agora menos um segundo" ainda é três horas no **futuro** pelo relógio local,
então o vínculo vencido continuava concedendo acesso. Foi o TD-03 se manifestando ponta a ponta,
antes de ser corrigido, e não uma hipótese.

`dotnet build Back.sln` não completa neste ambiente: há um `Back.API` em execução travando os DLLs
em `bin/` (MSB3021/MSB3027). É bloqueio de arquivo, não de código — `dotnet msbuild -t:Compile`
sobre o `Back.API` passa limpo, e as duas suítes compilam e rodam.

## Handoff
Nenhum.

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
```

## Handoff
Link para o handoff ativo, quando aplicável.

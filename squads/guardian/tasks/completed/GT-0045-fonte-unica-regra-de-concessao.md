---
id: GT-0045
title: "Fonte única da regra de concessão de módulo: predicado triplicado, abstrações com zero uso em produção"
status: completed
type: tech-debt
severidade: media
owner: Sergio
created_at: 2026-09-09
updated_at: 2026-09-09
origem: "TD-04, TD-05, TD-06, TD-07, TD-12 — auditoria ad-hoc de Dante Débito sobre TASK-055/056/057 (2026-09-09)"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0045-fonte-unica-regra-de-concessao.md"
branch: feature/fix/refactor-08_09-11_09
affected_modules: ["Back.API", "Back.Application", "Back.Domain", "Back.Persistence", "Back.UnitTests"]
related_use_cases: []
related_adrs: ["ADR-003", "ADR-005"]
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/452"
sprint: 08/09-11/09/2026
---

# GT-0045 — Fonte única da regra de concessão

## Contexto

Auditoria ad-hoc de Dante Débito sobre a modularização (TASK-055/056/057). Cinco achados com um
padrão só: **a regra de "quando um módulo concede acesso" mora em vários lugares ao mesmo tempo, e
as abstrações criadas para ser a fonte única não são chamadas por produção — apenas por teste.**

Não é bug hoje. É que a próxima mudança na regra exige achar todas as cópias, uma vai ficar para
trás, e a suíte continua verde — porque os testes exercitam a abstração que ninguém chama.

Aprovado pelo dono do produto para correção na branch `feature/fix/refactor-08_09-11_09`.

## Problema

### TD-04 (média) — predicado de concessão literal 3 vezes

`am.status IN ('active','trial') AND (am.endDate IS NULL OR am.endDate > NOW())` literal em
`ModuleRepository.cs:45-46`, `:76-77` e `:109-111`, com `'active'` e `'trial'` à mão em cada uma.

`AccountModuleStatus.Grants` (`Back.Domain/Classes/AccountModule.cs`) tem **zero usos em `src/`**;
os 3 usos estão em `ModuleStatusTests`. A linha `ModuleRepository.cs:66` traz o comentário
"ver AccountModuleStatus.Grants" ao lado de uma cópia literal da regra.

### TD-05 (média) — documentação diverge da implementação, e os predicados divergem entre si

`IModuleService.GetCapabilities` **documenta** que resolve pelo `IPermissionService` e respeita o
perfil e o bypass de `isSystemAdmin`. A implementação (`ModuleService.cs:129`) deliberadamente não
usa, com comentário longo explicando por quê (chave de capacidade descreve o que a conta contratou,
não o que o perfil concede; ADR-003).

A decisão está certa. O problema é que os predicados divergem:

- `PermissionService.cs:227` nega **só o que está mapeado e não concedido**;
- `ModuleService.cs:134` concede **só o que está em `GrantedKeys`**.

Chave **não mapeada** a nenhum módulo: backend permite, UI esconde. Cada lado está certo segundo o
próprio predicado, e discordam.

`ModuleGateDecision.Denies()` existe para ser a fonte única desse predicado e tem **11 usos, todos
em teste**.

### TD-06 (média) — 4 chaves de capacidade escritas à mão

`ModuleService.cs:104-107` declara `viewer.singleView`, `viewer.multiView`, `viewer.coreView`,
`viewer.view3D` num array literal — duplicando o que a migration `M20260908223605` já grava no banco
(3 vezes no `Up`, 1 no `Down`). `GetAllModuleMappedKeys` existe e já é carregado via `_gate`.

### TD-07 (média) — sobrecarga sem chamador em produção

`GetGrantedFunctionalityKeys(accountId)`, de 1 argumento: **zero chamadores em `src/`**, 5 em teste
de integração. É a sobrecarga de 2 argumentos com `coreOnly=false`. Duas das três cópias do
predicado do TD-04 estão nessas duas sobrecargas.

### TD-12 (baixa) — regra de negócio no SQL, e o arquivo declara o oposto duas vezes

`ModuleRepository.cs:45-46` (alias `GrantsNow`) e `:166` (`ORDER BY m.isCore ASC LIMIT 1`, escolha
**comercial** de qual módulo oferecer) põem regra de negócio no SQL, o que `.claude/rules/global.md`
proíbe.

E o mesmo arquivo declara a regra oposta duas vezes: `:67-69` ("A REGRA de quando aplicar o recorte
vive no serviço (TASK-056), não aqui — ver a nota sobre não esconder a decisão dentro do SQL") e
`:100-102`. Ler o arquivo é ler uma contradição.

**Atenção ao implementar — o ponto mais importante desta task**: `GrantsNow` foi movido para o SQL
**de propósito** na TASK-057, para corrigir comparação entre dois relógios (o do banco e o do
processo). Reverter para C# reintroduz aquele bug. A correção aqui é **tornar a leitura coerente**,
não mover a lógica de volta.

## Objetivo

A regra de concessão ter uma fonte única e localizável, e as abstrações que existem para sê-la serem
chamadas por código de produção — não só por teste.

## Fora de escopo

- **Mover `GrantsNow` de volta para C#.** Vedado: reintroduz o bug de comparação entre relógios da
  TASK-057.
- Reverter a decisão de `GetCapabilities` não usar `IPermissionService` (ADR-003). O TD-05 pede
  alinhar documentação e predicado, não trocar a decisão.
- Comportamento do fluxo de módulo (`startTrial`, respostas de erro) — GT-0044.
- Cobertura, fuso e custo — GT-0046.

## Comportamento atual

- 3 cópias literais do predicado, com status à mão.
- `AccountModuleStatus.Grants`: 0 usos em `src/`, 3 em teste.
- `ModuleGateDecision.Denies()`: 11 usos, todos em teste.
- Chave não mapeada: backend permite, UI esconde.
- 4 chaves de capacidade duplicando a migration.
- `GetGrantedFunctionalityKeys(accountId)`: 0 chamadores em `src/`, 5 em teste.
- `ModuleRepository.cs` afirma duas vezes que a regra não mora no SQL, e a põe no SQL duas vezes.

## Comportamento esperado

- Uma definição do predicado, referenciada pelas três consultas.
- `Grants` e `Denies()` chamados por produção, ou removidos com o motivo registrado — abstração
  testada e nunca chamada é pior que a ausência dela, porque simula cobertura.
- Um único predicado decidindo o caso da chave não mapeada, com a escolha registrada.
- Chaves de capacidade derivadas do banco.
- Sobrecarga sem chamador removida, ou o chamador identificado.
- `ModuleRepository.cs` sem contradição entre comentário e SQL.

## Regras de negócio

- RN-01: chave de capacidade descreve o que a **conta contratou**, não o que o **perfil do usuário**
  concede (ADR-003). A divergência do TD-05 se resolve alinhando documentação e escolhendo um
  predicado — nunca desfazendo esta regra.
- RN-02: para chave **não mapeada** a nenhum módulo, backend e UI têm de dar a mesma resposta. Qual
  resposta é a certa é decisão de produto e precisa ser registrada em `.agents/decisions/`.
- RN-03: `GrantsNow` continua avaliado pelo relógio do banco (TASK-057).
- RN-04: `ORDER BY m.isCore ASC LIMIT 1` codifica "se a chave está em dois módulos, oferecer o pago,
  porque o Core toda conta já tem". A regra permanece; muda onde ela é declarada.

## Critérios de aceitação

- [x] CA-01: predicado de concessão com definição única, referenciada pelas três consultas
      (`ModuleRepository.cs:45-46, 76-77, 109-111`).
- [x] CA-02: `'active'` e `'trial'` não aparecem mais escritos à mão no SQL — vêm de
      `AccountModuleStatus`.
- [x] CA-03: `AccountModuleStatus.Grants` com pelo menos um uso em `src/`, ou removido com motivo
      registrado.
- [x] CA-04: `ModuleGateDecision.Denies()` com pelo menos um uso em `src/`, ou removido com motivo
      registrado.
- [x] CA-05: documentação de `IModuleService.GetCapabilities` descreve o que a implementação faz —
      sem menção a `IPermissionService`, perfil ou bypass de `isSystemAdmin` se ela não os usa.
- [x] CA-06: chave não mapeada produz a mesma resposta em `PermissionService.cs:227` e
      `ModuleService.cs:134`, com a escolha registrada em `.agents/decisions/`.
- [x] CA-07: teste cobrindo a chave não mapeada nos dois caminhos.
- [x] CA-08: as 4 chaves de capacidade derivam do banco (via `GetAllModuleMappedKeys` ou
      equivalente), não do array literal de `ModuleService.cs:104-107`.
- [x] CA-09: `GetGrantedFunctionalityKeys(accountId)` de 1 argumento removida da interface e da
      implementação, com os 5 testes de integração migrados para a sobrecarga de 2 argumentos — ou
      um chamador de produção identificado e registrado.
- [x] CA-10: `ModuleRepository.cs` sem contradição: os comentários de `:67-69` e `:100-102`
      reescritos para descrever o que acontece, ou a decisão retirada do SQL onde isso é possível
      **sem** mover `GrantsNow`.
- [x] CA-11: `GrantsNow` continua avaliado no SQL, pelo relógio do banco, com teste ou nota de
      validação comprovando que a comparação entre relógios não voltou.

## Impacto técnico

### Backend
`ModuleRepository`: predicado consolidado, status vindo do domínio.
`ModuleService`: chaves derivadas do banco; predicado alinhado com `PermissionService`.
`IModuleService` / `IModuleRepository`: documentação corrigida, sobrecarga sem uso removida.
`.claude/rules/global.md`: a consolidação não pode fazer o Service montar SQL nem o Repository ler
claim — a fronteira Controller → Service → Repository permanece.

### Frontend
Muda se e somente se CA-06 decidir que a resposta certa é a do backend (permitir chave não mapeada) —
aí a UI passa a desenhar controles que hoje esconde. Decisão de produto, registrada antes do código.

### Banco de dados
Nenhuma migration. `M20260908223605` continua a fonte das chaves; o que muda é o backend passar a
lê-la em vez de duplicá-la.

### Integrações
Nenhuma.

### Segurança
CA-06 é decisão de autorização. Se a resposta escolhida for "permitir chave não mapeada", passa pelo
`geocloud-permission-auditor` e por `api/docs/system/permission-rules.md` antes do merge.

## Plano de implementação

- [x] Etapa 1: decidir e registrar em `.agents/decisions/` a resposta para chave não mapeada (CA-06).
      Bloqueia as etapas de código do TD-05.
- [x] Etapa 2: consolidar predicado e strings de status (TD-04), preservando `GrantsNow` no SQL.
- [x] Etapa 3: derivar as chaves de capacidade do banco (TD-06).
- [x] Etapa 4: alinhar documentação e predicado de `GetCapabilities` (TD-05).
- [x] Etapa 5: remover a sobrecarga de 1 argumento e migrar os 5 testes (TD-07).
- [x] Etapa 6: reescrever os comentários contraditórios de `ModuleRepository.cs` (TD-12).
- [x] Etapa 7: dar uso em produção a `Grants` e `Denies()`, ou removê-los com registro.

## Estratégia de testes

- [x] Unitários: chave não mapeada nos dois caminhos; predicado consolidado; chaves derivadas do
      banco.
- [x] Integração: as três consultas do predicado consolidado contra o schema real, com `endDate`
      nulo, futuro e passado — é o que prova que a consolidação não mudou a semântica.
- [x] E2E: N/A.
- [x] Manual: `GrantsNow` para vínculo cujo `endDate` está a segundos de vencer — o caso que a
      TASK-057 corrigiu e que a consolidação pode reintroduzir.

## Riscos e rollback

Risco principal: consolidar o predicado e, no caminho, mover `GrantsNow` de volta para C#.
Reintroduz o bug de comparação entre relógios da TASK-057 — que suíte verde não pega, porque só
aparece quando os relógios divergem. CA-11 existe para barrar isso.

Risco secundário: CA-06 escolher "permitir chave não mapeada" e abrir acesso a capacidade não
contratada. Por isso a decisão passa pelo auditor de permissão antes do código.

Rollback: cada etapa é independente e reversível isoladamente. A Etapa 1 é decisão, não código — tem
revisão, não rollback.

## Registro de execução

### Alterações realizadas

**TD-04 — o predicado, agora um.** `AccountModuleGrantSql.ConcedeAgora`
(`Back.Persistence/Data/`) é a definição única, montada a partir de
`AccountModuleStatus.Granting`. As três consultas a referenciam, incluindo a coluna calculada
`GrantsNow` — a mesma string serve de `SELECT` e de `WHERE`, que é o que garante que a tela e a
autorização não discordem sobre vigência.

`AccountModuleStatus.Grants(status)` **removido**, e o motivo está registrado no próprio domínio:
era metade da regra. A regra inteira é estado **e** vigência, e a vigência é do relógio do banco.
Meia regra em C# é exatamente a segunda fonte que esta task existe para eliminar. O conjunto
`Granting` ficou, e passou a ter uso em produção — é dele que o SQL monta o `IN (...)`.

**TD-05 e TD-06 — os dois predicados viraram um.** `PermissionService.IsDeniedByModuleAsync` e
`ModuleService.GetCapabilities` agora decidem por `ModuleGateDecision.Denies()`. A escolha para
chave não mapeada está registrada na **ADR-005**. As quatro chaves de capacidade saem do banco
(`GetCapabilityKeys("viewer.")`); sobrou um literal, o prefixo, no lugar de quatro chaves
duplicando a migração em quatro pontos.

A documentação de `IModuleService.GetCapabilities` foi reescrita para descrever o que o método
faz. Ela afirmava resolver por `IPermissionService`, perfil e bypass de `isSystemAdmin` — nada
disso acontece, e não deve acontecer (ADR-003). A implementação estava certa; o contrato mentia.

**TD-07 — sobrecarga sem chamador.** `IModuleRepository.GetGrantedFunctionalityKeys(int)` removida,
com os seis pontos de chamada em teste de integração migrados para `coreOnly: false`. Removida
também `IModuleService.GetGrantedFunctionalityKeys(int)`, que não tinha chamador **nenhum** — nem
controller, nem serviço, nem teste. Não estava no escopo escrito da task; estava no escopo do
problema dela.

**TD-12 — a contradição e a regra escondida.** Os comentários de `ModuleRepository` foram
reescritos para dizer o que o arquivo faz, incluindo o que ele deliberadamente **não** faz (ler
`billingStatus`). E o `ORDER BY m.isCore ASC LIMIT 1` saiu: `GetModuleCodeForFunctionality` virou
`GetModulesForFunctionality`, que devolve os módulos sem escolher, e a escolha comercial da RN-04 —
oferecer o pago, porque o Core toda conta já tem — passou para
`PermissionService.GetRequiredModuleAsync`, com os dois testes que ela nunca teve.

### Arquivos principais
- `api/src/Back.Persistence/Data/AccountModuleGrantSql.cs` (novo) — a definição única.
- `api/src/Back.Domain/Classes/AccountModule.cs` — `Granting` entra, `Grants()` sai.
- `api/src/Back.Persistence/Repositories/ModuleRepository.cs` — três consultas consolidadas,
  `GetCapabilityKeys`, `GetModulesForFunctionality`, comentários coerentes.
- `api/src/Back.Application/Middlewares/PermissionService.cs` — `Denies()` e a escolha da RN-04.
- `api/src/Back.Application/Services/ModuleService.cs` — chaves do banco, predicado único.
- `api/src/Back.Application/Contracts/IModuleService.cs` — CA-05.
- `.agents/decisions/005-chave-nao-mapeada-a-modulo.md` (novo) — CA-06.
- `api/docs/system/permission-rules.md` — o portão como segundo eixo, e o que `capabilities` é.

### Decisões

1. **A resposta para chave não mapeada é "permitir"** (ADR-005), e o que muda é a tela passar a
   concordar. Negar nos dois lados soa mais seguro e não é: faria toda chave criada por migração
   bloquear a funcionalidade para todos os clientes até alguém mapeá-la, com a ordem de duas
   migrações decidindo se o produto funciona.

2. **`GrantsNow` continua no SQL.** Era o risco número um desta task, declarado como fora de
   escopo. A consolidação junta as três cópias num lugar; não muda onde são avaliadas.

3. **`Grants()` removido em vez de ganhar um chamador artificial.** Procurei um uso honesto em
   produção e não existe: todo ponto que precisa da resposta usa `GrantsNow`, que é a regra
   inteira. Inventar um chamador para satisfazer a CA-03 seria pior que remover.

4. **A escolha comercial saiu do `ORDER BY`.** A CA-10 permitia só reescrever comentários. Reescrever
   um comentário que explica uma regra de negócio dentro de uma cláusula de ordenação é documentar
   o problema, não corrigi-lo — e a regra estava sem teste nenhum, o que é o sintoma de estar no
   lugar errado.

### Divergências

- **Removi um item além do escrito**: `IModuleService.GetGrantedFunctionalityKeys(int)`. A CA-09
  nomeia só a sobrecarga do repositório; a do serviço tinha zero chamadores em qualquer lugar.
- **A CA-10 foi cumprida pelo caminho mais caro dos dois** (tirar a decisão do SQL, não só
  reescrever comentário), pelo motivo da decisão 4.
- **`ModuleController` não ganhou seção em `permission-rules.md`.** As tabelas por controller são
  geradas contra a `main`, e ele vive na branch. O que entrou foi a nota das duas regras
  transversais do portão, mais o registro de que a seção falta. Anotado no próprio documento.

### Revisão do auditor de permissão

A CA-06 é decisão de autorização, e a seção de Segurança desta task exigia passagem pelo
`geocloud-permission-auditor` antes do merge. Rodou sobre o commit `da971353`. Veredicto:
**nada do que a GT-0045 mudou altera o que o backend autoriza.**

O que ele confirmou por leitura de código, em vez de aceitar o que a ADR-005 afirma:
- a troca do predicado por `Denies()` é comportamentalmente idêntica, incluindo o comparador —
  `IReadOnlySet<string>` faz `.Contains` despachar para `HashSet<string>.Contains` e usar o
  `OrdinalIgnoreCase` da instância. Com `IEnumerable<string>` teria caído em
  `Enumerable.Contains`, case-**sensitive**, e virado fail-open silencioso;
- nenhuma chave `viewer.*` aparece em `[RequiredPermission]` algum, e `capabilities` é consumido
  só pelo frontend — rastreando cada consumidor, não confiando na ADR;
- `functionality` é catálogo **global**: não há `accountId` na tabela, então `GetCapabilityKeys`
  sem filtro de conta não tem o que vazar. O escopo por conta está um salto adiante, em `Denies`;
- a remoção da sobrecarga de 1 argumento retira um *footgun*: ela era `coreOnly: false`, e um
  chamador futuro que a alcançasse concederia chave de módulo pago a conta inadimplente.

**Três apontamentos corrigidos nesta mesma task:**

1. **`BillingStatus` sintético no caminho de autorização.** A decisão remontada do cache usava
   `Current` fixo, porque a entrada de cache não guardava o valor. Inerte hoje — `Denies()` não
   olha o campo — mas é a mesma divergência que esta task eliminou, esperando uma única edição em
   `Denies` para virar conta inadimplente avaliada como em dia, falhando **aberto**. O campo passou
   a ser guardado e lido.
2. **O arame de tropeço da ADR-005 não existia.** O `CA08_*` é um `BeEquivalentTo` sobre os quatro
   nomes, e a reação natural a uma chave nova é acrescentá-la à lista esperada — o que passa a
   suíte sem mapear nada. Entrou
   `ADR005_toda_chave_de_capacidade_esta_mapeada_a_algum_modulo`: a única forma de silenciá-lo é
   mapear a chave.
3. **A mesma afirmação falsa da CA-05, no arquivo que eu não abri.**
   `ModuleController.cs:229-231` ainda dizia que a resposta é "calculada pelo `IPermissionService`"
   — e essa era a justificativa citada para o endpoint não ter `[RequiredPermission]`. A conclusão
   valia; o motivo, não. Corrigido.

**Um apontamento anotado, sem qualificar como defeito:** o predicado é único mas os insumos têm
frescor diferente — autorização lê o cache `modgate:` (5 min em produção), `GetCapabilities`
resolve o portão a cada requisição. Só abre janela na expiração **por relógio**, porque toda
mutação invalida. Registrado nas consequências da ADR-005.

**Um achado pré-existente, fora desta task:** a fronteira do visualizador avançado é enforçada
**só na UI**. As quatro chaves `viewer.*` gateiam abas; os endpoints de dado carregam chave do
Core. Uma conta com só o Core que chame `GET api/DrillHoleView3D/getByAccount` direto recebe os
dados. É o que a migração `M20260908223605` declara desde a TASK-055, então é desenho da ADR-003 e
não regressão — mas é decisão de receita que merece passagem própria. Virou **GT-0047**, no
backlog, sem issue.

### Pendências

Nenhuma desta task. A GT-0046 encosta em dois pontos daqui: `GetCapabilities` ganhou mais uma
consulta (`GetCapabilityKeys`), o que soma ao TD-09 — as seis consultas por chamada que a GT-0046
vai colapsar. E o `modgate:` continua sendo o cache que o TD-10 trata.

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
```

```
Back.UnitTests          269 aprovados   (eram 264)
Back.IntegrationTests    37 aprovados   (eram 31)
```

`ng test` não foi executado: nenhum arquivo em `web/` mudou. A ADR-005 escolheu a resposta que o
frontend **já** dá — `hasCapability` concede o que está em `granted`, e a chave não mapeada passou
a vir em `granted`.

**Prova de que o predicado sai do domínio, e não de um literal esquecido** (CA-01 / CA-02). Removi
`Trial` de `AccountModuleStatus.Granting` e rodei a suíte de integração:

```
Com falha: 5, Aprovado: 31, Total: 36
```

Restaurado, 36 aprovados. Se alguma das três consultas tivesse ficado com `'trial'` escrito à mão,
esses cinco testes teriam passado.

**Prova de que os dois relógios divergem neste ambiente** (CA-11). O `CA11_*` só executa a
asserção forte quando o banco está atrás do UTC. Para confirmar que ela roda de verdade aqui,
acrescentei temporariamente `deslocamento.Should().BeLessThan(TimeSpan.FromMinutes(-1))` e rodei o
teste: **aprovado** — o MySQL local está em UTC-3, o ramo é exercitado, e o vínculo que o banco
considera vigente está de fato no passado segundo `DateTime.UtcNow`. A asserção temporária foi
removida.

## Handoff
Nenhum.

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
```

## Handoff
Link para o handoff ativo, quando aplicável.

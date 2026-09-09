---
id: GT-0047
title: "Fronteira do visualizador avançado é enforçada só na UI: os endpoints de dado carregam chave do Core"
status: completed
type: decision
severidade: media
owner: Sergio
created_at: 2026-09-09
updated_at: 2026-09-09
origem: "geocloud-permission-auditor, na revisão da GT-0045 (2026-09-09) — achado 2.1, pré-existente à GT-0045"
contraparte: C:\Software\GeoCloud\GeoCloudAI\.agents\tasks\completed\GT-0047-fronteira-do-visualizador-so-na-ui.md
issue: 457
branch: feature/fix/refactor-08_09-11_09
affected_modules: ["Back.API", "Back.Persistence"]
related_use_cases: []
related_adrs: ["ADR-003", "ADR-005", "ADR-008"]
---

# GT-0047 — Fronteira do visualizador avançado é enforçada só na UI

## Contexto

Levantado pelo auditor de permissão na revisão da GT-0045. **Não é regressão da GT-0045 nem de
nenhuma task desta sprint** — é como a modularização foi desenhada na TASK-055, e a migração
`M20260908223605` declara isso nas próprias linhas 16-20: as quatro chaves `viewer.*` gateiam a
**disponibilidade da aba**, não o acesso ao dado.

## Problema

As quatro chaves de capacidade (`viewer.singleView`, `viewer.multiView`, `viewer.coreView`,
`viewer.view3D`) não aparecem em `[RequiredPermission]` nenhum. Os endpoints que servem os dados
daquelas telas carregam chave do **Core** — `DrillHoleView3DController` exige
`drillHoleView3D.getByAccount`, e o passo 7 da migração mapeia ao Core toda chave **exceto** as
quatro do visualizador.

Consequência: uma conta que contratou só o Core, cujo perfil conceda
`drillHoleView3D.getByAccount`, pode chamar `GET api/DrillHoleView3D/getByAccount` direto e receber
os dados do visualizador 3D. O que ela não recebe é a aba.

Isso **não** é vazamento entre contas — o escopo de tenant continua íntegro, e o auditor conferiu
os `Forbid()` do `ModuleController` de passagem. É um controle de **receita** que só existe no
navegador: o cliente que não pagou pelo módulo não vê a tela, mas o dado está a um `curl` de
distância para quem souber o nome do endpoint.

## Objetivo

Decidir se essa fronteira deve ser de autorização ou continuar sendo de interface — e registrar a
escolha, qualquer que seja.

## Fora de escopo

Implementar antes da decisão. Se a resposta for "mapear os endpoints ao módulo", isso muda
autorização de endpoints existentes e precisa de ADR própria, mais varredura de quais endpoints
pertencem a quais telas.

## Comportamento atual

Fronteira do módulo pago aplicada só pela UI, via `GET api/Module/capabilities`.

## Levantamento (feito em 2026-09-09, antes da decisão)

Mapeando os serviços que cada tela consome — a Etapa 3 antecipada, porque sem ela a decisão seria
tomada sobre uma premissa errada:

| Capacidade | Endpoints exclusivos da tela | Compartilhados com telas do **Core** |
|---|---|---|
| `viewer.singleView` | **nenhum** | `drillBox.*`, `drillCore.*`, as nove de anotação, `lithology.*`, `fractureType.*` |
| `viewer.multiView` | **nenhum** | as mesmas |
| `viewer.coreView` | **nenhum** | `drillCore.*` + anotações |
| `viewer.view3D` | `drillHoleView3D.getByAccount` | `drillBox.*`, `terrain.*` (este também é do Mine 3D) |

`DrillBoxService` é consumido por **12 componentes**, entre eles `drill-boxes` (lista),
`drill-box-view-images` (guia Images) e `deposit-view` — todos Core. `DrillCoreService`, pela guia
Images também.

**Consequência para a decisão:** mapear `drillBox.*` ou `drillCore.*` ao `advanced-viewer` tiraria
a guia Images e a lista de caixas de toda conta que só tem o Core. É o que a RN-01 proíbe. A saída
(b) original **não é implementável como estava escrita**.

Sobra **um** endpoint exclusivo de tela paga no produto inteiro: `drillHoleView3D.getByAccount`.

## Comportamento esperado

Uma decisão registrada em `.agents/decisions/`. O levantamento acima transformou duas saídas em
três:

- **(1) É de propósito.** O visualizador avançado é conveniência de interface, e cobrar por
  interface é legítimo. Falta dizer isso onde alguém procuraria — ADR-003 e `permission-rules.md` —
  para ninguém "corrigir" depois achando que é lacuna.
- **(2) Fechar só o que é fechável.** Mapear `drillHoleView3D.getByAccount` ao módulo. Custo baixo,
  ganho parcial e honesto: uma das quatro telas ganha fronteira de dado, e as outras três seguem
  sendo de interface — declaradamente.
- **(3) Separar os endpoints por tela** para poder gatear de verdade. Refatoração grande de API,
  risco alto de tirar acesso de quem tem, e não cabe numa task de dívida técnica.

## Regras de negócio

- RN-01: qualquer mudança aqui não pode tirar acesso de conta que já tem o módulo contratado.
- RN-02: o isolamento entre contas não está em questão e não deve ser tocado.

## Critérios de aceitação

- [x] CA-01: decisão registrada em `.agents/decisions/`, com o custo da alternativa rejeitada.
- [x] CA-02: se (1) ou (2), a ADR-003 e `api/docs/system/permission-rules.md` dizem explicitamente
      quais telas têm fronteira de dado e quais têm só de interface. Sem isso, a próxima auditoria
      levanta o mesmo achado.
- [x] CA-03: se (2), `drillHoleView3D.getByAccount` mapeado ao `advanced-viewer` por migração, com
      prova de que nenhuma conta que tem o módulo perde acesso.
- [ ] CA-04: confirmação por HTTP — **continua aberta**. O achado e a correção foram verificados por
      leitura de código e consulta ao banco, não por chamada autenticada à API. É o mesmo limite que
      o auditor declarou, e não vale marcá-lo como feito por semelhança.

## Impacto técnico

### Backend
Nenhum em (1). Em (2), uma linha em `modulefunctionality` e um endpoint hoje livre passa a ser
negado por módulo. Em (3), refatoração de API — fora do escopo desta task.

### Frontend
Nenhum. A UI já esconde as abas.

### Banco de dados
Em (2), migração de mapeamento — só `modulefunctionality`, nunca `profilefunctionality`.

### Segurança
É o eixo de receita, não o de tenant. Em (2), passa pelo `geocloud-permission-auditor`.

## Plano de implementação

- [x] Etapa 1: levantamento de quais endpoints pertencem a cada tela — **feito** (ver acima), e
      antes da decisão de propósito: sem ele, (b) teria sido escolhida sobre premissa errada.
- [x] Etapa 2: pergunta ao dono do produto — (1), (2) ou (3)?
- [x] Etapa 3: registrar a decisão em `.agents/decisions/`.
- [x] Etapa 4: só em (2), a migração de uma linha, com o teste de que ninguém perde acesso.

## Estratégia de testes

- [ ] Manual: autenticar como usuário de conta que tem só o Core e chamar
      `GET api/DrillHoleView3D/getByAccount`. Hoje responde os dados; é a reprodução do achado.
- [ ] Integração, só em (b): a mesma chamada passa a ser negada, e a conta com o módulo contratado
      continua recebendo.

## Riscos e rollback

O risco de (b) é tirar acesso de quem tem — mapear uma chave a mais derruba tela de cliente
pagante. Rollback é apagar as linhas de `modulefunctionality`, que o portão relê a cada resolução.

## Registro de execução

### Alterações realizadas

Migração `M20260909190753` move `drillHoleView3D.getByAccount` do Core para o `advanced-viewer` —
concedendo antes de retirar, para que uma falha no meio deixe a chave nos dois módulos (todo mundo
enxerga) em vez de em nenhum. `View3dModuleBoundaryTests` prova as duas metades e a contraprova.
ADR-008 registra a decisão; `permission-rules.md` ganhou a tabela de qual tela tem fronteira de dado
e qual tem de interface.

### Arquivos principais
- `api/src/Back.Persistence/Migrations/M20260909190753_View3dDataKeyToAdvancedViewer.cs` (novo)
- `api/tests/Back.IntegrationTests/Repositories/View3dModuleBoundaryTests.cs` (novo)
- `api/tests/Back.IntegrationTests/Repositories/ModuleBackfillTests.cs` — invariante atualizado
- `.agents/decisions/008-fronteira-do-visualizador-avancado.md` (novo)
- `api/docs/system/permission-rules.md`

### Decisões

1. **Saída (2), do dono do produto**: fechar só o que é fechável. O parcial é escolha — é tudo o que
   pode ser fechado sem tirar acesso de quem tem.
2. **O levantamento veio antes da decisão**, invertendo a ordem do plano original. Foi o que impediu
   a saída (b) de ser escolhida sobre premissa errada: ela teria tirado a guia Images de toda conta
   só com Core.

### Divergências

- **`ModuleBackfillTests` teve de mudar.** Ele codificava "o Core tem tudo menos as quatro chaves de
  capacidade", e a decisão torna isso falso. Falhou antes de eu atualizá-lo, que é o comportamento
  pretendido: mover a próxima chave para fora do Core exige acrescentá-la ali e dizer por quê.
- **Uma correção factual de outra task, descoberta aqui.** Um teste desta GT falhou numa asserção
  que eu esperava trivial, e a investigação mostrou que a **suíte de integração roda migrations** —
  `IntegrationCollection.cs:31` chama `ApplyPendingMigrations` depois de restaurar o dump. A GT-0046
  afirmava o contrário, em três lugares (ADR-006, registro da task, comentário de
  `ModuleTimeConversionTests`). O erro foi meu: li `MySqlTestDatabase`, vi o dump, e parei antes de
  abrir o arquivo da fixture. Corrigido nos três.

### Pendências

**CA-04 continua aberta**: nada aqui foi confirmado por HTTP. Leitura de código e consulta ao banco
provam o mapeamento e a resolução de chaves; não provam o comportamento de uma requisição
autenticada de ponta a ponta. É o mesmo limite que o auditor declarou, e marcá-lo como feito por
semelhança seria o tipo de afirmação que esta sprint passou o dia removendo.

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
```

```
Back.UnitTests          276 aprovados   (inalterado)
Back.IntegrationTests    48 aprovados   (eram 46)
```

## Handoff
Nenhum.

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
```

## Handoff
Nenhum.

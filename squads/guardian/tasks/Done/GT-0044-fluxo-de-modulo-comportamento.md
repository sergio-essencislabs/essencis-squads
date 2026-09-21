---
id: GT-0044
title: "Correção de comportamento no fluxo de módulo: startTrial rebaixa contrato pago e erros vazam schema"
status: completed
type: tech-debt
achado_origem: "TD-01, TD-08, TD-13, TD-14"
auditor_origem: "Dante Débito"
severidade: "alta"
produto: "GeoCloudAI"
camada: "backend"
run_origem: "auditoria ad-hoc de Dante Débito sobre o código de modularização (TASK-055/056/057), 2026-09-09 — sem run de pipeline; achados aprovados pelo dono do produto para correção na branch feature/fix/refactor-08_09-11_09"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/452"
grupo_execucao: ""
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0044-fluxo-de-modulo-comportamento.md"
owner: ""
created_at: 2026-09-09
updated_at: 2026-09-09
affected_modules: ["Back.API", "Back.Application", "Back.Persistence", "Back.UnitTests"]
related_adrs: []
---

# GT-0044 — Correção de comportamento no fluxo de módulo

## Contexto

Dante Débito auditou, em caráter ad-hoc, o código de modularização escrito nas TASK-055, TASK-056 e
TASK-057 (modelo de módulo e vínculo com a conta; desligamento por módulo e inadimplência; tela de
módulo não habilitado e teste de 7 dias). Dos 14 achados, quatro são de **comportamento observável
pelo cliente** — o que a API faz de errado, não como ela está escrita. Esta task agrupa esses
quatro. O achado que a encabeça, TD-01, foi **reproduzido contra o banco real** e derruba sozinho o
acesso de um cliente pagante sete dias depois de um clique legítimo na tela.

Todos os 14 achados foram aprovados pelo dono do produto para correção na branch
`feature/fix/refactor-08_09-11_09`.

## Achado original

### TD-01 (severidade alta) — `startTrial` rebaixa contrato pago a teste de 7 dias

`ModuleService.cs:154-210` + `ModuleRepository.cs:189-199`.

`StartTrial` valida quatro coisas: módulo informado, módulo existente/ativo, módulo não-Core, e
teste já usado. **Não valida o status atual do vínculo.**

`SetAccountModule` (`ModuleRepository.cs:124-139`) nunca grava `trialStartedAt`, e `HasUsedTrial`
lê exatamente esse campo. Logo, uma conta com `status='active'`, `endDate=NULL`,
`trialStartedAt=NULL` — o estado normal de um cliente que **contratou** o módulo pela rota
administrativa — passa por todas as quatro guardas. O upsert de `StartTrial` então sobrescreve
`status='trial'` e `endDate = NOW+7d`.

**Reproduzido contra o banco real**: vínculo `active` / `endDate NULL` / `trialStartedAt NULL`
passou a `trial` / `+7 dias` / `trialStartedAt = agora`.

Sete dias depois, o portão de módulo derruba o acesso de um cliente pagante, sozinho, sem
intervenção de ninguém.

Nenhum dos 15 casos de `ModuleTrialTests` cobre vínculo `active` pré-existente.

### TD-08 (severidade média) — `setAccountModule` com conta inexistente devolve 500 com schema no corpo

`setAccountModule` chamado com um `accountId` inexistente estoura a FK no MySQL, cai no `catch`, e
responde `500` com `ex.Message` cru — nome de schema, nome de tabela e nome da constraint no corpo
da resposta. O `NotFound("Conta ou módulo não encontrado")` (`ModuleController.cs:139`) só é
alcançável pela metade "módulo" da mensagem; a metade "conta" nunca chega lá.

Nota já resolvida durante a auditoria, registrada para não ser reinvestigada: `UseAffectedRows`
fica no default do MySqlConnector (found-rows), então uma escrita idempotente devolve 1 — **não há
404 falso** por reescrita do mesmo valor.

### TD-13 (severidade baixa) — validação duplicada com semânticas divergentes

`ModuleController.cs:126-134` e `:167-174` validam os valores aceitos de status; `ModuleService.cs:78-79`
e `:88-89` validam de novo. As duas semânticas divergem: o controller devolve `400` **com a lista de
valores aceitos**; o serviço devolve `false`, que o controller converte em `404` — mentindo sobre a
causa (dizendo "não encontrado" para um valor inválido).

### TD-14 (severidade baixa) — `catch (Exception ex) => StatusCode(500, ex.Message)` em 7 ações, sem `ILogger`

`ModuleController.cs`, linhas 56, 82, 99, 143, 183, 220, 271, 315. A classe não injeta `ILogger`,
então nada é registrado: a exceção vai inteira para o cliente e não fica em log nenhum.

**Dante marcou explicitamente como dívida herdada**, não introduzida por estas tasks: o mesmo padrão
está em `AnalysisController`, `ContactController` e `DepositController`. Esta task trata **só o
`ModuleController`** — a varredura dos outros controllers é trabalho separado, e não deve ser
puxada para dentro desta correção.

## Objetivo

1. `startTrial` nunca degradar um vínculo que já concede acesso — nem hoje, nem depois de sete dias.
2. Conta inexistente responder com o código de status que descreve o fato, sem expor nome de
   schema, tabela ou constraint.
3. Cada validação de status ter um único lugar e uma única semântica de erro.
4. Falha inesperada no `ModuleController` ser registrada em log e não devolver a exceção ao cliente.

## Fora de escopo

- Varrer `AnalysisController`, `ContactController`, `DepositController` e demais controllers pelo
  mesmo padrão de `catch` do TD-14 — dívida herdada, task própria.
- Qualquer mudança na regra de concessão, na fonte das chaves de capacidade ou no predicado de
  vigência — isso é a GT-0045.
- Cobertura de teste de `GetByAccount`, fuso horário dos timestamps, e custo de `GetCapabilities` —
  isso é a GT-0046.

## Comportamento atual

- Conta com módulo `active`/`endDate NULL` que aciona "iniciar teste" na tela tem o contrato
  rebaixado a `trial` com `endDate = NOW+7d`; sete dias depois perde o acesso.
- `POST` de vínculo com `accountId` inexistente → `500` com a mensagem do MySQL no corpo.
- Status inválido pode produzir `400` (pelo controller) ou `404` (pelo serviço), dependendo do
  caminho.
- Exceção inesperada → `500` com `ex.Message`, sem nenhum registro em log.

## Comportamento esperado

- `startTrial` sobre vínculo que já concede acesso não altera o vínculo, e responde `Started=false`
  com motivo que diga que o módulo já está disponível — sem consumir o teste.
- `accountId` inexistente → resposta de "não encontrado" com mensagem própria da aplicação.
- Status inválido → `400` com os valores aceitos, por um único caminho.
- Exceção inesperada → log com contexto + resposta genérica, sem `ex.Message`.

## Regras de negócio

- RN-01: um vínculo que **já concede acesso** (status que concede e vigência válida) não pode ser
  substituído por teste. O teste é a porta de entrada de quem não tem o módulo, não um caminho de
  volta para quem tem.
- RN-02 (preexistente, preservada): `trialStartedAt` é fato histórico imutável — a correção do TD-01
  não pode passar a gravá-lo em caminhos onde hoje não é gravado, nem a sobrescrevê-lo.
- RN-03: mensagem de erro devolvida ao cliente nunca contém identificador de schema, tabela ou
  constraint do banco.

## Critérios de aceitação

- [ ] CA-01: `StartTrial` recusa iniciar teste quando o vínculo atual concede acesso, sem alterar
      `status`, `endDate` ou `trialStartedAt`, e sem marcar o teste como usado.
- [ ] CA-02: teste cobrindo o caso exato reproduzido — vínculo `active` / `endDate NULL` /
      `trialStartedAt NULL` — que hoje passa e não deveria. `ModuleTrialTests` tem 15 casos e nenhum
      cobre vínculo `active` pré-existente.
- [ ] CA-03: teste cobrindo vínculo `active` com `endDate` futuro (ainda vigente) e vínculo
      `expired`/`cancelled` (que **deve** poder iniciar teste, se nunca usado).
- [ ] CA-04: `setAccountModule` com `accountId` inexistente responde "não encontrado" com mensagem
      da aplicação — sem nome de schema, tabela ou constraint no corpo.
- [ ] CA-05: validação de status vive em um único lugar; status inválido produz `400` com os valores
      aceitos, e nunca `404`.
- [ ] CA-06: `ModuleController` injeta `ILogger`; as 8 capturas registram a exceção e devolvem
      mensagem genérica, sem `ex.Message`.
- [ ] CA-07: a nota de dívida herdada do TD-14 fica registrada na task (os outros controllers com o
      mesmo padrão), para que a correção deste não seja confundida com a varredura geral.

## Impacto técnico

### Backend
`ModuleService.StartTrial` ganha a leitura do vínculo atual antes do upsert.
`ModuleController` ganha `ILogger` e perde `ex.Message` nas 8 respostas de erro.
Validação de status consolidada em um dos dois lados (controller ou serviço), não nos dois.

### Frontend
Nenhum contrato novo. A tela que dispara "iniciar teste" passa a poder receber `Started=false` com
um motivo novo — verificar se a mensagem é exibida como as outras.

### Banco de dados
Nenhuma migration. O TD-01 é falha de guarda na aplicação, não de schema.

### Integrações
Nenhuma.

### Segurança
TD-08 é vazamento de estrutura interna do banco em resposta de erro. TD-14 é a mesma classe de
vazamento, generalizada para qualquer exceção.

## Plano de implementação

- [ ] Etapa 1 (TD-01): ler o vínculo atual em `StartTrial` e recusar quando ele já conceder acesso.
- [ ] Etapa 2 (TD-01): escrever os testes de CA-02 e CA-03 — o de CA-02 deve falhar antes da Etapa 1.
- [ ] Etapa 3 (TD-08): distinguir conta inexistente de módulo inexistente antes de tentar a escrita.
- [ ] Etapa 4 (TD-13): consolidar a validação de status em um lugar, com semântica de `400`.
- [ ] Etapa 5 (TD-14): `ILogger` no `ModuleController`; substituir `ex.Message` por mensagem genérica.

## Estratégia de testes

- [ ] Unitários: `ModuleTrialTests` com os casos de CA-02 e CA-03; validação de status.
- [ ] Integração: `setAccountModule` com `accountId` inexistente contra o schema real (é o caminho
      que hoje estoura FK, e só o banco real o exercita).
- [ ] E2E: N/A.
- [ ] Manual: a reprodução do TD-01 contra o banco real, repetida depois da correção — vínculo
      `active`/`NULL`/`NULL` deve continuar `active`/`NULL`/`NULL`.

## Riscos e rollback

Risco: a guarda nova do TD-01 recusar teste para quem deveria poder iniciá-lo — um vínculo
`expired` ou `cancelled` **deve** permitir teste se nunca usado. É por isso que CA-03 cobre esses
estados explicitamente; sem eles a correção troca um bug por outro na direção oposta.

Rollback: reverter a guarda restaura o comportamento atual, que degrada contrato pago — rollback
não é opção segura aqui, é retorno a um defeito conhecido de severidade alta.

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

## Resultado

Concluída. Detalhe da execução, decisões e prova: ver a contraparte no repositório de produto.

O achado que abriu esta frente (TD-01) foi **reproduzido contra o banco real** antes da correção, e o teste que o cobre **falha sem a guarda** — verificado por remoção.

Issue aguarda o Gate de Promoção; nenhuma foi criada.

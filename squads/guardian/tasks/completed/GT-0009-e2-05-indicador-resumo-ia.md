---
id: GT-0009
title: "Indicador de resumo gerado por IA na caixa aberta"
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/326"
status_atualizado: reaberta_qa_2026-09-03
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [images-viewer, chat-ia]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0009 — Indicador de resumo gerado por IA

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-02; o diretório `.agents/tasks/` do
GeoCloudAI só passou a existir em 2026-09-09, no commit `8e10d774` (TASK-060). O mecanismo de
par não existia quando ela nasceu — o `contraparte:` não é ponteiro quebrado, é ausência
decidida.

**A ausência é decisão, não buraco — e não é por falta de informação.** A rastreabilidade do
lado-produto continua alcançável pelo que este arquivo já cita: issue, PR ou commit. Há por
onde chegar ao que foi feito; o que não há é um registro do lado de lá, porque não havia onde
escrevê-lo.

Um par criado hoje acrescentaria um ponteiro a uma rota que já funciona, e pagaria por isso
afirmando, pela própria existência, que o mecanismo de par cobria esta GT. Seria **registro
com proveniência falsa** — a mesma inversão de "planejado documentado como implementado",
com outra roupa. Por isso não foi criado.

Apurado na GT-0146 (issue #634), CA-07, em 12/09/2026. A busca forense e o controle positivo
ficam no registro daquela task e não são copiados aqui.

## Contexto
Sinalizar visualmente que a caixa aberta já possui resumo gerado por IA, permitindo visualizá-lo.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/326. Badge/ícone no cabeçalho (e opcionalmente na miniatura), conteúdo acessível em modal/popover, estado "sem resumo" visualmente distinto.

## Objetivo
Indicador confiável, atualiza sem reload durante a sessão.

## Fora de escopo
Geração do resumo em si (já existe, é o GeoMind/chat).

## Comportamento atual
Sem indicador visual de resumo existente.

## Comportamento esperado
Badge quando há resumo, resumo legível sem sair do visualizador, atualiza em tempo real.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Caixa com resumo exibe o indicador; caixa sem resumo, não.
- [x] CA-02: Resumo legível sem sair do visualizador.
- [x] CA-03: Indicador atualiza sem reload quando um resumo é gerado durante a sessão.

## Impacto técnico
### Backend
Confirmar contrato de leitura do resumo já existente (endpoint do GeoMind/chat).
### Frontend
Badge + modal/popover.
### Banco de dados
N/A — usa dado já existente.
### Integrações
Chat de IA (GeoMind) — só leitura, sem mudar o E2-08.
### Segurança
N/A.

## Plano de implementação
- [x] Confirmar endpoint de leitura do resumo.
- [x] Implementar badge + modal/popover.
- [x] Garantir atualização em tempo real (sem reload).

## Estratégia de testes
- [ ] Manual — usar dado do GT-0001 (1 caixa com resumo, 1 sem). **Não executado nesta sessão** (sem acesso a um ambiente com banco/API rodando); ver "Pendências" e "Validação".

## Riscos e rollback
Nenhum.

## Registro de execução

### Alterações realizadas
Backend (novo endpoint de leitura + persistência que faltava no chat de caixa):
- `ChatController`: novo `GET api/Chat/drillbox/summary?drillBoxId=` (permissão `chat.drillbox/summary`).
- `ChatService`: `GetDrillBoxSummary(drillBoxId, accountId)` — autoriza via `IDrillBoxRepository.GetById` + `box.DrillHole.Region.AccountId == accountId` (mesmo padrão de `DrillBoxChatContextService`), lê a mensagem `assistant` mais recente com a metadata do seed. `SendDrillBoxMessage` passa a persistir o par pergunta/resposta com essa metadata **somente quando `dto.ReportMode == true`** (best-effort, nunca derruba a resposta ao usuário se a persistência falhar).
- `IChatRepository`/`ChatRepository`: `GetLatestDrillBoxSummaryMessage(accountId, drillBoxId)` — join `chat_message`/`chat_conversation`, filtra por `account_id` (não por usuário) e pela metadata JSON (`JSON_EXTRACT`/`JSON_UNQUOTE`).
- `DrillBoxAiSummaryDto` (`HasSummary`, `Content`, `GeneratedAt`) em `DrillBoxChatDto.cs`.
- Migration `M20260902194727_ChatDrillBoxSummaryPermission` — registra a chave `chat.drillbox/summary` no catálogo `functionality` (mesmo padrão de `M20260831170750_UserPasswordReset`; não popula `profilefunctionality` — concessão a perfil é manual via Settings > Profiles).
- `api/docs/system/dev-data-seed.md` atualizado com a decisão (confirma a convenção do seed, não cria tabela nova).

Frontend:
- `ChatService.getDrillBoxSummary(drillBoxId)` + `DrillBoxAiSummary` (model `Chat.ts`).
- `DrillBoxAiChatComponent`: novo `@Output() summaryGenerated` emitido após uma resposta de `reportMode=true` bem-sucedida.
- `ViewerToolbarComponent`/`ViewerMenuComponent`: `@Input() hasAiSummary` (badge verde sobre o botão "Neural", com destaque de borda mesmo sem o badge visível de perto) + `@Output() aiSummaryBadgeClick` (independente do clique que abre o chat completo).
- `DrillBoxViewImagesComponent`: `aiSummary`/`loadAiSummary()` (chamado ao carregar/trocar de caixa), `onAiSummaryGenerated()` (reconsulta ao evento do chat — sem reload), `openAiSummaryModal()` (modal `ng-bootstrap` com o conteúdo em Markdown, atalho para abrir a análise completa).

### Arquivos principais
- `api/src/Back.API/Controllers/ChatController.cs`
- `api/src/Back.Application/Services/ChatService.cs`
- `api/src/Back.Application/Contracts/IChatService.cs`
- `api/src/Back.Application/Dtos/DrillBoxChatDto.cs`
- `api/src/Back.Persistence/Contracts/IChatRepository.cs`
- `api/src/Back.Persistence/Repositories/ChatRepository.cs`
- `api/src/Back.Persistence/Migrations/M20260902194727_ChatDrillBoxSummaryPermission.cs`
- `api/docs/system/dev-data-seed.md`
- `web/src/app/services/chat.service.ts`, `web/src/app/models/Chat.ts`
- `web/src/app/pages/geodata/drill-boxes/drill-box-ai-chat/drill-box-ai-chat.component.ts`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.{ts,html}`
- `web/src/app/shared/openseadragon-viewer/viewer-toolbar/*`, `web/src/app/shared/openseadragon-viewer/viewer-menu/*`

### Decisões
- **Convenção do seed confirmada, não substituída**: mantidas as tabelas `chat_conversation`/`chat_message` + `metadata` `{"drillBoxId":X,"kind":"drillbox_ai_summary_seed"}`; nenhuma tabela dedicada de "resumo por caixa" foi criada. Registrado em `api/docs/system/dev-data-seed.md`.
- **"O resumo" = o relatório formal (`ReportMode == true`)**, não qualquer troca de mensagem do chat da caixa. Motivo: `SendDrillBoxMessage` também é usado internamente por `fetchAiDescriptions` (export PDF/Word/Excel, `reportMode: false`) para descrever litologias — persistir isso como "resumo" produziria falsos positivos no indicador a partir de uma ação de bastidores do usuário, não de uma geração de resumo de fato.
- **Leitura escopada por conta, não por usuário**: diferente de `GetMyConversations`/`GetMessages` (que checam `conv.UserId == userId`), o resumo é tratado como artefato do tenant — qualquer colega da mesma conta vê o mesmo indicador, não só quem gerou o relatório.
- **Nova permissão via migration, sem popular `profilefunctionality`**: não existe nenhum seeder desse tipo neste código (confirmado no próprio doc do GT-0001); segue o precedente já mesclado de `M20260831170750_UserPasswordReset`.

### Divergências
- O achado original (issue #326) assumia que "a geração já existe" e tratava isso como fora de escopo. Na prática, o chat de caixa (`SendDrillBoxMessage`) **nunca persistia nada** — cada resposta só vivia no estado local do componente Angular. Sem persistir pelo menos o caso "relatório", o CA-03 não teria dado real fora da caixa seedada pelo GT-0001. Optei por um recorte mínimo (persistir apenas `ReportMode == true`) em vez de reabrir todo o desenho do chat de caixa, para não invadir o escopo do E2-08.
- Badge na miniatura da lista lateral (mencionado como "opcional" na issue) não foi implementado — mantido fora do escopo desta entrega para não expandir a superfície de mudança além dos 3 CAs.

### Pendências
- **Conceder a permissão `chat.drillbox/summary` a pelo menos um perfil** via Settings > Profiles antes de QA/uso real — a migration só registra a chave no catálogo `functionality` (mesmo padrão já usado no repo), não concede a nenhum perfil automaticamente.
- **Validação manual end-to-end não executada nesta sessão** (sem ambiente com API+MySQL rodando disponível) — ver "Validação" para o que foi de fato verificado (build/testes automatizados) e o que fica para quem revisar o PR.

## Validação

Executado nesta sessão (branch `feature/gt-0009-e2-05-indicador-resumo-ia`, a partir de `origin/feature/visualizadores-navegacao-layout`):

1. `cd api && dotnet build Back.sln` — **build limpo, 0 erros** (6 warnings pré-existentes, nenhum nos arquivos alterados).
2. `cd api && dotnet test tests/Back.UnitTests/Back.UnitTests.csproj --filter "FullyQualifiedName~Migrations"` — **3/3 passando** (confirma o timestamp/nome da nova migration).
3. `cd api && dotnet test tests/Back.UnitTests/Back.UnitTests.csproj` — **114/115 passando**; a falha (`ForeignKeyRangeValidationTests.Writable_foreign_keys_follow_the_range_convention`, sobre `DrillBoxChatSendDto.DrillBoxId` sem `[Range]`) é **pré-existente** — confirmado via `git log`/`git diff` que a propriedade já existia sem esse atributo antes desta branch (introduzida no commit `2da4d2d`, já mesclado na branch de integração); não relacionada a este PR.
4. `cd web && npx ng build --configuration development` — **build limpo, exit 0** (3 warnings `NG8107` pré-existentes em `login2`, `drill-hole-view-mult`, `drillholes-view-3d` — nenhum arquivo tocado por este PR). O build Angular faz checagem estrita de template, então cobre os bindings novos (`[hasAiSummary]`, `(aiSummaryBadgeClick)`, `(summaryGenerated)`, a referência forward ao `#modalAiSummary`, os pipes `markdown`/`date`).
5. `cd web && npx ng test --browsers=ChromeHeadlessCI --watch=false` — executado; ambiente com quebra de baseline pré-existente e abrangente (**179 de 245 specs falhando** por `declarations:` de NgModule usados com componentes `standalone`, já rastreada por uma branch própria `fix/angular-standalone-testbed-specs` presente no repo). Nenhum arquivo tocado por este PR aparece na lista de falhas como uma regressão nova: `viewer-toolbar`/`viewer-menu`/`drill-box-ai-chat` não têm spec dedicado; `drill-box-view-images.component.spec.ts` já usava o mesmo padrão quebrado antes desta branch.
6. **Não executado**: teste manual end-to-end (abrir a caixa seedada SEED-DH-01/caixa 1 e confirmar o badge; abrir outra caixa e confirmar a ausência; gerar um relatório em uma caixa sem resumo e confirmar atualização sem reload). Requer ambiente com API+MySQL rodando e a permissão `chat.drillbox/summary` concedida a um perfil (ver "Pendências").

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/367 (base: `feature/visualizadores-navegacao-layout`).

## Handoff
Depende de GT-0001 (dado com e sem resumo) — concluído, seed já popula os dois casos.

Para quem revisar/mergear o PR #367:
- Conceder `chat.drillbox/summary` a um perfil de teste (Settings > Profiles) antes de validar manualmente.
- Validar manualmente os 3 CAs com API+MySQL rodando (ver checklist na seção "Validação", item 6).

**PR #367 mesclado (squash) em `feature/visualizadores-navegacao-layout`.** O merge exigiu resolução manual de conflito (Jarvis) contra GT-0010 (#364, já mesclado antes): ambos adicionam `@Output()`/binding próprios em `ViewerToolbarComponent`/`ViewerMenuComponent` e em `drill-box-view-images.component.html` (GT-0009: `aiSummaryBadgeClick`/`hasAiSummary`; GT-0010: `analyzeHoleClick`/`showAnalyzeHoleButton`) — resolução por união (ambas as features são aditivas e independentes, nenhuma se sobrepõe semanticamente). `ng build` e `dotnet build` confirmados limpos após o merge, antes do push.

## Achado de QA pós-implementação (2026-09-03)
Relatório de QA (Matheus, `TASKS.md`, Observações gerais): a permissão `chat.drillbox/summary` (criada por esta task) nunca foi concedida a nenhum perfil, incluindo Administrator — o "Handoff" desta própria task já alertava exatamente para isso ("Conceder... antes de validar manualmente"), mas o passo manual nunca foi executado antes do teste do usuário. Isso, combinado com o comportamento pré-existente de `error.interceptor.ts` (redireciona a tela inteira em qualquer 403), derrubou toda a navegação de Images para o Dashboard — bloqueando E2-01 a E2-07 por completo, não só o indicador de resumo de IA desta task.

Correção roteada para **GT-0028** (nova, cross-cutting — grant da permissão + decisão de política sistêmica + tolerância do interceptor a 403 não-críticos). Ver plano consolidado em `squads/guardian/output/qa-pos-implementacao-2026-09-03.md`.

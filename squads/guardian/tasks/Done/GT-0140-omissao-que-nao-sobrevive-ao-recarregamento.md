---
id: GT-0140
title: "Aviso de omissão não sobrevive ao recarregamento da conversa"
status: completed
type: security
achado_origem: "N/A — achado do despacho da Vision (12/09/2026), sem run de auditoria do Guardian"
auditor_origem: "Vision (despacho direto)"
severidade: media
produto: GeoCloudAI
camada: cross-cutting
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/620"
grupo_execucao: ""
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [ChatRepository, ChatMessageDto, drill-box-ai-chat.component]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0140-omissao-que-nao-sobrevive-ao-recarregamento.md"
---

# GT-0140 — a omissão declarada some quando a conversa é reaberta

## Contexto
A GT-0138 (#597) existe porque *"instrução a modelo não é garantia"*: a via forte de declarar
omissão é o campo `omittedKinds`, lido pela UI, e não o texto que a IA foi instruída a escrever.
A GT-0138 ligou essa via — mas só no turno ao vivo. Reabrir a conversa devolve as mensagens sem
o campo, e o aviso desaparece de um histórico que continua parcial.

O campo é gravado. É na releitura que ele se perde, em três camadas seguidas.

## Achado original
**A gravação funciona.** `ChatService.cs:605` grava
`assistantMsg.OmittedKinds = JsonSerializer.Serialize(ctx.OmittedKinds)`, e
`ChatRepository.cs:248` persiste em `omitted_kinds`:
```sql
@AccountId, @DrillBoxId, CAST(@CoveredKeys AS JSON), CAST(@OmittedKinds AS JSON)); SELECT LAST_INSERT_ID()
```

**A releitura não lê a coluna.** `ChatRepository.GetMessagesByConversation`
(`api/src/Back.Persistence/Repositories/ChatRepository.cs:270-287`) seleciona sete colunas e
nenhuma delas é `omitted_kinds`:
```sql
SELECT M.id, M.conversation_id, M.role, M.content,
       CAST(M.metadata AS CHAR), M.stop_reason, M.register
```
Compare com `ListDurableDrillBoxSummaries` (`ChatRepository.cs:329-352`), que no mesmo arquivo
seleciona `CAST(M.omitted_kinds AS CHAR) AS OmittedKinds` — é por isso que o modal do resumo
durável mostra o aviso e a conversa reaberta não.

**O DTO não tem o campo.** `api/src/Back.Application/Dtos/ChatMessageDto.cs:3-16` expõe `Id`,
`ConversationId`, `Role`, `Content`, `Metadata`, `CreatedAt` e `StopReason`. Não há `OmittedKinds`.
`ChatService.cs:172-174` mapeia direto (`_mapper.Map<ChatMessageDto>`), então mesmo que a query
passasse a trazer a coluna, o campo morreria aqui.

**O frontend não remonta o campo.**
`web/src/app/pages/geodata/drill-boxes/drill-box-ai-chat/drill-box-ai-chat.component.ts:482-489`
```typescript
private turnFromMessage(m: ChatMessage): ChatTurn {
  return { id: m.id, role: m.role, content: m.content ?? '', incomplete: m.incomplete === true };
}
```
Sem `omittedKinds`. É a função usada por `selectConversation` (`:296-308`, via `:302`) para
remontar o histórico. O caminho ao vivo, por contraste, preenche o campo (`:584`:
`omittedKinds: result.data.omittedKinds ?? []`), e o template só renderiza o aviso quando ele
existe (`drill-box-ai-chat.component.html:113`: `[kinds]="turn.omittedKinds"`).

**Consequência.** A mesma resposta exibe o aviso de omissão enquanto está na tela e o perde ao
ser reaberta. Quem lê o histórico não tem como saber que aquele texto foi gerado sobre contexto
podado — que é precisamente o que a GT-0138 foi criada para impedir.

## Objetivo
O aviso de omissão da GT-0138 sobrevive ao recarregamento: a mesma mensagem mostra a mesma
declaração de omissão ao vivo e relida.

## Fora de escopo
- Não mostrar nem preencher o conteúdo omitido — a regra da GT-0128/0138 continua: declara-se
  **que** algo foi omitido, nunca **o quê**.
- Não retroagir sobre mensagens gravadas antes de `omitted_kinds` existir; ausência continua
  significando "nada omitido ou anterior à task", e a UI não precisa distinguir os dois.
- Não mexer no chat de plataforma, que não tem contexto de caixa nem omissão.

## Comportamento atual
Aviso presente no turno ao vivo, ausente no mesmo turno depois de reabrir a conversa.

## Comportamento esperado
Presente nos dois.

## Regras de negócio
- RN-01: o aviso depende apenas de `omittedKinds`, como na GT-0138 — nenhuma inferência a partir
  do texto da resposta.
- RN-02: lista vazia ou ausente não exibe aviso e não polui a UI.
- RN-03: o campo é aditivo no DTO — cliente antigo que não o conhece continua válido.

## Critérios de aceitação
- [ ] CA-01: mensagem gravada com `omitted_kinds` não vazio exibe o aviso depois de reabrir a
      conversa.
- [ ] CA-02: mensagem sem `omitted_kinds` (ou com lista vazia) não exibe aviso ao ser reaberta.
- [ ] CA-03: o turno ao vivo continua exibindo o aviso — sem regressão da GT-0138.
- [ ] CA-04: o campo trafega pelas três camadas — query, DTO e remontagem do turno — com teste em
      cada uma, já que o defeito é justamente uma camada silenciosa entre duas que funcionam.

## Impacto técnico
### Backend
`ChatRepository.GetMessagesByConversation` (acrescentar a coluna) e `ChatMessageDto`
(acrescentar o campo). Conferir o mapeamento do AutoMapper: a coluna é JSON em texto e o contrato
de saída é lista de string, como já faz `ParseArrayDeChaves` (`ChatService.cs:711`).
### Frontend
`turnFromMessage` e a interface `ChatMessage` em `web/src/app/models/Chat.ts`. O campo
`omittedKinds?: string[]` já existe no arquivo em duas outras interfaces — `:73`
(resposta do envio) e `:101` (`DrillBoxAiSummary`) — e **não** em `ChatMessage`, que é
justamente a que `turnFromMessage` consome. É o mesmo buraco das camadas de trás: o contrato
existe em volta e falta no caminho da releitura.
### Banco de dados
N/A — a coluna `omitted_kinds` já existe e já é gravada. Nenhuma migration.
### Integrações
N/A.
### Segurança
Transparência sem vazamento: o campo carrega nome de tipo, nunca valor.

## Plano de implementação
- [ ] Etapa 1 — acrescentar `omitted_kinds` à query de releitura.
- [ ] Etapa 2 — acrescentar o campo a `ChatMessageDto` e conferir o mapeamento.
- [ ] Etapa 3 — remontar `omittedKinds` em `turnFromMessage`.
- [ ] Etapa 4 — testes das três camadas (CA-04).

## Estratégia de testes
- [ ] Unitários: DTO/serviço no backend; `turnFromMessage` no frontend.
- [ ] Integração: releitura da conversa devolvendo o campo.
- [ ] E2E: N/A.
- [ ] Manual: gerar resposta com omissão, sair da conversa e reabrir.

## Riscos e rollback
- **Risco:** baixo. Mudança aditiva em três pontos; nada existente muda de forma.
- **Atenção:** `GetMessagesByConversation` também alimenta a montagem de histórico para o LLM
  (`ChatService.cs:242-246`). Acrescentar coluna não altera aquele uso, mas o teste deve confirmar
  que o histórico enviado ao modelo não mudou.
- **Rollback:** reverter os três pontos; nenhum dado é alterado.

## Registro de execução
### Alterações realizadas
Pendente — cunhada, não implementada. O Registro vai na contraparte.
### Arquivos principais
Pendente.
### Decisões
Pendente.
### Divergências
Nenhuma.
### Pendências
`grupo_execucao` vazio de propósito (Step 09). Toca `ChatService.cs`/`ChatRepository.cs` — não
pode rodar em paralelo com a GT-0139 nem com a GT-0141 sem roteamento.

## Validação
Pendente.

## Handoff
Cunhada e promovida no mesmo despacho. Relaciona-se com a GT-0138 (#597), que introduziu o aviso
e cobriu só o caminho ao vivo.
LLML: não consultada (branch de integração, não `main`).

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido - escopo desta GT especifica.** Commit `5accadb3` (PR #642), em main. Tres camadas:
`ChatRepository.cs:356,393,456` (projecao SQL), `ChatMessageDto.cs` (OmittedKinds),
`Chat.ts:56`/`drill-box-ai-chat.component.ts:570-576` (frontend). Testes versionados:
`ChatMessageOmittedKindsContractTests.cs` e `ChatRepositoryOmittedKindsColumnGuardTests.cs`.
Contraparte produto em completed/, Registro preenchido.

Nota: o Achado 1 do executor original (gravacao de omitted_kinds condicionada,
`ChatService.cs:438/600`) nao e escopo desta GT - ja foi cunhado a parte como GT-0148 (hoje
ainda aberta, ver relatorio da reconciliacao). Issue #620 continua OPEN apesar do merge.

Evidencia completa no relatorio da reconciliacao GT-0156.

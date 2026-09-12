---
id: GT-0141
title: "Conversa e mensagens não são gravadas na mesma transação"
status: active
type: tech-debt
achado_origem: "N/A — achado do despacho da Vision (12/09/2026), sem run de auditoria do Guardian"
auditor_origem: "Vision (despacho direto)"
severidade: media
produto: GeoCloudAI
camada: backend
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/621"
grupo_execucao: ""
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [ChatService, ChatRepository]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0141-janela-transacional-da-conversa.md"
---

# GT-0141 — a janela entre o insert da conversa e o das mensagens

## Contexto
A GT-0130 (#590) moveu toda a persistência para **depois** de o LLM devolver algo aproveitável,
porque antes dela uma falha do provedor deixava no histórico uma conversa órfã — com pergunta e
sem resposta, indistinguível de uma conversa real abandonada.

Isso fechou a janela grande, a que durava a chamada ao modelo. Sobrou uma pequena, e ela produz
exatamente o mesmo estado.

## Achado original
Os três inserts são round-trips independentes, sem transação em volta de nenhum deles.

**Chat de plataforma** — `api/src/Back.Application/Services/ChatService.cs:295-319`:
```csharp
conv.Id = await _repo.AddConversation(conv, userId);   // :303
userMsg.ConversationId = conv.Id;
userMsg.Id = await _repo.AddMessage(userMsg, userId);  // :307
...
assistantMsg.Id = await _repo.AddMessage(assistantMsg, userId);  // :319
```

**Chat da caixa** — `ChatService.cs:560-608`, mesma sequência: `AddConversation` (`:571`),
`AddMessage` do usuário (`:584`), `AddMessage` do assistente (`:607`).

Uma varredura por `TransactionScope` e `BeginTransaction` em `ChatService.cs` e
`ChatRepository.cs` não retorna **nenhuma ocorrência**. Cada `Add*` abre e fecha sua própria
operação em `_db.Connection`.

**Consequência.** Falha entre `:303` e `:307` — timeout de conexão, restart do processo, erro
do banco no segundo insert — deixa `chat_conversation` com uma linha e zero mensagens. É a
conversa órfã da GT-0130 de novo, por outra porta: menos provável, porque a janela é de
milissegundos em vez da duração da chamada ao LLM, e com o mesmo resultado no histórico do
usuário. Falha entre `:307` e `:319` deixa a variante com pergunta e sem resposta.

O produto já tem precedente registrado para esse tipo de meio-estado: a GT-0107
("atomicidade decorativa") e a GT-0089/0090 (baixa atômica e o guard do `TransactionScope`)
trataram o mesmo problema no financeiro.

## Objetivo
Conversa, pergunta e resposta entram juntas ou não entram — sem meio-estado no histórico.

## Fora de escopo
- Não mover a persistência para antes do LLM. A ordem da GT-0130 é o ponto de partida desta task,
  não algo a rever.
- Não alterar a contabilização de consumo de token, que continua acontecendo mesmo quando a
  chamada não rende resposta aproveitável (RN-01 da GT-0130, e o mesmo princípio da GT-0124).
- Não tocar o caminho efêmero (`dto.Ephemeral`), que de propósito não persiste nada.

## Comportamento atual
Três inserts independentes; falha no meio deixa conversa órfã ou conversa sem resposta.

## Comportamento esperado
Os inserts de uma mesma interação são atômicos: ou existem os três registros, ou nenhum.

## Regras de negócio
- RN-01: atomicidade não pode adiar a gravação para antes do sucesso do LLM — a ordem da GT-0130
  se mantém.
- RN-02: o consumo de token continua registrado independentemente do resultado da transação.
- RN-03: a transação cobre a interação inteira, incluindo o `UpdateConversation` quando houver.

## Critérios de aceitação
- [ ] CA-01: falha no insert da mensagem do usuário não deixa conversa gravada.
- [ ] CA-02: falha no insert da mensagem do assistente não deixa nem conversa nem pergunta.
- [ ] CA-03: o caminho feliz grava os três registros, sem mudança de comportamento observável.
- [ ] CA-04: falha do LLM continua não gravando nada — as asserções da GT-0130 seguem passando,
      **reescritas se preciso mas nunca removidas** (ver o aviso abaixo).
- [ ] CA-05: o consumo de token continua contabilizado nos cenários de falha (RN-02).
- [ ] CA-06: o caminho efêmero continua não persistindo nada.

## ⚠️ Aviso a quem implementar — não apague a prova da GT-0130
A suíte atual prova a GT-0130 com asserções negativas, agrupadas em `NadaFoiPersistido()`:

`api/tests/Back.UnitTests/Ai/ChatServicePersistenceAfterLlmTests.cs:109-115`
```csharp
private async Task NadaFoiPersistido()
{
    await _repo.DidNotReceive().AddConversation(Arg.Any<ChatConversation>(), Arg.Any<int?>());
    await _repo.DidNotReceive().AddMessage(Arg.Any<ChatMessage>(), Arg.Any<int?>());
    await _repo.DidNotReceive().UpdateConversation(Arg.Any<ChatConversation>(), Arg.Any<int?>());
    _gravadas.Should().BeEmpty();
}
```
Há outras quatro asserções `DidNotReceive().AddMessage` no mesmo estilo, em
`ChatServiceAttachmentTests.cs:125` e `:142` e `ChatServiceConversationScopeTests.cs:88` e `:166`.

Essas asserções provam que **nada foi gravado antes do LLM** — comportamento da GT-0130, que está
certo e precisa continuar valendo. Quem unir as duas escritas numa transação provavelmente vai
fazê-las falhar, e o conserto tentador é apagá-las. **Apagar essas asserções destrói a prova da
GT-0130 e reabre, sem ninguém perceber, o defeito que a #590 fechou.**

O caminho correto é reescrevê-las para o novo desenho — continuar provando "nada foi persistido
quando o LLM falhou", pela via que o novo desenho oferecer (mock da transação, verificação de
rollback, ou asserção sobre o estado final em vez da chamada). Se em algum cenário isso for
genuinamente impossível, é divergência para registrar e devolver à Vision — não uma linha a menos
no arquivo de teste.

## Impacto técnico
### Backend
`ChatService.SendMessage` e `ChatService.SendDrillBoxMessage`; possivelmente a fronteira de
transação no repositório. Avaliar o precedente do financeiro (GT-0089/0090) antes de escolher o
mecanismo — há guard de `TransactionScope` já estabelecido no produto.
### Frontend
N/A.
### Banco de dados
Sem schema novo. Conferir que as tabelas envolvidas são InnoDB — transação em MyISAM é silenciosa
e não reverte nada, o que transformaria a correção em atomicidade decorativa (GT-0107).
### Integrações
N/A.
### Segurança
Indireto: conversa órfã polui o histórico e dificulta auditoria do que foi perguntado.

## Plano de implementação
- [ ] Etapa 1 — decidir o mecanismo (transação no repositório vs. `TransactionScope` no serviço),
      olhando o guard já existente da GT-0090.
- [ ] Etapa 2 — envolver os inserts dos dois endpoints.
- [ ] Etapa 3 — reescrever as asserções da GT-0130 para o novo desenho, sem removê-las (CA-04).
- [ ] Etapa 4 — testes de falha no meio (CA-01, CA-02) e do caminho feliz (CA-03).

## Estratégia de testes
- [ ] Unitários: CA-01 a CA-06 em `Back.UnitTests/Ai/`.
- [ ] Integração: atomicidade real contra o banco — é onde se vê se a transação reverte de fato.
- [ ] E2E: N/A.
- [ ] Manual: N/A.

## Riscos e rollback
- **Risco principal:** a suíte ficar verde por remoção de asserção em vez de por correção. O CA-04
  e o aviso acima existem por isso.
- **Risco:** transação longa segurando conexão. A janela é curta (três inserts, sem chamada
  externa dentro dela, porque o LLM já respondeu antes).
- **Rollback:** reverter a fronteira de transação; os inserts voltam a ser independentes.

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
`grupo_execucao` vazio de propósito (Step 09). Toca `ChatService.cs` nos mesmos blocos que a
GT-0139 e a GT-0140 — as três não podem ser despachadas em paralelo sem roteamento.

## Validação
Pendente.

## Handoff
Cunhada e promovida no mesmo despacho. Sucessora direta da GT-0130 (#590): fecha a janela que
sobrou depois que a persistência foi movida para depois do LLM.
LLML: não consultada (branch de integração, não `main`).

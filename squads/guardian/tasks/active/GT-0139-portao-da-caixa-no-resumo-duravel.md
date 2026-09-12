---
id: GT-0139
title: "Resumo durável não exige do leitor a chave da própria caixa"
status: active
type: security
achado_origem: "N/A — achado do despacho da Vision (12/09/2026), sem run de auditoria do Guardian"
auditor_origem: "Vision (despacho direto)"
severidade: alta
produto: GeoCloudAI
camada: backend
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/619"
grupo_execucao: ""
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [ChatService, DrillBoxChatContextService]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0139-portao-da-caixa-no-resumo-duravel.md"
---

# GT-0139 — o portão da caixa não é conferido no resumo durável

## Contexto
A GT-0128 (#588) estabeleceu que `drillBox.getByDrillHole` autoriza os dados invariantes da
caixa — cabeçalho do furo, número, código, profundidades e a foto do testemunho — e escreveu a
razão no próprio código: *"o chat não pode ser um caminho mais curto para o mesmo dado"*
(`DrillBoxChatContextService.cs:37-42`).

Ela fechou o caminho de **geração**. O caminho de **leitura** do resumo durável nunca foi
estendido para a chave nova, e é por ele que o mesmo dado sai.

## Achado original
O portão existe em três lugares e falta num quarto.

1. **Via REST, a chave é exigida.**
   `api/src/Back.API/Controllers/DrillBoxController.cs:624-626`
   ```csharp
   [Route("getByDrillHole")]
   [RequiredPermission("drillBox.getByDrillHole")]
   public async Task<IActionResult> GetByDrillHole(int drillHoleId, [FromQuery]PageParams pageParams)
   ```

2. **Na geração do contexto, a chave é conferida.**
   `api/src/Back.Application/Services/DrillBoxChatContextService.cs:121-127` — sem ela o contexto
   vai redigido e `drillBox` entra em `omittedKinds` (`:130`).

3. **Mas a chave é deliberadamente excluída de `CoveredPermissionKeys`.**
   `api/src/Back.Application/Services/DrillBoxChatContextService.cs:133-141`
   ```csharp
   // CoveredPermissionKeys continua medindo só cobertura de MARCAÇÃO. A chave da caixa
   // não entra: [...] Somar aqui uma chave que não é de marcação desligaria esse veto.
   var coveredKeys = AnnotationPermissionKeys
       .Where(kv => granted[kv.Key])
       .Select(kv => kv.Value)
       .ToList();
   ```
   A exclusão tem motivo declarado e legítimo — a GT-0123 usa "lista vazia" como veto, e somar
   uma chave que não é de marcação desligaria esse veto.

4. **E o portão do leitor é derivado exclusivamente dessa lista.**
   `api/src/Back.Application/Services/ChatService.cs:785-790`
   ```csharp
   private static List<string> ChavesExigidas(ChatMessage candidato)
   {
       return ParseArrayDeChaves(candidato.CoveredKeys)
           ?? ExtractCoveredKeys(candidato.Metadata)
           ?? DrillBoxChatContextService.AnnotationPermissionKeys.Values.ToList();
   }
   ```
   Os três ramos — coluna, metadata e o fallback do resumo legado — só produzem chaves de
   marcação. Nenhum deles contém `drillBox.getByDrillHole`.

`ChatService.GetDrillBoxSummary` (`ChatService.cs:659-713`) confere escopo de conta
(`:664-668`) e depois só `PodeLer(exigidas, userId)` (`:684-688`). **Nunca confere a chave da
caixa.** O controller acima dele exige apenas `chat.drillbox/summary`
(`ChatController.cs:91-94`).

**Consequência.** Um usuário da mesma conta, com as dez chaves de marcação e com
`chat.drillbox/summary`, mas **sem** `drillBox.getByDrillHole`, recebe em
`DrillBoxAiSummaryDto.Content` (`ChatService.cs:706-712`) o texto de um resumo gerado por quem
tinha a chave da caixa — texto que contém exatamente o cabeçalho, número, código e profundidades
que a GT-0128 redige para esse perfil. O item 3 não é o defeito; o defeito é o item 4 não ter
uma segunda via para a chave que o item 3 corretamente deixou de fora.

## Objetivo
Ler o resumo durável de uma caixa exige do leitor a mesma chave que a via REST exige para
entregar a caixa, sem desligar o veto de cobertura vazia da GT-0123.

## Fora de escopo
- Não mexer em `CoveredPermissionKeys`. A exclusão da chave da caixa ali tem motivo escrito
  (GT-0123) e continua válida — a correção precisa de outra via, não de reverter aquela.
- Não alterar o cálculo de cobertura da GT-0126 (`CoberturaDe`, `ChatService.cs:806-812`).
- Não tocar o caminho de geração (`Build`), que já confere a chave.
- Não distinguir "não existe" de "não pode ver" na resposta — `ChatService.cs:698-704` fecha isso
  de propósito e deve continuar fechado.

## Comportamento atual
Quem não tem `drillBox.getByDrillHole` lê, pelo resumo durável, dados da caixa que a GT-0128
redige para ele em todo outro caminho.

## Comportamento esperado
Sem `drillBox.getByDrillHole`, o resumo durável de uma caixa não é servido — pelo mesmo
`HasSummary = false` que já cobre o caso "existe mas você não pode ver".

## Regras de negócio
- RN-01: a chave da caixa é exigida do leitor **em adição** às chaves de marcação, nunca em
  substituição a elas.
- RN-02: a recusa por falta da chave da caixa usa a mesma resposta indistinguível de
  `ChatService.cs:698-704` — negar não pode revelar que o resumo existe.
- RN-03: o veto da GT-0123 (`coveredKeys` vazio exige o conjunto completo) continua valendo
  sem alteração.

## Critérios de aceitação
- [ ] CA-01: leitor sem `drillBox.getByDrillHole` recebe `HasSummary = false` mesmo tendo todas
      as dez chaves de marcação e o resumo existindo.
- [ ] CA-02: leitor com a chave da caixa e com as chaves de marcação exigidas continua recebendo
      o resumo — nenhuma regressão do caminho feliz da GT-0126.
- [ ] CA-03: resumo legado (sem `coveredKeys`) continua exigindo o conjunto completo de marcação
      **e** passa a exigir a chave da caixa.
- [ ] CA-04: `CoveredPermissionKeys` permanece contendo só chaves de marcação — verificado por
      teste, para que a correção não seja feita pelo atalho que a GT-0123 veta.
- [ ] CA-05: a recusa não distingue "não existe" de "não pode ver".

## Impacto técnico
### Backend
`ChatService.GetDrillBoxSummary` e/ou `ChavesExigidas`. A chave da caixa é constante pública
(`DrillBoxChatContextService.DrillBoxPermissionKey`, `:43`) — a fonte única já existe.
### Frontend
N/A. `HasSummary = false` já é tratado.
### Banco de dados
N/A. Nenhuma coluna nova: a chave é conferida contra o leitor, não lida do registro.
### Integrações
N/A.
### Segurança
É o ponto da task: restabelece na leitura o controle que a GT-0128 criou na geração.

## Plano de implementação
- [ ] Etapa 1 — exigir `DrillBoxPermissionKey` do leitor em `GetDrillBoxSummary`, sem tocar
      `CoveredPermissionKeys`.
- [ ] Etapa 2 — testes dos cinco CAs, incluindo o CA-04 como trava contra o atalho vetado.

## Estratégia de testes
- [ ] Unitários: os cinco CAs em `Back.UnitTests/Ai/`.
- [ ] Integração: N/A.
- [ ] E2E: N/A.
- [ ] Manual: perfil sem a chave da caixa abrindo o modal de resumo.

## Riscos e rollback
- **Risco:** endurecer a leitura pode esconder resumo de quem hoje o vê legitimamente. O CA-02
  existe para medir isso. Se o perfil "todas as marcações, sem a caixa" for comum em produção, é
  achado de configuração de perfil, não motivo para afrouxar o portão.
- **Rollback:** a mudança é local ao método; reverter é um commit.

## Registro de execução
### Alterações realizadas
Pendente — esta GT foi cunhada, não implementada (despacho da Vision de 12/09/2026 separa as
duas coisas). O Registro vai na contraparte.
### Arquivos principais
Pendente.
### Decisões
Pendente.
### Divergências
Nenhuma.
### Pendências
`grupo_execucao` vazio de propósito: quem o preenche é o Step 09 (roteamento), olhando arquivo e
endpoint. Sem ele esta GT não pode ser despachada em paralelo com outra que toque `ChatService.cs`.

## Validação
Pendente.

## Handoff
Cunhada e promovida no mesmo despacho. Implementação é despacho posterior da Vision.
LLML: não consultada (branch de integração, não `main`).

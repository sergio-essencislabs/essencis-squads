---
type: checkpoint
outputFile: squads/guardian/output/audit-scope.md
---

# Step 01: Escopo

O squad **Guardian** audita dívida técnica, drift de documentação e
segurança no **GeoCloudAI** e **E-LIMS** — usando o material de referência
interno do squad (`reference/geocloud` e `reference/elims`) como fonte de
policies/playbooks — transforma achados aprovados em tasks estruturadas e,
mediante pedido explícito do usuário, em issues no GitHub Project
**Essencis-Labs** e implementação coordenada. Também aceita, como entrada
alternativa a uma auditoria, um pedido direto de implementação ("Guardian,
preciso fazer X"). Este checkpoint define o modo de execução e o escopo
exato antes de qualquer trabalho começar.

## Pergunta ao Usuário

Pergunte ao usuário, em português, o modo de execução:

0. **Modo desta execução?**
   1. **Auditoria nova** — rodar os três auditores (Dívida Técnica, Segurança,
      Documentação) e trabalhar a partir dos achados encontrados.
   2. **Retomar tasks pendentes** — já existem `GT-*.md` em
      `squads/guardian/tasks/backlog/` ou `tasks/active/` de uma run
      anterior; pular a auditoria e ir direto para promover/continuar essas
      tasks.
   3. **Solicitação direta de implementação** — o usuário já sabe o que quer
      construir/corrigir ("preciso implementar X"); pular a auditoria e deixar
      o Jarvis planejar e quebrar por camada a partir do pedido em texto livre.

Se o modo for **1 (auditoria nova)**, prosseguir com as três perguntas de
sempre:

1. **Qual produto auditar?**
   1. GeoCloudAI
   2. E-LIMS
   3. Ambos
2. **Quais frentes priorizar?**
   1. Dívida técnica
   2. Documentação
   3. Segurança
   4. Todas
3. **Profundidade da varredura?**
   1. Rápida — só achados óbvios, alta confiança, sem varredura exaustiva
   2. Completa — varredura extensa, incluindo achados de baixa severidade e
      revisão de código detalhada

Se o modo for **2 (retomar)**, perguntar apenas: "retomar tudo que está
pendente, ou só algumas `GT-IDs` específicas?" — aceitar lista de IDs ou
"tudo".

Se o modo for **3 (solicitação direta)**, pedir o texto livre do pedido de
implementação, e as mesmas duas perguntas de produto/profundidade acima (sem
a pergunta de frentes, que não se aplica).

## Ação do Pipeline Runner

1. Coletar o modo e as respostas correspondentes. Resolver também a **branch alvo**: por padrão,
   usar a branch semanal/de integração vigente. `main`/`master` só pode ser escolhida quando o
   usuário tiver ordenado explicitamente atuação direta nela nesta execução; o checkout estar em
   `main` não basta. Se não houver branch semanal conhecida, perguntar em vez de assumir `main`.
2. Modo 1: se o usuário não especificar produto, assumir "Ambos"; se não
   especificar frentes, assumir "Todas"; se não especificar profundidade,
   assumir "Completa".
3. Modo 2: fazer `Glob` em `squads/guardian/tasks/backlog/*.md` e
   `tasks/active/*.md` para listar as `GT-IDs` pendentes antes de perguntar
   quais retomar.
4. Modo 3: registrar o pedido em texto livre, fielmente, sem resumir a ponto
   de perder intenção do usuário.
5. Registrar o escopo em `squads/guardian/output/audit-scope.md` no formato
   abaixo — este arquivo é o `inputFile` dos Steps 02-05, então cada um deles
   precisa conseguir determinar, só lendo este arquivo, qual é o `modo` desta
   execução e se deve rodar de verdade ou virar stub.
6. Incluir na mesma gravação a branch e a decisão sobre LLML já resolvidas no Passo 0 do wrapper
   (`~/.claude/skills/guardian/SKILL.md`):
   - branch semanal/de integração: `LLML: não consultada`, pois a Library representa a `main`;
   - `main`/`master` com ordem explícita: reutilizar em "Conhecimento Prévio (VaultS)" o resultado
     já consultado uma única vez. Nunca consultar o VaultS de novo aqui.
7. Avançar: modo 1 → Steps 03, 04 e 05 (auditorias, em paralelo; Step 02 vira
   stub); modo 3 → Step 02 (planejamento do Jarvis; Steps 03-05 viram stub);
   modo 2 → Steps 02-05 todos stub, indo direto para o Step 06 com a lista de
   `GT-IDs` pendentes.

## Formato de Salvamento

```markdown
# Escopo da Execução

**Data:** YYYY-MM-DD
**Modo:** [auditoria-nova | retomar-promocao | implementacao-direta]
**Branch alvo:** [nome exato]
**Atuação direta na main autorizada nesta execução:** [sim | não]
**LLML:** [não consultada — branch semanal/de integração | consultada — atuação direta na main explicitamente autorizada]

## Modo 1 — Auditoria nova
**Produto(s):** [GeoCloudAI | E-LIMS | Ambos]
**Frentes priorizadas:** [Dívida técnica | Documentação | Segurança | Todas]
**Profundidade:** [Rápida | Completa]

### Codebases no escopo
- [lista derivada do produto escolhido, sempre em caminho absoluto:
  GeoCloudAI → `C:\Software\GeoCloud\GeoCloudAI` (backend `api/src/Back.*`, frontend `web/`),
  mais o framework de policy `C:/Software/ClaudeCode/squads/guardian/reference/geocloud`.
  E-LIMS → `C:\Software\ELIMS\ELIMS` (backend `backend/src/Back.*`, frontend
  `frontend/`), mais o framework de policy `C:/Software/ClaudeCode/squads/guardian/reference/elims`.
  Ambos → as quatro entradas acima.]

## Modo 2 — Retomar tasks pendentes
**GT-IDs alvo:** [lista de IDs, ou "todas as pendentes"]
**Pendentes encontradas:** [lista de GT-NNNN + pasta atual (backlog/active), do Glob feito no passo 3]

## Modo 3 — Solicitação direta de implementação
**Pedido do usuário (texto livre, fiel):** "..."
**Produto(s):** [GeoCloudAI | E-LIMS | Ambos]
**Profundidade:** [Rápida | Completa]

## Conhecimento Prévio (VaultS)
[Em branch semanal/de integração: "N/A — LLML representa a main e esta execução atua na branch
<nome>; fontes de verdade são código, testes, tasks, handoffs e issues da branch." Em atuação
direta na main explicitamente autorizada: resumo reunido no Passo 0 do wrapper, ou "Nada relevante
encontrado no VaultS para este escopo."]

## Observações do usuário
[qualquer contexto adicional em texto livre fornecido pelo usuário]
```

---
execution: subagent
agent: documentation-architect
inputFile: squads/guardian/output/aprovacao-prs.md
outputFile: squads/guardian/output/docs-atualizados.md
model_tier: fast
---

# Step 19: Fechamento — Atualização de Docs/Knowledge

## Context Loading

Load these files before executing:
- `squads/guardian/output/aprovacao-prs.md` — decisão do usuário: quais PRs foram aprovados para merge (só estes entram no fechamento de documentação)
- `squads/guardian/output/implementacao-backend.md`, `squads/guardian/output/implementacao-frontend.md`, `squads/guardian/output/implementacao-database.md` — detalhe do que cada PR aprovado efetivamente mudou (arquivos, componentes, schema)
- `squads/guardian/agents/documentation-architect.agent.md` — persona/principles de Marta Documentation: drift documental, planejado vs. implementado, extensão preferida a criação
- `squads/guardian/agents/documentation-architect/tasks/atualizar-documentacao.md` — processo operacional de atualização pós-implementação (fase de fechamento, distinto da auditoria do step 5)
- Docs e planilhas estruturais dos produtos afetados, no próprio repositório de produto: `C:\Software\GeoCloud\GeoCloudAI` (`docs/`, `Documentation/`) e `C:\Software\ELIMS\ELIMS` (`docs/`, `Documentation/`); e a knowledge base do framework correspondente (`C:/Software/ClaudeCode/squads/guardian/reference/geocloud` ou `C:/Software/ClaudeCode/squads/guardian/reference/elims`: knowledge/patterns, knowledge/known-issues, knowledge/decisions)

## Instructions

Ler primeiro `audit-scope.md` desta run e aplicar o gate de branch:

- Se a branch alvo for semanal/de integração (ou uma branch de task derivada dela), **não atualizar
  documentação nem knowledge base**. A documentação viva representa a `main`, pelo mesmo motivo que
  a LLML: doc escrito a partir de código que ainda não foi mesclado afirma como implementado aquilo
  que a `main` não tem — é exatamente o "planejado documentado como implementado" que esta persona
  existe para impedir. Gravar o output curto no formato "Fechamento documental omitido" abaixo e
  avançar.
- Somente se `audit-scope.md` registrar simultaneamente branch `main`/`master` e autorização
  explícita do usuário para atuação direta nela, executar o processo abaixo.
- Checkout em `main` sem autorização explícita é veto, não autorização implícita.

**O caminho normal é ad-hoc, não este passo.** Como toda sprint roda em branch, este passo é
omitido na maioria das execuções, e a atualização real acontece depois: Marta Documentation
invocada via runner ad-hoc (`runner.agent.md`) contra a `main` já com os PRs mesclados, e Lívia
Librarian logo em seguida. A ordem entre as duas não é preferência — Lívia usa como fonte o que
Marta acabou de verificar, e sincronizar a LLML antes da documentação inverteria a cadeia de
verdade.

### Process

1. Filtrar em `aprovacao-prs.md` apenas os PRs marcados como "Aprovados para Merge" — PRs bloqueados ou rejeitados pelo usuário não geram atualização de documentação nesta execução.
2. Para cada PR aprovado, identificar no arquivo de implementação correspondente (backend/frontend/database) o conjunto completo da mudança — entidade, DTO, controller, permissão, fluxo, schema — e atualizar o conjunto completo de documentos afetados, nunca só o arquivo que mudou por acaso.
3. Decidir, para cada documento afetado, se a ação é estender o documento existente (preferido) ou criar um novo; documentação irremediavelmente enganosa é removida, nunca deixada "quase certa".
4. Se o PR fechou um achado que tinha um known-issue correspondente na knowledge base, marcar esse known-issue como resolvido, citando o PR e a branch mesclada.
5. Avaliar, para cada lição extraída da implementação, se ela é cross-projeto (vai para `C:\Software\ClaudeCode\squads\guardian\knowledge\`) ou específica de produto (vai para `.agents/memory` do produto) — nunca duplicar a mesma lição nos dois lugares.
6. Atualizar planilhas estruturais (ex.: `Planilha_GEOCLOUD_permissoes.xlsx` ou equivalente) quando o PR alterou entidade, DTO, controller ou permissão mapeados nessas planilhas.
7. Consolidar todas as atualizações de documentação/knowledge feitas nesta execução no arquivo de saída, um bloco por PR mesclado.

## Output Format

The output MUST follow this exact structure:
```markdown
# Docs/Knowledge Atualizados — {data da execução}

## Fechamentos por PR Mesclado

### {referência do PR} — {task original}
**Docs/system atualizados:** {lista de arquivos, com o que mudou em cada}
**Planilha estrutural atualizada:** {arquivo/aba, ou "N/A"}
**Known-issue correspondente:** {ID marcado como resolvido, ou "nenhum known-issue prévio"}
**Lição registrada:** {cross-projeto (knowledge/patterns|decisions) ou específica de produto (.agents/memory)} — {resumo da lição}

(repetir bloco para cada PR mesclado)

## PRs Sem Ação de Documentação
{lista de PRs aprovados que não exigiram nenhuma mudança de doc/knowledge, com justificativa breve}
```

Para branch semanal/de integração, usar:

```markdown
# Fechamento documental omitido — {data da execução}

**Branch alvo:** {nome}
**Motivo:** a documentação viva representa somente a `main`; esta execução atua em branch
semanal/de integração.
**Docs/knowledge alterados:** nenhum.
**Encaminhamento:** atualização a fazer via runner ad-hoc contra a `main` depois do merge — Marta
Documentation primeiro, Lívia Librarian em seguida.
```

## Output Example

```markdown
# Docs/Knowledge Atualizados — 2026-08-21

## Fechamentos por PR Mesclado

### PR #142 — GT-0001 (AllowAnonymous em POST /Address/add)
**Docs/system atualizados:** `docs/system/permission-rules.md` — seção "Address" atualizada de "pendente de controle de acesso" para "protegido por address.create"; `docs/system/auth-overview.md` — exemplo de endpoint sem proteção removido da lista de gaps conhecidos.
**Planilha estrutural atualizada:** `Planilha_GEOCLOUD_permissoes.xlsx`, aba "Endpoints", linha `Address/add` marcada como `address.create` provisionada.
**Known-issue correspondente:** `reference/geocloud/knowledge/known-issues/0002-address-add-allowanonymous.md` marcado como resolvido, citando PR #142 e branch `fix/address-add-authorization`.
**Lição registrada:** cross-projeto (`knowledge/patterns/permissao-explicita-por-endpoint.md`) — reforça o padrão "toda rota nova nasce com [RequiredPermission], nunca depois".

### PR #144 — GT-0002 (campo JSON legado em testrequest)
**Docs/system atualizados:** `docs/system/schema-testrequest.md` — campo `testsjson` marcado como em descontinuação, com data prevista de remoção total da leitura de fallback.
**Planilha estrutural atualizada:** N/A.
**Known-issue correspondente:** nenhum known-issue prévio — achado veio direto da auditoria de dívida técnica desta execução.
**Lição registrada:** específica de produto (`.agents/memory/geocloud-ai/schema-legado.md`) — detalhe do fluxo específico do GeoCloudAI que ainda escrevia no campo legado.

## PRs Sem Ação de Documentação
Nenhum.
```

## Veto Conditions

Reject and redo if ANY of these are true:
0. Documentação ou knowledge base foi atualizada numa execução em branch semanal/de integração, ou
   em `main`/`master` sem ordem explícita do usuário para atuação direta nela.
1. Um documento foi deixado "quase certo" em vez de corrigido ou removido, quando a divergência era clara.
2. Uma funcionalidade planejada foi documentada como implementada (ou o inverso) em qualquer doc atualizado.
3. Uma entrada de knowledge base foi criada que é apenas um resumo de código, sem lição acionável.
4. A mesma lição foi registrada duplicada entre `.agents/memory` do produto e `squads/guardian/knowledge/`.
5. Um PR aprovado para merge em `aprovacao-prs.md` foi ignorado e não recebeu nenhuma avaliação de impacto documental.

## Quality Criteria

- [ ] A branch alvo e a autorização explícita para atuação direta na main foram verificadas em
      `audit-scope.md` antes de qualquer alteração de documentação ou knowledge base.
- [ ] Em branch semanal/de integração, nenhum doc e nenhuma entrada de knowledge base foi alterada,
      e o encaminhamento ad-hoc ficou registrado no output.
- [ ] Todo PR aprovado para merge tem um bloco de fechamento correspondente (mesmo que seja "sem ação de documentação").
- [ ] Known-issues cobertos por um PR mesclado foram marcados como resolvidos, citando o PR.
- [ ] Toda lição nova está classificada corretamente como cross-projeto ou específica de produto, sem duplicação.
- [ ] Planilhas estruturais refletem entidade/DTO/controller/permissão alterados pelos PRs mesclados.

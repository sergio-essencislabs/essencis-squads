---
execution: subagent
agent: documentation-architect
inputFile: squads/guardian/output/audit-scope.md
outputFile: squads/guardian/output/audit-documentacao.md
model_tier: powerful
---

# Step 05: Auditoria de Documentação

## Context Loading

Load these files before executing:
- `squads/guardian/output/audit-scope.md` — modo desta execução, produto(s),
  frentes priorizadas e profundidade decididos pelo usuário no Step 01;
  determina se este step deve rodar de fato (modo auditoria-nova, com
  "Documentação" priorizada) ou virar stub.
- `squads/guardian/agents/documentation-architect.agent.md` —
  persona de Marta Documentation: detecta drift de documentação/knowledge base vs.
  código real nesta fase de auditoria (a fase de atualização pós-implementação
  só roda no Step 19).
- `squads/guardian/agents/documentation-architect/tasks/auditar-documentacao.md`
  — processo operacional a seguir: quais documentos comparar contra qual
  código, e como classificar cada divergência.
- `C:\Software\GeoCloud\GeoCloudAI` (GeoCloudAI — backend em `api/src/Back.*`, frontend em `web/`) e
  `C:\Software\ELIMS\ELIMS` (E-LIMS — backend em `backend/src/Back.*`, frontend em
  `frontend/`) — os codebases de produto reais sob auditoria. Mesma stack
  (.NET 9 + Dapper, Angular 19), layout de pastas diferente: nunca assumir o
  layout de um produto ao varrer o outro. A documentação viva a
  comparar contra o código mora nesses mesmos repositórios: `docs/`,
  `Documentation/` e `.agents/memory/` de cada produto.
- `C:/Software/ClaudeCode/squads/guardian/reference/geocloud` e `C:/Software/ClaudeCode/squads/guardian/reference/elims` — o
  material de referência interno do squad, por produto; contém as
  policies/playbooks de qualidade e a knowledge base de known-issues já
  registrados. Não é o codebase auditado. Também fornece
  knowledge/patterns e knowledge/decisions para o cruzamento.

## Instructions

> **Independência de `.claude`/`.cursor`:** `documentation-sync` e `structural-spreadsheet-sync` não são skills nativas deste squad — são as metodologias em `C:/Software/ClaudeCode/squads/guardian/reference/{geocloud|elims}/skills/{nome}/SKILL.md` (caminho absoluto, conforme codebase em escopo). Ler o `SKILL.md` correspondente e aplicar o método diretamente via Grep/Glob/Bash/Read, sem depender do Skill tool nem de `.claude/`/`.cursor/` do repositório de produto.

### Process

1. Ler `audit-scope.md`. Se o **modo** não for "auditoria-nova" (ou seja, for
   "retomar-promocao" ou "implementacao-direta"), gravar o output só com a
   nota "N/A — modo {modo}, ver audit-scope.md" e encerrar imediatamente, sem
   nenhuma varredura. Se o modo for "auditoria-nova" mas "Documentação" não
   estiver entre as frentes priorizadas, registrar o output apenas com a nota
   "Fora do escopo definido no checkpoint" e encerrar — não auditar mesmo
   assim. Se a seção "Conhecimento Prévio (VaultS)" citar achados relevantes a
   esta frente, tratá-los como ponto de partida já verificado: focar a
   varredura em confirmar se ainda são verdade e em cobrir o que essa seção
   não cobre, em vez de rederivar do zero o que ela já documenta — nunca
   aceitar sem checagem quando o achado do VaultS parecer desatualizado
   frente ao código atual.
2. Rodar `documentation-sync` para localizar todos os documentos que
   mencionam a(s) área(s) sob auditoria no(s) codebase(s) do escopo, e
   comparar cada afirmação do documento contra o comportamento real do
   código correspondente.
3. Classificar cada divergência encontrada. Documento afirmar "implementado"
   quando não está (ou o inverso) é o pior tipo — sinalizar com prioridade
   máxima; demais divergências recebem prioridade Alta/Média/Baixa conforme
   o impacto de confundir quem lê o documento.
4. Se a área auditada envolve entidade/DTO/controller/permissão, rodar também
   `structural-spreadsheet-sync` para verificar as planilhas estruturais do
   produto contra o schema/contrato real.
5. Para cada divergência, decidir a ação recomendada: corrigir o texto,
   marcar como "planejado" em vez de "implementado" (ou vice-versa), ou
   remover documentação irremediavelmente enganosa — nunca "deixar quase
   certo". Registrar a ação recomendada sem executá-la (a execução de
   fechamento acontece no Step 19, após as correções serem aprovadas).
6. Consolidar achados no formato abaixo e salvar em `audit-documentacao.md`,
   citando `documentation-sync`/`structural-spreadsheet-sync` como evidência
   em cada achado.

## Output Format

```markdown
# Auditoria de Documentação — Marta Documentation

**Data:** YYYY-MM-DD
**Escopo auditado:** [produto(s) e codebase(s) conforme audit-scope.md]

### Achado DOC-NN — Prioridade: [Máxima/Alta/Média/Baixa]
**Documento:** `caminho/do/doc.md`, seção "[seção]"
**Divergência:** [o que o doc afirma vs. o que o código realmente faz]
**Classificação:** [doc descreve implementado quando é planejado | doc desatualizado | doc a remover | outro]
**Evidência:** [documentation-sync | structural-spreadsheet-sync] — [detalhe]
**Ação recomendada:** [corrigir texto | marcar como planejado/implementado | remover com registro]

[repetir por achado]

## Resumo
- Total de achados: N
- Por prioridade: Máxima N / Alta N / Média N / Baixa N
```

## Output Example

```markdown
# Auditoria de Documentação — Marta Documentation

**Data:** 2026-08-21
**Escopo auditado:** GeoCloudAI (C:\Software\GeoCloud\GeoCloudAI)

### Achado DOC-01 — Prioridade: Máxima
**Documento:** `docs/system/auth-overview.md`, seção "SSO"
**Divergência:** documento afirma "SSO corporativo implementado via SAML",
código não contém nenhuma integração SAML.
**Classificação:** doc descreve implementado quando é apenas planejado.
**Evidência:** documentation-sync — nenhuma referência a biblioteca/fluxo SAML
encontrada no codebase varrido.
**Ação recomendada:** corrigir seção para "planejado — ver
o roadmap do material de referência (reference/{produto}/knowledge/roadmap/)", nunca deletar sem registro.

### Achado DOC-02 — Prioridade: Média
**Documento:** `Planilha_GEOCLOUD_permissoes.xlsx`, aba "Endereços"
**Divergência:** planilha não lista a permission key `address.create`, que já
existe no seed do código.
**Classificação:** doc desatualizado.
**Evidência:** structural-spreadsheet-sync — comparação seed vs. planilha
aponta 1 key ausente.
**Ação recomendada:** adicionar a linha correspondente na planilha.

## Resumo
- Total de achados: 2
- Por prioridade: Máxima 1 / Alta 0 / Média 1 / Baixa 0
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Algum achado não cita `documentation-sync` (ou `structural-spreadsheet-sync`
  quando aplicável) como evidência.
- Um achado do tipo "doc afirma implementado quando é planejado" (ou o
  inverso) recebeu prioridade diferente de Máxima.
- Algum achado propõe deletar documentação sem registro, em vez de marcar
  como superada.
- O relatório mistura, sem distinguir, lição cross-projeto (framework) com
  lição específica de produto.

## Quality Criteria

- [ ] `documentation-sync` (e `structural-spreadsheet-sync` quando aplicável)
      executado e citado como evidência em cada achado.
- [ ] Nenhum achado afirma "não implementado" para algo já implementado, ou
      o inverso, sem ter sido essa a própria divergência relatada.
- [ ] Zero duplicação de lição entre a KB de engenharia (`squads/guardian/knowledge/`, `reference/*/knowledge/`) e docs vivos do
      produto no relatório.
- [ ] Achados respeitam o escopo (produto/frentes/profundidade) definido no
      checkpoint anterior.

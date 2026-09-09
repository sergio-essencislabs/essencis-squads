---
execution: subagent
agent: tech-debt-auditor
inputFile: squads/guardian/output/audit-scope.md
outputFile: squads/guardian/output/audit-divida-tecnica.md
model_tier: powerful
---

# Step 03: Auditoria de Dívida Técnica

## Context Loading

Load these files before executing:
- `squads/guardian/output/audit-scope.md` — modo desta execução, produto(s),
  frentes priorizadas e profundidade decididos pelo usuário no Step 01;
  determina se este step deve rodar de fato (modo auditoria-nova, com
  "Dívida técnica" priorizada) ou virar stub.
- `squads/guardian/agents/tech-debt-auditor.agent.md` — persona de
  Dante Debit: detecta código morto, duplicação e complexidade acidental
  sempre com evidência de ferramenta, nunca por impressão subjetiva, e nunca
  implementa a correção.
- `squads/guardian/agents/tech-debt-auditor/tasks/auditar-divida-tecnica.md`
  — processo operacional a seguir: quais detectores rodar, como mapear
  consumidores e como classificar cada achado.
- `C:\Software\GeoCloud\GeoCloudAI` (GeoCloudAI — backend em `api/src/Back.*`, frontend em `web/`) e
  `C:\Software\ELIMS\ELIMS` (E-LIMS — backend em `backend/src/Back.*`, frontend em
  `frontend/`) — os codebases de produto reais sob auditoria. Mesma stack
  (.NET 9 + Dapper, Angular 19), layout de pastas diferente: nunca assumir o
  layout de um produto ao varrer o outro.
- `C:/Software/ClaudeCode/squads/guardian/reference/geocloud` e `C:/Software/ClaudeCode/squads/guardian/reference/elims` — o
  material de referência interno do squad, por produto; contém as
  policies/playbooks de qualidade e a knowledge base de known-issues já
  registrados. Não é o codebase auditado.

## Instructions

> **Independência de `.claude`/`.cursor`:** `duplicate-detector`, `dead-code-detector`, `code-smell-detector` e `dependency-mapper` não são skills nativas deste squad — são as metodologias em `C:/Software/ClaudeCode/squads/guardian/reference/{geocloud|elims}/skills/{nome}/SKILL.md` (caminho absoluto, conforme codebase em escopo). Ler o `SKILL.md` correspondente e aplicar o método diretamente via Grep/Glob/Bash/Read, sem depender do Skill tool nem de `.claude/`/`.cursor/` do repositório de produto.

### Process

1. Ler `audit-scope.md`. Se o **modo** não for "auditoria-nova" (ou seja, for
   "retomar-promocao" ou "implementacao-direta"), gravar o output só com a
   nota "N/A — modo {modo}, ver audit-scope.md" e encerrar imediatamente, sem
   nenhuma varredura. Se o modo for "auditoria-nova" mas "Dívida técnica" não
   estiver entre as frentes priorizadas, registrar o output apenas com a nota
   "Fora do escopo definido no checkpoint" e encerrar — não auditar mesmo
   assim. Se a seção "Conhecimento Prévio (VaultS)" citar achados relevantes a
   esta frente, tratá-los como ponto de partida já verificado: focar a
   varredura em confirmar se ainda são verdade e em cobrir o que essa seção
   não cobre, em vez de rederivar do zero o que ela já documenta — nunca
   aceitar sem checagem quando o achado do VaultS parecer desatualizado
   frente ao código atual.
2. Rodar detecção com evidência de ferramenta sobre cada codebase no escopo:
   `duplicate-detector` e `dead-code-detector` primeiro (acham candidatos),
   depois `code-smell-detector` (complexidade acidental). Ajustar a
   profundidade da varredura (rápida vs. completa) conforme decidido no
   checkpoint.
3. Para cada candidato encontrado, rodar `dependency-mapper` e listar todos os
   consumidores antes de estimar risco ou classificar severidade.
4. Classificar cada achado em uma das três categorias: duplicação real,
   dívida legada convivendo com padrão novo, ou complexidade acidental — e
   verificar contra a knowledge base de known-issues do material de referência (`reference/{geocloud|elims}/knowledge/known-issues/`) para
   confirmar que não é um achado já aberto.
5. Atribuir severidade (Alta/Média/Baixa) e esforço estimado (Alto/Médio/
   Baixo) a cada achado, já quebrando qualquer correção proposta em etapas
   pequenas e revisáveis — sem propor implementação, apenas o plano.
6. Consolidar todos os achados no formato de saída abaixo e salvar em
   `audit-divida-tecnica.md`.

## Output Format

```markdown
# Auditoria de Dívida Técnica — Dante Debit

**Data:** YYYY-MM-DD
**Escopo auditado:** [produto(s) e codebase(s) conforme audit-scope.md]

### Achado TD-NN — Severidade: [Alta/Média/Baixa]
**Componente:** `caminho/ou/símbolo` (Produto)
**Evidência:** [ferramenta(s) usada(s)] — [o que a ferramenta reportou]
**Classificação:** [duplicação real | dívida legada convivendo com padrão novo | complexidade acidental]
**Esforço estimado:** [Alto/Médio/Baixo] — [resumo da correção em etapas pequenas]
**Consumidores mapeados:** N ([detalhe de leitura vs. escrita])
**Known-issue relacionado:** [nenhum | referência]

[repetir por achado]

## Resumo
- Total de achados: N
- Por severidade: Alta N / Média N / Baixa N
```

## Output Example

```markdown
# Auditoria de Dívida Técnica — Dante Debit

**Data:** 2026-08-21
**Escopo auditado:** GeoCloudAI (C:\Software\GeoCloud\GeoCloudAI)

### Achado TD-01 — Severidade: Média
**Componente:** `testrequest.testsjson` (GeoCloudAI)
**Evidência:** dead-code-detector + dependency-mapper — campo JSON legado ainda
escrito por 2 fluxos antigos, mas 100% das leituras já migraram para as
tabelas relacionais novas de testes.
**Classificação:** dívida legada convivendo com padrão novo (não é duplicação
ativa).
**Esforço estimado:** Baixo — remover escrita legada, manter leitura de
fallback por 1 release.
**Consumidores mapeados:** 2 (ambos de escrita, nenhum de leitura ativa).
**Known-issue relacionado:** nenhum.

### Achado TD-02 — Severidade: Baixa
**Componente:** `ReportGeneratorService.BuildLegacyExport()`
**Evidência:** code-smell-detector — complexidade ciclomática 18, 4
responsabilidades misturadas (parsing, formatação, persistência, notificação).
**Classificação:** complexidade acidental.
**Esforço estimado:** Médio — quebrar em 4 métodos/serviços menores, sem
mudança de comportamento.
**Consumidores mapeados:** 3 (nenhum afetado pela quebra proposta).
**Known-issue relacionado:** nenhum.

## Resumo
- Total de achados: 2
- Por severidade: Alta 0 / Média 1 / Baixa 1
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Algum achado não cita evidência de ferramenta (nome da skill + saída) —
  descrição textual sozinha não é suficiente.
- Algum achado está fora do produto/codebase definido em `audit-scope.md`.
- Algum achado se sobrepõe a um known-issue já aberto na knowledge base sem
  citar essa relação.
- O relatório contém qualquer recomendação de implementação em vez de apenas
  priorização e plano de correção em etapas pequenas.
- Algum achado toca o núcleo compartilhado de Conta/Identidade e não está
  explicitamente marcado como tal.

## Quality Criteria

- [ ] Todo achado tem evidência de ferramenta (nome da skill + saída).
- [ ] Todo achado tem consumidores mapeados e severidade justificada.
- [ ] Nenhum achado se sobrepõe a um known-issue já aberto.
- [ ] Relatório final não contém nenhuma recomendação de implementação —
      apenas priorização.
- [ ] Achados respeitam o escopo (produto/frentes/profundidade) definido no
      checkpoint anterior.

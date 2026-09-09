# Material de referência do squad Guardian

Cópia integral (menos `.git/`) dos antigos frameworks de produto, internalizada
em **2026-08-28** para tornar o squad autossuficiente:

| Pasta | Origem (aposentada) | Produto |
|---|---|---|
| `geocloud/` | `C:\Software\geocloud-ai-framework` | GeoCloudAI (`C:\Software\GeoCloud\GeoCloudAI`) |
| `elims/` | `C:\Software\elims-ai-framework` | E-LIMS (`C:\Software\ELIMS\ELIMS`) |

Depois desta internalização, **nenhum arquivo do squad aponta para os
diretórios de origem** — eles podem ser removidos do disco sem afetar o
Guardian ou o Reporter.

## O que os agentes usam daqui

- `{produto}/skills/{nome}/SKILL.md` — as 18 metodologias (duplicate-detector,
  endpoint-scanner, permission-matrix-auditor, documentation-sync,
  structural-spreadsheet-sync, database-diff etc.). Ler o `SKILL.md` do produto
  em escopo e aplicar o método via Grep/Glob/Bash/Read.
- `{produto}/policies/` e `{produto}/playbooks/` — as policies de qualidade,
  segurança e documentação citadas pelos auditores e pelo revisor.
- `{produto}/knowledge/known-issues/` — registro de achados por produto
  (filtro anti-duplicação de Dante/Selma/Marta/Tomás e registro de resolução
  no fechamento). **Atenção:** o ELIMS tem KIs de segurança críticos ainda
  abertos (0008–0012).
- `{produto}/knowledge/` (patterns, decisions, architecture, domain, roadmap)
  — histórico herdado por produto.

## O que é importante saber

- **As duas cópias NÃO são idênticas** — 23 diferenças substantivas. As que
  mais mordem: metodologia de migration oposta (GeoCloud = FluentMigrator
  `M0xx_*.cs`; ELIMS = script SQL manual, ADR-0004 vigente) e política de
  planilha/documentação (GeoCloud = por pasta de branch; ELIMS = só `Main`).
  Nunca aplicar o material de um produto no outro.
- Lições cross-projeto **novas** não entram aqui — vão para
  `C:\Software\ClaudeCode\squads\guardian\knowledge\` (ver README de lá).
  Este diretório recebe apenas atualizações por produto (ex.: marcar um
  known-issue como resolvido).
- Referências internas dos arquivos copiados (`policies/...`, `knowledge/...`)
  são relativas à raiz de cada produto (`geocloud/` ou `elims/`) e continuam
  resolvendo normalmente.

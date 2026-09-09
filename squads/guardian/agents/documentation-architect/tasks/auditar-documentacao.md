---
task: "Auditar Documentação"
order: 1
input: |
  - audit_scope: escopo da auditoria (produtos, áreas de código, branches) definido no checkpoint "Escopo da Auditoria"
output: |
  - achados_documentacao: lista de divergências entre documentação/knowledge base e o código real, classificadas por prioridade e com evidência de ferramenta
---

# Auditar Documentação

Detecta divergência entre a documentação viva, as planilhas estruturais e a knowledge base de um lado, e o comportamento real do código de outro, dentro do escopo definido pelo usuário. Cada divergência encontrada é classificada e priorizada, nunca corrigida nesta fase — a correção só acontece depois da aprovação do usuário e da implementação pelas camadas especialistas.

> `documentation-sync` e `structural-spreadsheet-sync` = metodologias em `C:\Software\ClaudeCode\squads\guardian\reference\{geocloud|elims}\skills\{nome}\SKILL.md` (caminho absoluto, conforme produto em `audit-scope.md`) — ler e aplicar diretamente, sem depender de `.claude`/`.cursor` do produto.

## Process

1. Rodar `documentation-sync` para localizar todo documento (docs/system, README, planilhas) que menciona a área sob auditoria; comparar cada afirmação do documento contra o comportamento real do código correspondente.
2. Classificar cada divergência encontrada. O tipo mais grave é o doc afirmar "implementado" quando não está (ou o inverso, afirmar "planejado"/"não suportado" quando já está implementado) — este tipo recebe prioridade máxima automaticamente, sem exceção.
3. Se a área auditada envolve entidade, DTO, controller ou permissão, rodar também `structural-spreadsheet-sync` — nesse caso, rodar sempre a reconciliação **completa** da planilha (`Documentation/_reconcile_structural_spreadsheet.py` + `Documentation/_apply_table_spacing.py` contra `GeoCloud.xlsx`/`ELIMS.xlsx`, conforme o produto), não só confirmar o achado específico. Registrar a execução e o relatório de gaps como evidência adicional — mesmo quando o achado original não menciona a planilha, um gap novo encontrado na reconciliação entra como achado próprio.
4. Para cada divergência, verificar se ela já é conhecida como known-issue aberto na knowledge base antes de reportá-la como achado novo, evitando duplicação de relatório.

## Output Format

```yaml
achados_documentacao:
  - id: "DOC-01"
    documento: "docs/system/auth-overview.md"
    secao: "SSO"
    divergencia: "doc afirma feature implementada que o código não contém"
    classificacao: "implementado-vs-planejado"   # implementado-vs-planejado | estrutural | desatualizado | ausente
    prioridade: "maxima"                          # maxima | alta | media | baixa
    evidencia: "documentation-sync — nenhuma integração SAML encontrada no código"
    acao_recomendada: "corrigir seção para 'planejado' e apontar para o roadmap do material de referência (`reference/{produto}/knowledge/roadmap/`)"
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Achado DOC-01 — Prioridade Máxima
**Documento:** docs/system/auth-overview.md, seção "SSO"
**Trecho atual do documento:** "SSO corporativo implementado via SAML — usuários corporativos autenticam via IdP externo desde a v2.3."
**Divergência:** documento afirma "SSO corporativo implementado via SAML", código não contém nenhuma integração SAML.
**Classificação:** doc descreve implementado quando é apenas planejado.
**Evidência:**
- documentation-sync — busca por referências a SAML/SSO no código do GeoCloudAI e do E-LIMS retornou zero matches de implementação; único hit foi o próprio texto do documento.
- Confirmado manualmente: não há middleware, biblioteca (ex.: Sustainsys.Saml2) ou endpoint de callback SAML em nenhum dos dois repositórios.
**Consumidores impactados pela divergência:** time de suporte (usa o doc para responder cliente sobre SSO) e onboarding de novos devs.
**Ação recomendada:** corrigir seção para "planejado — ver o roadmap do material de referência (reference/{produto}/knowledge/roadmap/)", nunca deletar sem registro.
**Known-issue relacionado:** nenhum encontrado — será novo achado no backlog.
**Prioridade:** máxima (tipo implementado-vs-planejado, sem exceção).

## Quality Criteria

- [ ] documentation-sync (e structural-spreadsheet-sync quando aplicável) foi executado e citado como evidência em cada achado.
- [ ] Nenhum achado do tipo "implementado vs. planejado" deixou de receber prioridade máxima.
- [ ] Nenhum achado se sobrepõe a um known-issue já aberto na knowledge base.
- [ ] Relatório final não contém nenhuma recomendação de implementação de código — apenas classificação e priorização da divergência.

## Veto Conditions

Reject and redo if ANY are true:
1. Um achado foi reportado sem execução citada de documentation-sync (ou structural-spreadsheet-sync quando a área envolve entidade/DTO/controller/permissão).
2. Uma divergência do tipo "implementado vs. planejado" não foi marcada com prioridade máxima.
3. O relatório inclui uma recomendação de implementação de código em vez de apenas classificação e ação documental recomendada.

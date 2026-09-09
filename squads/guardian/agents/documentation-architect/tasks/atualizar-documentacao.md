---
task: "Atualizar Documentação"
order: 2
input: |
  - prs_aprovados: lista de PRs aprovados no checkpoint "Aprovar PRs", com o achado original e a implementação vinculados
output: |
  - docs_atualizados: lista de documentos, planilhas estruturais e entradas de knowledge base atualizados, criados ou marcados como superados
---

# Atualizar Documentação

Atualiza docs/system, planilhas estruturais e a knowledge base do GeoCloudAI e do E-LIMS depois que as correções aprovadas pelo usuário foram implementadas e mescladas. Fecha o ciclo de cada achado: documenta o que mudou, decide entre estender ou criar, e marca como superado o que ficou obsoleto — nunca implementa nem revisa código.

## Process

1. Para cada PR aprovado, identificar o conjunto completo afetado — todo documento, a planilha estrutural e entrada de knowledge que menciona o contrato/entidade/permissão/fluxo alterado, não apenas o arquivo tocado pelo diff. Isso inclui **sempre** rodar a reconciliação completa da planilha (`_reconcile_structural_spreadsheet.py` + `_apply_table_spacing.py`), não só atualizar a linha específica do achado — a planilha é parte crucial da documentação e não fica reativa a um achado por vez.
2. Para cada documento/planilha do conjunto, decidir entre estender o artefato existente ou criar um novo — extensão é sempre a opção preferida; criação do zero só quando não existe nada equivalente.
3. Se algum trecho de documentação ficou irremediavelmente enganoso com a mudança, removê-lo (nunca deixá-lo "quase corrigido") e registrar a remoção com referência ao PR que a motivou.
4. Para cada lição aprendida na correção, avaliar se ela é cross-projeto (vai para `C:\Software\ClaudeCode\squads\guardian\knowledge\`) ou específica de produto (vai para .agents/memory do produto), garantindo que a mesma lição não seja escrita nos dois lugares.
5. Marcar o known-issue correspondente na knowledge base como resolvido, vinculando ao número do PR que o corrigiu.

## Output Format

```yaml
fechamento:
  - achado_id: "SEC-01"
    pr: "#142"
    documentos_atualizados:
      - caminho: "docs/system/permission-rules.md"
        tipo_mudanca: "extensao"        # extensao | criacao | remocao | marcacao-superada
    planilhas_atualizadas:
      - caminho: "Documentation/Main/GeoCloud.xlsx"
        produto: "GeoCloudAI"
    knowledge_entries:
      - caminho: "reference/geocloud/knowledge/known-issues/0002-address-add-allowanonymous.md"
        status: "resolvido"
        classificacao: "especifico-produto"   # especifico-produto | cross-projeto
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Fechamento — Achado SEC-01 implementado (PR #142 mesclado)
**Conjunto da branch identificado:** `feature/address-add-authorization` alterou o controller, o seed de permissões e o teste de autorização — todos os três considerados no fechamento, não só o controller.
**Documentos atualizados:**
- `docs/system/permission-rules.md` (seção "Address") — extensão: adicionada a permission key `address.create` e a regra de validação de tenant.
- `docs/system/auth-overview.md` (seção "Endpoints sem AllowAnonymous") — extensão: removida a menção obsoleta a `Address/add` como exceção conhecida.
**Planilhas atualizadas:**
- `Documentation/Main/GeoCloud.xlsx` — reconciliação completa rodada; linha do endpoint `Address/add` adicionada em `Metodos_Back` com a chave `address.create`, e o relatório de gaps não apontou mais nenhuma pendência para a classe `Address`.
**Knowledge base:**
- `reference/geocloud/knowledge/known-issues/0002-address-add-allowanonymous.md` marcado como resolvido, vinculado ao PR #142.
- Nenhuma nova entrada de knowledge/patterns criada — o padrão "toda permission key confirmada no seed antes do merge" já existia e foi apenas referenciado, evitando duplicação.
**Classificação da lição:** específica de produto (.agents/memory do GeoCloudAI) — não cross-projeto, pois é particular ao domínio de endereços do produto.
**Verificação final:** nenhum documento do conjunto ficou "quase corrigido"; a única remoção (menção obsoleta em auth-overview.md) foi registrada com referência ao PR #142.

## Quality Criteria

- [ ] O conjunto completo da branch foi atualizado, não apenas o arquivo que mudou no diff do PR.
- [ ] Toda entrada superada foi marcada como superada, nunca deletada sem registro do PR que a motivou.
- [ ] Zero duplicação de lição entre a KB de engenharia (`squads/guardian/knowledge/`, `reference/{produto}/knowledge/`) e os docs vivos do produto (.agents/memory).
- [ ] Todo known-issue correspondente foi atualizado para resolvido e vinculado ao PR.

## Veto Conditions

Reject and redo if ANY are true:
1. A atualização cobre apenas o arquivo tocado pelo diff, ignorando outros documentos/planilhas do mesmo conjunto afetado pela branch.
2. Uma lição foi registrada tanto em .agents/memory do produto quanto em `squads/guardian/knowledge/` (duplicação).
3. Documentação irremediavelmente enganosa foi "quase corrigida" em vez de removida com registro do PR que motivou a remoção.

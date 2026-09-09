---
task: "Atualizar Conhecimento do Produto"
order: 1
input: |
  - foco_semanal: escopo definido no checkpoint "Foco da Pesquisa Semanal" (produtos em foco nesta execução)
  - product_capabilities_atual: product-capabilities.md existente de cada produto em foco (GeoCloudAI, E-LIMS)
  - repositorio_main: branch main atual de cada repositório de produto, acessada via git worktree somente leitura
output: |
  - product_capabilities_atualizado: product-capabilities.md atualizado por produto, com evidência de commit/arquivo para cada mudança
  - atualizacao_produto: squads/reporter/output/atualizacao-produto.md com o resumo do delta encontrado (ou confirmação de que nada mudou)
---

# Atualizar Conhecimento do Produto

Analisa a branch `main` real de GeoCloudAI e E-LIMS via git worktree somente leitura, comparando o estado atual do código contra o último commit registrado em cada `product-capabilities.md`. Atualiza o documento de forma incremental sempre que uma mudança de capacidade de negócio real for confirmada por evidência de código, sem nunca alterar o `overview.md` técnico nem executar qualquer operação git além de leitura.

## Process

1. Ler o escopo definido no checkpoint "Foco da Pesquisa Semanal" para saber quais produtos estão em foco nesta execução.
2. Para cada produto no escopo, criar um git worktree somente leitura na branch `main` atual — nunca tocar no checkout de trabalho ativo do repositório.
3. Comparar a `main` atual contra o commit citado no `product-capabilities.md` existente. Se não houver commits novos, apenas confirmar validade e não reescrever o documento.
4. Se houver commits novos, inspecioná-los via `git log`/`git show` para separar mudanças de capacidade de negócio real de fixes/refatoração sem impacto de capacidade.
5. Atualizar (nunca recriar do zero) o `product-capabilities.md`: adicionar capacidades novas confirmadas, corrigir capacidades que mudaram, remover o que foi confirmado como removido — cada mudança com evidência de código real (commit + arquivo).
6. Nunca alterar o `overview.md` técnico nem qualquer outro arquivo do repositório de produto.
7. Remover o worktree temporário ao final; nunca fazer commit/push — isso é decidido no checkpoint de aprovação final do squad.

## Output Format

```yaml
produto: "GeoCloudAI | E-LIMS"
commit_anterior: "<hash citado no product-capabilities.md existente>"
commit_atual: "<hash HEAD da main no momento da análise>"
houve_mudanca: true | false
commits_novos_analisados: <int>
mudancas_de_capacidade:
  - tipo: "adicionada | alterada | removida"
    descricao: "<capacidade em linguagem de negócio>"
    evidencia:
      commit: "<hash>"
      arquivo: "<caminho do arquivo/classe/controller>"
documento_atualizado: true | false
worktree_removido: true
git_operations_executadas: "somente leitura"
```

## Output Example

### Exemplo 1 — Nenhum commit novo desde a última análise

## Paulo Produto — GeoCloudAI
**Produto:** GeoCloudAI
**Commit anterior (citado no documento):** `83863f1`
**Commit atual da main:** `83863f1`
**Commits novos analisados:** 0
**Houve mudança de capacidade:** Não

O commit atual da main (`83863f1`) é o mesmo já registrado em `product-capabilities.md`.
Nenhuma atualização necessária. Documento permanece válido nesta execução.

**Ações realizadas:**
- Worktree somente leitura criado na branch `main`, apontando para o commit atual.
- Comparação `git log 83863f1..HEAD` retornou zero commits novos.
- Nenhuma inspeção adicional de código foi necessária.
- Worktree removido ao final da análise.

**Operações git executadas:** apenas leitura (`git worktree add`, `git log`). Nenhum commit, push ou checkout de branch de trabalho foi realizado.

### Exemplo 2 — Commits novos com mudança de capacidade real

## Paulo Produto — E-LIMS
**Produto:** E-LIMS
**Commit anterior (citado no documento):** `ad10947`
**Commit atual da main:** `f3a9c21`
**Commits novos analisados:** 8

Inspecionados via `git log --oneline ad10947..f3a9c21` e `git show` em cada commit relevante:
- 6 commits são fixes de validação de formulário e refatoração de serviço interno, sem impacto de capacidade.
- 2 commits introduzem um novo endpoint `POST /Equipment/{id}/telemetry/ingest` com persistência real de leituras.

**Evidência de código:**
- Commit `f3a9c21`: novo arquivo `EquipmentTelemetryController.cs`, método `Ingest(int id, TelemetryReadingDto dto)`.
- Commit `e28b410`: nova entidade `EquipmentTelemetry` e migração de banco correspondente.

**Atualização de capacidade real:** a limitação "sem ingestão automática de telemetria" descrita na versão anterior do documento não é mais válida. Adicionada nova seção "Ingestão de Telemetria de Equipamento" ao `product-capabilities.md`, com evidência do novo controller/entidade.

**Documento atualizado:** Sim.
**Commit/push realizado:** Não — decisão pertence ao checkpoint de aprovação final do squad (step 7).
**Worktree removido:** Sim.

## Quality Criteria

- Toda capacidade nova/alterada cita o commit e o arquivo de evidência real.
- `overview.md` técnico nunca é alterado por este agente.
- Nenhuma operação git além de leitura via worktree foi executada.
- Worktree temporário removido ao final.

## Veto Conditions

Reject and redo if ANY are true:
- Qualquer capacidade nova foi declarada sem commit e arquivo de evidência específicos.
- O `product-capabilities.md` foi reescrito do zero quando uma atualização incremental resolveria o caso.
- Qualquer operação git além de leitura (checkout, commit, push) foi executada nos repositórios de produto.
- O `overview.md` técnico ou qualquer arquivo fora de `product-capabilities.md` foi alterado.

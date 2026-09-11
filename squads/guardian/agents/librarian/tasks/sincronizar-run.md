---
task: "Sincronizar a LLML ao fim de uma run"
order: 1
input: |
  - docs_atualizados: saída de Marta Documentation no Step 19 (squads/guardian/output/docs-atualizados.md) — fechamentos por PR mesclado, com docs/system, planilhas e knowledge base tocados
output: |
  - sincronizacao: lista de propostas geradas na LLML (Silver), com origem citada, e resultado da decisão do usuário via LLML-approve (Gold ou rejeitado/adiado)
---

# Sincronizar a LLML ao fim de uma run

Pega o que Marta Documentation já verificou como verdade nesta execução (Step 19) e propõe a atualização correspondente na LLM Library (o vault Obsidian, `C:\VaultS\VaultS\`) — nunca decide sozinha o que mudou, só traduz o que já foi confirmado.

## Process

0. Ler `audit-scope.md`. Prosseguir somente quando ele registrar branch `main`/`master` **e** ordem
   explícita do usuário para atuação direta nela. Em branch semanal/de integração, ou sem essa
   autorização, encerrar sem consultar nem sincronizar a LLML; checkout em `main` sozinho não vale
   como autorização.
1. Ler `docs-atualizados.md` por inteiro — um bloco por PR mesclado, cada um com docs/system atualizados, planilha estrutural (se houver), known-issue resolvido (se houver), e lição registrada (cross-projeto ou específica de produto).
2. Para cada doc/system ou planilha tocada, identificar se existe página correspondente já na Library (`Library/Products/<Produto>/...`) — se existir, é candidata a atualização; se não existir, é candidata a página nova.
3. Invocar a skill `LLML-ingest` apontando para os arquivos de produto tocados (GeoCloudAI/ELIMS, conforme o PR) — deixa a skill gerar a proposta em `_Proposals/`, seguindo as regras dela de front-matter, hub-and-spoke e nomenclatura.
4. Invocar a skill `LLML-sync-squads` para a própria memória/histórico/knowledge do Guardian desta execução (memories.md, runs.md, e qualquer entrada nova em `knowledge/`) — nunca ler esses arquivos diretamente, delegar a leitura e a checagem de concorrência pra skill.
5. Se um known-issue foi marcado como resolvido nesta execução, e existir página na Library que ainda o cita como aberto, incluir isso explicitamente no pedido pra `LLML-ingest` tratar como atualização daquela página (não como órfã nova).
6. Ao final das duas invocações, chamar `LLML-approve` para revisar as propostas geradas — apresentar ao usuário, aguardar a decisão dele (Aprovar/Modificar/Rejeitar/Adiar), nunca presumir aprovação.
7. Invocar a task `verificar-consistencia-bidirecional.md` com escopo **"toda a Library"** (sempre, em modo fim-de-run — decisão do usuário, 2026-08-30) — ela compara a Library inteira contra os 3 guias HTML e, quando necessário, contra a realidade viva (chamando Marta ou, exceção documentada, Rita Radar do Reporter). Apresentar o relatório dela ao usuário e aguardar autorização explícita antes de tocar em qualquer arquivo — Library ou guias HTML.
8. Consolidar o resultado (o que foi proposto/aprovado/rejeitado/adiado via `LLML-approve`, e os achados + decisões da Verificação Bidirecional) no arquivo de saída desta run.

## Output Format

```yaml
sincronizacao:
  - origem: "PR #142 — SEC-01 (docs/system/permission-rules.md)"
    skill_invocada: "LLML-ingest"
    pagina_afetada: "Library/Products/GeoCloudAI/S - GeoCloudAI - Reference Tables Map.md"
    tipo: "atualização"   # atualização | página nova
    decisao_usuario: "aprovado como está"   # via LLML-approve
  - origem: "Guardian _memory/memories.md (nova entrada 2026-08-30)"
    skill_invocada: "LLML-sync-squads"
    pagina_afetada: "Library/Squads-Digest/Guardian/S - Guardian - Memories.md"
    tipo: "atualização"
    decisao_usuario: "adiado"
verificacao_bidirecional:
  - area: "Entities/Frameworks/Bootstrap-Agent-Architecture"
    guia_tem_e_llml_nao: ["nova entrada de knowledge/ desta run"]
    autorizado: null   # preenchido só depois da decisão do usuário
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Sincronização — PR #142 (SEC-01)
**Origem:** `docs-atualizados.md`, bloco "PR #142 — SEC-01", doc tocado `docs/system/permission-rules.md`.
**Skill invocada:** `LLML-ingest`, apontando para o doc atualizado do GeoCloudAI.
**Proposta gerada:** atualização de `Library/Products/GeoCloudAI/S - GeoCloudAI - Reference Tables Map.md`, seção "Address" — de "pendente de controle de acesso" para "protegido por `address.create`".
**Decisão do usuário (via LLML-approve):** aprovado como está.

### Sincronização — memória do Guardian
**Origem:** nova entrada em `_memory/memories.md`, registrada ao fim desta execução.
**Skill invocada:** `LLML-sync-squads` (checagem de concorrência: OK, é a cauda da própria run — ver nota de coordenação em `librarian.agent.md`).
**Proposta gerada:** atualização de `Library/Squads-Digest/Guardian/S - Guardian - Memories.md`.
**Decisão do usuário:** adiado — usuário pediu para revisar numa próxima sessão.

## Quality Criteria

- [ ] Toda proposta cita o bloco exato de `docs-atualizados.md` que a motivou.
- [ ] Nenhuma proposta foi criada para algo que `docs-atualizados.md` não mencionou.
- [ ] `LLML-sync-squads` foi invocada para a própria memória do Guardian desta execução, não só para os docs de produto.
- [ ] Nenhuma proposta virou Gold sem passar por `LLML-approve`.

## Veto Conditions

Reject and redo if ANY are true:
0. A task consultou ou sincronizou a LLML sem `audit-scope.md` registrar atuação direta na
   `main`/`master` explicitamente autorizada pelo usuário.
1. Uma proposta foi gerada sem citar o bloco exato de `docs-atualizados.md` de origem.
2. Uma página da Library foi editada diretamente, sem passar por `LLML-ingest`/`LLML-approve`.
3. A checagem de concorrência de `LLML-sync-squads` abortou a sincronização por confundir a cauda desta run com uma leitura externa concorrente.
4. Um achado da Verificação Bidirecional foi aplicado (Library ou guia HTML) sem autorização explícita do usuário para aquele achado específico.

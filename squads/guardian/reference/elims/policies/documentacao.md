---
description: Documentação viva obrigatória e sincronizada com o código
globs:
alwaysApply: true
---

# Documentação

- Documentação não é uma etapa "depois" — é parte da definição de "concluído" de qualquer tarefa que altere contrato, entidade, permissão, fluxo ou diagrama.
- O Documentation Architect **sempre** atualiza o conjunto completo da pasta `Main/`, não só o arquivo que mudou: overview, planilha estrutural, UML 2 e o índice.
- Pasta canônica no repositório: `Documentation/` (`Documentation/`)
  - `Main/` — branch `main` (`Planilha_ELIMS_main.xlsx`)
- Só a `main` é documentada neste produto. Não criar pasta para outras branches.
- **Uma cópia canônica.** Não gravar planilha na raiz de `Miscelaneous/` nem em `docs/estrutura/`. Abas: `Base`, `Atributos`, `Metodos_Back`, `Permissões` — nunca inventar aba nova. A coluna OBSERVAÇÃO só registra divergência ainda verdadeira no código da `main`.
- Planilha: skill `structural-spreadsheet-sync`. Diagramas: skill `uml-generator` (Mermaid em `Main/uml/*.md`).
- Doc que descreve algo como "não implementado" quando já está implementado (ou vice-versa) é pior que ausência de doc — corrija ou remova imediatamente.
- Prefira estender um documento existente em `Documentation/Main/` a criar outro para o mesmo assunto.
- Lição não-óbvia → arquivo atômico em `.agents/memory/` (produto) ou `knowledge/patterns/` (cross-projeto).
- `elims-ai-framework/knowledge/` nunca duplica conteúdo já documentado perto do código (ADR-0002).

Antes de encerrar uma tarefa que mude estrutura: **ler e seguir** `documentation-sync`, `structural-spreadsheet-sync` e `uml-generator`. Índice: `Documentation/README.md`.

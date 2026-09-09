---
description: Documentação viva obrigatória e sincronizada com o código
globs:
alwaysApply: true
---

# Documentação

- Documentação não é uma etapa "depois" — é parte da definição de "concluído" de qualquer tarefa que altere contrato, entidade, permissão, fluxo ou diagrama.
- O Documentation Architect **sempre** atualiza o conjunto completo afetado, não só o arquivo que mudou: overview, planilha estrutural, UML, Knowledge Base e o índice da pasta.
- Pasta canônica: `Documentation/` na raiz do repositório do produto. Referenciar sempre de forma **relativa** — caminho absoluto aqui já quebrou mais de uma vez (`Documents\` → `C:\Software\`, `GeoCloudAI_Replit` → `GeoCloudAI`) e a quebra é silenciosa.
  - `Main/` — **única pasta**, branch `main` (`GeoCloud.xlsx`). Toda branch nova nasce da `main`, então documentação por branch de trabalho é redundante (decisão 2026-08-25).
  - `FixModelsDto/`, `Hallucination/` — planilhas por branch do desenho anterior, **removidas** em 2026-08-25 (histórico em `git log` do repositório de produto). Não recriar — se uma automação antiga (`_generate_uml.py`) referenciar esses caminhos, é bug, não comportamento esperado.
- **Uma cópia canônica.** Não gravar em `.cursor/skills/Documentation/` nem na raiz de `Miscelaneous/`. Abas: `Base` (congelada por design — enviada por Luiz D'Amore para estabelecer o padrão, nunca editada), `Atributos`, `Metodos_Back`, `Permissões` — nunca inventar aba nova. Divergência que não é uma linha simples faltando vira achado/issue, nunca nota solta na planilha (a coluna OBSERVAÇÃO existia para isso e foi removida em 2026-08-25).
- Planilha: skill `structural-spreadsheet-sync`. Editar `GeoCloud.xlsx` direto via os scripts versionados em `Documentation/_*.py` — não reescrever a lógica de formatação/detecção do zero.
- Knowledge Base de produto (`Documentation/Main/KnowledgeBase/`): voltada a usuário final (futuro SAC, passo a passo) — distinta da KB de engenharia interna (`.agents/memory/`, `knowledge/`). Nunca misturar as duas.
- Diagramas: skill `uml-generator`. Mermaid em `uml/*.md`, por domínio. Não um único grafo do produto inteiro.
- Doc que descreve algo como "não implementado" quando já está implementado (ou vice-versa) é pior que ausência de doc — corrija ou remova imediatamente.
- Prefira estender um documento existente a criar outro para o mesmo assunto.
- Lição não-óbvia → arquivo atômico em `.agents/memory/` (produto) ou `knowledge/patterns/` (cross-projeto).
- `geocloud-ai-framework/knowledge/` nunca duplica conteúdo já documentado perto do código (ADR-0002).
- **Antes de dar push/pull na `main`**, rodar a invocação ad-hoc da Marta (documentation-architect) para reconciliar a planilha/docs contra o estado real — o Guardian não está pendurado em git hook, então esse é um passo manual, não automático.

Antes de encerrar uma tarefa que mude estrutura: **ler e seguir** `documentation-sync`, `structural-spreadsheet-sync` e `uml-generator` (quando houver entidade/fluxo novo). Não pular porque a skill tem `disable-model-invocation`.

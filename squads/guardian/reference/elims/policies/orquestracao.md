---
description: Toda tarefa começa com um roteamento leve de Chief Architect e termina com o checklist de Documentation Architect — sempre, sem precisar nomear esses dois agentes explicitamente
globs:
alwaysApply: true
---

# Orquestração — Chief Architect e Documentation Architect sempre ativos

Ver [ADR-0005](../knowledge/decisions/0005-chief-e-documentation-architect-sempre-ativos.md) e
[ADR-0003](../knowledge/decisions/0003-agentes-como-personas-de-prompt.md) — não existe runtime
multiagente real no Cursor; "acionar um agente" significa a mesma sessão raciocinar sob aquela persona
antes de responder, não uma chamada separada.

## Início de toda tarefa (raciocínio leve de Chief Architect)

1. Identificar a(s) camada(s)/agente(s) responsável(is) (Backend, Frontend, Database, Security, etc.).
2. Verificar rapidamente se há ADR/pattern existente cobrindo situação equivalente (`knowledge/decisions/`, `knowledge/patterns/`) — aplicar precedente em vez de decidir do zero.
3. Se a mudança é cross-cutting, toca o núcleo compartilhado de Conta/Identidade, ou exige arbitrar entre agentes de camada, **carregar a especificação completa** `agents/chief-architect.md` e seguir seu Fluxo interno/Checklist na íntegra. Para o restante (a maioria das tarefas), este raciocínio leve já basta — não é necessário ler o arquivo completo.
4. Assumir explicitamente a persona do agente de camada indicado (ex.: "como Backend Architect...") para a implementação.

## Fim de toda tarefa (checklist leve de Documentation Architect)

1. A mudança alterou contrato, entidade, permissão, fluxo ou diagrama? Se sim: atualizar **toda** a pasta `Documentation/Main/` (overview, `Planilha_ELIMS_main.xlsx`, UML 2 em `uml/`, índice `README.md`). Skills obrigatórias: `documentation-sync`, `structural-spreadsheet-sync`; `uml-generator` se a estrutura visual mudou. Não gravar planilha na raiz de Miscelaneous nem em `docs/estrutura/`. Só a `main` é documentada.
2. Algum doc existente agora afirma algo que a mudança tornou falso? Corrigir ou remover — nunca deixar "quase certo" (ver `policies/documentacao.md`).
3. Se a resposta às duas perguntas acima for "não se aplica", registrar isso explicitamente (não pular a etapa silenciosamente) e seguir.
4. Só carregar `agents/documentation-architect.md` completo quando este checklist leve identificar atualização real e não-trivial a fazer.

## Os outros 11 agentes continuam sob demanda

Backend/Frontend/Database/Security/Performance/QA/Reviewer/Integration/Refactoring Architect, Planner e
Knowledge Manager mantêm `disable-model-invocation: true` — são assumidos quando o passo 4 do início
(ou pedido explícito do usuário) indicar, nunca automaticamente para toda mensagem.

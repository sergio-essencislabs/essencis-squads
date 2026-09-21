---
id: GT-0038
title: "LLML-sync-squads ancora exceção de concorrência em número de step defasado"
status: completed
type: documentation
achado_origem: "Verificação bidirecional da LLML (Lívia, atualizar-vault.md)"
auditor_origem: "Lívia Librarian"
severidade: "Média — leitura literal faria a skill abortar exatamente no caso que a exceção existe para permitir"
produto: "N/A — tooling do squad"
camada: "documentacao"
run_origem: "adhoc-livia-llml-2026-09-08"
issue_url: ""
grupo_execucao: ""
owner: "Lívia Librarian"
created_at: 2026-09-08
updated_at: 2026-09-08
affected_modules: ["skills/LLML-sync-squads"]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0038 — LLML-sync-squads ancora exceção de concorrência em número de step defasado

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-08; o diretório `.agents/tasks/` do
GeoCloudAI só passou a existir em 2026-09-09, no commit `8e10d774` (TASK-060). O mecanismo de
par não existia quando ela nasceu — o `contraparte:` não é ponteiro quebrado, é ausência
decidida.

**E aqui não haveria de onde derivar um par, mesmo que se quisesse:** este arquivo não cita PR
nem commit do produto. Um par escrito hoje seria conteúdo inventado — o que a RN-01 da GT-0146
veta, porque arquivo fabricado é pior que a ausência: a ausência é visível, a fabricação não.

Apurado na GT-0146 (issue #634), CA-07, em 12/09/2026.

## Contexto

A skill `LLML-sync-squads` aborta quando detecta sinal de run ativa do Guardian, para não ler memória
operacional durante escrita concorrente. Ela tem uma exceção documentada: se a chamada vier da própria
Lívia, como cauda da run que acabou de terminar, não é leitura concorrente e não deve abortar.

Essa exceção estava ancorada em **"Step 14 (Sincronização da LLML)"** e **"Step 13"**. O pipeline real
usa `pipeline/steps/step-20-sincronizacao-llml.md`, e a atualização de documentação é o Step 19. Os
números vieram de uma numeração anterior do pipeline e nunca foram acompanhados quando ele cresceu.

## Comportamento atual e esperado

**Antes:** numa leitura literal, a exceção não casava com nenhum step existente, então a skill poderia
abortar justamente no caso que a exceção foi escrita para permitir — a sincronização de fim de run.

**Depois:** ancorada em Step 20 e Step 19, com o nome do step 19 explicitado ("Atualizar Documentação")
para que a âncora sobreviva a uma renumeração futura.

## Registro de execução

**Alterações:** `~/.claude/skills/LLML-sync-squads/SKILL.md`, linha 30 — "Step 14 ... Step 13" →
"Step 20 (Sincronização da LLML) ... Step 19 (Atualizar Documentação)".

**Nota:** este achado não chegou a causar falha real. Na run desta sessão a Lívia foi invocada em modo
ad-hoc, não como cauda de pipeline, e a checagem de concorrência passou por não haver run ativa.

## Validação

O trecho corrigido aparece na linha 30 da skill. `grep "Step 14\|Step 13"` não retorna mais ocorrência.

## Pendências

Mesma da GT-0037: o arquivo está fora de controle de versão.

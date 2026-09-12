---
id: GT-0037
title: "Wrapper do Guardian diz 9 personas e não mapeia a Lívia Librarian"
status: completed
type: documentation
achado_origem: "Verificação bidirecional da LLML (Lívia, atualizar-vault.md)"
auditor_origem: "Lívia Librarian"
severidade: "Média — a persona resolve pelo squad-party.csv, mas sem mapeamento de task o runner escolhe sozinho"
produto: "N/A — tooling do squad"
camada: "documentacao"
run_origem: "adhoc-livia-llml-2026-09-08"
issue_url: ""
grupo_execucao: ""
owner: "Lívia Librarian"
created_at: 2026-09-08
updated_at: 2026-09-08
affected_modules: ["skills/guardian"]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0037 — Wrapper do Guardian diz 9 personas e não mapeia a Lívia Librarian

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

Achado da verificação bidirecional que a Lívia roda como passo 8 da `atualizar-vault.md`, comparando a
Library contra os guias HTML e contra a realidade viva.

O `squad-party.csv` tem **10 personas**, sendo `librarian` (Lívia Librarian, Curadora da LLM Library) a
décima, criada em 2026-08-30. O guia HTML `Guardian e Reporter.html` já dizia 10 corretamente. Mas o
wrapper `~/.claude/skills/guardian/SKILL.md` afirmava "**qualquer uma das 9**" e **não tinha nenhuma
menção à Lívia** no mapa ad-hoc por persona — nem a `librarian`, nem a vault, nem a LLML.

## Comportamento atual e esperado

**Antes:** "Lívia, atualiza o vault" ainda resolvia, porque a persona existe no CSV. Mas sem entrada no
mapa ad-hoc, o runner escolhia a task por conta própria, sem a reclassificação que as outras personas
têm. O risco concreto é ele escolher `sincronizar-run.md`, que é a task de pipeline e exige
`output/docs-atualizados.md` — arquivo que não existe em modo ad-hoc.

**Depois:** contagem corrigida para 10 e entrada própria da Lívia no mapa, declarando `atualizar-vault.md`
para pedido de sincronização, `verificar-consistencia-bidirecional.md` para pedido de conferência, e
`sincronizar-run.md` explicitamente marcada como exclusiva do pipeline.

## Registro de execução

**Alterações:** `~/.claude/skills/guardian/SKILL.md` — "9" → "10", e bloco novo da Lívia logo após o do
Otávio Olhar, cobrindo as duas tasks ad-hoc, os limites de escrita (só dentro do vault e dos 3 guias
HTML, propostas nunca direto em `Library/`), o gate `LLML-approve`, a regra de nunca aplicar achado da
verificação bidirecional sem autorização, e a exceção cross-squad da Rita Radar.

**Divergência:** o arquivo vive em `~/.claude/skills/`, **fora de qualquer repositório git**. Não foi
possível seguir o processo semanal de branch + PR + merge. Ver Pendências.

## Validação

`grep "qualquer uma das 10"` retorna 1 ocorrência; a entrada da Lívia está nas linhas 95-104 do wrapper.

## Pendências

As skills em `~/.claude/skills/` não estão sob controle de versão. Enquanto isso não mudar, correções
nelas não têm branch, PR nem histórico. Proposta ao dono do produto: versionar essa pasta, ou movê-la
para dentro do repositório `sergio-essencislabs/opensquad`, que já é git mas hoje não contém as skills.

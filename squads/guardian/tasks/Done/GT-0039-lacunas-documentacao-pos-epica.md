---
id: GT-0039
title: "Fechar lacunas remanescentes da sincronização de documentação pós-épica"
status: completed
type: documentation
achado_origem: "Auditoria de cobertura pedida pelo dono do produto após a run da Marta e da Lívia"
auditor_origem: "Marta Documentation / Lívia Librarian"
severidade: "Média — nada factualmente errado, mas ausências que enganam por omissão"
produto: "GeoCloudAI"
camada: "documentacao"
run_origem: "adhoc-lacunas-2026-09-08"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/431"
grupo_execucao: ""
owner: "Marta Documentation / Lívia Librarian"
created_at: 2026-09-08
updated_at: 2026-09-08
affected_modules: ["Documentation/Main", "api/docs/system", "LLML vault"]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0039 — Fechar lacunas remanescentes da sincronização de documentação pós-épica

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-08; o diretório `.agents/tasks/` do
GeoCloudAI só passou a existir em 2026-09-09, no commit `8e10d774` (TASK-060). O mecanismo de
par não existia quando ela nasceu — o `contraparte:` não é ponteiro quebrado, é ausência
decidida.

**A ausência é decisão, não buraco — e não é por falta de informação.** A rastreabilidade do
lado-produto continua alcançável pelo que este arquivo já cita: issue, PR ou commit. Há por
onde chegar ao que foi feito; o que não há é um registro do lado de lá, porque não havia onde
escrevê-lo.

Um par criado hoje acrescentaria um ponteiro a uma rota que já funciona, e pagaria por isso
afirmando, pela própria existência, que o mecanismo de par cobria esta GT. Seria **registro
com proveniência falsa** — a mesma inversão de "planejado documentado como implementado",
com outra roupa. Por isso não foi criado.

Apurado na GT-0146 (issue #634), CA-07, em 12/09/2026. A busca forense e o controle positivo
ficam no registro daquela task e não são copiados aqui.

## Contexto

O dono do produto perguntou se a Marta e a Lívia tinham feito a run completa. A resposta honesta foi
**não**: a rodada anterior (PR #430 e 5 páginas promovidas na LLML) priorizou o que estava
factualmente errado, e deixou de fora o que estava apenas incompleto. Esta task fecha o restante.

## Achados e tratamento

| # | Lacuna | Tratamento |
|---|---|---|
| 1 | `overview.md` com zero menção aos quatro visualizadores | Seção própria criada |
| 2 | `permission-rules.md` sem `drillbox/send` e `drillbox/summary` | 2 linhas acrescentadas, totais corrigidos |
| 3 | 15 diagramas `uml/` supostamente defasados | **Falso alarme** — ver abaixo |
| 4 | Quadro de backlog na LLML ignora 25 issues fechadas | Vault |
| 5 | 5 páginas do GeoCloudAI e 1 do Guardian sem atualizar na LLML | Vault |

## Duas medições que mudaram o escopo

**`permission-rules.md` não precisava ser regerado.** A suspeita era de que 40 arquivos de backend
alterados o tivessem invalidado. Comparando contra o commit da data de geração, e não contra a âncora
antiga de agosto, o resultado foi: **1 controller alterado, 1 chave de permissão nova**. O documento
estava 99,9% correto. Varrer 104 controllers de novo teria sido desperdício.

**Os diagramas UML não estavam defasados.** `_generate_uml.py` foi executado e produziu saída
**byte a byte idêntica** à versionada, nos dois produtos. Estavam velhos de data de arquivo, corretos
de conteúdo. O gerador também escreve no repositório do ELIMS; conferido que nada mudou lá também.

## Registro de execução

**Repositório GeoCloudAI** (branch `docs/fecha-lacunas-pos-epica` → `feature/fix/refactor-08_09-11_09`):
`Documentation/Main/overview.md` e `api/docs/system/permission-rules.md`.

**Vault** (`C:\VaultS\VaultS`, repositório git local próprio): páginas restantes, via `LLML-ingest`
mais `LLML-approve`, conforme o processo da Lívia.

## Validação

`overview.md` passou de 0 para 6 menções aos visualizadores. `permission-rules.md` tem `drillbox/summary`
em 2 ocorrências (tabela e nota). `git status` limpo nos dois repositórios após o gerador de UML rodar.

## Pendências

O processo semanal (branch, task, issue, merge na branch da semana) só se aplica à metade que vive no
GeoCloudAI. A metade do vault é repositório local sem remoto, então tem task e commit local, mas não
tem issue nem PR.

## Fechamento (2026-09-08)

**Repositório**: PR #432 mesclado na branch da semana e, em seguida, a `main` avançada até ele por
fast-forward — o dono do produto liberou documentação direto na `main` e no vault, dispensando o
processo semanal para esse tipo de mudança. Main e branch da semana idênticas em `8ef54558`.

**Vault**: 7 páginas promovidas nesta segunda leva (12 no dia), commit `d8b682a`. A correção mais
importante foi de afirmação **ativa errada**, não de omissão: a Engineering Memory dizia que o perfil
Administrator recebe "todas as keys ativas + sentinela `*`", e a sentinela não existe desde a GT-0028.

**Incidente durante a promoção**: um laço de shell usando `$(find ...)` quebrou em nomes de arquivo com
espaço e escreveu 35 linhas inválidas em `_Meta/approvals.md`, sem hash. Nenhum arquivo da Library foi
sobrescrito — os `cp` falharam antes. O ledger foi limpo e a promoção refeita em Python, que lida com
espaços. Lição para o hub: **nunca iterar caminhos do vault com `for f in $(find ...)`** — os nomes de
página têm espaços por convenção (`S - Produto - Assunto.md`). Usar glob do shell ou Python.

**Três suspeitas que a medição desmentiu**, e que teriam custado trabalho à toa: os 15 diagramas UML
estavam corretos (gerador produziu saída idêntica nos dois produtos); o `permission-rules.md` estava
99,9% correto (1 controller e 1 chave desde a geração, não 40 arquivos); e a comparação certa era contra
o commit da data de geração, não contra a âncora antiga de agosto.

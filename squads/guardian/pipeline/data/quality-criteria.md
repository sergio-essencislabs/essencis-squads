# Quality Criteria — Guardian

> Nomes de ferramenta citados abaixo (`documentation-sync`, `structural-spreadsheet-sync`,
> `database-diff` etc.) não são skills nativas — ver a nota de independência de
> `.claude`/`.cursor` em `domain-framework.md`.

## Baseline aplicável a todos

- **DRY** — procurar equivalente antes de criar.
- **KISS/YAGNI** — sem abstração sem evidência de necessidade.
- **SOLID / Separation of Concerns.**
- Toda regra de negócio nova exige teste.
- Refatoração e feature nunca na mesma tarefa.

## Jarvis (chief-architect)

- Todo achado aprovado aparece no plano de roteamento, nenhum é esquecido.
- Achados de núcleo compartilhado estão explicitamente marcados.
- Dependências entre achados do mesmo componente estão declaradas.

## Dante Debit (tech-debt-auditor)

- Todo achado tem evidência de ferramenta (nome da skill + saída), não só descrição textual.
- Todo achado tem consumidores mapeados e severidade justificada.
- Nenhum achado se sobrepõe a um known-issue já aberto.
- Relatório final não contém nenhuma recomendação de implementação — apenas priorização.

## Selma Security (security-auditor)

- Zero endpoint sem decisão explícita de acesso (autorizado ou AllowAnonymous justificado).
- Toda permission key referenciada existe no seed correspondente.
- Isolamento de tenant validado e citado com arquivo:linha em cada achado.
- Nenhum segredo novo em texto plano versionado.

## Marta Documentation (documentation-architect)

- documentation-sync (e structural-spreadsheet-sync quando aplicável) executado e citado como evidência.
- Nenhum doc afirma "não implementado" para algo já implementado, ou o inverso.
- Zero duplicação de lição entre a KB de engenharia (`squads/guardian/knowledge/`, `reference/*/knowledge/`) e docs vivos do produto.

## Tomás Ticket (task-curator)

- Nenhuma issue criada sem busca de duplicata comprovada (resultado citado na issue).
- Toda issue tem evidência concreta e critério de aceite claro.
- Toda issue tem severidade, camada e produto etiquetados corretamente.

## Breno Backend (backend-architect)

- Nenhum endpoint novo sem controle de acesso explícito.
- AutoMapper/DTO não descarta campo novo silenciosamente.
- PR aberto, nunca push direto em main/master.
- docs/system atualizados na mesma tarefa (ou encaminhado a Marta Documentation).

## Flávia Frontend (frontend-architect)

- Nenhum componente novo duplica um shared existente.
- Nenhuma chamada HTTP direta de componente sem service.
- PR aberto, nunca push direto em main/master.

## Rui Register (database-architect)

- Zero migration sem plano de reversão.
- database-diff executado e citado após cada migration aplicada.
- Schema documentado reflete o schema vivo ao final da tarefa.

## Otávio Review (reviewer)

- Nenhuma tarefa aprovada com pendência bloqueante aberta.
- Toda aprovação/bloqueio cita evidência concreta.
- Toda pendência não bloqueante está registrada antes do fechamento da revisão.

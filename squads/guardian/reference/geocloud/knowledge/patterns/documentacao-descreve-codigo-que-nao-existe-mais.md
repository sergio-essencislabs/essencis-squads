# Documentação descreve código que não existe mais

**Data:** 2026-08-15
**Origem:** absorção dos agents/skills gerados em julho para o Claude Code, ao unificar no framework.

## Lição

Instrução gerada a partir do código envelhece em silêncio. Uma SOP escrita em julho
continuava mandando fazer coisas que o código de agosto já não faz — e, por ser
detalhada e confiante, era mais perigosa do que não ter SOP nenhuma: um agente seguindo
aquilo produziria código que nem compila, ou pior, que compila e diverge do resto.

Três premissas foram encontradas erradas na mesma leva, todas verificáveis em segundos:

| Afirmava | Realidade em 2026-08-15 | Como verificar |
|---|---|---|
| Banco é PostgreSQL, driver Npgsql | MySQL 8 com MySqlConnector | `grep -r "Npgsql\|MySqlConnector" api/src/*/*.csproj` |
| `INSERT ... RETURNING id` | `INSERT ...; SELECT LAST_INSERT_ID()` | ler qualquer `*Repository.Add` |
| Soft-delete por `deleted_at`, com `ISoftDeletableEntity` | Hard delete: 94 repositórios com `DELETE FROM`, zero com `deleted_at`, interface removida, coluna inexistente no schema | `grep -rl "DELETE FROM" api/src/Back.Persistence/Repositories/ \| wc -l` |

O agravante, em 15/08/2026: a documentação de migrations do produto
(`api/docs/migrations.md`) descrevia um runner FluentMigrator que **também não
estava no código**. Mesmo defeito, quarta vez. Em 21/08/2026 o código passou a
ter o runner de fato (`M001`…`M027`); o [ADR-0007](../decisions/0007-fluentmigrator-para-migrations.md)
realinhou a doc — o padrão desta lição é exatamente esse ciclo (verificar no
código, depois escrever).

## Como aplicar

- **Toda SOP que cita sintaxe, tabela ou interface tem prazo de validade.** Ao segui-la,
  confirme a premissa no código antes de gerar arquivo. Custa um `grep`.
- **Ao absorver instrução de outra fonte, corrija — não copie.** Foi o que se fez aqui:
  o conteúdo concreto da SOP era bom e virou `playbooks/nova-entidade.md`, mas com as
  três premissas corrigidas e a divergência registrada na própria página.
- **Registre a divergência onde ela vai ser lida**, não só no changelog. A tabela de
  armadilhas ficou dentro do playbook, na seção que o agente lê ao criar entidade.
- Quando a premissa antiga é uma *decisão* que mudou (soft-delete → hard delete), o
  correto não é apagar a menção e seguir: é dizer que a decisão precisa ser retomada
  como ADR se a feature nova depender dela.

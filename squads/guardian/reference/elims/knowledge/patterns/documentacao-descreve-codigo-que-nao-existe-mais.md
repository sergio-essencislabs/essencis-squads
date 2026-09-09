# Documentação descreve código que não existe mais

**Data:** 2026-08-15
**Origem:** herdado do `geocloud-ai-framework`, onde as três premissas foram descobertas ao absorver
SOPs de julho. Os números abaixo foram **reverificados contra o código do ELIMS**.

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
| Soft-delete por `deleted_at`, com `ISoftDeletableEntity` | Hard delete: dos 57 repositórios do ELIMS, 52 usam `DELETE FROM` e só 1 menciona `deleted_at` | `grep -rl "DELETE FROM" backend/src/Back.Persistence/Repositories/ \| wc -l` |

O agravante: a documentação de migrations do produto (`backend/docs/migrations.md`) descreve
um runner FluentMigrator que também não está no código. É o mesmo defeito, três vezes.

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

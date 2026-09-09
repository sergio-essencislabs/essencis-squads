---
id: KI-0009
title: "Migration M021_MySqlPasswordActionToken existe no código mas password_action_token não está no baseline real"
severidade: baixa
status: aberta
produto: GeoCloud
---

## Descrição

**Correção desta entrada (2026-08-31)**: a premissa original — que
`password_action_token` existia no schema, sem uso, e que `UserPasswordReset`
duplicaria esse mecanismo — estava errada. Verificação direta em
`api/src/Back.Persistence/Migrations/Scripts/mysql_baseline.sql` (e
`baseline.sql`) confirma que **`password_action_token` não está no schema
real** — não há `CREATE TABLE password_action_token` em nenhum dos dois
arquivos de baseline. Não existe duplicidade: a tabela simplesmente não
existe hoje, então `UserPasswordReset` não conflita com nada.

O achado que sobra, e que é real: a migration
`M021_MySqlPasswordActionToken.cs` (2026-08-04, comentário "*Restores the
password action token table present in the PostgreSQL source*") **existe
no código-fonte** mas seu efeito não está refletido no baseline MySQL
atual. Ou seja: ou (a) essa migration nunca chegou a rodar contra o
schema que gerou o baseline vigente, ou (b) a tabela foi criada e depois
removida fora do fluxo de migration (o que violaria a regra deste
repositório de que schema só muda via migration revisável). Nenhuma das
duas hipóteses foi confirmada — só o fato de que código e baseline
discordam.

## Evidência

```bash
grep -r "password_action_token" api/src/Back.Persistence/Migrations/Scripts/
# (sem resultado — não está em mysql_baseline.sql nem em baseline.sql)
```
`M021_MySqlPasswordActionToken.cs` existe e seria aplicada num boot que
rodasse todas as migrations em sequência a partir de um schema anterior
a ela — mas o baseline vigente (ponto de partida para ambientes novos)
já não a contém.

## Ação recomendada

Database Architect (Rui) confirmar contra o banco real (não só os
arquivos) se `password_action_token` existe fisicamente hoje. Se não
existir: decidir se `M021` deve ser removida do histórico de migrations
(risco: quebra reprodutibilidade se algum ambiente ainda depender dela) ou
se o baseline precisa ser regenerado para refletir o estado real —
qualquer uma das duas é uma decisão de schema, não algo a aplicar sem
revisão.

## Resolução

Premissa original (duplicidade com `UserPasswordReset`) invalidada em
2026-08-31 — não há ação pendente para a feature `UserPasswordReset` por
conta desta entrada. Achado residual (migration M021 divergente do
baseline) permanece aberto, sob dono abaixo.

## Dono

Database Architect (Rui).

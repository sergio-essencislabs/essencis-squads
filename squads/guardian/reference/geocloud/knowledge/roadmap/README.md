# Roadmap Cross-Projeto

Roadmap do *framework em si* está em `FRAMEWORK_ROADMAP.md`. Este documento cobre oportunidades de evolução dos **produtos** identificadas durante a descoberta, que se beneficiam de coordenação entre GeoCloud.

## Curto prazo

1. Restaurar parity do núcleo de Conta/Identidade (aplicar `seed_functionality_keys.sql` + migrations de paridade no banco vivo) — ver `knowledge/known-issues/`.
2. Estender a campanha de fuzz de permissão do GeoCloud (100 fuzz runners) para o GeoCloud (hoje sem fuzz de permissão).
3. Fechar o `POST /Address/add` público (`[AllowAnonymous]`) nos dois produtos.

## Médio prazo

4. ~~Decidir e adotar uma ferramenta real de migration~~ — adotado **FluentMigrator 6.2** (`M001`…`M027`, runner no startup). Ver [ADR-0007](../decisions/0007-fluentmigrator-para-migrations.md) (supersede ADR-0004); `KI-0005` resolvida.
5. Avaliar unificação do cliente de e-mail (SMTP) entre os dois produtos via Integration Architect.
6. Padronizar `FunctionalityType` entre os dois produtos (ou documentar a divergência como intencional).

## Longo prazo

7. Avaliar CI real (nenhum dos produtos tem `.github/workflows` hoje).
8. Avaliar MCP server de MySQL para acelerar `database-diff`/`parity-diff`.

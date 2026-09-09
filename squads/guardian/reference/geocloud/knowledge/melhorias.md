# Oportunidades de Melhoria

Identificadas na Fase 1 de descoberta, com evidência concreta. Priorização é do Chief Architect + Planner.

| Oportunidade | Evidência | Agente responsável |
|---|---|---|
| ~~Ferramenta de migration real~~ (adotada: FluentMigrator) | Em 30/07 o [ADR-0004](decisions/0004-sem-framework-de-migration.md) formalizou SQL manual porque o runner não existia no código. Em 21/08 o código já tinha `M001`…`M027`; o [ADR-0007](decisions/0007-fluentmigrator-para-migrations.md) supersede o 0004. `KI-0005` resolvida. | Database Architect (encerrado) |
| Completar `LITERALS` de i18n (es/pt) | [KI-0007](known-issues/0007-i18n-literais-hardcoded.md): 5287 bindings `uiText`, ~890 entradas ainda iguais ao inglês. Canônico no produto: `Documentation/Hallucination/known-issues/0001-i18n-literais-hardcoded.md`. | Frontend Architect |
| Fuzz de permissão | GeoCloud tem 100 fuzz runners; GeoCloud tem 1 arquivo de teste (`StatusTransitionServiceTests`) | QA Architect |
| `docs/testing.md` desatualizado | Afirma 57 testes; suíte real é dominada pela suíte de fuzz | Documentation Architect |
| Unificação de cliente de e-mail | SMTP implementado de forma diferente em `AccountInviteService` (envia) vs `UserInviteService` (só loga) | Integration Architect |
| CI/CD | Nenhum `.github/workflows` em nenhum dos dois produtos | Chief Architect (proposta de roadmap) |
| Hardening de JWT | Sem validação de issuer/audience; `RequireHttpsMetadata=false` | Security Architect |
| Segredos em texto plano | `appsettings*.json` versionado com connection string/SMTP/TokenKey | Security Architect |

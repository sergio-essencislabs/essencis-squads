# Oportunidades de Melhoria

Identificadas na Fase 1 de descoberta, com evidência concreta. Priorização é do Chief Architect + Planner.

| Oportunidade | Evidência | Agente responsável |
|---|---|---|
| ~~Ferramenta de migration real~~ (decidido: não adotar) | `docs/migrations.md` do ELIMS documentava FluentMigrator sem estar no código; [ADR-0004](decisions/0004-sem-framework-de-migration.md) formalizou scripts SQL manuais versionados como padrão definitivo. Doc corrigido; `KI-0005`/`KI-0006` resolvidas/registradas. | Database Architect (encerrado) |
| Fuzz de permissão | ELIMS tem 100 fuzz runners; ELIMS tem 1 arquivo de teste (`StatusTransitionServiceTests`) | QA Architect |
| `docs/testing.md` desatualizado | Afirma 57 testes; suíte real é dominada pela suíte de fuzz | Documentation Architect |
| Unificação de cliente de e-mail | SMTP implementado de forma diferente em `AccountInviteService` (envia) vs `UserInviteService` (só loga) | Integration Architect |
| CI/CD | Nenhum `.github/workflows` em nenhum dos dois produtos | Chief Architect (proposta de roadmap) |
| Hardening de JWT | Sem validação de issuer/audience; `RequireHttpsMetadata=false` | Security Architect |
| Segredos em texto plano | `appsettings*.json` versionado com connection string/SMTP/TokenKey | Security Architect |

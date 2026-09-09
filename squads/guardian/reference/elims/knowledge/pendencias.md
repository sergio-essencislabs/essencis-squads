# Pendências

Itens que exigem decisão ou ação, ainda não resolvidos. Diferente de `known-issues/` (bug/dívida técnica), aqui ficam pendências de **decisão** ou de **processo**.

| Pendência | Contexto | Bloqueado em |
|---|---|---|
| Decidir estratégia de migration real | Nenhuma ferramenta em uso hoje apesar de documentada | Chief Architect + Database Architect |
| Confirmar estado atual do banco vivo `elims` | `ELIMS DB/elims.sql` é um dump binário (`pg_restore`), não inspecionado linha a linha nesta descoberta — `functionality.key` pode ou não já existir | Database Architect (rodar `database-diff` real) |
| Decidir se `FunctionalityType` diverge por design ou deve ser unificado | ELIMS: 1/2/3 = Sistema/Conta/Empresa; ELIMS: 1-4 = Menu/Ação/Relatório/Configuração | Chief Architect (ADR pendente) |
| Validar build real de `ELIMS`/`ELIMS` após scaffold | Parte da Fase 5 (Validação) deste framework | QA Architect |
| ~~Analisar e replicar em `ELIMS` o trabalho de Thiago e Victor~~ — **Resolvida em 2026-08-04**: branch `elims-geocloud-padronization` (`ELIMS`) portada para `ELIMS` (211 arquivos), backend compilando e `Back.Tests` 66/66. Migração para MySQL formalizada no [ADR-0006](decisions/0006-elims-migra-para-mysql.md); Dapper mantido como camada de acesso a dados no produto. Ver [domain/equipe.md](domain/equipe.md). | — | Encerrada |
| Revisar o "modelo misto de autorização" no ELIMS após a porta acima: `TenantAuthorizationFilter` (global, tenant isolation por referência de entidade/projeto/perfil/recurso — trazido pela branch portada) agora coexiste com `PermissionMiddleware`/`[RequiredPermission]` (extensão granular por permissão, exclusiva deste framework). Avaliar se isso já resolve de fato KI-0002/KI-0009/KI-0010 (re-teste real necessário antes de fechá-los) ou se é preciso unificar os dois mecanismos. | Ver KI novo sobre o tema em `known-issues/` | Security Architect + QA Architect |
| Build do frontend `ELIMS` (`npm run build`) não pôde ser re-verificado de ponta a ponta nesta tarefa — Shell/terminal ficou indisponível na sessão (ver KI novo em `known-issues/`); erros de compilação encontrados na primeira tentativa já foram corrigidos nos arquivos (`Account.ts`, `settings.component.html`), mas falta rodar o build uma última vez para confirmar. | Ambiente/infraestrutura da sessão, não lógica de código | Quem retomar a tarefa (rodar `npm run build` em `ELIMS/frontend` assim que o terminal responder) |

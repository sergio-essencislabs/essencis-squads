# Known Issues — Índice

Backlog rastreável de dívida técnica/segurança já identificada por evidência de código (Fase 1 de descoberta + `ELIMS_GeoCloud_Visao_Tecnica.md`). Status: aberta | em progresso | resolvida.

| ID | Título | Severidade | Status | Produto |
|---|---|---|---|---|
| [KI-0001](0001-permissoes-inertes-em-runtime.md) | Permissões inertes em runtime | Crítica | Aberta | ELIMS |
| [KI-0002](0002-address-add-allowanonymous.md) | `POST /Address/add` público (BOLA) | Crítica | Aberta | ELIMS |
| [KI-0003](0003-functionalitytype-divergente.md) | `FunctionalityType` divergente do padrão ELIMS | Média | Aberta | ELIMS |
| [KI-0004](0004-segredos-em-texto-plano.md) | Segredos em texto plano em `appsettings*.json` versionado | Alta | Aberta | ELIMS |
| [KI-0005](0005-ferramenta-de-migration-ausente.md) | Ferramenta de migration documentada mas não implementada | Média | Resolvida (ADR-0004) | ELIMS |
| [KI-0006](0006-relatorio-implementacao-29-audit-sobrestimado.md) | Relatório de implementação #29 descreve sistema de auditoria que não existe no código | Média | Aberta | ELIMS |
| [KI-0007](0007-budget-scss-inconsistente-elims-build-falhava.md) | Orçamento `anyComponentStyle` do ELIMS mais restritivo que o do ELIMS — build de produção falhava | Baixa | Resolvida | ELIMS |
| [KI-0008](0008-elims-imagecontroller-leitura-arbitraria-arquivo.md) | `ImageController.get` permite leitura arbitrária de arquivo local sem autenticação, vazando `appsettings.Development.json` (TokenKey JWT + DB + SMTP) | Crítica | Aberta | ELIMS |
| [KI-0009](0009-elims-36-controllers-sem-authorize.md) | 36 dos 58 controllers (todo o núcleo de negócio LIMS) sem `[Authorize]` na classe — acesso anônimo confirmado via HTTP real | Crítica | Aberta | ELIMS |
| [KI-0010](0010-elims-entity-getbyuser-idor-nao-corrigido.md) | `Entity.GetByUser` sem guarda de tenant (IDOR) — correção já aplicada no ELIMS não foi replicada | Alta | Aberta | ELIMS |
| [KI-0011](0011-elims-missingclaim-nullref-controllerbasemiddleware.md) | JWT sem claim `accountId` derruba `ControllerBaseMiddleware` com `NullReferenceException` (500 em vez de 401) — recorrência do bug já catalogado no ELIMS | Média | Aberta | ELIMS |
| [KI-0012](0012-elims-modelo-misto-autorizacao-pos-porta-mysql.md) | Modelo misto de autorização após a porta de `elims-ELIMS-padronization`: `TenantAuthorizationFilter` (global) coexiste com `PermissionMiddleware`/`[RequiredPermission]` (granular) — pode já mitigar KI-0002/KI-0009/KI-0010, mas falta reteste real | Média | Aberta | ELIMS |

Use `templates/known-issue.md` para adicionar novo item (numeração sequencial `KI-XXXX`).

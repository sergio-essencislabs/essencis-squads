# Known Issues — Índice

Backlog rastreável de dívida técnica/segurança já identificada por evidência de código (Fase 1 de descoberta + `ELIMS_GeoCloud_Visao_Tecnica.md`). Status: aberta | em progresso | resolvida.

| ID | Título | Severidade | Status | Produto |
|---|---|---|---|---|
| [KI-0001](0001-permissoes-inertes-em-runtime.md) | Permissões inertes em runtime | Crítica | Aberta | GeoCloud |
| [KI-0002](0002-address-add-allowanonymous.md) | `POST /Address/add` público (BOLA) | Crítica | Aberta | GeoCloud |
| [KI-0003](0003-functionalitytype-divergente.md) | `FunctionalityType` divergente do padrão GeoCloud | Média | Aberta | GeoCloud |
| [KI-0004](0004-segredos-em-texto-plano.md) | Segredos em texto plano em `appsettings*.json` versionado | Alta | Aberta | GeoCloud |
| [KI-0005](0005-ferramenta-de-migration-ausente.md) | Ferramenta de migration documentada mas não implementada | Média | Resolvida (ADR-0007) | GeoCloud |
| [KI-0006](0006-relatorio-implementacao-29-audit-sobrestimado.md) | Relatório de implementação #29 descreve sistema de auditoria que não existe no código | Média | Aberta | GeoCloud |
| [KI-0007](0007-i18n-literais-hardcoded.md) | i18n via `uiText`/`LITERALS` com dicionários incompletos | Média | Aberta | GeoCloud |
| [KI-0008](0008-userpasswordreset-email-nao-enviado.md) | `UserPasswordReset` — e-mail do código de verificação não é enviado (deliberado) | Média | Aberta | GeoCloud |
| [KI-0009](0009-userpasswordreset-duplica-password-action-token.md) | Migration `M021_MySqlPasswordActionToken` existe no código mas `password_action_token` não está no baseline real | Baixa | Aberta | GeoCloud |
| [KI-0010](0010-userinviteservice-random-e-email-nao-enviado.md) | `UserInviteService` — código de convite com `System.Random` + e-mail comentado com método inexistente | Média | Aberta | GeoCloud |
| [KI-0011](0011-userpasswordreset-system-random-deliberado.md) | `UserPasswordReset` — código gerado com `System.Random` (fidelidade deliberada ao D'Amore) | Média | Aberta | GeoCloud |
| [KI-0012](0012-docs-geracao-citam-usercurrent-obsoleto.md) | 4 documentos gerados do código citam `UserCurrent` — controller renomeado para `UserLogin` | Média | Aberta | GeoCloud |

Use `templates/known-issue.md` para adicionar novo item (numeração sequencial `KI-XXXX`).
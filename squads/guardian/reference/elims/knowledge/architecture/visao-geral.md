# Visão Geral de Arquitetura (cross-projeto)

Síntese da descoberta (Fase 1). Fonte original: `Documents/ELIMS/Miscelaneous/Markdown Files/ELIMS_GeoCloud_Visao_Tecnica.md`. Detalhes de cada produto ficam em `docs/system/README.md` do respectivo produto — este documento só cobre o que é comum.

## Stack comum

- Backend: .NET 9, Clean Architecture (`Back.Domain`/`Back.Persistence`/`Back.Application`/`Back.API`), Dapper + MySqlConnector (sem EF Core), JWT Bearer + permission keys via `[RequiredPermission]`/`PermissionMiddleware`.
- Frontend: Angular 19, template Velzon (Bootstrap 5), componentes standalone, roteamento lazy.
- Banco: MySQL (`elims` para ELIMS, `elims`), tabelas/colunas minúsculas sem aspas, FK por convenção de nome.
- Testes: xUnit + FluentAssertions + NSubstitute (unitário), MySQL real efêmero sem Docker (integração), fuzz de permissão (`Back.ApiTests` no ELIMS — padrão a estender).

## Diferenças de domínio (não drift, são o propósito de cada produto)

| | ELIMS | ELIMS |
|---|---|---|
| Domínio | Geologia/exploração mineral (drill boxes, drill holes, mines, deposits, assays) | LIMS de laboratório (amostras, ordens de análise, QA/QC, certificados) |
| State management frontend | `@ngrx/signals` (SignalStore) | `@ngrx/store` (hoje só layout) |
| Escala de controllers | ~100 | ~58 |

## Núcleo compartilhado

Ver [domain/nucleo-conta-identidade.md](../domain/nucleo-conta-identidade.md).

## Onde este framework se aplica

O produto ativo é `ELIMS` (`C:\Software\ELIMS\ELIMS`). O `elims-ai-framework`
referencia esses caminhos via `$deployTargets` em `scripts/sync-cursor.ps1` e não embute o código
de produto.

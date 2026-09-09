---
id: KI-0009
title: "ELIMS: 36 dos 58 controllers (todo o núcleo de negócio LIMS) sem `[Authorize]` na classe — acesso anônimo confirmado via HTTP real"
severidade: crítica
status: aberta
produto: ELIMS
---

## Descrição

36 dos 58 controllers de `Back.API/Controllers` do ELIMS — exatamente os controllers específicos do domínio LIMS (Sample, Certificate, AuditTrail, CustodyEvent, AnalysisOrder, AnalysisRequest, Invoice, Equipment, NonConformance, Project, Document, Label, Reagent, StorageLocation, TestRequest, XrfMeasurement, etc.) — não herdam `ControllerBaseMiddleware` e não têm `[Authorize]` na classe, ao contrário dos 20 controllers do núcleo de Conta/Identidade herdado do ELIMS (Account, Entity, User, Role, Profile, etc.), que são protegidos corretamente.

Como `PermissionMiddleware` (`Back.API/Middlewares/PermissionMiddleware.cs`, linha ~20) só age quando o endpoint tem o atributo `[RequiredPermission]` — sem esse atributo, o middleware chama `_next(context)` direto, sem nenhuma checagem — e **nenhum** destes 36 controllers usa `[RequiredPermission]`, a requisição chega direto na lógica de negócio sem qualquer camada de identidade ou permissão.

**Confirmado por execução HTTP real** (não só leitura de código): 30 dos 36 controllers testados via `NoAuthSystemicRunner.cs` retornaram HTTP 200/400/404 (nunca 401/403) para uma chamada `GetById` 100% anônima, sem qualquer header `Authorization`. Os 6 restantes foram confirmados apenas por análise estática nesta rodada (ver `TestCenter/Elims/README.md`).

Para o subconjunto `AuditTrail`/`CustodyEvent`, o impacto é agravado: um chamador anônimo consegue **ler, forjar e apagar** linhas da trilha de auditoria (confirmado por efeito real no banco, não só status HTTP) e forjar eventos de cadeia de custódia — comprometendo o próprio mecanismo de rastreabilidade/prova que um LIMS ISO 17025 depende para demonstrar integridade.

## Evidência

- Análise estática: `TestCenter/_ferramentas/scripts/elims_endpoints_scan.csv` (coluna `achado_preliminar`), gerado por `endpoint_scanner.py`.
- Testes dinâmicos reais: `ELIMS/ELIMS/backend/src/Back.ApiTests/Endpoints/NoAuthSystemicRunner.cs` e `AuditTrailIntegrityRunner.cs`, resultados em `ELIMS/ELIMS/backend/src/Back.ApiTests/v7-results/elims-noauth-systemic-fuzz.json` (30/30 casos confirmados) e `elims-audit-custody-integrity-fuzz.json` (5/5 casos confirmados, incluindo efeito real de DELETE no banco).
- Curadoria: `TestCenter/Elims/RELATORIO_BUGS_CURADO_FINAL_V7.xlsx`, aba "Padrões Sistêmicos", linhas 2-3.

## Ação recomendada

1. Fazer os 36 controllers herdarem de `ControllerBaseMiddleware` (como o núcleo de Conta/Identidade) e adicionar `[Authorize]` na classe + `[RequiredPermission]` por action, com escopo por `AccountIdToken` em cada consulta/mutação — mesmo padrão já usado corretamente no núcleo.
2. Priorizar `AuditTrailController` e `CustodyEventController` (impacto de compliance/rastreabilidade, não só confidencialidade).
3. Após a correção, criar as `functionality`/`profilefunctionality` correspondentes no seed (ver KI-0001, mesma classe de problema: `[RequiredPermission]` sem a `functionality.key` provisionada resulta em 403 para todo mundo, inclusive o dono legítimo).

## Dono

Security Architect (desenho da correção) + QA Architect (re-teste de regressão via `NoAuthSystemicRunner`/`AuditTrailIntegrityRunner` após a correção).

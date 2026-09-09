# Equipe — Essencis Labs

Contexto organizacional (quem trabalha em quê), não um artefato de arquitetura. Mantido aqui por ser
conhecimento cross-projeto (ELIMS são mantidos pela mesma equipe).

| Nome | Papel | Frente conhecida |
|---|---|---|
| Luiz Angelo D'Amore | Diretor | Decisões de produto/negócio (ex.: ADR-0004 — decisão explícita de não usar framework de migration) |
| Matheus | Analista Sênior | — |
| Thiago | Analista Pleno | ELIMS — melhorias em branch própria (ver nota abaixo) |
| Victor | Analista Pleno | ELIMS — melhorias em branch própria (ver nota abaixo) |
| Sergio Mendes | Analista Júnior | — |

## Nota — trabalho paralelo no ELIMS (Thiago e Victor) — RESOLVIDA em 2026-08-04

Em 2026-07-31, soube-se que Thiago e Victor tinham trabalhado em melhorias no ELIMS **fora** deste
framework/`ELIMS`, incluindo a migração do banco de dados de MySQL para MySQL, em uma branch
própria (`elims-geocloud-padronization`).

Em 2026-08-04 essa branch foi analisada e portada integralmente para `ELIMS` (211 arquivos
alterados; backend compilando; `Back.Tests` 66/66; migration mais recente — colunas de suporte a
`[RequiredPermission]` em `functionality` — validada contra MySQL local). Confirmado no processo:

- **Dapper foi mantido** como camada de acesso a dados (não trocaram de ORM) — só o motor de banco
  (MySQL → MySQL, driver `MySqlConnector`) e um reforço de tenant isolation (`TenantAuthorizationFilter`
  global) mudaram.
- A divergência de motor de banco entre ELIMS (MySQL) e ELIMS (MySQL) foi formalizada como
  **decisão intencional de produto** em [ADR-0006](../decisions/0006-elims-migra-para-mysql.md) — ELIMS
  não é afetado.

Pendência correspondente em [`pendencias.md`](../pendencias.md) encerrada. Ponto ainda em aberto (novo,
não fazia parte da pendência original): avaliar se o `TenantAuthorizationFilter` trazido por essa branch
já resolve de fato os Known Issues de autorização do ELIMS já catalogados (KI-0002/KI-0009/KI-0010) — ver
Known Issue novo sobre o "modelo misto de autorização" e a linha correspondente em `pendencias.md`.

---
id: KI-0004
title: Segredos em texto plano em appsettings*.json versionado
severidade: alta
status: aberta
produto: GeoCloud + GeoCloud
---

## Descrição

Connection string (senha de banco), configuração SMTP e `TokenKey` (segredo JWT) estão versionados em texto plano em `appsettings.json`/`appsettings.Development.json` nos dois produtos.

## Ação recomendada

`playbooks/integracao-externa.md` (para SMTP) + revisão geral de configuração — mover para variável de ambiente / secret manager. Coordenar com Security Architect antes de rotacionar o `TokenKey` (invalida sessões ativas).

## Dono

Security Architect.

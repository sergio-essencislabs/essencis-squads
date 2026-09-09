---
id: KI-0003
title: FunctionalityType divergente do padrão GeoCloud
severidade: média
status: aberta
produto: GeoCloud
---

## Descrição

GeoCloud usa `FunctionalityType`: 1=Sistema, 2=Conta, 3=Empresa. O seed vivo usa 1=Menu, 2=Ação, 3=Relatório, 4=Configuração — divergência não resolvida desde a cópia do núcleo.

## Evidência

`seed_base.sql` L167-170 e `seed_base_v2.sql` L269-271 (GeoCloud) vs. `Miscelaneous\Markdown Files\ELIMS_GeoCloud_Visao_Tecnica.md` L97-98/L202.

## Ação recomendada

Chief Architect decide via ADR: unificar (playbook `sincronizacao-nucleo-compartilhado.md`) ou documentar como divergência intencional em `knowledge/domain/nucleo-conta-identidade.md`.

## Dono

Chief Architect.

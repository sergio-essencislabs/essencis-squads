---
id: GT-0048
title: "Profundidade de manobra é decimal(10,0): metros inteiros, com 163 linhas já arredondadas"
status: backlog
type: tech-debt
severidade: media
owner: a definir
created_at: 2026-09-09
updated_at: 2026-09-09
origem: "achado adjacente da GT-0043, ao mapear caixa→manobra por profundidade"
contraparte: "GeoCloudAI/.agents/tasks/backlog/GT-0048-profundidade-de-manobra-em-metros-inteiros.md"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/461"
branch: a definir
affected_modules: ["Back.Persistence", "Back.Domain"]
related_use_cases: []
related_adrs: []
---

# GT-0048 — Profundidade de manobra em metros inteiros

## Pareamento por número resolvido em 2026-09-22 (não apenas aposentado)

Diferente dos pares GT-0148..0155/GT-0064 (aposentados sem mais nenhuma ação, GT-0714 Fase 2/3):
este par foi **resolvido e fechado**. O lado produto (GeoCloudAI) já estava implementado e mesclado
desde 09/09/2026 (PR #462 + PR #478, issue #461 fechada), mas o arquivo de task lá nunca tinha sido
atualizado para refletir isso — ficou em `backlog/`/`Open/` com os critérios em aberto enquanto o
código já estava em produção. Corrigido em 2026-09-22 (GT-0714 Fase 4): o lado produto teve seu
Registro de Execução preenchido com evidência real (commits `80d38673`/`7dc4fe4a`, migração
`M20260909223130_DepthColumnsKeepDecimals.cs`, ADR-009, `DepthPrecisionTests.cs`),
`status: completed`, e moveu para `Done/` — mantendo `id: GT-0048`, sem renumeração (o `issue_url:`
já apontava para a #461 dos dois lados; não havia campo antigo `issue:` a migrar aqui no hub). Este
arquivo do hub mantém seu número e conteúdo sem alteração, além desta nota.

## Contexto

Encontrado ao implementar a GT-0043, que passou a mapear caixa→manobra por sobreposição de
profundidade. Não é regressão: é assim desde o schema original.

## Problema

`drillholerun.startDepth` e `endDepth` são **`decimal(10,0)`** — zero casas decimais. O domínio
declara `double`, o DTO aceita `double`, o formulário aceita decimais, e o MySQL **arredonda em
silêncio** na gravação. Uma manobra de 40,5 a 43,2 m vira 41 a 43.

Três consequências, em ordem de gravidade:

1. **A precisão perdida não volta.** São 163 manobras já gravadas; o que foi arredondado não é
   recuperável.
2. **O RQD por caixa herda o erro.** A GT-0043 deriva o RQD da caixa pela sobreposição com as
   manobras. Com limites arredondados a até meio metro, a atribuição de trecho fica grosseira — e é
   invisível, porque o número exibido continua parecendo exato.
3. **Ninguém é avisado.** Nem o formulário, nem a API, nem o banco reclamam. O geólogo digita 40,5 e
   o sistema guarda 41.

`drillcore.startDepth`/`endDepth` e `drillbox` **não** têm o problema — vale conferir a varredura
completa antes de decidir o alcance.

## Objetivo

Profundidade de manobra guardar o que o geólogo digitou.

## Fora de escopo

Recuperar a precisão das 163 linhas existentes. Não é possível: o dado original não está em lugar
nenhum.

## Regras de negócio

- RN-01: nenhuma linha existente pode mudar de valor. Alargar a coluna preserva o que está lá —
  `41` continua `41`, e é o que se sabe hoje sobre aquela manobra.
- RN-02: a data de corte precisa ser registrada, como na ADR-006 — antes dela, metro inteiro; depois,
  duas casas. Sem isso, uma comparação entre manobras antigas e novas mente sem avisar.

## Critérios de aceitação

- [ ] CA-01: varredura das colunas de profundidade do schema, dizendo quais têm o problema.
- [ ] CA-02: migração alargando `startDepth`/`endDepth` de `drillholerun`, com prova de que nenhum
      valor existente mudou.
- [ ] CA-03: data de corte registrada, como a ADR-006 fez para o fuso.
- [ ] CA-04: teste de integração gravando profundidade fracionária e lendo de volta o mesmo valor —
      é o que hoje falharia.

## Riscos e rollback

Alargar `decimal(10,0)` para `decimal(10,2)` é ampliação: nenhum valor existente muda, e o
arredondamento apenas deixa de acontecer daqui para frente. O risco real é de expectativa — alguém
supor que a precisão foi recuperada retroativamente. Daí a CA-03.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
```

## Handoff
Nenhum.

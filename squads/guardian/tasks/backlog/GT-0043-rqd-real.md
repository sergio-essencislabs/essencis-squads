---
id: GT-0043
title: "RQD real: substituir o valor simulado por medição registrada"
status: backlog
severidade: media
origem: GT-0041 — sinalizar o mock deixou explícito que sinalizar não resolve
run_origem: —
produto: GeoCloudAI
issue: 446
contraparte: GeoCloudAI/.agents/tasks/backlog/GT-0043-rqd-real.md
camada: backend + frontend + database
created_at: 2026-09-09
updated_at: 2026-09-09
---

# GT-0043 — RQD real

## Por que isto entrou na fila

Saiu da GT-0041. Ao fechar o CA-02 da #338 — garantir que toda coluna simulada carrega selo MOCK,
inclusive no cabeçalho desenhado no canvas, que é o que sobrevive a uma captura de tela — ficou
explícito que **sinalizar o mock não resolve o mock**.

## Evidência

`drill-hole-view-unic.component.ts`, no carregamento das caixas:

```ts
// MOCK: DrillBox nao tem campo de RQD e nao existe endpoint que o forneca.
if (!this.rqdByBoxId.has(box.id)) this.rqdByBoxId.set(box.id, Math.random());
```

Varredura no domínio: `DrillBox`, `DrillCore` e `DrillHoleRun` **não têm** campo de RQD. Nenhum
endpoint fornece. Recuperação de testemunho também não existe.

## Por que não pode ser derivado — e por que isso importa

RQD é a soma dos trechos íntegros ≥ 10 cm sobre o comprimento da manobra. O GeoCloud tem
`DrillCoreFracture` (intervalo, marcação **oportunista sobre foto**, não exaustiva) e
`DrillCoreDepth` (marca **pontual**). Nenhum permite reconstruir comprimento de peça íntegra.

Derivar produziria um número com aparência de medição e nenhuma validade — **pior que o aleatório
atual**, porque o aleatório está marcado como falso e o derivado não estaria. É o tipo de melhoria
que piora: troca um mock declarado por um dado falso convincente.

## Severidade

Média. Não é regressão nem risco de segurança — é lacuna de produto num número que geólogo usa
para decidir. Enquanto o selo MOCK estiver nos três pontos, o risco de alguém tomar decisão sobre
o valor está mitigado; sem o selo, seria alta.

## Roteamento

Atravessa três camadas (banco, backend, frontend) e **depende de quatro decisões de produto** antes
de qualquer código — origem do dado, granularidade, se recuperação entra junto, e o que a interface
faz sem medição. Por isso nasce em `backlog/`, não em `active/`: não é falta de capacidade, é falta
de decisão.

Quando as decisões existirem, é caso de **pipeline completo**, não ad-hoc — três camadas com
arbitragem entre elas.

## Estimativa

Não estimada de propósito. O esforço depende inteiramente da origem do dado: digitado na manobra é
pequeno; importação de planilha do sondador é outra ordem de grandeza.

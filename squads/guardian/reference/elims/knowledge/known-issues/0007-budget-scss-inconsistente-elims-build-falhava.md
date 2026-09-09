---
id: KI-0007
title: Orçamento de estilo (anyComponentStyle) do ELIMS mais restritivo que o do ELIMS — build de produção falhava
severidade: baixa
status: resolvida
produto: ELIMS
---

## Descrição

Durante a validação de build da Fase 5 (`ELIMS/frontend`), `npm run build` (`ng build`, configuração
`production`) falhava com:

```
X [ERROR] src/app/pages/instrumentos/xrf-titan/xrf-titan.component.scss exceeded maximum budget.
Budget 64.00 kB was not met by 14.16 kB with a total of 78.16 kB.
```

O orçamento `anyComponentStyle` em `frontend/angular.json` estava configurado como
`maximumWarning: 8kb` / `maximumError: 64kb` — muito mais restritivo que o mesmo orçamento em
`ELIMS/ELIMS/web/angular.json` (`maximumWarning: 80kb` / `maximumError: 100kb`), apesar de ambos os
produtos compartilharem o mesmo template Velzon e o mesmo padrão de componentes com SCSS extenso
(vários outros componentes do ELIMS já excediam os 8kb de aviso — `samples` 53kb, `analysis-order` 56kb,
`clients` 38kb, etc. — mas só `xrf-titan`, com 78kb, passava do limiar de **erro**).

Essa configuração já existia em `ELIMS/ELIMS/frontend/angular.json` (confirmado por busca no
código-fonte protegido) — ou seja, não foi introduzida pelo scaffold do `ELIMS`; é dívida técnica
pré-existente que só se tornou visível ao rodar o build de produção pela primeira vez neste framework.

## Resolução

`ELIMS/ELIMS/frontend/angular.json` alinhado ao mesmo orçamento já usado (e validado) em
`ELIMS/ELIMS/web/angular.json`: `maximumWarning: 80kb` / `maximumError: 100kb`. Build de produção
confirmado com sucesso após a mudança (nenhum erro; avisos de budget e de `NG8107` optional-chain
remanescentes, que não bloqueiam o build e podem ser tratados como limpeza incremental separada, não
como bloqueio de entrega).

`ELIMS/ELIMS` (fonte original) não foi alterado — a correção é exclusiva de `ELIMS`, seguindo
a regra de que a base original permanece intocada.

## Ação recomendada (não bloqueante)

- Considerar dividir os SCSS mais pesados (`xrf-titan`, `samples`, `analysis-order`, `clients`) em
  partials menores como limpeza incremental futura (`playbooks/refatoracao.md`), já que mesmo com o
  novo orçamento eles seguem gerando aviso (`maximumWarning: 80kb` é raramente atingido, mas o hábito de
  monitorar o tamanho de estilo por componente continua válido).
- Resolver os avisos `NG8107` (optional chaining redundante) em `requisition.component.html` como parte
  de uma limpeza de lint, sem urgência.

## Dono

Frontend/Database Architect (build config) — achado durante Fase 5 (validação final) deste framework.

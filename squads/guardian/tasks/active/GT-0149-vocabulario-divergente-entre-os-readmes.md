---
id: GT-0149
title: "Os dois READMEs discordam sobre o que dois campos podem conter"
status: active
type: documentation
achado_origem: "achado da Lívia ao executar a GT-0147 (CA-08); números conferidos pelo Otávio"
auditor_origem: "Lívia (execução da GT-0147, CA-08)"
severidade: media
produto: GeoCloudAI
camada: ""
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/647"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: []
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0149-vocabulario-divergente-entre-os-readmes.md"
---

# GT-0149 — os dois READMEs discordam sobre o que dois campos podem conter

## Contexto
São **duas** divergências, e vêm juntas por uma razão declarada, não por conveniência.

O critério é da Lívia, e a formulação dela é o que ancora o escopo: **o README do produto governa
a relação entre os dois lados** — é ele que diz que todo `GT-NNNN` nasce em par e que o
`contraparte:` aponta nos dois sentidos. *"Dois READMEs discordando sobre o que um campo pode
conter é falha dessa relação."*

**A âncora é a competência do documento, não a jurisdição de quem executa.** Jurisdição expira na
próxima redistribuição de faixas; competência não.

## Problema

### 1. `issue_url` tem três estados e um só valor

Medido em `b99055f`, hub, conferido pelo Otávio e reconferido aqui lendo de commit:

| | |
|---|---|
| total de arquivos | **82** |
| com `issue_url` preenchido | **54** |
| com `issue_url` vazio | **11** |
| **sem o campo** | **17** |

São **três fatos distintos** — *"nunca teve issue"*, *"tem e não registrou"* e *"o campo nem
existe"* — e **nenhuma varredura os separa**. Os 11 vazios e os 17 sem campo respondem igual a
qualquer pergunta automática sobre promoção.

Isto já produziu erro real: a `GT-0045` dizia `issue: a criar` e **a issue existia** (#452,
*"[GT-0044/45/46]"*); a `GT-0044` tinha `issue_url: ""` pelo mesmo motivo. As duas foram
corrigidas na GT-0145 **por leitura do título da issue**, não por convenção — porque não havia
convenção que as distinguisse.

O `_template.md` do hub já ganhou, na GT-0145, a forma `N/A — <motivo>` para o `contraparte:`
quando não há par. **`issue_url` não tem equivalente**, e é o mesmo problema.

### 2. `status: blocked` é sancionado num README e ignorado no outro

`.agents/tasks/README.md:7` (produto):
```
backlog/ → active/ → completed/
                 ↘ blocked (ou um campo `status: blocked` no frontmatter)
```

O README do hub **não menciona `blocked`** — zero ocorrências.

Consequência medida: a Marta normalizou a `GT-0030` no lado do hub, e **estava certa ali** —
o vocabulário do hub não tem `blocked`. A mesma normalização no produto **estaria errada**, porque
lá o valor é sancionado. **O mesmo ato é certo de um lado e errado do outro, e nada no acervo diz
isso.**

## Objetivo
Os dois READMEs concordam sobre o que cada um dos dois campos pode conter, ou declaram por escrito
onde e por que divergem de propósito.

## Fora de escopo
- Não converter nenhum dos 11 vazios nem dos 17 sem campo. **Descobrir quais têm issue não
  registrada é conferência um a um**, e é trabalho próprio — esta GT define o vocabulário que
  torna a conferência possível.
- Não renomear pasta, não mexer em `contraparte:` (feito na GT-0145).

## Comportamento atual
Três estados de `issue_url` sob dois valores; `blocked` válido de um lado e inexistente do outro.

## Comportamento esperado
Cada campo com vocabulário declarado nos dois READMEs — ou com a divergência declarada e
justificada, o que também é resposta válida.

## Regras de negócio
- RN-01: **divergência deliberada é resposta aceitável**, desde que escrita nos dois READMEs. O
  que não é aceitável é a diferença existir sem estar dita.
- RN-02: a forma de "não se aplica" segue a convenção já estabelecida na GT-0145 —
  `N/A — <motivo>`, nunca `""` —, porque `""` é o valor de campo ainda não preenchido.
- RN-03: nenhuma conversão de dado nesta GT. Só vocabulário.

## Critérios de aceitação
- [ ] CA-01: os dois READMEs declaram o vocabulário de `issue_url`, distinguindo **os três
      estados**: promovida, nunca promovida, e campo ausente.
- [ ] CA-02: os dois declaram o vocabulário de `status`, incluindo se `blocked` vale nos dois
      lados ou só num — **e, se só num, por quê**.
- [ ] CA-03: a justificativa de cada divergência remanescente está escrita **nos dois** READMEs,
      não só naquele a que ela favorece.
- [ ] CA-04: o `_template.md` de cada lado reflete o vocabulário declarado.
- [ ] CA-05: existe uma frase dizendo **qual dos dois documentos governa** quando eles
      discordarem, para a próxima divergência ter onde ser resolvida sem nova GT.

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum.
### Integrações
`.agents/tasks/README.md` e `_template.md` no produto; `squads/guardian/tasks/README.md` e
`_template.md` no hub.
### Segurança
Nenhum direto.

## Plano de implementação
- [ ] Etapa 1 — CA-05 primeiro: sem saber quem governa, as outras viram negociação.
- [ ] Etapa 2 — `issue_url` (CA-01), com os três estados nomeados.
- [ ] Etapa 3 — `status`/`blocked` (CA-02), decidindo se converge ou diverge declaradamente.
- [ ] Etapa 4 — moldes (CA-04).

## Estratégia de testes
- [ ] Unitários / Integração / E2E: N/A — não há código.
- [ ] Manual: reler os dois READMEs lado a lado e confirmar que não resta afirmação sobre campo
      que só um deles faça.

## Riscos e rollback
- **Risco:** resolver a divergência convergindo o vocabulário **sem** perguntar se ela era
  deliberada — `blocked` pode existir só no produto por um motivo que ninguém escreveu. A RN-01
  existe para isso: declarar é resposta.
- **Risco:** aproveitar a GT para converter os 11 vazios. A RN-03 veta; é conferência um a um.
- **Rollback:** markdown; um revert.

## Registro de execução
### Alterações realizadas
Pendente — cunhada em 12/09/2026, não executada.
### Arquivos principais
Pendente.
### Decisões
Pendente.
### Divergências
Nenhuma.
### Pendências
`grupo_execucao` não preenchido: é do Step 09.

## Validação
Pendente. Os números do `issue_url` (82 / 54 / 11 / 17) foram medidos em `b99055f` lendo de
commit, não da árvore; o `blocked` foi conferido em `.agents/tasks/README.md:7` e por contagem
zero no README do hub.

## Handoff
Sem dependência de entrada.

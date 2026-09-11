---
task: "Fechar Sprint"
order: 4
input: |
  - sprint: branch de integração da sprint e a janela de datas
  - balanco: saída do Tomás Ticket — planejado, entregue, delta e o que sobrou
  - proxima: saída de Jarvis — proposta da próxima sprint, travamentos e decisões pendentes
output: |
  - documento_tecnico: o que foi feito na sprint, com evidência verificável
  - apresentacao: fecho da sprint e pauta de debate da próxima
  - verificacao: parecer de Otávio Review confirmando que o documento bate com os diffs
---

# Fechar Sprint

Produz o pacote de fechamento de uma sprint: o documento técnico do que foi feito, o balanço
entre o que estava planejado e o que saiu, e a apresentação que fecha a sprint e abre o debate da
próxima. Marta é a dona do pacote e quem consolida — mas **não levanta sozinha os três insumos**,
porque eles vêm de fontes diferentes e o custo de fazê-los em série é o próprio tempo de entrega,
que é o que esta task existe para encurtar.

Nada aqui é escrito por dedução: cada afirmação do documento aponta para um PR, um commit, uma
saída de CI ou um arquivo de task. Documento de fechamento que exagera é pior que documento
ausente — vira a versão oficial de uma história que não aconteceu.

## Quem faz o quê

O pacote tem três frentes que leem fontes distintas, então rodam em paralelo, cada uma na janela
da persona que é dona daquele dado:

| Frente | Persona | Fonte |
|---|---|---|
| Documento técnico | **Marta Documentation** | GTs em `completed/`, PRs mesclados, diffs, evidência de CI |
| Balanço planejado × entregue × delta | **Tomás Ticket** | GTs, issues, o backlog — é o dado dele |
| Próxima sprint, travamentos e decisões | **Jarvis** | GTs restantes, GADRs, dependências, roteamento |
| Conferência antes da entrega | **Otávio Review** | o diff real, contra o que o documento afirma |

Marta consolida as três saídas na apresentação. A conferência de Otávio é a última etapa e não é
opcional: ele lê o documento técnico contra os diffs e aponta toda afirmação que o código não
sustenta.

## Process

1. **Delimitar a sprint.** Branch de integração, commit-base e HEAD, janela de datas. Todo o resto
   é derivado disso: `git log base..HEAD`, os PRs mesclados nessa faixa, as GTs que mudaram de
   estado. Sem essa delimitação explícita o documento vira "o que eu lembro que aconteceu".
2. **Disparar as duas frentes paralelas** — Tomás e Jarvis — passando a delimitação do passo 1.
   Enquanto elas rodam, escrever o documento técnico.
3. **Documento técnico.** Por GT entregue: o defeito, a correção, a evidência vermelho/verde, o PR
   e o resultado do CI. Agrupado por área, não por ordem cronológica — quem lê quer saber o que
   mudou no produto, não em que ordem os commits caíram.
4. **Delta da sprint.** O que foi feito **além** do planejado, e por quê. Trabalho não previsto que
   entrou é informação de planejamento, não sobra: ou o escopo estava incompleto, ou apareceu
   achado no caminho. Nomear qual dos dois, caso a caso.
5. **Apresentação.** Fecho da sprint e pauta da próxima, consolidando as três frentes. Termina em
   **decisões pendentes nomeadas** — cada travamento com as opções e o que muda em cada uma, para
   o dono decidir na reunião em vez de sair dela com "vamos ver".
6. **Conferência de Otávio.** Entregar o documento técnico a ele antes de considerar o pacote
   pronto. Toda afirmação que ele não conseguir sustentar no diff volta para correção.

## Onde os artefatos ficam

`docs/processo/sprints/{identificador-da-sprint}/` no repositório de produto — mesma pasta de
processo onde o mapa do Guardian já vive. Um arquivo por artefato, em Markdown; a apresentação em
Markdown também, para virar slide depois sem ficar presa a um formato binário.

## Output Format

```yaml
fechamento_sprint:
  sprint: "{branch de integração}"
  janela: "{data inicial} a {data final}"
  base: "{commit}"
  head: "{commit}"
  entregue:
    - gt: "GT-0126"
      pr: "#602"
      area: "backend"
      evidencia: "708 aprovados, 0 falhas; migration ida e volta"
  delta:
    - item: "{o que foi feito além do planejado}"
      origem: "escopo-incompleto | achado-no-caminho"
      justificativa: "{por que entrou}"
  nao_entregue:
    - gt: "GT-0137"
      motivo: "{bloqueio ou dependência}"
  decisoes_pendentes:
    - assunto: "{travamento}"
      opcoes: ["{A}", "{B}"]
      consequencia: "{o que muda em cada}"
  artefatos:
    - caminho: "docs/processo/sprints/{id}/documento-tecnico.md"
    - caminho: "docs/processo/sprints/{id}/apresentacao.md"
  verificacao_otavio: "{aprovado | correções pedidas}"
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Fechamento — sprint `feature/fix/refactor-08_09-11_09`

**Delimitação:** 08/09 a 11/09, base `fff6260a`, HEAD `a9646a5a`. 15 PRs mesclados.

**Entregue:** nove GTs da épica do chat unificado. Exemplo de linha do documento técnico —
*GT-0126, PR #602: o resumo da caixa morria junto com a conversa pessoal que o gerou, porque a FK
era `ON DELETE CASCADE`. Virou `SET NULL`, e as chaves de cobertura viraram coluna. Evidência: 2
dos 8 testes novos falham com a seleção antiga; depois, 708 aprovados e 0 falhas; migration
validada na ida e na volta.*

**Delta:** o primeiro workflow de CI do repositório (#607) — origem `achado-no-caminho`: três
sessões redescobriram independentemente que a suíte exige `lower_case_table_names=1`, e o
conhecimento não estava versionado em lugar nenhum.

**Não entregue:** GT-0137, bloqueada por depender de GT-0130 e GT-0138 (grupo G3 do roteamento).

**Decisão pendente levada à reunião:** contexto da caixa sob permissão — recusa total (403) ou
contexto redigido (200 com aviso). Consequência: a primeira não vaza a existência da caixa; a
segunda mantém a coerência com o resto do fluxo, que já evita usar código de erro como sinal de
permissão.

**Verificação de Otávio:** aprovado, com uma correção — a contagem de testes citada na GT-0132
era de antes do merge da GT-0126; corrigida para o número pós-merge.

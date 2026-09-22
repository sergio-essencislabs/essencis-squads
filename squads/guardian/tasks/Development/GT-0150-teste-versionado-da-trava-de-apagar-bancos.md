---
id: GT-0150
title: "A trava que impede apagar bancos não é exercitada por teste nenhum"
status: active
type: tech-debt
achado_origem: "escopo escrito pelo Dante ao executar a GT-0143; recebido por mim via despacho da Vision"
auditor_origem: "Dante (execução da GT-0143)"
severidade: alta
produto: GeoCloudAI
camada: ""
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/648"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: []
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0150-teste-versionado-da-trava-de-apagar-bancos.md"
---

# GT-0150 — a trava que impede apagar bancos não é exercitada por teste nenhum

## Pareamento por número aposentado em 2026-09-22

O pareamento por número compartilhado com o lado produto (GeoCloudAI) foi aposentado em
2026-09-22, por decisão de Sergio (GT-0714 Fase 2 — reconciliação do passivo histórico). O lado
produto passou a **GT-0648**, o número da própria issue, sob a convenção que a GT-0714 define (GT
e issue com numeração idêntica). Este arquivo do hub mantém o número antigo, **GT-0150**, e o
resto do seu conteúdo, sem alteração.

> **Procedência do texto.** O escopo desta GT foi escrito pelo **Dante** ao executar a GT-0143, e
> chegou a mim resumido no despacho da Vision — **não li a mensagem original dele**. Transcrevi o
> que veio, preservando as formulações citadas. Se algum critério dele se perdeu no caminho, a
> falha é de transcrição e não de decisão: vale conferir contra o original antes de implementar.

## Contexto
A frase do Dante que justifica a GT, e que é o argumento inteiro:

> *"A caixa `PAREI ANTES DE APAGAR DADOS` é a única coisa entre um comando e apagar os bancos de
> alguém, e **nunca é exercitada pelo CI**."*

A trava existe e funciona — o que não existe é prova continuada de que ela continua funcionando.

## Problema
Nenhum teste versionado exercita `listar_bancos_de_usuario` nem o caminho que leva à caixa de
autorização. Uma regressão ali não quebra build, não quebra suíte, e só aparece quando alguém
perde dados.

## Objetivo
A trava passa a ser exercitada por teste versionado, que **falha** se ela for removida.

## Fora de escopo
- Não reescrever a trava. O que falta é teste, não conserto.
- Não cobrir outros caminhos destrutivos do script; esta GT é a caixa de autorização.

## Regras de negócio
- RN-01: o teste **recorta a função do próprio arquivo**, nunca trabalha sobre cópia.
- RN-02: o teste tem **controle negativo** — se ele não falha quando a trava é removida, ele não
  está testando.
- RN-03: nenhum teste é pulado ou afrouxado para o CI ficar verde.

## Critérios de aceitação
- [ ] **CA-01:** o teste recorta `listar_bancos_de_usuario` **do próprio arquivo**, por `sed`, e
      **nunca por cópia** — *"cópia diverge em silêncio e o teste passa a testar a cópia"*.
- [ ] **CA-02:** o teste roda no CI, junto da suíte, sem passo manual.
- [ ] **CA-03:** o caminho feliz é coberto: com a trava presente, o teste passa.
- [ ] **CA-04 — é o que separa isto de teatro:** **controle negativo obrigatório.** Reintroduzir o
      `|| echo` **faz o teste falhar**. Sem esta demonstração, o critério não fecha.
- [ ] **CA-05:** o teste não depende de banco vivo nem de credencial.
- [ ] **CA-06:** a matriz `return` × ponto de chamada fica escrita **no próprio teste**, como
      comentário, **com os números medidos** — não como descrição genérica.

## Risco declarado, e a defesa contra ele
**O recorte por `sed` depende do nome da função.** Se alguém renomear `listar_bancos_de_usuario`,
o recorte devolve vazio e **o teste "passa" sem testar nada** — a pior falha possível num teste de
trava, porque o verde vira mentira.

**O CA-04 é a defesa:** um teste com controle negativo que deixe de falhar quando a trava é
removida denuncia que o recorte parou de recortar. Sem o CA-04, o CA-01 é uma armadilha.

Isto é a mesma família de defeito que apareceu o dia inteiro no acervo: **consulta que devolve
vazio e é lida como "nada errado"**. A defesa é sempre a mesma — provar que a peneira enxerga
antes de acreditar no que ela não achou.

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum.
### Integrações
O script da trava e a suíte do CI.
### Segurança
Direto: a trava é o último obstáculo antes de perda de dados.

## Plano de implementação
- [ ] Etapa 1 — recorte por `sed` (CA-01) e caminho feliz (CA-03).
- [ ] Etapa 2 — **controle negativo** (CA-04), demonstrado e revertido.
- [ ] Etapa 3 — matriz no comentário, com os números medidos (CA-06).
- [ ] Etapa 4 — ligar no CI (CA-02).

## Estratégia de testes
- [ ] Unitários: o próprio teste da trava.
- [ ] Integração: N/A — o CA-05 proíbe depender de banco.
- [ ] E2E: N/A.
- [ ] Manual: o CA-04, reintroduzindo o `|| echo` uma vez e revertendo.

## Riscos e rollback
- **Risco principal:** o recorte silencioso (acima). CA-04.
- **Risco:** marcar o CA-04 sem executar a demonstração. É o único critério aqui que **exige uma
  falha observada**, não uma passagem.
- **Rollback:** é teste novo; apagar o arquivo reverte.

## Registro de execução
### Alterações realizadas
Pendente — cunhada em 12/09/2026, não implementada.
### Arquivos principais
Pendente.
### Decisões
Pendente.
### Divergências
Ver a nota de procedência no topo: o escopo veio resumido, não do original.
### Pendências
`grupo_execucao` não preenchido: é do Step 09.

## Validação
Pendente.

## Handoff
Sem dependência de entrada. Sucessora da GT-0143 (#623), que consertou a trava; esta prova que ela
continua consertada.

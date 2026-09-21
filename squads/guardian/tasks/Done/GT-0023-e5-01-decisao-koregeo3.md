---
id: GT-0023
title: "Decisão: KoreGeo3 como visualizador padrão"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — decisão, bloqueia GT-0024/GT-0025"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/323"
grupo_execucao: "Onda 1"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [koregeo3, koregeo2]
related_adrs: [GADR-0002]
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0023 — Decisão: KoreGeo3 como visualizador padrão

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-02; o diretório `.agents/tasks/` do
GeoCloudAI só passou a existir em 2026-09-09, no commit `8e10d774` (TASK-060). O mecanismo de
par não existia quando ela nasceu — o `contraparte:` não é ponteiro quebrado, é ausência
decidida.

**E aqui não haveria de onde derivar um par, mesmo que se quisesse:** este arquivo não cita PR
nem commit do produto. Um par escrito hoje seria conteúdo inventado — o que a RN-01 da GT-0146
veta, porque arquivo fabricado é pior que a ausência: a ausência é visível, a fabricação não.

Apurado na GT-0146 (issue #634), CA-07, em 12/09/2026.

## Contexto
Registrar formalmente a decisão de adotar o KoreGeo3 e o plano de descontinuação do KoreGeo2.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/323. Listar o que precisa ser portado antes do corte (as duas conhecidas: faixas de litologia, barra lateral — verificar se há mais).

## Objetivo
Decisão registrada (GADR-0002), lista de gaps fechada, data de corte definida.

## Fora de escopo
Implementação dos portes em si (GT-0024, GT-0025).

## Comportamento atual
KoreGeo2 e KoreGeo3 coexistem, sem decisão formal.

## Comportamento esperado
GADR-0002 aceito, lista de gaps fechada, corte do KoreGeo2 com data/critério definidos.

## Regras de negócio
- RN-01: N/A — ver GADR-0002.

## Critérios de aceitação
- [x] CA-01: Decisão registrada (GADR-0002, Alternativa A aceita por Sergio Mendes em 2026-09-02).
- [x] CA-02: Lista completa de funcionalidades do KoreGeo2 ainda ausentes no KoreGeo3 — investigação de código encontrou 5 gaps reais (2 causados por código comentado, fáceis de reativar: faixas de litologia/barra lateral; 3 gaps novos não mapeados originalmente: botão de anotação por core, highlight do core ativo, fallback de imagem quebrada). Ver GADR-0002.
- [ ] CA-03: Data/critério de corte do KoreGeo2 — **deliberadamente deferido**, por decisão do próprio GADR-0002 (Alternativa A): só definir depois que GT-0024/GT-0025 portarem os 3 gaps novos e a paridade for validada. Não é uma pendência esquecida, é a ordem correta segundo a decisão aceita.

## Impacto técnico
### Frontend
Levantamento de gaps entre KoreGeo2 e KoreGeo3.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [ ] Levantar gaps de paridade além dos 2 conhecidos.
- [ ] Redigir/aceitar GADR-0002.
- [ ] Definir data/critério de corte.

## Estratégia de testes
- [ ] N/A — decisão, sem código de produto.

## Riscos e rollback
Descontinuar KoreGeo2 sem paridade completa quebra fluxo de quem depende das funcionalidades ausentes.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação

## Handoff
Bloqueia GT-0024, GT-0025.

## Achado de QA pós-implementação (2026-09-03) — pendente de decisão, nada alterado ainda
Relatório de QA (Matheus, `TASKS.md`, E5-01): "Por ser um visualizador de furo único (drillcore), deveria estar disponível só a partir de DrillHole, não de Region/Deposit/Mine/MineArea. Contradiz a matriz atual, que libera nos 6 níveis — ajustar junto do rename 'Core View' (E1-03)."

**Decisão confirmada pelo usuário (2026-09-03)**: "Só a partir de DrillHole. Conversamos e decidimos isso." Confirma a reversão — ver GADR-0001, "Revisão" (entrada de 2026-09-03). CA-02 desta task precisa de uma nova entrada: KoreGeo3 restrito a DrillHole/DrillBox, diferente de Single View/MultiView. Implementação roteada para GT-0026 (reabrir, reverter as 4 telas agregadoras).

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido.** A decisao foi tomada: `GADR-0002-adocao-koregeo3.md` (hub), `status: accepted`,
`date: 2026-09-02`, Alternativa A aceita. O corte do KoreGeo2 (unico CA em aberto) esta em
`origin/main`: `web/.../drill-hole-view/drill-hole-view.component.html:307-323` e `:325-340`
comentadas, citando nominalmente GT-0024/GT-0025 como a paridade que habilitou o corte. Cadeia
GT-0023 -> GT-0024/GT-0025 fecha nos dois sentidos (GADR-0002 e anterior aos PRs #359/#365/#378).

Nota: o "Registro de execucao" deste arquivo estava vazio apesar do trabalho estar feito - o que
segue sendo o defeito de forma que a GT-0144/GT-0151 catalogam. Preenchido agora com esta evidencia.

Evidencia completa no relatorio da reconciliacao GT-0156.

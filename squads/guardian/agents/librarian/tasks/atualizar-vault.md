---
task: "Atualizar o vault sob demanda (fora de uma run)"
order: 2
input: |
  - pedido: pedido direto do usuário (ex.: "Lívia, atualiza o vault", ou um escopo específico como "atualiza a LLML sobre o ELIMS")
output: |
  - sincronizacao: mesmo formato da task "Sincronizar a LLML ao fim de uma run", cobrindo todas as fontes conhecidas ou só o escopo pedido
---

# Atualizar o vault sob demanda

Modo de Lívia fora de uma run do Guardian — o usuário pede diretamente, sem que a pipeline tenha acabado de rodar. Cobre qualquer fonte conhecida da LLML (produtos, GitHub, memória dos squads, Miscelaneous, documentos), não só o que uma run específica tocou.

## Process

1. Determinar o escopo do pedido: se o usuário não especificar, tratar como "todas as fontes conhecidas"; se especificar um produto/área, restringir a isso.
2. **Checar frescor antes de sincronizar**: para cada fonte no escopo, verificar se a documentação subjacente foi verificada recentemente (comparar data da última auditoria/atualização de Marta Documentation contra a data atual). Se estiver visivelmente desatualizada, chamar Marta Documentation ad-hoc primeiro (modo ad-hoc do squad, profundidade 1) para uma verificação rápida antes de prosseguir — nunca sincronizar documentação sabidamente velha como se fosse verdade atual.
3. Se o escopo tocar algo fora da alçada de Marta (ex.: confirmar uma regra de segurança específica), chamar o especialista correspondente ad-hoc (ex.: Selma Security), mesma regra de profundidade 1 — nunca encadear helper chamando helper.
4. Para fontes de produto (GeoCloudAI/ELIMS/Geral_Cs_MLP): invocar `LLML-ingest` normalmente.
5. Para a própria memória/histórico do Guardian e do Reporter: invocar `LLML-sync-squads`.
6. Para GitHub, Miscelaneous ou documentos pessoais, se estiverem no escopo pedido: invocar `LLML-ingest` apontando pra fonte correspondente (ou `LLML-digest` primeiro, se o pedido for só "o que mudou", antes de decidir o que vale ingerir de verdade).
7. Ao final, chamar `LLML-approve` para o lote inteiro gerado nesta rodada — apresentar tudo de uma vez ao usuário, nunca presumir aprovação.
8. Invocar a task `verificar-consistencia-bidirecional.md` com o escopo pedido (ou "toda a Library" se o usuário disser "verifica tudo") — ela compara contra os 3 guias HTML e, quando necessário, contra a realidade viva (chamando Marta ou, exceção documentada, Rita Radar do Reporter para Concepts de mercado). Apresentar o relatório e aguardar autorização explícita antes de tocar em qualquer arquivo — Library ou guias HTML.
9. Reportar ao usuário, em texto, o que foi verificado como desatualizado e precisou de um passo extra (chamada ad-hoc a Marta ou outro especialista) antes da sincronização, e os achados da Verificação Bidirecional aguardando autorização.

## Output Format

Mesmo formato YAML da task "Sincronizar a LLML ao fim de uma run", com um campo adicional:

```yaml
sincronizacao:
  - origem: "..."
    skill_invocada: "..."
    pagina_afetada: "..."
    tipo: "atualização"
    verificacao_previa: "Marta Documentation chamada ad-hoc — documentação de permission-rules estava desatualizada (última verificação há 12 dias)"
    decisao_usuario: "..."
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Pedido: "Lívia, atualiza a LLML sobre o ELIMS"
**Verificação prévia:** `.agents/memory/` do ELIMS (61 arquivos) não tinha verificação de Marta Documentation há mais de 2 semanas — chamada ad-hoc feita antes de prosseguir.
**Skill invocada:** `LLML-ingest`, sobre os documentos atualizados por Marta nessa chamada ad-hoc.
**Proposta gerada:** atualização de `Library/Products/ELIMS/S - ELIMS - Engineering Memory.md`.
**Decisão do usuário (via LLML-approve):** aprovado com modificação — usuário ajustou um trecho antes de promover.

## Quality Criteria

- [ ] O frescor da documentação de origem foi checado antes de qualquer sincronização.
- [ ] Toda chamada ad-hoc a outro agente (Marta ou especialista) está registrada explicitamente no resultado.
- [ ] Nenhuma sincronização ocorreu sem passar por `LLML-approve`.

## Veto Conditions

Reject and redo if ANY are true:
1. Uma fonte foi sincronizada sem checar se a documentação subjacente estava recente.
2. Uma chamada ad-hoc necessária (Marta ou especialista) foi pulada, e a sincronização seguiu mesmo assim.
3. Uma proposta virou Gold sem passar por `LLML-approve`.
4. Um achado da Verificação Bidirecional foi aplicado (Library ou guia HTML) sem autorização explícita do usuário.
5. Uma chamada ad-hoc cross-squad foi feita para alguém além de Rita Radar (Reporter).

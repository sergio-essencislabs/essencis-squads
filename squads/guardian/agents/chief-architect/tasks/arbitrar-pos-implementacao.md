---
task: "Arbitrar Pós-Implementação"
order: 4
input: |
  - implementacao_especialista: implementacao-{backend,frontend,database}.md do especialista que acabou de rodar (squads/guardian/output/)
  - roteamento_vigente: versão mais recente de squads/guardian/output/roteamento.md
output: |
  - roteamento_atualizado: squads/guardian/output/roteamento.md (regravado; o runner versiona automaticamente v1→v2→v3...)
---

# Arbitrar Pós-Implementação

Task parametrizada, reaproveitada pelos Steps 12 (pós-Backend), 14 (pós-Frontend)
e 16 (pós-Database/Consolidação). Substitui o modelo antigo de Jarvis rodar
uma única vez no início e nunca mais participar — agora ele reavalia o
roteamento com evidência real entre cada especialista.

## Process

1. Ler o resultado real do especialista que acabou de rodar: PRs abertos,
   contratos alterados, "Coordenação necessária" declarada por task, tasks
   bloqueadas/não implementadas.
2. Tratar toda "Coordenação necessária" declarada como dependência
   obrigatória — nunca manter, no roteamento atualizado, uma task que
   dependa dela no mesmo grupo paralelo enquanto a dependência não estiver
   resolvida (PR mesclado ou confirmado como seguro sem merge).
3. Reaplicar as regras de veto de sempre (núcleo compartilhado, mesmo
   arquivo/endpoint, segurança antes de dívida técnica) com a informação
   nova — ajustar `grupo_execucao` das tasks ainda não implementadas se a
   realidade mudou o que é seguro paralelizar.
4. Se alguma task ficou bloqueada, decidir se isso bloqueia dependentes de
   outras camadas ou se pode seguir em paralelo (dependência não confirmada
   = nunca paralelizar por padrão — pecar pelo lado conservador).
5. No Step 16 (Consolidação), adicionalmente: reconstituir se alguma
   "Coordenação necessária" entre as três camadas ficou sem resposta, e
   consolidar a "Ordem de merge sugerida" final — mesmo com implementação
   paralela, a integração é sempre sequencial.
6. Regravar `roteamento.md` com a seção de arbitragem correspondente
   (Pós-Backend / Pós-Frontend / Consolidação Final), registrando
   explicitamente o que mudou em relação à versão anterior, ou a nota
   explícita de que nada mudou.

## Quality Criteria

- Toda "Coordenação necessária" do especialista que acabou de rodar foi avaliada e refletida no roteamento atualizado.
- Nenhuma dependência real (confirmada pelo PR) foi tratada como paralelizável.
- No Step 16: todo PR das três camadas aparece na ordem de merge final.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
- Uma "Coordenação necessária" foi ignorada na atualização do roteamento.
- Uma task ainda não implementada foi mantida em grupo paralelo com uma task da qual depende e que ainda não foi mesclada.
- O `roteamento.md` foi regravado sem registrar o que mudou.

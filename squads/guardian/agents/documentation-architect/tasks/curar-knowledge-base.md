---
task: "Curar Knowledge Base"
order: 3
input: |
  - docs_atualizados: saída da task "Atualizar Documentação" (conjunto de docs/planilha já sincronizados nesta rodada)
  - product_capabilities: estado atual de Documentation/Main/product-capabilities.md (GeoCloud) ou equivalente ELIMS
output: |
  - kb_atualizada: lista de artigos da Knowledge Base de produto estendidos, criados ou marcados como obsoletos
---

# Curar Knowledge Base

Mantém `Documentation/Main/KnowledgeBase/` (produto/usuário final) coerente com o que o sistema
realmente faz, depois que a documentação técnica já foi atualizada nesta rodada. Esta é uma KB
**distinta** da KB de engenharia interna (`.agents/memory/`, `squads/guardian/knowledge/`) — nunca
escrever a mesma lição nos dois lugares, e nunca escrever nesta KB algo que só faz sentido para quem
lê código (isso é sintoma de estar copiando prosa de auditoria em vez de reescrever para usuário final).

Cobre só a branch `main` — não existe (nem deve ser criada) uma cópia por branch de trabalho.

## Process

1. Para cada módulo/funcionalidade tocado pela mudança desta rodada (via `docs_atualizados`), verificar
   se `KnowledgeBase/modulos/<modulo>.md` já reflete o comportamento atual.
2. Decidir: estender o artigo existente (preferido), criar um novo (só se o módulo genuinamente não
   tem artigo ainda), ou marcar uma seção como obsoleta com justificativa — nunca deletar sem registro.
3. Reescrever sempre em linguagem de usuário final ("como fazer X", "o que significa Y") — nunca copiar
   trecho de `product-capabilities.md` (que é o artefato técnico/evidência de código, não a KB).
4. Se a mudança introduz um termo novo do domínio, adicionar/atualizar `glossario.md`.
5. Se a mudança resolve uma dúvida recorrente identificável, adicionar/atualizar `faq.md`.
6. Se um achado desta rodada tem, além da causa técnica, um sintoma claro do ponto de vista do usuário
   final, criar/atualizar a entrada correspondente em `troubleshooting/`.
7. Atualizar `KnowledgeBase/README.md` (tabela de módulos) se algum artigo saiu do estado "esqueleto".

## Output Format

```yaml
kb_atualizada:
  - artigo: "KnowledgeBase/modulos/14-conta-identidade-acesso.md"
    tipo_mudanca: "extensao"        # extensao | criacao | marcacao-obsoleta
    motivo: "endpoint de reset de tentativas de login (user.resetAttempts) documentado nesta rodada"
  - artigo: "KnowledgeBase/glossario.md"
    tipo_mudanca: "extensao"
    motivo: "termo novo introduzido pela mudança"
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Curadoria de KB — módulo Conta/Identidade/Acesso
**Gatilho:** achado desta rodada adicionou os endpoints `user.block`/`user.resetAttempts` ao
`Metodos_Back` da planilha.
**Artigo estendido:** `KnowledgeBase/modulos/14-conta-identidade-acesso.md` — nova seção "Bloquear ou
resetar tentativas de login de um usuário", escrita como passo a passo para um administrador de conta,
sem mencionar nome de controller/permission key.
**Glossário:** nenhum termo novo — bloqueio de usuário já é linguagem corrente.
**FAQ:** nenhuma pergunta nova identificada nesta rodada.
**Troubleshooting:** nenhum sintoma de usuário associado a este achado (é uma funcionalidade nova, não
correção de bug percebido).

## Quality Criteria

- [ ] Nenhum artigo da KB de produto é cópia/resumo da prosa de `product-capabilities.md` ou de um
      achado de auditoria — está reescrito em linguagem de usuário final.
- [ ] Nenhuma lição foi escrita tanto aqui quanto em `.agents/memory`/`squads/guardian/knowledge/` (duplicação).
- [ ] Toda seção marcada obsoleta tem justificativa registrada, nunca foi só deletada.
- [ ] `KnowledgeBase/README.md` reflete o estado real (esqueleto vs. completo) de cada artigo tocado.

## Veto Conditions

Reject and redo if ANY are true:
1. Um artigo da KB contém referência a nome de controller, DTO, classe C# ou trecho de código — sinal
   de que é cópia de auditoria, não conteúdo de usuário final.
2. A mesma lição foi escrita nesta KB e também em `.agents/memory`/`knowledge/patterns`.
3. Uma pasta/arquivo de Knowledge Base foi criado para uma branch diferente de `main`.

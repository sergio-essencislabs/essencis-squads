---
task: "Verificação Bidirecional"
order: 3
input: |
  - escopo: "toda a Library" (padrão em modo fim-de-run) OU um recorte específico (produto, framework, squad), quando pedido sob demanda
output: |
  - achados_bidirecionais: por área da Library, o que um lado tem que o outro não tem (LLML → guia HTML, guia HTML → LLML, ou nenhum dos dois bate com a realidade), com a chamada ad-hoc que settled a verdade quando necessário — nunca aplicado sozinha, sempre aguardando autorização
---

# Verificação Bidirecional

Compara a LLM Library inteira contra tudo o que a descreve — os 3 guias HTML de referência (`Guardian e Reporter.html`, `LLM Library.html`, `Bootstrap Agent Architecture.html`) e, quando nenhum dos dois bate, a realidade viva dos sistemas (código/docs dos produtos, `.agents/`, memória dos squads, GitHub). Nunca decide sozinha qual lado está certo nem aplica nada — só aponta a discrepância e pede autorização.

## Mapa de área → mecanismo de verdade

| Área da Library | Fonte de verdade | Quem/o que verifica |
|---|---|---|
| `Products/{GeoCloudAI,ELIMS,Geral_Cs_MLP}` | Código/docs reais do repositório | Chamar **Marta Documentation** ad-hoc (`documentation-sync`) |
| `Entities/Frameworks/*` (Bootstrap) | `.agents/`, `.claude/agents/`, `plugin.json` reais | Chamar **Marta Documentation** ad-hoc |
| `Squads-Digest/{Guardian,Reporter}` | Memória real dos squads (`_memory/*.md`) | Já é inerentemente ao vivo — invocar `LLML-sync-squads` normalmente, sem precisar de especialista extra |
| `Backlog/*` (derivado do GitHub) | Issues/Project reais no GitHub | Reconsultar `gh` diretamente — sem precisar de especialista |
| `Concepts/*` de mercado/competidores | Pesquisa de mercado atual | Chamar **Rita Radar (Reporter)** ad-hoc — **exceção documentada**: única chamada cross-squad permitida a Lívia, mesma regra de profundidade 1 |
| `Entities/People`, `Documents/*` (NDA, produtividade, etc.) | Não existe sistema vivo — foram capturados uma vez (conversa, planilha, PDF) | **Sem mecanismo de recheck** — reportar como "não aplicável", nunca forçar uma comparação sem fonte viva |

## Process

1. Determinar o escopo: em modo fim-de-run, **sempre a Library inteira** (decisão do usuário, 2026-08-30 — mais caro, mas nada fica de fora). Em modo sob-demanda, o escopo pedido pelo usuário, ou a Library inteira se ele disser "verifica tudo".
2. Para cada página no escopo, identificar a área (tabela acima) e o guia HTML correspondente, se houver.
3. Comparar os três lados possíveis: página da Library, trecho do guia HTML (se a área tiver um), e a fonte de verdade real (se a área tiver uma).
4. Se a área tem uma fonte de verdade real e página/guia divergem dela ou entre si, chamar o agente responsável (tabela acima) ad-hoc — profundidade 1, nunca encadear helper chamando helper. Para Rita Radar (Reporter), documentar explicitamente que essa é a exceção cross-squad autorizada.
5. Se a área não tem fonte de verdade real (Entities/People, Documents), não forçar recheck — só sinalizar se a página parece inconsistente internamente (ex.: contradiz outra página já Gold), o que é papel do item 5 do `LLML-lint`, não desta task.
6. Consolidar os achados por área: o que a Library tem que o guia HTML não tem, o que o guia HTML tem que a Library não tem, o que nenhum dos dois tem (com a chamada ad-hoc que resolveu, se houve).
7. Apresentar o relatório completo ao usuário e **pedir autorização explícita antes de tocar em qualquer arquivo**, dos dois lados — Library (via `LLML-ingest`/`LLML-approve`, Silver→Gold normal) e guias HTML (edição direta, mas só depois do "sim" do usuário para aquele achado específico, nunca antes).

## Output Format

```yaml
achados_bidirecionais:
  - area: "Entities/Frameworks/Bootstrap-Agent-Architecture"
    fonte_verdade: ".agents/, .claude/agents/, plugin.json (verificado por Marta Documentation ad-hoc)"
    llml_tem_e_guia_nao: []
    guia_tem_e_llml_nao: ["8 skills detalhadas", "ciclo de vida de task", "assimetria docs/"]
    nenhum_bate_com_realidade: []
    recomendacao: "enriquecer o hub da Library via LLML-ingest"
    autorizado: null   # true/false/adiado — preenchido só depois da decisão do usuário
  - area: "Entities/People"
    fonte_verdade: "não aplicável — sem sistema vivo"
    recomendacao: "nenhuma — fora do escopo desta task"
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Verificação Bidirecional — 2026-08-30 (escopo: Library inteira)

**Bootstrap Agent Architecture**: guia HTML tinha 8 skills, estrutura completa e ciclo de vida de task que o hub da Library não tinha. Marta Documentation confirmou ad-hoc que o guia bate com a realidade (`.agents/`, `plugin.json`). Recomendação: enriquecer o hub via `LLML-ingest`.

**Concepts — Paisagem Competitiva**: página cita KoBold Metals com valuation de fevereiro; Rita Radar (Reporter), chamada ad-hoc (exceção cross-squad), confirma que houve uma rodada de captação nova em agosto que mudou o número. Recomendação: atualizar a página via `LLML-ingest`, citando a pesquisa nova da Rita como fonte.

**Entities/People**: sem fonte viva — não aplicável, nenhum achado.

**Aguardando autorização do usuário para os 2 achados acima antes de qualquer escrita.**

## Quality Criteria

- [ ] Toda página no escopo foi mapeada pra uma área da tabela, mesmo que a conclusão seja "não aplicável".
- [ ] Nenhuma chamada ad-hoc pulou a regra de profundidade 1.
- [ ] A chamada a Rita Radar (Reporter), quando ocorreu, está documentada explicitamente como a exceção cross-squad.
- [ ] Nenhum arquivo (Library ou guia HTML) foi tocado antes da autorização explícita do usuário para aquele achado específico.

## Veto Conditions

Reject and redo if ANY are true:
1. Um achado foi reportado sem identificar a área/fonte de verdade correspondente.
2. Uma comparação foi forçada numa área sem fonte de verdade real (Entities/People, Documents) em vez de marcada "não aplicável".
3. Um arquivo foi editado (Library ou guia HTML) antes da autorização explícita do usuário para aquele achado.
4. Uma chamada ad-hoc cross-squad foi feita para alguém que não seja Rita Radar, ou sem documentar a exceção.

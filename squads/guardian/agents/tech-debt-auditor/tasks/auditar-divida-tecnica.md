---
task: "Auditar Dívida Técnica"
order: 1
input: |
  - escopo_auditoria: diretórios/produtos/módulos em escopo definidos no checkpoint "Escopo da Auditoria" (squads/guardian/output/audit-scope.md)
output: |
  - achados_divida_tecnica: lista de achados com componente, evidência de ferramenta, classificação, severidade, esforço estimado e consumidores mapeados (squads/guardian/output/audit-divida-tecnica.md)
---

# Auditar Dívida Técnica

Varre o(s) codebase(s) no escopo definido (`C:\Software\GeoCloud\GeoCloudAI` e/ou `C:\Software\ELIMS\ELIMS`) buscando código morto, duplicação e complexidade acidental, sempre com evidência de ferramenta de detecção. Classifica, prioriza e encaminha cada achado — nunca implementa a correção.

> `duplicate-detector`, `dead-code-detector`, `code-smell-detector` e `dependency-mapper` = metodologias em `C:\Software\ClaudeCode\squads\guardian\reference\{geocloud|elims}\skills\{nome}\SKILL.md` (caminho absoluto, conforme produto em `audit-scope.md`) — ler e aplicar diretamente, sem depender de `.claude`/`.cursor` do produto.

## Process

1. Rodar detecção com evidência de ferramenta sobre o escopo: `duplicate-detector` para duplicação, `dead-code-detector` para código morto, `code-smell-detector` para complexidade acidental. Nenhum achado é reportado por impressão subjetiva de leitura de código.
2. Para cada componente suspeito, rodar `dependency-mapper` e mapear todos os consumidores antes de estimar risco — a estimativa de risco depende diretamente de quantos e quais fluxos consomem o componente.
3. Classificar cada achado em uma das três categorias: duplicação real, dívida legada convivendo com padrão novo, ou complexidade acidental. A categoria determina o tipo de correção esperada.
4. Atribuir severidade (crítica/alta/média/baixa) e esforço estimado (baixo/médio/alto) a cada achado; toda correção proposta já vem quebrada em etapas pequenas e revisáveis, nunca como uma reescrita monolítica.
5. Verificar cada achado contra a knowledge base de known-issues já aberta — se já existe um registro equivalente, não duplicar o achado.
6. Registrar cada achado como item rastreável e encaminhar ao relatório final — nunca implementar a correção proposta.

## Output Format

```yaml
achados_divida_tecnica:
  - achado_id: "TD-01"
    componente: "testrequest.testsjson (GeoCloudAI)"
    evidencia:
      ferramenta: "dead-code-detector + dependency-mapper"
      saida: "campo JSON legado ainda escrito por 2 fluxos antigos; 100% das leituras já migraram para tabelas relacionais novas"
    classificacao: "divida_legada_convivendo_com_padrao_novo"
    severidade: "media"
    esforco_estimado: "baixo"
    consumidores_mapeados: 2
    produto: "GeoCloudAI"
```

## Output Example

### Achado TD-01 — Severidade: Média
**Componente:** `testrequest.testsjson` (GeoCloudAI)
**Evidência:** dead-code-detector + dependency-mapper — campo JSON legado ainda escrito por 2 fluxos antigos, mas 100% das leituras já migraram para as tabelas relacionais novas de testes.
**Classificação:** dívida legada convivendo com padrão novo (não é duplicação ativa).
**Esforço estimado:** baixo — remover escrita legada, manter leitura de fallback por 1 release.
**Consumidores mapeados:** 2 (ambos de escrita, nenhum de leitura ativa).

### Achado TD-02 — Severidade: Baixa
**Componente:** `ReportGeneratorService.BuildLegacyExport()`
**Evidência:** code-smell-detector — complexidade ciclomática 18, 4 responsabilidades misturadas (parsing, formatação, persistência, notificação).
**Classificação:** complexidade acidental.
**Esforço estimado:** médio — quebrar em 4 métodos/serviços menores, sem mudança de comportamento.
**Consumidores mapeados:** 3 (chamadores do endpoint de exportação legada).

## Quality Criteria

- Todo achado tem evidência de ferramenta (nome da skill + saída), não só descrição textual.
- Todo achado tem consumidores mapeados e severidade justificada.
- Nenhum achado se sobrepõe a um known-issue já aberto.
- Relatório final não contém nenhuma recomendação de implementação — apenas priorização.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
- Um achado foi reportado sem saída de ferramenta de detecção citada (duplicate-detector, dead-code-detector ou code-smell-detector).
- Um achado recomenda refatoração e mudança de comportamento na mesma proposta.
- Um achado do núcleo compartilhado de Conta/Identidade foi classificado como dívida comum, sem sinalização de tratamento à parte.

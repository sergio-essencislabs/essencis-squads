---
id: GT-0043
title: "RQD real: substituir o valor simulado por medição registrada"
status: completed
type: feature
owner: Sergio
created_at: 2026-09-09
updated_at: 2026-09-09
issue: 446
contraparte: C:\Software\GeoCloud\GeoCloudAI\.agents\tasks\completed\GT-0043-rqd-real.md
origem: GT-0041 — sinalizar o mock deixou explícito que sinalizar não resolve
affected_modules: ["Back.Domain", "Back.Persistence", "Back.Application", "Back.API", "web"]
related_use_cases: []
related_adrs: []
branch: feature/fix/refactor-08_09-11_09
sprint: 08/09-11/09/2026
---

# GT-0043 — RQD real

## Contexto
A GT-0041 fechou o CA-02 da #338 garantindo que a coluna de RQD aparece marcada como MOCK nos três
pontos da interface. Marcar não é ter: o geólogo continua sem RQD.

## Problema
A coluna **não exibe dado**, exibe `Math.random()` — um número por caixa, sorteado a cada carga,
colorido nas faixas 0–25/25–50/50–75/75–100 como se fosse medição.

**Não existe dado de RQD em lugar nenhum do domínio.** Nem `DrillBox`, nem `DrillCore`, nem
`DrillHoleRun` têm o campo; não há endpoint, coluna ou importação. Recuperação de testemunho
também não existe.

**E não dá para derivar.** RQD é a soma dos trechos íntegros ≥ 10 cm sobre o comprimento da
manobra. O que existe é `DrillCoreFracture` (intervalo, marcação oportunista sobre foto, não
exaustiva) e `DrillCoreDepth` (marca pontual). Nenhum dos dois permite reconstruir comprimento de
peça íntegra. Calcular a partir deles produziria um número com aparência de medição e nenhuma
validade — **pior que o aleatório**, porque o aleatório está marcado como falso.

## Objetivo
A coluna exibir medição registrada, e perder o selo MOCK.

## Fora de escopo
Recuperação de testemunho, salvo decisão em contrário (ver decisão 3).

## Decisões — respondidas pelo dono do produto em 2026-09-09
1. **De onde vem o RQD?** → **Digitado**, junto com a recuperação, na tela de manobras.
2. **Granularidade?** → **Por manobra** (`DrillHoleRun`). A tela continua exibindo por caixa,
   derivando das manobras que a caixa cobre.
3. **Recuperação entra junto?** → **Sim.** Uma migração, os dois campos, porque são a mesma linha da
   ficha de campo.
4. **O que a interface faz sem dado?** → **Traço, com a coluna visível.** A lacuna fica à vista e
   vira pergunta; é a pergunta que faz o dado ser preenchido.

## Critérios de aceitação
- [x] CA-01: campo persistido de RQD na granularidade decidida, com migração.
- [x] CA-02: caminho de entrada do dado (tela, importação, ou ambos).
- [x] CA-03: a coluna exibe o valor medido e perde o selo MOCK.
- [x] CA-04: furo sem medição tem comportamento definido e explícito — nunca número inventado.
- [x] CA-05: nenhum RQD calculado a partir de fratura ou profundidade pontual.
- [x] CA-06: teste cobrindo furo com medição, sem, e parcialmente medido.

## Impacto técnico
### Banco de dados
Coluna nova, granularidade a definir. Migração com `[Tags("MySql")]` e timestamp UTC de 14 dígitos, como manda `global.md`.

### Backend
Campo no domínio, no DTO, no repositório; endpoint de escrita se a entrada for por tela.

### Frontend
A coluna deixa de sortear e passa a ler. O selo MOCK sai — e sair é parte do critério, senão o aviso vira mentira na direção oposta.

### Segurança
Nenhum impacto: dado do próprio tenant, pelas rotas já escopadas.

## Estratégia de testes
- [x] Unitários: derivação manobra→caixa, com ausência e zero separados (`rqd-por-caixa.spec.ts`).
- [x] Integração: persistência e leitura sobre o schema real (`DrillHoleRunRqdTests`).
- [ ] Manual: furo com medição parcial, que é o caso que engana. **Não feito** — depende de digitar
      RQD em manobras de um furo real e abrir a tela. É o teste de vocês, e o caso a olhar primeiro
      é a caixa que cruza duas manobras: ela mostra o número com `*` e a cobertura no tooltip.

## Riscos e rollback
Risco de produto, não técnico: escolher a granularidade errada (caixa em vez de manobra) produz um
número que parece certo e não é comparável com o que a indústria chama de RQD. Rollback: a coluna
volta a ser oculta; nenhum dado do cliente se perde.

## Registro de execução

### Alterações realizadas

**Banco e backend.** `M20260909191854` acrescenta `rqd DECIMAL(5,2)` e `recoveredLength
DECIMAL(10,2)` a `drillholerun`, ambas nulas — nulo é "não medido" e é informação. Domínio, DTO,
repositório (`INSERT`/`UPDATE`) e a validação de serviço que barra recuperação maior que o intervalo
perfurado: o DTO limita a faixa, mas o **teto** depende da manobra e por isso é regra de serviço.

**Frontend.** `rqd-por-caixa.ts` deriva o RQD da caixa a partir das manobras que ela cobre, por
média ponderada pelo trecho sobreposto. A tela de furo deixou de sortear e passou a ler; a tela de
manobras ganhou os dois campos, opcionais. Os três selos MOCK saíram.

### Arquivos principais
- `api/src/Back.Persistence/Migrations/M20260909191854_DrillHoleRunRqdAndRecovery.cs` (novo)
- `api/src/Back.Domain/Classes/DrillHoleRun.cs`, `Dtos/DrillHoleRunDto.cs`,
  `Repositories/DrillHoleRunRepository.cs`, `Services/DrillHoleRunService.cs`
- `api/tests/Back.IntegrationTests/Repositories/DrillHoleRunRqdTests.cs` (novo)
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/rqd-por-caixa.ts` + spec (novos)
- `drill-hole-view-unic.component.{ts,html}` e `drill-hole-view-runs.component.{ts,html}`

### Decisões

1. **Média ponderada pelo trecho sobreposto, não média simples.** Uma caixa que pega 2,4 m de uma
   manobra com RQD 90 e 0,6 m de outra com 30 mostra 78, não 60. A média simples daria peso igual a
   trechos de tamanhos muito diferentes.
2. **Manobra sem medição sai da conta; não entra como zero.** Incluí-la como zero puxaria a média
   para baixo e inventaria fragmentação. É a asserção central do spec.
3. **Número parcial é marcado.** Caixa cujo RQD cobre parte do comprimento mostra `*` e diz a
   cobertura no tooltip. Sem isso, uma caixa medida em 20% aparece igual a uma medida inteira — o
   tipo de igualdade falsa que o RQD aleatório produzia.
4. **Recuperação guardada como comprimento, não como percentual.** É o valor cru da ficha do
   sondador; o percentual é derivado. Guardar os dois seria guardar o mesmo número duas vezes, e
   duas cópias divergem.
5. **Campos opcionais na tela de manobras.** A manobra é registrada quando é perfurada e a medição
   chega depois. Obrigá-los faria o geólogo digitar zero para escapar do validador — que é como
   campo obrigatório vira dado falso.
6. **A escala de cor passou de 0–1 para 0–100.** Os limites eram 0,25/0,50/0,75/1,0 porque o valor
   vinha de `Math.random()`. Agora é percentual medido.

### Divergências

- **A migração perdeu os `COMMENT` de coluna.** A primeira versão os tinha, e a aspa simples do
  comentário fechava cedo a string do `SET @sql := '...'` do `PREPARE` — cinco testes caíram com
  erro de sintaxe. O significado das colunas está em `DrillHoleRun`, que é onde se procura.
- **Um achado adjacente, não corrigido aqui:** `drillholerun.startDepth`/`endDepth` são
  `decimal(10,0)` — **metros inteiros** — com 163 manobras já gravadas, enquanto o domínio declara
  `double`. Qualquer profundidade fracionária é silenciosamente arredondada na escrita, e isso
  degrada a precisão do mapeamento caixa→manobra que esta task introduziu. Virou **GT-0048**, no
  backlog: mudar tipo de coluna com dado dentro é mudança própria, e misturá-la aqui faria esta
  entrega tocar dois problemas.

### Pendências

O teste manual (acima) e a GT-0048.

## Validação
```bash
cd api && dotnet build Back.sln && dotnet test Back.sln
cd web && ng test
```

```
Back.UnitTests          276 aprovados   (inalterado)
Back.IntegrationTests    53 aprovados   (eram 48)
web (Karma)             344 aprovados   (eram 332)
```

## Handoff
Link para o handoff ativo, quando aplicável.

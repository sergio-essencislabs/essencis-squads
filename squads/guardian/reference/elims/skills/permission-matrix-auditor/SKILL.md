---
name: permission-matrix-auditor
description: Audita se cada [RequiredPermission] no código tem chave correspondente provisionada no seed e reflete corretamente as matrizes de permissão já existentes (planilhas Controle_Permissoes_*). Use antes de aprovar qualquer mudança em autorização, e periodicamente como auditoria de segurança.
---

# Permission Matrix Auditor

## Objetivo

Reaproveitar o investimento já feito na campanha de fuzz V7 do ELIMS (100 fuzz runners, matrizes em `Miscelaneous/*.xlsx`) como padrão de auditoria contínua, em vez de reinventar a verificação de permissão do zero a cada tarefa.

## Entradas

- Endpoint(s)/permission key(s) alterados.

## Saídas

- Para cada `[RequiredPermission("chave")]`: confirmação de que `chave` existe em `seed_functionality_keys.sql` (ou equivalente do produto), e que está vinculada a pelo menos um perfil ativo.
- Lista de achados equivalentes à escala já usada no relatório V7 (crítico/alto/médio/baixo).

## Fluxo

Pré-requisito: o agente invocador já rodou `endpoint-scanner` no escopo alterado (inventário puro de
endpoint × atributo). Esta skill parte desse inventário para fazer a parte que o scanner não faz —
provisionamento e severidade:

1. Para cada `[RequiredPermission]` do inventário, verificar existência da chave no seed
   (`seed_functionality_keys.sql` ou equivalente) e vínculo com pelo menos um perfil ativo.
2. Cruzar com a planilha de controle de permissões do produto, se disponível, para achados já conhecidos versus novos.
3. Classificar severidade seguindo a escala já estabelecida (BOLA/IDOR = crítico; chave ausente = alto; inconsistência de nomenclatura = médio).

## Limitações

- Não substitui o fuzz real de runtime (`Back.ApiTests`) — é uma verificação estática complementar.
- Depende de as planilhas de controle estarem acessíveis; se não estiverem, a auditoria fica limitada ao código+seed.

## Exemplos

- `AddressController.Add` com `[AllowAnonymous]` → achado crítico já catalogado (BOLA), reportado mesmo que a tarefa atual não toque esse controller diretamente, se estiver na área de escopo.

## Quando usar

Antes de aprovar qualquer mudança em `[RequiredPermission]`/`[AllowAnonymous]`; auditoria periódica de segurança.

## Quando não usar

Para endpoints que não têm nenhuma checagem de autorização por design documentado (ex.: healthcheck).

# Decisões do Guardian (GADR)

Registro de decisões arquiteturais tomadas pelo Jarvis (chief-architect)
durante o roteamento (Step 09) ou o planejamento de um pedido de implementação
direta (Step 02). Formato adaptado do ADR usado pelo `bootstrap-agent-architecture`,
com ID próprio (`GADR-NNNN`) para nunca colidir com `.agents/decisions/` do
repositório alvo.

## Quando um GADR é criado

Só quando pelo menos uma destas condições é verdadeira:
- O achado ou pedido toca o núcleo compartilhado de Conta/Identidade
  (Account, Entity, Profile, Functionality, User) entre GeoCloudAI e E-LIMS.
- Há mais de uma abordagem de remediação/implementação viável, com trade-offs
  reais entre elas.
- É severidade crítica com impacto cross-produto.

Achado comum vira só uma `GT-NNNN.md` em `tasks/`, sem o ritual de opções —
o mesmo critério gradual que o `bootstrap-plan` já usa: nunca abrir um GADR
para o que é uma correção óbvia de único caminho.

## Quem escreve aqui

Só Jarvis. Tomás (task-curator) nunca decide mérito arquitetural — só
referencia o GADR relacionado (`related_adrs`) na task e na issue.

## Numeração

`GADR-NNNN`, sequencial, escaneado neste diretório. Nome do arquivo:
`GADR-NNNN-{slug}.md`.

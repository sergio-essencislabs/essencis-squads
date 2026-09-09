---
id: GT-0042
title: Nenhum nome de fornecedor de LLM no código; OpenAiChatClient vira ChatClient
status: completed
severidade: baixa
origem: pedido direto do dono do produto, repetido
run_origem: —
produto: GeoCloudAI
issue: 329
contraparte: GeoCloudAI/.agents/tasks/completed/GT-0042-chatclient-sem-nome-de-fornecedor.md
camada: backend
created_at: 2026-09-09
updated_at: 2026-09-09
---

# GT-0042 — Nenhum nome de fornecedor no código

## Por que isto entrou na fila

A GT-0040 removeu o adaptador do segundo provedor e deixou o **nome** dele espalhado em
comentários, mensagens de erro, padrão de redação, testes e documentação. O dono do produto teve de
repetir o pedido — *"Não quero ter que dizer novamente"* — e acrescentou que a classe não deve
nomear fornecedor.

**Lição para o squad**: "remover X" inclui remover a menção a X. Meia limpeza gera um segundo
pedido e queima confiança; e a parte não limpa vira documentação falsa, porque descreve
comportamento que já não existe.

## Evidência

16 ocorrências em `api/src`, `api/tests`, `docs/`, `Documentation/` e no baseline SQL — incluindo
dois usuários de seed nomeados com a marca, e trechos de `docs/ai/README.md` descrevendo uma
verificação que a GT-0040 já havia removido.

## Severidade

Baixa em risco, alta em confiança. Nada quebrado; mas documentação que descreve comportamento
inexistente manda o leitor para o lugar errado com convicção.

## Achado de segurança embutido

Os padrões de redação de credencial eram um por fornecedor. Ao unificar, verifiquei **antes de
apagar** se o padrão genérico cobria o específico: **não cobria** — exigia `[A-Za-z0-9]` depois de
`sk-`, parava no primeiro hífen, e por isso nunca casava com chave que traz prefixo
(`sk-algo-XXXX`). Apagar sem verificar teria sido regressão de segurança silenciosa.

O unificado aceita hífen e sublinhado: cobre mais que a soma dos dois. E não havia **nenhum** teste
de redação no repositório — 8 casos escritos, com contraprova.

## Roteamento

Camada única, backend, mais documentação. Sem impacto no núcleo compartilhado Conta/Identidade.

## Resultado

Concluída. Uma mudança de comportamento declarada: a verificação de "modelo do outro fornecedor
esquecido na configuração" saiu, porque a condição que ela pegava não é mais produzível com um
provedor só.

Issue #329 já está em Done; esta GT completa o que a GT-0040 deixou pela metade.

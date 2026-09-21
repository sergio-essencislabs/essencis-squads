---
id: GT-0156
title: "Reconciliacao dos 22 GTs deixados ativos pelo Guardian aposentado"
status: completed
type: documentation
achado_origem: "Squad Guardian aposentado em 21/09/2026 (skills guardian e start-guardian removidas); 22 GTs ficaram marcados active no hub sem ninguem para executa-las ou reconcilia-las"
auditor_origem: "GuardianS Vision, em quatro despachos paralelos de investigacao (Explore, so leitura)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A - despacho direto da Vision, fora de run de pipeline"
issue_url: "N/A - trabalho de reconciliacao de registro do hub, sem issue propria no GeoCloudAI"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-21
updated_at: 2026-09-21
affected_modules: [acervo-de-tasks]
related_adrs: []
contraparte: "N/A - GT do hub sobre o proprio acervo do hub; numeracao propria do hub (adaptador corrigido em 21/09)"
---

# GT-0156 - Reconciliacao dos 22 GTs deixados ativos pelo Guardian aposentado

## Contexto

O squad Guardian (Opensquad) foi aposentado em 21/09/2026 - as skills guardian e start-guardian
foram removidas e ninguem mais o executa. Ele deixou 22 GTs marcados active no hub, provavelmente
com parte ja resolvida pelo GuardianS ou por trabalho normal de sprint sem que o hub soubesse.

## Correcao de premissa, antes de qualquer verificacao

A lista de "22 ativos" recebida veio de uma branch desatualizada. tasks/gt-0153-entregas-sem-arquivo
(checada fora do worktree desta reconciliacao) tem GT-0144 em active/; em origin/main, GT-0144
ja estava fechada desde 13/09/2026, com escopo proprio (forma do campo contraparte, ver
GT-0144-reconciliar-o-acervo-de-gts.md, em completed/) e continuacao registrada na GT-0151
(ainda em backlog/, travada esperando decisao do Sergio sobre a forma canonica do ponteiro).

Em origin/main, a contagem real de GTs genuinamente ativos era 21, nao 22. Esta reconciliacao
verificou os 21.

Este trabalho tambem corrigiu um erro do mesmo dia: o adaptador do hub no GuardianS
(C:\Users\Essencis006\.guardianS\adapters\EssencisSquads\project.adapter.json) tinha sido
registrado com a politica de numeracao da GT-0714 (derivar de issue do GeoCloudAI) - errado, porque
o hub tem sequencia GT-NNNN propria, independente do GeoCloudAI. Corrigido para a politica original
(escanear o maior GT-NNNN existente, usar o proximo). Por isso esta GT e GT-0156 (proximo apos
GT-0155), nao um numero derivado de issue.

## Metodo

Nao feche nada por titulo, semelhanca ou por parecer resolvido - exigido: um artefato concreto por
verdicto (commit/PR com SHA, teste versionado que falharia se o defeito voltasse, caminho de codigo,
ou contraparte em completed/ com Registro de execucao preenchido). Quatro despachos paralelos,
so-leitura, cada um verificando um lote contra origin/main dos dois repositorios (hub e produto),
e contra todas as branches remotas quando a evidencia nao estava em main.

Cuidado especial nos 5 GTs de seguranca (GT-0028, GT-0049, GT-0050, GT-0051, GT-0052): confirmado
que TenantDerivationCoverageTests, a skill geocloud-tenant-isolation e GT-0160/0161/0162
(trabalho de 20-21/09) nao estao em origin/main - so na branch de sprint
feat/fix/refactor-14_09-18_09. Nao cobrem o defeito especifico de nenhum dos 5 GTs deste lote,
que se sustentam sozinhos em merges de 09/09/2026.

## Resultado - tabela dos 21

| GT | Veredito | Evidencia | Acao tomada |
|---|---|---|---|
| GT-0012 | Obsoleto | Anthropic removida do produto por decisao do dono (ADR-004, commit f9cecc26); streaming entregue contra OpenAI, nao Anthropic | Movida para completed/, nota explicando cancelamento |
| GT-0017 | Parcial | Camadas entregues (93762c5b, #362) exceto geoquimica (nunca feita) e hiperespectral (revertida por ordem do usuario, 0214edc1) | Fica em active/, nota com decisao pendente (reescopar ou nao) |
| GT-0023 | Resolvido | Decisao tomada (GADR-0002, 2026-09-02); corte do KoreGeo2 em main, citando GT-0024/GT-0025 | Movida para completed/ |
| GT-0024 | Resolvido | Commits 85e2448f + d6fdc3ef, em main; defeito do QA corrigido em addOverlayBar | Movida para completed/ |
| GT-0025 | Resolvido | Commit cc92fc10, em main; 3 gaps portados, 6 CAs ja marcados [x] no arquivo | Movida para completed/ |
| GT-0028 | Parcial | Dois defeitos nomeados corrigidos (f0937095, a993945f); portao (#422) segue aberto | Fica em active/, nota com o estado exato |
| GT-0030 | Aberto | Bloqueado por decisao (Blocker no board), zero codigo de geoquimica em main | Sem alteracao |
| GT-0049 | Resolvido | Commit 83f0b852 (PR #464), teste versionado AuthSettingsTests.cs | Movida para completed/ |
| GT-0050 | Resolvido | Commit f78aee20 (PR #466), TenantScopeReadApiTests.cs sem Skip= | Movida para completed/ |
| GT-0051 | Resolvido | Commits 0e80eea6+5cfcce2e (PR #468), issues #296/#297 fechadas | Movida para completed/ |
| GT-0052 | Resolvido | Commits 0bba7088+3507143f (PR #469); deriva hub-x-produto confirmada e corrigida | Movida para completed/ |
| GT-0064 | Parcial | Exportacao feita (88b5ec7a, PR #484) com prova dupla; importacao sem decisao registrada | Fica em active/, pergunta direta ao Sergio |
| GT-0109 | Resolvido | Commit 82cdf039 (PR #561), TOTAL 490 SUCCESS; premissa de ponteiro pendurado nao procedia | Movida para completed/ |
| GT-0139 | Resolvido | Commit 8c36e1e7 (PR #630), teste passando em CI real (run 34859293961) | Movida para completed/ |
| GT-0140 | Resolvido | Commit 5accadb3 (PR #642); residuo separado ja e GT-0148 | Movida para completed/ |
| GT-0141 | Resolvido | Commit e7a630af (PR #650), testes contra MySQL real | Movida para completed/ |
| GT-0142 | Resolvido | CA-05/CA-07 confirmados com runs de CI reais e doc versionada | Movida para completed/ |
| GT-0143 | Resolvido | Commits c566b559+b4df2270, run de CI real 34711724092 = success | Movida para completed/ |
| GT-0148 | Aberto | if condicional presente em TODAS as branches verificadas; zero commit implementando | Sem alteracao |
| GT-0149 | Aberto, escopo a reduzir | Defeito reproduzivel hoje (READMEs divergem); ver analise de sobreposicao com GT-0714 abaixo | Sem alteracao no arquivo - achado registrado aqui |
| GT-0150 | Aberto | Zero linhas de implementacao em 9 dias; maior severidade do lote, menor progresso | Sem alteracao |

Totais: 13 resolvidas + 1 obsoleta = 14 fechadas. 3 parciais e 4 abertas = 7 seguem em active/.
Nenhuma contraparte quebrada nova foi encontrada alem das ja catalogadas pela GT-0151.

## Achados que nao sao veredito, mas pedem decisao do Sergio

1. GT-0064 - a exportacao esta pronta e testada. O que trava fechar e saber se a importacao
   (pedida na issue original #203) continua dentro do escopo desta GT ou vira demanda nova. Ver a
   nota anexada ao proprio arquivo.

2. GT-0017 - reescopar formalmente para excluir geoquimica/hiperespectral (que ja migraram para
   GT-0030) fecharia esta GT hoje. Sem o reescopo, ela segue aberta descrevendo trabalho que nao e
   mais dela.

3. GT-0149 x GT-0714, sobreposicao parcial - nao e a mesma coisa. A GT-0714 (criada hoje pelo
   Sergio, GeoCloudAI/.agents/tasks/backlog/GT-0714-*.md) exclui explicitamente "reconciliar o
   passivo historico" e nao toca a manifestacao de corpo (o que torna um arquivo fechado por dentro,
   quem marca a caixa, adiantado-x-atrasado) que e a substancia pela qual a GT-0149 cresceu. A
   GT-0151 (backlog) depende da GT-0149 - declara-la obsoleta deixaria essa dependencia orfa.
   Recomendacao: nao fechar a GT-0149; marcar CA-02 dela como superado pela Fase 2 da GT-0714
   (pasta Blocker nas tres pontas) e CA-05 como conflito potencial a resolver antes (as duas podem
   canonizar respostas diferentes para "quem manda quando os dois lados divergem"). Isso nao foi
   escrito no arquivo da GT-0149 - fica aqui, para o Sergio decidir antes de qualquer edicao la.

4. GADR-0003 (hub, squads/guardian/decisions/GADR-0003-anthropic-thinking-blocks-sdk.md)
   continua status: accepted, decidindo sobre um SDK Anthropic que nao existe mais no codigo desde
   a GT-0040/ADR-004. Candidato a superseded - nao alterado aqui, fora do escopo desta reconciliacao.

5. Tres issues do GitHub seguem OPEN apesar do trabalho estar mesclado em main: #620 (GT-0140),
   #622 (GT-0142), #623 (GT-0143). Tambem #504 (GT-0028, a migration ja esta em main mas a issue de
   rastreio continua aberta). Nenhuma foi fechada aqui - a instrucao desta reconciliacao foi
   explicita: nao fechar issue sem perguntar, porque fechar e visivel para a equipe.

6. Defeito de forma, transversal, ja catalogado pela GT-0151/GT-0152 e nao corrigido aqui: tres
   dos quatro GTs de seguranca fechados (GT-0049, GT-0050, GT-0051) tem contraparte: do lado
   produto apontando para o proprio produto em vez do hub (auto-ponteiro). E o mover destas 14 GTs
   de active/ para completed/ no hub torna os ponteiros contraparte: correspondentes do lado
   produto atrasados (apontam para active/, o arquivo agora vive em completed/) - mais
   instancias exatas do padrao que a GT-0151 ja mede e que segue travada esperando a decisao do
   Sergio sobre a forma canonica do ponteiro. Nao consertado aqui, de proposito: forma canonica e
   decisao, nao medicao, e corrigir o texto do ponteiro antes dessa decisao e o erro que a GT-0151
   foi escrita para evitar.

## O que eu nao consegui decidir, nomeado

- GT-0030: nao consegui confirmar o estado atual da issue #373 no board do GitHub (conectores
  nao autenticados nos despachos de investigacao). Reportado o que o acervo diz, nao o que o board
  diz hoje.
- GT-0064: diagnostico tecnico seguro (resolvido, se o escopo for so exportacao); a chamada de
  escopo e do Sergio, nao minha.
- GT-0017: mesma natureza - tecnicamente parcial, mas fechar exige reescopo que so o Sergio
  autoriza.

## Registro de execucao

### Alteracoes realizadas
14 arquivos movidos de active/ para completed/ no hub, cada um com nota de evidencia anexada e
status: atualizado para completed. 3 arquivos mantidos em active/, cada um com nota de
evidencia parcial anexada, sem alteracao de status:. 4 arquivos (GT-0030, GT-0148, GT-0149,
GT-0150) nao tocados, por instrucao explicita ("ainda aberto: deixe como esta").

Fora do hub: corrigido C:\Users\Essencis006\.guardianS\adapters\EssencisSquads\project.adapter.json
(numberingPolicy, ver acima).

### Arquivos principais
squads/guardian/tasks/completed/GT-{0012,0023,0024,0025,0049,0050,0051,0052,0109,0139,0140,0141,0142,0143}-*.md
(movidos); squads/guardian/tasks/active/GT-{0017,0028,0064}-*.md (anotados, nao movidos).

### Decisoes
Tratar GT-0144 como ja fechada (nao reabrir, nao reusar seu numero) e registrar esta reconciliacao
como GT nova (GT-0156), porque o escopo dos 21 GTs verificados nao e o mesmo assunto que a GT-0144
fechou (forma do ponteiro) - sao defeitos de produto distintos que o Guardian encontrou e nunca
implementou.

### Divergencias
Nenhuma das quatro investigacoes paralelas divergiu entre si nos vereditos. Uma delas (GT-0109)
corrigiu uma premissa errada do briefing original (a suposta contraparte pendurada de GT-0109/GT-0110
na GT-0151); verificado e registrado como nao procedente.

### Pendencias
Os 6 itens da secao "Achados que nao sao veredito, mas pedem decisao do Sergio", acima.

## Validacao

Evidencia por item, na tabela acima e nas notas anexadas a cada arquivo movido/anotado. Nenhum
dotnet test/ng test foi executado localmente por esta reconciliacao - a prova de "passa hoje"
veio de runs de CI reais ja existentes (citados por numero de run), nunca de execucao nova.

## Handoff

Reconciliacao concluida em 21/09/2026, despacho da Vision (GuardianS), a pedido do Sergio via outra
sessao. Proximo GT livre do hub: GT-0157.

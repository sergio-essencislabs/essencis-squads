---
id: GT-0050
title: "Suíte de API não exercitava autorização: verde ou vermelha conforme o ambiente de quem roda"
status: active
type: bug
severidade: alta
owner: sergio-essencislabs
created_at: 2026-09-09
updated_at: 2026-09-09
origem: "descoberto ao tentar provar as guardas de tenant das issues #296 e #297 — nenhum teste conseguia chegar ao controller"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0050-suite-de-api-volta-a-exercitar-autorizacao.md"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/465"
branch: fix/gt-0050-suite-de-api-volta-a-exercitar-autorizacao
affected_modules: ["Back.ApiTests", "Back.IntegrationTests", "Back.Persistence"]
related_use_cases: []
related_adrs: ["ADR-003"]
---

# GT-0050 — A suíte de API volta a exercitar autorização

## Como isto apareceu

Não foi uma auditoria. Foi a tentativa de **provar** a correção das issues #296 e #297: escrever um
teste que atacasse `StructureType.getById` de outra conta e verificasse o bloqueio. Todos os casos
davam 403 — inclusive `getByAccount`, que não tem guarda nenhuma e é o caminho legítimo. O 403 não
vinha da correção; vinha de antes.

## Cinco defeitos independentes, todos com o mesmo modo de falha

Cada um sozinho já impedia a suíte de exercitar o que ela diz exercitar. Todos produzem 401 ou 403,
que é indistinguível de "o teste passou" quando o caso esperado é justamente um bloqueio.

**1. `GEOCLOUD_TOKEN_KEY` do ambiente vencia a `TokenKey` das fábricas.**
Desde a TASK-054, `AppSecrets.ResolveTokenKey` lê a variável de ambiente **antes** da configuração —
de propósito, para que valor versionado não sobreponha segredo real. A consequência é que em toda
máquina de desenvolvimento do projeto (todas têm a variável) a API validava com a chave real
enquanto as fábricas assinavam com a de teste. 401 em massa. A suíte era verde ou vermelha conforme
quem a rodasse.

**2. `CampaignFactory` apontava o host para o banco de origem.**
A mesma TASK-054 fez `MySqlConnectionString.Resolve` preferir `DATABASE_URL` a
`ConnectionStrings:DefaultConnection`. O comentário da classe dizia que "na main a conexão sai
direto da configuração, sem override por variável de ambiente" — deixou de ser verdade e ninguém
percebeu, porque o sintoma foi 403. As personas nasciam no clone e o host falava com a origem.
**A campanha executa `delete` e `update` de ataque**; apontada para a origem, esses casos rodariam
contra dados reais.

**3. Contas semeadas nasciam sem módulo.**
O portão de módulo (TASK-055/056, ADR-003) nega **todas** as chaves para conta sem módulo
contratado — antes até do bypass de administrador de sistema, que é declaradamente subordinado a
ele. O backfill da migração alcança só as contas que já existiam; `SeedHelper` e `Personas` criam
conta por `INSERT` direto. Produção está correta: o auto-cadastro concede o Core na mesma transação.

**4. `ResetTransientState` truncava pai e deixava filha.**
`TRUNCATE` com `FOREIGN_KEY_CHECKS=0` esvazia `account` e `users` **e reinicia o AUTO_INCREMENT**,
enquanto `accountmodule`, `company` e outras sobrevivem apontando para ids que deixaram de existir.
A próxima linha semeada recebe um id que uma órfã já referencia.

**5. Um token que mentia sobre a identidade.**
`CreateAuthenticatedClient(int userId)` caía nos padrões `accountId = 1, entityId = 1` do
`IssueJwt`. Quatro testes a chamavam passando o `UserId` de um usuário de outra conta.
`PaginationApiTests` **passava por causa disso**: as rotas `/get` exigem a entidade dona do sistema,
e o token falso dizia ser ela.

## Um defeito de produto, encontrado por consequência

`UserRepository.Delete` fazia `DELETE FROM users` sem remover o vínculo em `userprofile`. A chave
estrangeira `userprofile_ibfk_2` derrubava a exclusão de **qualquer usuário com perfil atribuído** —
que é todo usuário criado pelo fluxo normal. O endpoint devolvia 500 com a mensagem crua do MySQL.

Só o vínculo é removido. As referências de **autoria** (`company.userId`, `region.userId`) ficam
onde estão: elas registram quem criou o dado, e o que fazer com elas é decisão de produto.

## Um teste que afirmava uma travessia de tenant

`PhysicalDeleteApiTests` criava chamador e vítima em **contas diferentes** e esperava que a exclusão
desse certo. `UserController.Delete` recusa corretamente. O assunto do teste é exclusão física, não
travessia: a vítima passou a ser semeada na mesma conta.

## Resultado

`Back.ApiTests/Endpoints`: de **5 de 14** para **14 de 14** — agora *com* `GEOCLOUD_TOKEN_KEY`
presente no ambiente, isto é, sem depender de quem executa.

## Critérios de aceitação

- [x] CA-01 — A suíte passa com e sem `GEOCLOUD_TOKEN_KEY` definida no ambiente.
- [x] CA-02 — O host da campanha falha alto se resolver um banco que não seja o clone efêmero.
- [x] CA-03 — Conta semeada recebe o Core, e a ausência de módulo `core` falha nomeando a causa.
- [x] CA-04 — `ResetTransientState` não reaproveita ids.
- [x] CA-05 — Não existe mais caminho para emitir token com conta diferente da do usuário.
- [x] CA-06 — `User/delete` remove o vínculo de perfil e devolve sucesso.
- [ ] CA-07 — Teste manual do fluxo de exclusão de usuário pela tela (Sergio/Matheus).

## Verificação

`Back.UnitTests` 287/287, `Back.IntegrationTests` 53/53, `Back.ApiTests/Endpoints` 14/14.

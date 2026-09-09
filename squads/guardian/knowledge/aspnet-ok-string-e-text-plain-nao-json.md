# `Ok(string)` no ASP.NET Core Web API serializa como `text/plain`, não JSON

**Data:** 2026-08-31
**Origem:** implementação de `UserPasswordReset` no GeoCloudAI, testada manualmente pelo usuário.

## Lição

Uma action de `[ApiController]` que retorna `Ok(algumaString)` — padrão comum
neste stack para respostas de sucesso que são só uma mensagem, sem dado
estruturado (`Ok(result.Message)`) — tem o corpo servido como texto puro
(`Content-Type: text/plain`), **sem aspas**, não como JSON. É a seleção de
formatter padrão do ASP.NET Core para `string`: o `StringOutputFormatter`
ganha do formatter JSON quando o tipo de retorno é exatamente `string`.

No Angular, `HttpClient` por padrão espera `responseType: 'json'` e faz
`JSON.parse()` no corpo da resposta. Um texto sem aspas não é JSON válido —
o parse falha, e o Angular trata uma resposta **200 genuinamente bem-sucedida**
como erro. O sintoma é enganoso: o `HttpErrorResponse` resultante não tem
`error.message` útil, só `statusText` — que para uma resposta 200 é
literalmente a string `"OK"`. Quem só olha a mensagem de erro vê "OK" e não
entende por que uma chamada que "deu certo" no backend aparece como falha
no frontend.

Evidência: `POST /api/UserPasswordReset/add` retornava 200 de verdade (linha
inserida no banco, código gerado) mas o modal de erro no Angular só mostrava
"OK" — rastreado até `HttpClient.post<string>(...)` sem `responseType: 'text'`.

## Como aplicar

- Toda vez que um service Angular chamar um endpoint que devolve `Ok(string)`
  (mensagem simples, sem DTO), passar `{ responseType: 'text' }` explicitamente
  — não confiar no `responseType: 'json'` padrão.
- Já existia um precedente disso no próprio GeoCloudAI antes desta lição
  (`user.service.ts`, `changePassword`) — o padrão já era conhecido em um
  lugar, mas não estava documentado, então foi redescoberto do zero aqui.
- Ao revisar/portar qualquer novo service Angular que chame uma action que
  devolve string simples, checar isso antes de testar — evita repetir a
  mesma investigação.
- Vale tanto para GeoCloudAI quanto para E-LIMS (mesma stack .NET 9
  `[ApiController]` + Angular `HttpClient`).

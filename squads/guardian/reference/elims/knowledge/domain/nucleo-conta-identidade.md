# Núcleo Compartilhado: Conta / Identidade

Fonte original: `Documents/ELIMS/Miscelaneous/Markdown Files/ELIMS_GeoCloud_Visao_Tecnica.md` (28/07/2026). Este documento sintetiza apenas a parte cross-projeto; detalhes de implementação ficam em `docs/system/attribute-mapping.md` de cada produto.

## As 16 classes

`Account`, `AccountInvite`, `Entity`, `EntityNature`, `EntityRole`, `Role`, `Profile`, `ProfileFunctionality`, `Functionality`, `FunctionalityType`, `User`, `UserProfile`, `Country`, `Address`, `AddressType`, `UserInvite`.

## Papéis

| Classe | Papel |
|---|---|
| `Account` | Raiz do multi-tenant. |
| `Entity` | Pessoa jurídica dona da conta (no LIMS também usada como Cliente). |
| `Profile`/`Functionality`/`ProfileFunctionality` | Perfil de acesso, unidade de permissão (com `.Key`), vínculo entre eles. |
| `User`/`UserProfile` | Usuário e vínculo com perfil. |
| `Country`/`Address`/`AddressType` | Referência e endereço. |

## Divergências intencionais (domínio de negócio, não drift)

- `EntityDetail` — existe só (40+ campos comerciais/CRM que saíram de `Entity`).
- `Contact`, `Sector`, `Log` — específicos (branch `Testando-multi-tenet`).

## Divergências NÃO intencionais (drift a resolver — ver `knowledge/known-issues/`)

- `FunctionalityType`: ELIMS usa 1=Sistema/2=Conta/3=Empresa.
- `User → Entity` no código, mas o banco vivo historicamente usava `accountid → Account` (verificar estado atual antes de assumir).
- `functionality.key`/`profilefunctionality` podem estar vazios no banco vivo mesmo com o código assumindo que estão populados.

## Regra de manutenção

Qualquer alteração nestas 16 classes segue `playbooks/sincronizacao-nucleo-compartilhado.md`, com a skill `parity-diff` antes e depois.

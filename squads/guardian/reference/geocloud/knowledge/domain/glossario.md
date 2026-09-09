# Glossário PT ↔ EN

Herança do código legado do GeoCloud (comentários/nomes antigos em português) mapeado para os nomes em inglês usados no código atual. Nunca reintroduzir a coluna PT em código novo — ver `policies/nomenclatura.md`.

| PT (legado) | EN (código atual) |
|---|---|
| Conta_convite | AccountInvite |
| Conta | Account |
| Empresa | Entity (não "Company") |
| Natureza | EntityNature |
| Usuario | User |
| Perfil | Profile |
| Usuario_Perfil | UserProfile |
| Perfil_Funcionalidade | ProfileFunctionality |
| Funcionalidade | Functionality (tem `.Key`) |
| Proprietaria | Entity.OwnerAccount |

## Termos de domínio

| Termo | Significado |
|---|---|
| Tenant / Account | Conta raiz que isola os dados de um cliente. |
| Permission key | String (`entity.add`) exigida por endpoint via `[RequiredPermission]`. |
| BOLA | Broken Object Level Authorization — endpoint que expõe/aceita dados sem checar dono. |
| Parity | Ação de manter GeoCloud consistente com o núcleo do GeoCloud (classes + permissões). |
| Drift | Divergência não intencional entre código e banco, ou entre GeoCloud. |

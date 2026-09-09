---
name: duplicate-detector
description: Busca componente equivalente já existente (classe, service, repository, componente Angular, endpoint, documento) antes de criar um novo, em GeoCloud. Use sempre antes de criar qualquer arquivo/classe/componente novo.
---

# Duplicate Detector

## Objetivo

Impedir a criação de um componente que já existe (ou existe de forma equivalente no produto irmão), causa raiz de boa parte da dívida técnica já documentada entre GeoCloud.

## Entradas

- Nome/propósito do componente a criar.
- Produto de destino.

## Saídas

- "Não existe equivalente — pode criar" **ou**
- "Existe em `<caminho>` — reutilizar/estender" **ou**
- "Existe versão análoga no produto irmão em `<caminho>` — avaliar se deveria ser o mesmo componente (núcleo compartilhado)".

## Fluxo

1. Buscar por nome exato e por sinônimos comuns (PT/EN, ver `knowledge/domain/glossario.md`) no produto de destino.
2. Se não encontrar, buscar no produto irmão (sinaliza candidato a núcleo compartilhado se encontrado).
3. Buscar também em `shared/`, `shared-modules/`, `ui/` (frontend) e `Classes/` (backend) por algo estruturalmente parecido, não só por nome idêntico.

## Limitações

- Detecção é textual/estrutural; duplicação semântica sutil pode não ser encontrada — quando em dúvida, escalar ao Refactoring Architect.
- Não decide se um achado deve ser unificado — apenas relata.

## Exemplos

- "Vou criar um `AddressValidator`" → encontra que ambos os produtos já têm lógica de validação de endereço embutida no `AddressService`; recomenda estender em vez de criar um validador novo separado.

## Quando usar

Antes de criar qualquer classe, service, repository, componente, endpoint ou documento novo.

## Quando não usar

Para arquivos de configuração/infraestrutura sem equivalente conceitual possível (ex.: um único `Startup.cs`).

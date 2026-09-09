<#
.SYNOPSIS
  Cria uma nova entrada de "lição aprendida" atômica, no formato já validado em
  .agents/memory/ (name/description + Why/How to apply).

.PARAMETER Slug
  Identificador curto em kebab-case (nome do arquivo).

.PARAMETER Scope
  "framework" para knowledge/patterns/ (cross-projeto) ou caminho do produto
  (ex.: "../../ELIMS/ELIMS/.agents/memory") para lição específica de um produto.

.EXAMPLE
  pwsh ./new-memory.ps1 -Slug "cache-permissao-por-conta" -Scope framework
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [Parameter(Mandatory = $true)]
    [string]$Scope
)

$ErrorActionPreference = "Stop"
$frameworkRoot = Split-Path -Parent $PSScriptRoot

if ($Scope -eq "framework") {
    $targetDir = Join-Path $frameworkRoot "knowledge\patterns"
    $indexNote = "Atualize knowledge/patterns/README.md com uma linha apontando para este arquivo."
} else {
    $targetDir = Join-Path $frameworkRoot $Scope
    $indexNote = "Atualize MEMORY.md nesse diretório com uma linha apontando para este arquivo (mesmo padrão das entradas existentes)."
}

if (-not (Test-Path $targetDir)) {
    throw "Diretório de destino não existe: $targetDir"
}

$destPath = Join-Path $targetDir "$Slug.md"
if (Test-Path $destPath) {
    throw "Já existe: $destPath — edite o arquivo existente em vez de criar um novo."
}

$content = @"
---
name: $Slug
description: <uma frase objetiva sobre o que esta lição cobre>
---

<Corpo curto: a regra/lição em 1-3 frases.>

**Why:** <por que isso é verdade / por que importa — a causa raiz, não o sintoma.>

**How to apply:** <o que fazer diferente na prática por causa desta lição.>
"@

Set-Content -Path $destPath -Value $content -Encoding UTF8
Write-Host "Criado: $destPath" -ForegroundColor Green
Write-Host $indexNote -ForegroundColor Yellow

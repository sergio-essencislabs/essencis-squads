<#
.SYNOPSIS
  Cria um novo ADR (Architecture Decision Record) do framework, numerado sequencialmente,
  em knowledge/decisions/, e adiciona a entrada em FRAMEWORK_DECISIONS.md.

.PARAMETER Title
  Título curto da decisão (usado no nome do arquivo, em kebab-case).

.EXAMPLE
  pwsh ./new-adr.ps1 -Title "Adotar paginacao em listagens grandes"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Title
)

$ErrorActionPreference = "Stop"
$frameworkRoot = Split-Path -Parent $PSScriptRoot
$decisionsDir = Join-Path $frameworkRoot "knowledge\decisions"
$indexPath = Join-Path $frameworkRoot "FRAMEWORK_DECISIONS.md"
$templatePath = Join-Path $frameworkRoot "templates\adr.md"

$existing = Get-ChildItem -Path $decisionsDir -Filter "*.md" | Where-Object { $_.Name -match '^\d{4}-' }
$nextNumber = 1
if ($existing.Count -gt 0) {
    $maxNumber = ($existing | ForEach-Object { [int]($_.Name.Substring(0, 4)) } | Measure-Object -Maximum).Maximum
    $nextNumber = $maxNumber + 1
}
$idPadded = $nextNumber.ToString("0000")
$slug = ($Title.ToLower() -replace '[^a-z0-9\s-]', '' -replace '\s+', '-')
$fileName = "$idPadded-$slug.md"
$destPath = Join-Path $decisionsDir $fileName

$today = Get-Date -Format "yyyy-MM-dd"
$content = Get-Content -Path $templatePath -Raw -Encoding UTF8
$content = $content -replace 'ADR-NNNN', "ADR-$idPadded"
$content = $content -replace '<título curto da decisão>', $Title
$content = $content -replace 'YYYY-MM-DD', $today
$content = $content -replace 'proposto \| aceito \| rejeitado \| superado por ADR-XXXX', 'proposto'

Set-Content -Path $destPath -Value $content -Encoding UTF8
Write-Host "Criado: $destPath" -ForegroundColor Green

# Adiciona ao índice (antes da última linha, mantendo formato de tabela)
$indexContent = Get-Content -Path $indexPath -Encoding UTF8
$newRow = "| [ADR-$idPadded](knowledge/decisions/$fileName) | $Title | Proposto | $today |"
$indexContent += $newRow
Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
Write-Host "Adicionado ao índice: FRAMEWORK_DECISIONS.md" -ForegroundColor Green
Write-Host "`nEdite $destPath para preencher Contexto/Decisão/Consequências/Alternativas." -ForegroundColor Yellow

<#
.SYNOPSIS
  Verifica que todos os links markdown relativos internos do geocloud-ai-framework
  apontam para arquivos que de fato existem (detecção de drift estrutural
  do próprio framework — ex.: arquivo renomeado sem atualizar quem o referenciava).

.EXAMPLE
  pwsh ./check-links.ps1
#>

$ErrorActionPreference = "Continue"
$frameworkRoot = Split-Path -Parent $PSScriptRoot
$mdFiles = Get-ChildItem -Path $frameworkRoot -Filter "*.md" -Recurse

$linkPattern = '\[[^\]]+\]\(([^)]+)\)'
$brokenLinks = @()
$checked = 0

foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $matches = [regex]::Matches($content, $linkPattern)
    foreach ($m in $matches) {
        $link = $m.Groups[1].Value

        # Ignora links externos (http/https/mailto) e anchors puros (#secao)
        if ($link -match '^(https?:|mailto:)' -or $link.StartsWith('#')) { continue }

        # Remove anchor da parte de arquivo, se houver (ex.: arquivo.md#secao)
        $filePart = $link.Split('#')[0]
        if ([string]::IsNullOrWhiteSpace($filePart)) { continue }

        $checked++
        $resolvedPath = Join-Path $file.DirectoryName $filePart
        if (-not (Test-Path $resolvedPath)) {
            $brokenLinks += [PSCustomObject]@{
                File = $file.FullName.Replace($frameworkRoot, "").TrimStart("\")
                Link = $link
            }
        }
    }
}

Write-Host "Links verificados: $checked"
if ($brokenLinks.Count -gt 0) {
    Write-Host "`nLinks quebrados encontrados:" -ForegroundColor Red
    $brokenLinks | ForEach-Object { Write-Host "  - $($_.File) -> $($_.Link)" -ForegroundColor Red }
    exit 1
} else {
    Write-Host "Nenhum link interno quebrado." -ForegroundColor Green
    exit 0
}

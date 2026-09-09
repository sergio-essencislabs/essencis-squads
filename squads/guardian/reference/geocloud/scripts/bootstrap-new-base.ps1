<#
.SYNOPSIS
  Cria uma base de desenvolvimento a partir de um produto original,
  seguindo playbooks/onboarding-nova-base.md: cópia limpa (sem artefatos
  regeneráveis), git próprio, BASELINE.md com proveniência.

.PARAMETER SourcePath
  Caminho absoluto do produto original (ex.: C:\...\GeoCloud\GeoCloudAI).

.PARAMETER DestPath
  Caminho absoluto da nova base (ex.: C:\...\GeoCloud\sandbox-geocloud).

.PARAMETER ProductName
  Nome do produto, para o BASELINE.md (ex.: "GeoCloud").

.EXAMPLE
  pwsh ./bootstrap-new-base.ps1 -SourcePath "C:\...\GeoCloud\GeoCloudAI" -DestPath "C:\...\GeoCloud\sandbox-geocloud" -ProductName "GeoCloud"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$DestPath,

    [Parameter(Mandatory = $true)]
    [string]$ProductName
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $SourcePath)) { throw "Origem não encontrada: $SourcePath" }
if ((Get-ChildItem -Path $DestPath -Force -ErrorAction SilentlyContinue).Count -gt 0) {
    throw "Destino já contém arquivos: $DestPath — este script só popula uma base vazia (segurança contra sobrescrever trabalho)."
}

$excludeDirs = @("node_modules", "bin", "obj", ".angular", "TestResults", "v7-results", ".git", ".vs", "dist", ".replit-artifact")
$excludeFiles = @("*.user")

Write-Host "== Bootstrap de nova base: $ProductName ==" -ForegroundColor Cyan
Write-Host "Origem: $SourcePath"
Write-Host "Destino: $DestPath"

# Commit SHA de origem (se a origem for um repo git)
$originSha = "desconhecido (origem não é um repositório git neste caminho)"
$gitDir = Join-Path $SourcePath ".git"
if (Test-Path $gitDir) {
    Push-Location $SourcePath
    try {
        $originSha = (git rev-parse HEAD).Trim()
    } catch {
        $originSha = "erro ao obter SHA: $_"
    } finally {
        Pop-Location
    }
}

New-Item -ItemType Directory -Force -Path $DestPath | Out-Null

# robocopy: /E copia subpastas incluindo vazias; /XD exclui diretórios; /XF exclui arquivos; /NFL /NDL /NJH /NJS reduz verbosidade
$xdArgs = $excludeDirs | ForEach-Object { $_ }
$xfArgs = $excludeFiles | ForEach-Object { $_ }
robocopy $SourcePath $DestPath /E /XD $xdArgs /XF $xfArgs /NFL /NDL /NJH /NP | Out-Null
$robocopyExit = $LASTEXITCODE
# robocopy usa códigos de saída bitmask; 0-7 = sucesso (8+ = erro)
if ($robocopyExit -ge 8) {
    throw "robocopy falhou com código $robocopyExit"
}

$today = Get-Date -Format "yyyy-MM-dd"
$baseline = @"
# BASELINE

Esta base foi criada pelo playbook ``onboarding-nova-base.md`` do geocloud-ai-framework.

- **Produto de origem:** $ProductName
- **Caminho de origem:** $SourcePath
- **Commit SHA de origem:** $originSha
- **Data da cópia:** $today
- **Exclusões aplicadas:** $($excludeDirs -join ', ')
- **Histórico de git:** não herdado (esta base começa com git próprio — ver commit inicial)

A partir deste ponto, esta base evolui de forma independente do produto de origem, seguindo os playbooks/agentes/policies do ``geocloud-ai-framework`` em ``../geocloud-ai-framework``.
"@
Set-Content -Path (Join-Path $DestPath "BASELINE.md") -Value $baseline -Encoding UTF8

Push-Location $DestPath
try {
    git init | Out-Null
    git add -A
    git commit -m "Baseline copiado de $ProductName @ $originSha" | Out-Null
    Write-Host "Git inicializado com commit de baseline." -ForegroundColor Green
} finally {
    Pop-Location
}

Write-Host "`nBase '$ProductName' pronta em: $DestPath" -ForegroundColor Green
Write-Host "Próximo passo: validar build (dotnet build / npm install) — ver playbooks/onboarding-nova-base.md passo 6." -ForegroundColor Yellow

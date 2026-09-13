<#
.SINOPSE
  Reabre o squad inteiro depois de um reinicio: as janelas do Claude Code em
  abas de uma unica janela do Windows Terminal, mais a aba do device
  (Remote Control), que e o que deixa a maquina visivel no celular.

.COMO USAR
  powershell -ExecutionPolicy Bypass -File .\abrir-squad.ps1

  -Conferir           so imprime o que faria, sem abrir nada
  -Apenas vision,rui  abre so as janelas nomeadas -- SEPARADAS POR VIRGULA,
                      sem espaco: com -File, "vision rui" nao passa as duas
  -SemDevice          nao abre a aba do Remote Control
  -Sim                pula a confirmacao do aviso de sessoes ja vivas.
                      Use so quando voce ja sabe que ha sessoes vivas e quer
                      abrir assim mesmo -- ou para testar o script sem teclado
  -Base <caminho>     raiz das worktrees (padrao: C:\Software\GeoCloud)
  -DeviceDir <cam>    diretorio de onde o Remote Control sobe
  -DeviceNome <nome>  nome do device -- trocar cria um device NOVO no celular
                      em vez de reconectar o mesmo

.COMO CADA JANELA VOLTA
  `claude --continue` retoma a conversa MAIS RECENTE do diretorio. Nao ha id
  fixo: quem decide e a data de modificacao do .jsonl em
  %USERPROFILE%\.claude\projects\<slug-do-diretorio>\

  Consequencia que morde: se um diretorio tiver mais de uma sessao e a errada
  for a mais nova, aquela janela volta na conversa errada e ninguem e avisado.
  Por isso o script imprime a data de cada uma antes de abrir, e marca as que
  tem mais de uma. Rode com -Conferir e leia essa lista.

.O QUE ESTE SCRIPT NAO GARANTE
  - Nao verifica que a sessao retomada e a "certa", so mostra a data.
  - Nao ordena a subida: as abas sobem juntas.
  - O aviso de duplicata conta processos claude.exe na maquina inteira; ele
    detecta que HA sessoes vivas, nao QUAIS.
#>

# PositionalBinding=$false de proposito: sem isso, "-Apenas vision rui" liga o
# "rui" ao -Base por posicao e o script vai procurar em "rui\_wt_vision".
# Argumento solto tem de dar erro, nao virar raiz de diretorio.
[CmdletBinding(PositionalBinding = $false)]
param(
  [switch]   $SemDevice,
  [string[]] $Apenas,
  [switch]   $Conferir,
  [switch]   $Sim,
  [string]   $Base       = 'C:\Software\GeoCloud',
  [string]   $DeviceDir  = 'C:\VaultS\VaultS',
  [string]   $DeviceNome = 'VaultS'
)

$ErrorActionPreference = 'Stop'

# Nome da aba -> diretorio de trabalho. A ordem aqui e a ordem das abas.
$janelas = @(
  @{ Nome = 'Vision';     Sub = '_wt_vision' }
  @{ Nome = 'Jarvis';     Sub = '_wt_jarvis' }
  @{ Nome = 'Breno';      Sub = '_wt_breno'  }
  @{ Nome = 'Otavio';     Sub = '_wt_otavio' }
  @{ Nome = 'Tomas';      Sub = '_wt_tomas'  }
  @{ Nome = 'Rui';        Sub = '_wt_rui'    }
  @{ Nome = 'Dante';      Sub = '_wt_dante'  }
  @{ Nome = 'Selma';      Sub = '_wt_selma'  }
  @{ Nome = 'Livia';      Sub = '_wt_livia'  }
  @{ Nome = 'Flavia';     Sub = '_wt_flavia' }
  @{ Nome = 'Marta';      Sub = '_wt_marta'  }
  @{ Nome = 'GeoCloudAI'; Sub = 'GeoCloudAI' }
) | ForEach-Object { $_.Dir = Join-Path $Base $_.Sub; [pscustomobject]$_ }

if ($Apenas) {
  # Invocado com -File, o PowerShell NAO separa "vision,rui" em dois: chega um
  # elemento so. E -File e como o atalho chama. Por isso separamos aqui.
  # Use virgula, nao espaco: "-Apenas vision rui" nao passa os dois.
  $filtro = @(($Apenas -join ',') -split ',' |
              ForEach-Object { $_.Trim().ToLowerInvariant() } |
              Where-Object { $_ })
  $janelas = @($janelas | Where-Object { $filtro -contains $_.Nome.ToLowerInvariant() })
  if ($janelas.Count -eq 0) {
    throw "Nenhuma janela casa com -Apenas: $($Apenas -join ', ')"
  }
}

# ---- conferencias antes de abrir --------------------------------------------

$faltando = @($janelas | Where-Object { -not (Test-Path -LiteralPath $_.Dir) })
if ($faltando.Count -gt 0) {
  throw "Diretorio inexistente: " + (($faltando | ForEach-Object { $_.Dir }) -join ', ')
}

$vivos = @(Get-Process claude -ErrorAction SilentlyContinue)
if ($vivos.Count -gt 0) {
  Write-Warning "Ja existem $($vivos.Count) processos claude.exe rodando."
  Write-Warning "Abrir agora cria janelas DUPLICADAS na mesma pasta -- e duas janelas"
  Write-Warning "na mesma worktree fazem trabalho ser atribuido a quem nao o fez."
  Write-Warning "Feche-as antes, ou use -Apenas para abrir so o que falta."
  if (-not $Conferir -and -not $Sim) {
    $r = Read-Host "Continuar mesmo assim? (s/N)"
    if ($r -ne 's') { Write-Host "Cancelado."; return }
  } elseif ($Sim) {
    Write-Warning "-Sim: seguindo sem perguntar."
  }
}

# Qual conversa cada janela vai retomar, pela data do .jsonl mais recente.
Write-Host ""
Write-Host "Janela        Conversa que o --continue vai retomar" -ForegroundColor Cyan
Write-Host "------------  -------------------------------------" -ForegroundColor Cyan
foreach ($j in $janelas) {
  # Sem regex de proposito: barra invertida em regex e fonte de erro silencioso.
  $slug = $j.Dir.Replace(':', '-').Replace([char]92, '-').Replace('/', '-').Replace('_', '-').Replace('.', '-')
  $proj = Join-Path $env:USERPROFILE ".claude\projects\$slug"
  $s = @(Get-ChildItem -LiteralPath $proj -Filter *.jsonl -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending)
  if ($s.Count -eq 0) {
    Write-Host ("{0,-13} SEM SESSAO -- vai comecar conversa nova" -f $j.Nome) -ForegroundColor Yellow
  } else {
    $marca = if ($s.Count -gt 1) { "  (de $($s.Count) sessoes -- confira que a mais nova e a certa)" } else { "" }
    Write-Host ("{0,-13} {1:yyyy-MM-dd HH:mm}{2}" -f $j.Nome, $s[0].LastWriteTime, $marca)
  }
}
Write-Host ""

if ($Conferir) { Write-Host "-Conferir: nada foi aberto."; return }

# ---- monta e dispara --------------------------------------------------------

# "-w new" de proposito: sem isso, o comportamento depende do windowingBehavior
# do Windows Terminal, e numa maquina configurada para reusar janela as abas
# entram na janela que ja esta aberta, misturadas com as sessoes vivas.
$wtArgs = New-Object System.Collections.Generic.List[string]
$wtArgs.AddRange([string[]]@('-w', 'new'))
$primeira = $true
foreach ($j in $janelas) {
  if (-not $primeira) { $wtArgs.Add(';') }
  $primeira = $false
  $wtArgs.AddRange([string[]]@(
    'new-tab', '--title', $j.Nome, '-d', $j.Dir,
    'powershell', '-NoExit', '-Command', 'claude --continue'
  ))
}

if (-not $SemDevice) {
  if (Test-Path -LiteralPath $DeviceDir) {
    $wtArgs.Add(';')
    $wtArgs.AddRange([string[]]@(
      'new-tab', '--title', "$DeviceNome (device)", '-d', $DeviceDir,
      'powershell', '-NoExit', '-Command', "claude --remote-control $DeviceNome"
    ))
  } else {
    Write-Warning "Device nao aberto: $DeviceDir nao existe. Use -DeviceDir."
  }
}

& wt @wtArgs

Write-Host ""
Write-Host "Disparado. Confira numa das janelas com /agents:" -ForegroundColor Green
Write-Host "  - devem aparecer $($janelas.Count - 1) pares;" -ForegroundColor Green
Write-Host "  - o device deve aparecer como 'Remote Control', nao 'offline'." -ForegroundColor Green
Write-Host "Contar as abas nao serve: aba aberta nao e sessao viva." -ForegroundColor Green

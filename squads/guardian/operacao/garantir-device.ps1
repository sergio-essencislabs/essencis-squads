<#
.SINOPSE
  Garante que o device (servidor de Remote Control) esteja de pe. Checa; se ja
  estiver rodando, nao faz nada; se nao estiver, sobe e registra em log.

  Feito para rodar pelo Agendador de Tarefas, com DOIS gatilhos:
    - no logon do usuario
    - a cada 30 minutos

.POR QUE CHECAGEM EXPLICITA, E NAO A POLITICA DO AGENDADOR
  O Agendador tem "nao iniciar nova instancia", mas isso impede duas execucoes
  DA TAREFA -- nao duas do device. Se a tarefa terminar deixando o processo
  vivo (que e o caso aqui), a politica nao diz mais nada sobre o device.
  Checar o processo e auditavel; confiar na politica falha em silencio.

.POR QUE NUNCA COMO SERVICO
  Servico do Windows roda na Sessao 0, isolada da area de trabalho. O device
  subiria, mas as janelas que ele abrisse seriam INVISIVEIS para o usuario --
  pior que nao subir, porque pareceria funcionar. A tarefa tem de rodar na
  sessao do usuario ("executar somente quando o usuario estiver conectado").
  Consequencia aceita: depois de um reinicio, o device so sobe apos o login.

.O LOG NAO E OPCIONAL
  Sem terminal, a saida do device some. Se ele falhar ao subir, ninguem fica
  sabendo -- e e no caso extremo que se precisa saber. Processo que morre
  calado nao e dificil de diagnosticar: e impossivel.

.COMO USAR
  powershell -ExecutionPolicy Bypass -NoProfile -File .\garantir-device.ps1
  -Conferir   diz o que faria, sem subir nada
#>

[CmdletBinding(PositionalBinding = $false)]
param(
  [string] $DeviceDir  = 'C:\Software\GeoCloud\_device',
  [string] $LogDir     = 'C:\Software\GeoCloud\_device-log',
  [string] $Spawn      = 'worktree',
  [int]    $Capacidade = 11,
  [string] $Permissao  = 'acceptEdits',
  [string] $ClaudeExe  = '',
  [switch] $Conferir
)

$ErrorActionPreference = 'Stop'

function Registrar([string]$texto) {
  $linha = '{0:yyyy-MM-dd HH:mm:ss}  {1}' -f (Get-Date), $texto
  Write-Host $linha
  if (-not $Conferir) {
    try {
      if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
      Add-Content -LiteralPath (Join-Path $LogDir 'garantir-device.log') -Value $linha -Encoding UTF8
    } catch {
      # Nao deixar falha de log derrubar a garantia do device.
      Write-Warning ("nao consegui escrever o log: " + $_.Exception.Message)
    }
  }
}

# --- onde esta o claude -------------------------------------------------------
# O PATH do Agendador nao e o PATH do terminal. Resolver aqui, e dizer qual foi.
if (-not $ClaudeExe) {
  $c = Get-Command claude -ErrorAction SilentlyContinue
  if ($c) {
    $ClaudeExe = $c.Source
  } else {
    $padrao = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
    if (Test-Path -LiteralPath $padrao) { $ClaudeExe = $padrao }
  }
}
if (-not $ClaudeExe -or -not (Test-Path -LiteralPath $ClaudeExe)) {
  Registrar "ERRO: nao achei o claude.exe (PATH do Agendador difere do PATH do terminal). Use -ClaudeExe."
  exit 1
}

if (-not (Test-Path -LiteralPath $DeviceDir)) {
  Registrar "ERRO: DeviceDir nao existe: $DeviceDir"
  exit 1
}

# --- ja esta rodando? ---------------------------------------------------------
# O criterio e a LINHA DE COMANDO, nao o nome do processo: ha muitos claude.exe
# na maquina e so um deles e o device.
$vivo = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
          Where-Object { $_.CommandLine -and $_.CommandLine -match '(?<!-)remote-control' })

if ($vivo.Count -gt 0) {
  Registrar ("ok: device ja rodando (PID " + (($vivo | ForEach-Object { $_.ProcessId }) -join ', ') + ")")
  if ($vivo.Count -gt 1) {
    Registrar ("ATENCAO: " + $vivo.Count + " processos de device ao mesmo tempo -- so deveria haver um")
  }
  exit 0
}

Registrar "device ausente -- subindo"

if ($Conferir) {
  Registrar "-Conferir: nada foi subido."
  exit 0
}

# --- subir --------------------------------------------------------------------
# Sem --name, e agora com o motivo medido (14/09).
#
# O rotulo que aparece no app -- "GeoCloudAI · ops/device" -- NAO e o nome do
# device nem coisa que o --name mude. E `<repositorio> · <branch>` do diretorio
# onde o servidor sobe: `_device` aponta para Essencis-Labs/GeoCloudAI, na
# branch ops/device. Testado: subir com `--name Essencis002` nao alterou o
# rotulo em nada. O --name nomeia SESSAO, nao ambiente, e o prefixo automatico
# de sessao ja e o hostname (Essencis002).
#
# Isso confundiu de verdade: o rotulo parecia uma persona e chegou a virar uma
# entrada errada no sessoes.json. Nao e persona -- e o repositorio do device.
# Para o rotulo mudar seria preciso subir o device em OUTRO repositorio, e o
# custo e alto: as sessoes que o celular cria nascem como worktrees DESSE repo.
#
# `--no-create-session-in-dir`: o servidor nao pre-cria sessao no proprio
# diretorio.
$argumentos = @(
  'remote-control',
  '--spawn', $Spawn,
  '--capacity', "$Capacidade",
  '--permission-mode', $Permissao,
  '--no-create-session-in-dir'
)

if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
$carimbo = Get-Date -Format 'yyyyMMdd-HHmmss'
$saida   = Join-Path $LogDir "device-$carimbo.out.log"
$erro    = Join-Path $LogDir "device-$carimbo.err.log"

$p = Start-Process -FilePath $ClaudeExe `
                   -ArgumentList $argumentos `
                   -WorkingDirectory $DeviceDir `
                   -WindowStyle Hidden `
                   -RedirectStandardOutput $saida `
                   -RedirectStandardError  $erro `
                   -PassThru

Start-Sleep -Seconds 8

# Confirmar pelo estado, nao pelo fato de Start-Process ter retornado.
$conf = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
          Where-Object { $_.CommandLine -and $_.CommandLine -match '(?<!-)remote-control' })

if ($conf.Count -gt 0) {
  Registrar ("subiu: PID " + (($conf | ForEach-Object { $_.ProcessId }) -join ', ') + " | saida: $saida")
  exit 0
} else {
  $motivo = ''
  if (Test-Path -LiteralPath $erro) { $motivo = (Get-Content -LiteralPath $erro -Raw -ErrorAction SilentlyContinue) }
  if ([string]::IsNullOrWhiteSpace($motivo)) {
    $motivo = "(stderr vazio -- veja $saida; a saida pode ter ido para outro destino)"
  }
  Registrar ("FALHOU ao subir. PID tentado: " + $p.Id + " | motivo: " + $motivo.Trim())
  exit 1
}

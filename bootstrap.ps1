#Requires -Version 7
[CmdletBinding()]
param([switch]$IncludeOptional)

$ErrorActionPreference = 'Stop'
$config = Join-Path $PSScriptRoot 'config'

# 1. パッケージ
winget configure -f (Join-Path $config 'setup.core.winget')
if ($IncludeOptional) {
    winget configure -f (Join-Path $config 'setup.optional.winget')
}

# 2. Windows Terminal フラグメント
$fragDir = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\syam"
New-Item -ItemType Directory -Path $fragDir -Force | Out-Null
Copy-Item (Join-Path $config 'terminal-fragment.json') (Join-Path $fragDir 'settings.json') -Force

# 3. PowerShell プロファイル
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
$line = ". `"$(Join-Path $config 'profile.ps1')`""
if (-not (Select-String -Path $PROFILE -SimpleMatch $line -Quiet)) {
    Add-Content -Path $PROFILE -Value $line -Encoding utf8
}

Write-Host "done. reopen the terminal." -ForegroundColor Green
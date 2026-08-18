############################## encoding ##############################
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

############################## alias 衝突解除 ##############################
'gc', 'gp', 'gl' | ForEach-Object {
    Remove-Alias -Name $_ -Force -ErrorAction SilentlyContinue
}

############################## prompt ##############################
# 表示する階層数（1 = カレントのみ / 2 = 親まで）
$global:PromptDepth = 2

function prompt {
    $parts = (Get-Location).Path -split '\\' | Where-Object { $_ }
    $short = ($parts | Select-Object -Last $global:PromptDepth) -join '\'

    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    $b = if ($LASTEXITCODE -eq 0 -and $branch) { " ($branch)" } else { '' }

    Write-Host "$short$b" -ForegroundColor Cyan -NoNewline
    return ' >>>> '
}

############################## general ##############################
function wg { winget @args }
function wsl { wsl.exe -d ubuntu @args }
function docker { wsl docker @args }
function gb { & "$env:PROGRAMFILES\Git\bin\sh.exe" --login -i }
function vs { code . }
function c { cursor . }
function cc { claude @args }

# エクスプローラーを再起動する
function re { Stop-Process -Name explorer -Force }

############################## git ##############################
function gs { git status }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git pull @args }
function gll { git log --oneline --graph --decorate -10 }

############################## terraform ##############################
$env:TENV_AUTO_INSTALL = 'true'

function t { terraform @args }
function tf { terraform fmt --recursive @args }
function ti { terraform import @args }
function tin { terraform init @args }
function tss { terraform state show @args }
function tsl { terraform state list @args }
function tsrm { terraform state rm @args }
function tsmv { terraform state mv @args }
function tui { tftui @args }

function tp {
    Start-Process -FilePath terraform -ArgumentList (@('plan') + $args) -NoNewWindow -Wait
}
function ta {
    Start-Process -FilePath terraform -ArgumentList (@('apply') + $args) -NoNewWindow -Wait
}

# terraform new module (cwd based)
function tnm {
    param([Parameter(Mandatory)][string]$ModuleName)

    $moduleDir = Join-Path (Get-Location) $ModuleName
    if (Test-Path $moduleDir) {
        Write-Error "module already exists: $moduleDir"
        return
    }
    New-Item -ItemType Directory -Path $moduleDir | Out-Null
    'main.tf', 'variables.tf', 'outputs.tf' | ForEach-Object {
        New-Item -ItemType File -Path (Join-Path $moduleDir $_) | Out-Null
    }
    Write-Host "Terraform module created: $moduleDir"
}

############################## kubernetes ##############################
function k { kubectl @args }

############################## local ##############################
$local = Join-Path $PSScriptRoot 'profile.local.ps1'
if (Test-Path $local) { . $local }
# -------------------------------
# Bootstrap helpers
# -------------------------------

function Ensure-Module {
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Write-Host "Installing module: $Name" -ForegroundColor Yellow
        Install-Module $Name -Scope CurrentUser -Force -SkipPublisherCheck
    }
}

function Ensure-Command {
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# Ensure PSGallery exists
if (-not (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Default
}

# -------------------------------
# Set XDG_CONFIG_HOME for Windows
# -------------------------------

# Default to ~/.config if XDG_CONFIG_HOME not already set
if (-not $env:XDG_CONFIG_HOME) {
    $env:XDG_CONFIG_HOME = Join-Path $env:USERPROFILE ".config"
}

# Optional: ensure the directory exists
if (-not (Test-Path $env:XDG_CONFIG_HOME)) {
    New-Item -ItemType Directory -Path $env:XDG_CONFIG_HOME | Out-Null
}

# -------------------------------
# Modules
# -------------------------------

Ensure-Module PSReadLine
Ensure-Module posh-git

Import-Module PSReadLine
Import-Module posh-git

Set-PSReadLineOption -PredictionSource None

# -------------------------------
# oh-my-posh
# -------------------------------

if (-not (Ensure-Command "oh-my-posh")) {
    Write-Host "Installing oh-my-posh..." -ForegroundColor Yellow
    winget install JanDeDobbeleer.OhMyPosh -s winget
}

if (Ensure-Command "oh-my-posh") {
    oh-my-posh init pwsh `
        --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin_mocha.omp.json" |
        Invoke-Expression
}

# -------------------------------
# Git helpers
# -------------------------------

function Remove-GoneBranches {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$Force
    )

    if (-not (Ensure-Command "git")) {
        Write-Warning "git is not installed."
        return
    }

    Write-Host "Pruning remote references..." -ForegroundColor Yellow
    git remote prune origin | Out-Null

    $goneBranches = git branch -vv |
        Where-Object { $_ -match '\[.*: gone\]' } |
        ForEach-Object { ($_ -split '\s+')[1] }

    if (-not $goneBranches) {
        Write-Host "No gone branches found." -ForegroundColor Green
        return
    }

    Write-Host "Found $($goneBranches.Count) gone branch(es):" -ForegroundColor Cyan
    $goneBranches | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }

    if (-not $Force) {
        $confirmation = Read-Host "Delete these branches? (y/N)"
        if ($confirmation -notin @('y', 'Y')) {
            Write-Host "Cancelled." -ForegroundColor Yellow
            return
        }
    }

    $deleteFlag = if ($Force) { "-D" } else { "-d" }

    foreach ($branch in $goneBranches) {
        Write-Host "Deleting branch: $branch" -ForegroundColor Red
        git branch $deleteFlag $branch
    }

    Write-Host "Cleanup complete!" -ForegroundColor Green
}

Set-Alias git-rgb Remove-GoneBranches

$PSStyle.FileInfo.Directory = ""

# -------------------------------
# Chocolatey profile
# -------------------------------

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) {
    Import-Module $ChocolateyProfile
}

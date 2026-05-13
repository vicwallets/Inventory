# Auto-deploy script for STW Inventory Tracker
# Copies generated HTML files from v2 build folder into this git repo,
# then commits and pushes any changes to GitHub.
# GitHub Pages picks up the push and rebuilds the live URL.

$ErrorActionPreference = 'Continue'

$source = "C:\Users\valen\OneDrive\Documents\Claude\Inventory\Inventory Database\Inventory Tracker v2"
$repo   = "C:\Users\valen\OneDrive\Documents\Inventory Check for Woocomm\Inventory"
$log    = Join-Path $repo "deploy.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $log -Value "$ts $msg"
    Write-Host "$ts $msg"
}

# Find git.exe — not always on PowerShell's PATH on Windows
function Find-Git {
    # Try PATH first
    try {
        $v = & git --version 2>&1
        if ($LASTEXITCODE -eq 0) { return "git" }
    } catch {}

    $candidates = @(
        "C:\Program Files\Git\cmd\git.exe",
        "C:\Program Files\Git\bin\git.exe",
        "C:\Program Files (x86)\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }

    # GitHub Desktop bundled git
    $gh = Get-ChildItem "$env:LOCALAPPDATA\GitHubDesktop" -Directory -Filter "app-*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    if ($gh) {
        $c = Join-Path $gh.FullName "resources\app\git\cmd\git.exe"
        if (Test-Path $c) { return $c }
    }
    return $null
}

$git = Find-Git
if (-not $git) {
    Write-Log "ERROR: git.exe not found. Install Git for Windows or fix the path in deploy.ps1."
    exit 1
}

try {
    Write-Log "deploy start (git=$git)"

    $noPricing = Join-Path $source "Quote Tool - No Pricing.html"
    $priced    = Join-Path $source "Quote Tool.html"

    if (-not (Test-Path $noPricing)) {
        Write-Log "MISSING source: $noPricing"
        exit 1
    }
    if (-not (Test-Path $priced)) {
        Write-Log "MISSING source: $priced"
        exit 1
    }

    $npSize = (Get-Item $noPricing).Length
    $pSize  = (Get-Item $priced).Length
    Write-Log "sources: no-pricing=$npSize bytes, priced=$pSize bytes"

    Copy-Item -Path $noPricing -Destination (Join-Path $repo "index.html") -Force
    Copy-Item -Path $priced    -Destination (Join-Path $repo "quote.html") -Force
    Write-Log "copied to repo folder"

    Set-Location $repo

    # Pull any remote changes first
    & $git fetch origin 2>&1 | Out-Null
    & $git pull --ff-only origin main 2>&1 | Out-Null
    Write-Log "fetch+pull done"

    & $git add index.html quote.html 2>&1 | Out-Null
    $status = & $git status --porcelain

    if ($status) {
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        & $git commit -m "auto-deploy: $ts" 2>&1 | Out-Null
        $pushOut = & $git push origin main 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "PUSHED ok"
        } else {
            Write-Log "PUSH FAILED exit=$LASTEXITCODE output=$pushOut"
        }
    } else {
        Write-Log "no changes to commit"
    }

    Write-Log "deploy end"
} catch {
    Write-Log "ERROR: $_"
    exit 1
}

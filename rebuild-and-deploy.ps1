# Daily pipeline: rebuild Quote Tool HTMLs from xlsx, copy to repo, push to GitHub.
# Designed to run unattended via Windows Task Scheduler at 10:00 AM.

$ErrorActionPreference = 'Continue'

$builder = "C:\Users\valen\OneDrive\Documents\Claude\Inventory\Inventory Database\Inventory Tracker v2"
$repo    = "C:\Users\valen\OneDrive\Documents\Inventory Check for Woocomm\Inventory"
$log     = Join-Path $repo "deploy.log"

function Write-Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $log -Value "$ts $msg"
    Write-Host "$ts $msg"
}

try {
    Write-Log "=== pipeline start ==="

    # --- Step 1: run the Python build ---
    $buildScript = Join-Path $builder "build_quote_tool_v7.py"
    if (-not (Test-Path $buildScript)) {
        Write-Log "ERROR: build script not found at $buildScript"
        exit 1
    }

    Write-Log "running build_quote_tool_v7.py..."
    Push-Location $builder
    $buildOut = & py "build_quote_tool_v7.py" 2>&1
    $buildExit = $LASTEXITCODE
    Pop-Location

    if ($buildExit -ne 0) {
        Write-Log "BUILD FAILED exit=$buildExit"
        $buildOut | ForEach-Object { Write-Log "  $_" }
        exit 1
    }
    Write-Log "build ok"

    # --- Step 2: copy outputs to repo with proper names ---
    $noPricing = Join-Path $builder "Quote Tool - No Pricing.html"
    $priced    = Join-Path $builder "Quote Tool.html"

    if (-not (Test-Path $noPricing)) { Write-Log "ERROR: missing $noPricing"; exit 1 }
    if (-not (Test-Path $priced))    { Write-Log "ERROR: missing $priced"; exit 1 }

    $npSize = (Get-Item $noPricing).Length
    $pSize  = (Get-Item $priced).Length
    Write-Log "no-pricing: $npSize bytes | priced: $pSize bytes"

    Copy-Item -Path $noPricing -Destination (Join-Path $repo "index.html") -Force
    Copy-Item -Path $priced    -Destination (Join-Path $repo "quote.html") -Force
    Write-Log "copied to repo"

    # --- Step 3: git add, commit, push ---
    Set-Location $repo

    # Clean up any stale locks from previous interrupted runs
    Get-ChildItem ".git" -Filter "*.lock" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    & git fetch origin 2>&1 | Out-Null
    & git pull --ff-only origin main 2>&1 | Out-Null

    & git add index.html quote.html 2>&1 | Out-Null
    $status = & git status --porcelain

    if ($status) {
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        & git commit -m "auto-deploy: $ts" 2>&1 | Out-Null
        $pushOut = & git push origin main 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "PUSHED ok"
        } else {
            Write-Log "PUSH FAILED exit=$LASTEXITCODE"
            $pushOut | ForEach-Object { Write-Log "  $_" }
            exit 1
        }
    } else {
        Write-Log "no changes to commit"
    }

    Write-Log "=== pipeline end ==="
} catch {
    Write-Log "EXCEPTION: $_"
    exit 1
}

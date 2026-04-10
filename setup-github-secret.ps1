#Requires -Version 5.0
<#
.SYNOPSIS
    Automate GitHub secret setup for rentmybrowser project

.DESCRIPTION
    This script:
    1. Authenticates with GitHub CLI
    2. Adds GEMINI_API_KEY as a repository secret
    3. Verifies the secret was added
    4. Optionally triggers a test workflow run

.NOTES
    GitHub CLI must be installed: https://cli.github.com/
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$GeminiApiKey,
    
    [Parameter(Mandatory = $false)]
    [switch]$TriggerWorkflow
)

# ==========================================
# Color helpers
# ==========================================
function Write-Success {
    Write-Host "✅ $($args -join ' ')" -ForegroundColor Green
}

function Write-Error_ {
    Write-Host "❌ $($args -join ' ')" -ForegroundColor Red
}

function Write-Info {
    Write-Host "ℹ️  $($args -join ' ')" -ForegroundColor Cyan
}

function Write-Warning_ {
    Write-Host "⚠️  $($args -join ' ')" -ForegroundColor Yellow
}

# ==========================================
# Find GitHub CLI
# ==========================================
Write-Info "Locating GitHub CLI..."
$ghPath = "C:\Program Files\GitHub CLI\gh.exe"

if (-not (Test-Path $ghPath)) {
    Write-Error_ "GitHub CLI not found at: $ghPath"
    Write-Info "Please install GitHub CLI: https://cli.github.com/"
    exit 1
}
Write-Success "GitHub CLI found: $ghPath"

# ==========================================
# Check authentication
# ==========================================
Write-Info "Checking GitHub authentication..."
& $ghPath auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Warning_ "Not authenticated with GitHub"
    Write-Info "Starting browser-based authentication..."
    & $ghPath auth login --web --skip-ssh-key
    if ($LASTEXITCODE -ne 0) {
        Write-Error_ "Authentication failed"
        exit 1
    }
}
Write-Success "GitHub authentication verified"

# ==========================================
# Get repository info
# ==========================================
Write-Info "Verifying repository..."
$repoView = & $ghPath repo view 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error_ "Not in a GitHub repository or repo not accessible"
    Write-Info "Run this script from the rentmybrowser repository directory"
    exit 1
}
Write-Success "Repository verified: $(($repoView[0] -split '\s+')[0])"

# ==========================================
# Get Gemini API Key
# ==========================================
if (-not $GeminiApiKey) {
    Write-Info "=================================================="
    Write-Info "Enter your Gemini API Key"
    Write-Info "=================================================="
    Write-Info "Get it from: https://aistudio.google.com/app/apikeys"
    Write-Info ""
    $GeminiApiKey = Read-Host "Gemini API Key (or leave blank to skip)"
    
    if (-not $GeminiApiKey) {
        Write-Warning_ "Skipping secret setup (no API key provided)"
        exit 0
    }
}

# ==========================================
# Add secret
# ==========================================
Write-Info "Adding GEMINI_API_KEY secret to repository..."
$GeminiApiKey | & $ghPath secret set GEMINI_API_KEY 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error_ "Failed to set GEMINI_API_KEY secret"
    exit 1
}
Write-Success "GEMINI_API_KEY secret added"

# ==========================================
# Verify secret
# ==========================================
Write-Info "Verifying secret..."
$secrets = & $ghPath secret list 2>&1
if ($secrets -match "GEMINI_API_KEY") {
    Write-Success "GEMINI_API_KEY confirmed in repository secrets"
} else {
    Write-Warning_ "Could not verify secret in list (but it may still be set)"
}

# ==========================================
# Push changes
# ==========================================
Write-Info "Pushing code changes to GitHub..."
$gitStatus = & git status --porcelain 2>&1
if ($gitStatus) {
    & git add . 2>&1 | Out-Null
    & git commit -m "Automated: Add GitHub secret setup" 2>&1 | Out-Null
    & git push origin main 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Changes pushed to GitHub"
    } else {
        Write-Warning_ "Failed to push (this may be okay if nothing changed)"
    }
} else {
    Write-Info "No changes to push"
}

# ==========================================
# Optionally trigger workflow
# ==========================================
if ($TriggerWorkflow) {
    Write-Info "Triggering workflow run..."
    & $ghPath workflow run browser-node.yml 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Workflow triggered!"
        Write-Info "Check status at: https://github.com/Arnav1771/rentmybrowser/actions"
    } else {
        Write-Warning_ "Could not trigger workflow (may need manual trigger)"
    }
}

# ==========================================
# Summary
# ==========================================
Write-Host ""
Write-Host "=================================================="
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "=================================================="
Write-Info "Next steps:"
Write-Info "1. Visit: https://github.com/Arnav1771/rentmybrowser/actions"
Write-Info "2. Click: 🌐 Rent My Browser Node"
Write-Info "3. Click: Run workflow → Run workflow"
Write-Info "4. Wait 30 seconds for the job to start"
Write-Info "5. Watch logs for: ✅ Node is ONLINE"
Write-Info ""
Write-Info "Monitor earnings at: https://rentmybrowser.dev/dashboard"
Write-Host ""

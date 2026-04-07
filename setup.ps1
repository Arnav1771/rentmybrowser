param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$COLOR_SUCCESS = 'Green'
$COLOR_WARNING = 'Yellow'
$COLOR_ERROR = 'Red'
$COLOR_INFO = 'Cyan'

function Write-Header {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "  RentMyBrowser + GitHub Actions Setup" -ForegroundColor Cyan
    Write-Host "  Earn money from your idle browser" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Write-Host "Choose an option:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Show Setup Guide (open SETUP_GUIDE.md)"
    Write-Host "  [2] Get Gemini API Key (opens browser)"
    Write-Host "  [3] Check Prerequisites (gh, git, node)"
    Write-Host "  [4] Create GitHub Repository"
    Write-Host "  [5] Add GEMINI_API_KEY Secret"
    Write-Host "  [6] Trigger Workflow (start earning!)"
    Write-Host "  [7] Check Workflow Status"
    Write-Host "  [8] View Logs"
    Write-Host "  [9] Set Repository URL (if needed)"
    Write-Host "  [0] Exit"
    Write-Host ""
}

function Check-Prerequisites {
    Write-Header
    Write-Host "Checking prerequisites..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $missing = @()
    
    # Check gh
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        $gh_version = gh --version
        Write-Host "OK - GitHub CLI: $gh_version" -ForegroundColor $COLOR_SUCCESS
    } else {
        Write-Host "MISSING - GitHub CLI (gh)" -ForegroundColor $COLOR_ERROR
        $missing += "GitHub CLI (gh)"
    }
    
    # Check git
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $git_version = git --version
        Write-Host "OK - Git: $git_version" -ForegroundColor $COLOR_SUCCESS
    } else {
        Write-Host "MISSING - Git" -ForegroundColor $COLOR_ERROR
        $missing += "Git"
    }
    
    # Check GitHub auth
    if (gh auth status 2>$null) {
        Write-Host "OK - GitHub Authentication: Logged in" -ForegroundColor $COLOR_SUCCESS
    } else {
        Write-Host "NEEDS SETUP - GitHub Authentication: Not authenticated" -ForegroundColor $COLOR_WARNING
        $missing += "GitHub CLI authentication"
    }
    
    # Check Node.js
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $node_version = node --version
        Write-Host "OK - Node.js: $node_version" -ForegroundColor $COLOR_SUCCESS
    } else {
        Write-Host "OPTIONAL - Node.js: Not found (but recommended)" -ForegroundColor $COLOR_WARNING
    }
    
    Write-Host ""
    if ($missing.Count -gt 0) {
        Write-Host "Missing prerequisites:" -ForegroundColor $COLOR_ERROR
        foreach ($item in $missing) {
            Write-Host "  - $item" -ForegroundColor $COLOR_ERROR
        }
        Write-Host ""
        Write-Host "To install:" -ForegroundColor $COLOR_INFO
        Write-Host "  - GitHub CLI: https://cli.github.com/" -ForegroundColor $COLOR_INFO
        Write-Host "  - Git: https://git-scm.com/" -ForegroundColor $COLOR_INFO
        Write-Host ""
    } else {
        Write-Host "All prerequisites met!" -ForegroundColor $COLOR_SUCCESS
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Get-GeminiKey {
    Write-Header
    Write-Host "Getting your Gemini API Key..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "A browser will open to aistudio.google.com" -ForegroundColor $COLOR_WARNING
    Write-Host ""
    Write-Host "Steps:" -ForegroundColor $COLOR_INFO
    Write-Host "  1. Click 'Create API Key'" -ForegroundColor $COLOR_INFO
    Write-Host "  2. Select 'Create API key in new project'" -ForegroundColor $COLOR_INFO
    Write-Host "  3. Copy the API key" -ForegroundColor $COLOR_INFO
    Write-Host "  4. Save it somewhere safe (you will need it next)" -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    Read-Host "Press Enter when ready (will open browser)"
    
    Start-Process "https://aistudio.google.com/app/apikeys"
    
    Write-Host ""
    Write-Host "Browser opened. Copy your API key when ready." -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    Read-Host "Press Enter after copying your API key"
}

function Show-Setup-Guide {
    Write-Header
    Write-Host "Opening SETUP_GUIDE.md..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $guide_path = Join-Path (Get-Location) "SETUP_GUIDE.md"
    if (Test-Path $guide_path) {
        Start-Process "notepad.exe" $guide_path
    } else {
        Write-Host "ERROR - SETUP_GUIDE.md not found" -ForegroundColor $COLOR_ERROR
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Create-Repository {
    Write-Header
    Write-Host "Creating GitHub Repository..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $user = gh api user -q '.login' 2>$null
    if (-not $user) {
        Write-Host "ERROR - Not authenticated with GitHub CLI" -ForegroundColor $COLOR_ERROR
        Write-Host "Run: gh auth login" -ForegroundColor $COLOR_WARNING
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Logged in as: $user" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    
    Write-Host "Repository will be:" -ForegroundColor $COLOR_INFO
    Write-Host "  https://github.com/$user/rentmybrowser-node" -ForegroundColor $COLOR_INFO
    Write-Host ""
    $confirm = Read-Host "Create private repository? (y/n)"
    
    if ($confirm -ne 'y' -and $confirm -ne 'yes') {
        Write-Host "Cancelled." -ForegroundColor $COLOR_WARNING
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host ""
    Write-Host "Creating repository..." -ForegroundColor $COLOR_INFO
    
    # Initialize git if not already done
    if (-not (Test-Path ".git")) {
        git init
        git add .
        git commit -m "Initial commit: RentMyBrowser node setup"
        git branch -M main
    }
    
    # Create and push
    gh repo create rentmybrowser-node --private --source=. --remote=origin --push
    
    Write-Host ""
    Write-Host "Repository created!" -ForegroundColor $COLOR_SUCCESS
    Write-Host "   https://github.com/$user/rentmybrowser-node" -ForegroundColor $COLOR_SUCCESS
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Add-Secret {
    Write-Header
    Write-Host "Adding GEMINI_API_KEY Secret..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $repo = gh repo view --json nameWithOwner -q '.nameWithOwner' 2>$null
    if (-not $repo) {
        Write-Host "ERROR - Cannot determine repository" -ForegroundColor $COLOR_ERROR
        Write-Host "Make sure you are in the rentmybrowser directory" -ForegroundColor $COLOR_WARNING
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Repository: $repo" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    
    $apiKey = Read-Host -AsSecureString "Enter your Gemini API Key"
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($apiKey)
    $apiKeyPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($bstr)
    
    if (-not $apiKeyPlain) {
        Write-Host "ERROR - API Key cannot be empty" -ForegroundColor $COLOR_ERROR
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host ""
    Write-Host "Adding secret..." -ForegroundColor $COLOR_INFO
    
    $apiKeyPlain | gh secret set GEMINI_API_KEY -R $repo
    
    Write-Host ""
    Write-Host "Secret added successfully!" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    
    $secrets = gh secret list -R $repo
    Write-Host "Visible secrets:" -ForegroundColor $COLOR_INFO
    Write-Host $secrets
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Trigger-Workflow {
    Write-Header
    Write-Host "Triggering Browser Node Workflow..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $repo = gh repo view --json nameWithOwner -q '.nameWithOwner' 2>$null
    if (-not $repo) {
        Write-Host "ERROR - Cannot determine repository" -ForegroundColor $COLOR_ERROR
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Repository: $repo" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    Write-Host "Starting workflow..." -ForegroundColor $COLOR_INFO
    
    gh workflow run browser-node.yml -R $repo
    
    Write-Host ""
    Write-Host "Workflow triggered!" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    Write-Host "Your node will start in about 30 seconds." -ForegroundColor $COLOR_INFO
    Write-Host "Monitor progress:" -ForegroundColor $COLOR_INFO
    Write-Host "  - GitHub: https://github.com/$repo/actions" -ForegroundColor $COLOR_INFO
    Write-Host "  - RentMyBrowser: https://rentmybrowser.dev/dashboard" -ForegroundColor $COLOR_INFO
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Check-Status {
    Write-Header
    Write-Host "Checking Workflow Status..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $repo = gh repo view --json nameWithOwner -q '.nameWithOwner' 2>$null
    if (-not $repo) {
        Write-Host "ERROR - Cannot determine repository" -ForegroundColor $COLOR_ERROR
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Recent workflow runs:" -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    gh run list -R $repo --limit 5
    
    Write-Host ""
    Write-Host "Full dashboard: https://github.com/$repo/actions" -ForegroundColor $COLOR_INFO
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function View-Logs {
    Write-Header
    Write-Host "Viewing Workflow Logs..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $repo = gh repo view --json nameWithOwner -q '.nameWithOwner' 2>$null
    if (-not $repo) {
        Write-Host "ERROR - Cannot determine repository" -ForegroundColor $COLOR_ERROR
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Fetching latest run..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    $latestRun = gh run list -R $repo --limit 1 --json number -q '.[0].number' 2>$null
    
    if (-not $latestRun) {
        Write-Host "ERROR - No workflow runs found" -ForegroundColor $COLOR_ERROR
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Latest run (Run #$latestRun):" -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    gh run view $latestRun -R $repo --log
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Set-RepoUrl {
    Write-Header
    Write-Host "Setting Repository URL..." -ForegroundColor $COLOR_INFO
    Write-Host ""
    
    Write-Host "Current remote:" -ForegroundColor $COLOR_INFO
    git remote -v
    
    Write-Host ""
    $repoUrl = Read-Host "Enter new repository URL (e.g., https://github.com/user/repo.git)"
    
    if (-not $repoUrl) {
        Write-Host "ERROR - URL cannot be empty" -ForegroundColor $COLOR_ERROR
        Write-Host ""
        Read-Host "Press Enter to continue"
        return
    }
    
    git remote set-url origin $repoUrl
    Write-Host ""
    Write-Host "Remote URL updated!" -ForegroundColor $COLOR_SUCCESS
    Write-Host ""
    Write-Host "Updated remote:" -ForegroundColor $COLOR_INFO
    git remote -v
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Main loop
while ($true) {
    Write-Header
    Show-Menu
    
    $choice = Read-Host "Enter choice"
    
    switch ($choice) {
        "1" { Show-Setup-Guide }
        "2" { Get-GeminiKey }
        "3" { Check-Prerequisites }
        "4" { Create-Repository }
        "5" { Add-Secret }
        "6" { Trigger-Workflow }
        "7" { Check-Status }
        "8" { View-Logs }
        "9" { Set-RepoUrl }
        "0" { 
            Write-Host ""
            Write-Host "Goodbye! Happy earning!" -ForegroundColor $COLOR_SUCCESS
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "Invalid choice. Try again." -ForegroundColor $COLOR_ERROR
            Read-Host "Press Enter to continue"
        }
    }
}

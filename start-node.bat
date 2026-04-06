@echo off
setlocal EnableDelayedExpansion
title Rent My Browser - Node Manager
color 0A

echo ============================================
echo   Rent My Browser - Node Manager
echo   Controls your GitHub Actions browser node
echo ============================================
echo.

:MENU
echo Choose an option:
echo.
echo   [1] Initial setup (git init + push to GitHub)
echo   [2] Push updates to GitHub
echo   [3] Open GitHub Actions (check status)
echo   [4] Trigger workflow manually (via gh CLI)
echo   [5] View workflow logs (via gh CLI)
echo   [6] Stop the workflow (via gh CLI)
echo   [7] Setup: Add Gemini API key
echo   [8] Troubleshoot workflow errors (Invalid slug)
echo   [9] OpenClaw Information & Troubleshooting
echo   [10] Exit
echo.
set /p choice="Enter choice (1-10): "

if "%choice%"=="1" goto INIT
if "%choice%"=="2" goto PUSH
if "%choice%"=="3" goto OPEN_ACTIONS
if "%choice%"=="4" goto TRIGGER
if "%choice%"=="5" goto LOGS
if "%choice%"=="6" goto STOP
if "%choice%"=="7" goto SETUP_SECRET
if "%choice%"=="8" goto TROUBLESHOOT_SLUG
if "%choice%"=="9" goto OPENCLAW_INFO
if "%choice%"=="10" goto EXIT

echo Invalid choice. Try again.
echo.
goto MENU

:INIT
echo.
cd /d "%~dp0"
if exist ".git" (
    echo Git repo already initialized.
    echo.
    git remote -v
    echo.
    echo If you need to change the remote, run:
    echo   git remote set-url origin https://github.com/YOUR_USER/YOUR_REPO.git
    echo.
    pause
    goto MENU
)
echo Initializing git repo...
git init
git branch -M main
echo.
set /p REPO_URL="Enter your GitHub repo URL (e.g. https://github.com/user/rentmybrowser.git): "
if "%REPO_URL%"=="" (
    echo No URL provided. Skipping remote setup.
    pause
    goto MENU
)
git remote add origin "%REPO_URL%"
echo.
echo Adding files and pushing...
git add .
git commit -m "Initial commit: browser node setup"
git push -u origin main
echo.
if %errorlevel% neq 0 (
    echo Push failed. Make sure the repo exists on GitHub and you are authenticated.
) else (
    echo Done! Now go to your repo's Actions tab to start the workflow.
)
echo.
pause
goto MENU

:PUSH
echo.
cd /d "%~dp0"
if not exist ".git" (
    echo Not a git repository. Please run option [1] first.
    pause
    goto MENU
)
echo Pushing updates to GitHub...
git add .
git commit -m "Update browser node files"
git push
echo.
if %errorlevel% neq 0 (
    echo Push failed. Check your git status and authentication.
) else (
    echo Updates pushed successfully.
)
echo.
pause
goto MENU

:OPEN_ACTIONS
echo.
echo Opening GitHub Actions in your browser...
start "" "https://github.com/%USERNAME%/%REPO_NAME%/actions"
echo (Replace %USERNAME%/%REPO_NAME% with your actual repo path if needed)
echo.
pause
goto MENU

:TRIGGER
echo.
echo Triggering workflow manually via gh CLI...
echo (Requires GitHub CLI 'gh' to be installed and authenticated)
gh workflow run main.yml
echo.
if %errorlevel% neq 0 (
    echo Failed to trigger workflow. Ensure 'gh' CLI is installed, authenticated,
    echo and 'main.yml' is the correct workflow file name.
) else (
    echo Workflow triggered. Use option [5] to view logs.
)
echo.
pause
goto MENU

:LOGS
echo.
echo Viewing workflow logs via gh CLI...
echo (Requires GitHub CLI 'gh' to be installed and authenticated)
gh run list --workflow main.yml --limit 1
echo.
set /p run_id="Enter the run ID to view logs (e.g., 1234567890): "
if "%run_id%"=="" (
    echo No run ID provided.
) else (
    gh run view %run_id% --log
)
echo.
if %errorlevel% neq 0 (
    echo Failed to view logs. Ensure 'gh' CLI is installed, authenticated,
    echo and the run ID is correct.
)
echo.
pause
goto MENU

:STOP
echo.
echo Stopping the last workflow run via gh CLI...
echo (Requires GitHub CLI 'gh' to be installed and authenticated)
gh run list --workflow main.yml --limit 1
echo.
set /p run_id="Enter the run ID to stop (e.g., 1234567890): "
if "%run_id%"=="" (
    echo No run ID provided.
) else (
    gh run cancel %run_id%
)
echo.
if %errorlevel% neq 0 (
    echo Failed to stop workflow. Ensure 'gh' CLI is installed, authenticated,
    echo and the run ID is correct.
) else (
    echo Workflow run %run_id% cancelled.
)
echo.
pause
goto MENU

:SETUP_SECRET
echo.
echo ============================================
echo   Setup: Add Gemini API Key
echo ============================================
echo.
echo This option helps you add your Gemini API key as a GitHub secret.
echo This secret will be used by your GitHub Actions workflow.
echo.
echo 1. Go to your GitHub repository settings:
echo    https://github.com/YOUR_USER/YOUR_REPO/settings/secrets/actions
echo    (Replace YOUR_USER/YOUR_REPO with your actual repository path)
echo.
echo 2. Click "New repository secret".
echo.
echo 3. For "Name", enter: GEMINI_API_KEY
echo.
echo 4. For "Value", paste your Gemini API key.
echo    You can get your key from: https://ai.google.dev/
echo.
echo 5. Click "Add secret".
echo.
echo Your workflow will now have access to the GEMINI_API_KEY.
echo.
pause
goto MENU

:TROUBLESHOOT_SLUG
echo.
echo ============================================
echo   Troubleshoot Workflow Errors (Invalid slug)
echo ============================================
echo.
echo If your workflow is failing with an "Invalid slug" error,
echo it often means the `gh` CLI cannot determine your repository context.
echo.
echo This can happen if:
echo 1. You haven't initialized a git repository in this directory (run option [1]).
echo 2. Your git remote 'origin' is not set to a GitHub repository.
echo    Check with: `git remote -v`
echo    Set it with: `git remote set-url origin https://github.com/YOUR_USER/YOUR_REPO.git`
echo 3. You are not authenticated with the `gh` CLI.
echo    Run: `gh auth login`
echo.
echo Ensure your local git repository is correctly linked to your GitHub repo.
echo.
pause
goto MENU

:OPENCLAW_INFO
echo.
echo ============================================
echo   OpenClaw Information & Troubleshooting
echo ============================================
echo.
echo It appears OpenClaw is a component or dependency for your setup.
echo The provided log indicates OpenClaw was installed successfully on Linux,
echo but a subsequent process failed with "Error: Process completed with exit code 1."
echo and "main: line 2598: /dev/tty: No such device or address".
echo.
echo This often happens in non-interactive CI/CD environments.
echo.
echo If you need to manually install OpenClaw on a Linux environment (e.g., SSH into a runner):
echo   curl -fsSL https://openclaw.ai/install.sh | bash
echo.
echo To troubleshoot issues related to OpenClaw in your GitHub Actions workflow:
echo 1. Check your workflow YAML file for OpenClaw installation steps.
echo 2. Use option [5] "View workflow logs" to inspect recent runs for OpenClaw-related errors.
echo 3. Ensure your workflow environment is compatible with OpenClaw's requirements.
echo 4. The error "/dev/tty: No such device or address" suggests an interactive prompt
echo    or TTY access was expected but not available in the CI environment.
echo    Check OpenClaw's documentation for non-interactive installation/usage.
echo.
pause
goto MENU

:EXIT
echo Exiting Node Manager.
endlocal
exit /b
```
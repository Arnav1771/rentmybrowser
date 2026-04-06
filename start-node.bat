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
    echo Initial push successful!
)
pause
goto MENU

:PUSH
echo.
cd /d "%~dp0"
echo Pushing updates to GitHub...
git add .
git commit -m "Update browser node"
git push
if %errorlevel% neq 0 (
    echo Push failed.
) else (
    echo Push successful!
)
pause
goto MENU

:OPEN_ACTIONS
echo.
echo Opening GitHub Actions...
rem Attempt to parse repo URL from git remote, or prompt if not found.
for /f "tokens=2 delims= " %%a in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%a"
if defined REMOTE_URL (
    echo Opening actions for %REMOTE_URL%
    start "" "%REMOTE_URL%/actions"
) else (
    set /p REPO_URL_PROMPT="Enter your GitHub repo URL (e.g., https://github.com/user/repo): "
    if not "%REPO_URL_PROMPT%"=="" (
        start "" "%REPO_URL_PROMPT%/actions"
    ) else (
        echo No URL provided. Cannot open GitHub Actions.
    )
)
pause
goto MENU

:TRIGGER
echo.
echo Triggering workflow manually via gh CLI...
echo Make sure you are logged in to gh CLI: gh auth login
gh workflow run main.yml
if %errorlevel% neq 0 (
    echo Failed to trigger workflow. Is gh CLI installed and authenticated?
) else (
    echo Workflow triggered.
)
pause
goto MENU

:LOGS
echo.
echo Viewing workflow logs via gh CLI...
echo Fetching latest workflow run...
for /f "tokens=*" %%i in ('gh run list --workflow main.yml --limit 1 --json databaseId -q ".[0].databaseId" 2^>nul') do set "RUN_ID=%%i"
if not "%RUN_ID%"=="" (
    echo Showing logs for run ID: %RUN_ID%
    gh run view %RUN_ID% --log
) else (
    echo No recent workflow runs found for main.yml.
)
pause
goto MENU

:STOP
echo.
echo Stopping the latest workflow run via gh CLI...
echo Fetching latest workflow run...
for /f "tokens=*" %%i in ('gh run list --workflow main.yml --limit 1 --json databaseId -q ".[0].databaseId" 2^>nul') do set "RUN_ID=%%i"
if not "%RUN_ID%"=="" (
    echo Stopping run ID: %RUN_ID%
    gh run cancel %RUN_ID%
    if %errorlevel% neq 0 (
        echo Failed to stop workflow run.
    ) else (
        echo Workflow run cancelled.
    )
) else (
    echo No recent workflow runs found for main.yml to stop.
)
pause
goto MENU

:SETUP_SECRET
echo.
echo Setting up Gemini API key...
echo This will add your Gemini API key as a GitHub secret.
echo Make sure you are logged in to gh CLI: gh auth login
set /p GEMINI_API_KEY="Enter your Gemini API Key: "
if "%GEMINI_API_KEY%"=="" (
    echo No API key provided. Skipping secret setup.
    pause
    goto MENU
)
gh secret set GEMINI_API_KEY --body "%GEMINI_API_KEY%"
if %errorlevel% neq 0 (
    echo Failed to set GitHub secret.
) else (
    echo Gemini API Key set as GitHub secret 'GEMINI_API_KEY'.
)
pause
goto MENU

:TROUBLESHOOT_SLUG
echo.
echo Troubleshooting workflow errors (Invalid slug)...
echo This usually means an OpenClaw skill or tool is not correctly installed or recognized.
echo Attempting to install 'rent-my-browser' skill for the default agent 'main'.
echo.
echo 📥 Installing rent-my-browser skill...
rem FIX: Changed 'openclaw install' to 'openclaw agent skill add main'
openclaw agent skill add main rent-my-browser
if %errorlevel% neq 0 (
    echo ❌ Failed to install rent-my-browser skill. Please check the slug or try again.
    echo Ensure OpenClaw is installed and configured, and 'main' is your agent name.
) else (
    echo ✅ Successfully installed rent-my-browser skill.
)
echo.
pause
goto MENU

:OPENCLAW_INFO
echo.
echo OpenClaw Information & Troubleshooting
echo -------------------------------------
echo.
echo Checking OpenClaw installation:
openclaw --version
if %errorlevel% neq 0 (
    echo ❌ OpenClaw command not found. Please install OpenClaw.
    echo Docs: https://docs.openclaw.ai/
) else (
    echo ✅ OpenClaw is installed.
)
echo.
echo Listing OpenClaw agents:
openclaw agent list
echo.
echo Listing skills for agent 'main':
openclaw agent skill list main
echo.
echo Checking Node.js version (OpenClaw recommends Node 22+):
node --version
echo.
pause
goto MENU

:EXIT
echo.
echo Exiting Node Manager. Goodbye!
echo.
exit /b
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
echo   [8] Exit
echo.
set /p choice="Enter choice (1-8): "

if "%choice%"=="1" goto INIT
if "%choice%"=="2" goto PUSH
if "%choice%"=="3" goto OPEN_ACTIONS
if "%choice%"=="4" goto TRIGGER
if "%choice%"=="5" goto LOGS
if "%choice%"=="6" goto STOP
if "%choice%"=="7" goto SETUP_SECRET
if "%choice%"=="8" goto EXIT

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
    echo Error: Git not initialized. Use option [1] first.
    echo.
    pause
    goto MENU
)
echo Pushing updates to GitHub...
git add .
git commit -m "Update browser node config"
if %errorlevel% neq 0 (
    echo Nothing new to commit.
)
git push
echo.
pause
goto MENU

:OPEN_ACTIONS
echo.
cd /d "%~dp0"
if not exist ".git" (
    echo Error: Git not initialized. Use option [1] first.
    echo.
    pause
    goto MENU
)
REM Get remote URL and convert to Actions page URL
for /f "usebackq tokens=*" %%a in (`git remote get-url origin 2^>nul`) do set "RAW_URL=%%a"
if not defined RAW_URL (
    echo Could not detect remote URL. Use option [1] to set it up.
    echo.
    pause
    goto MENU
)
REM Clean up URL: remove .git suffix and convert SSH to HTTPS
set "ACTIONS_URL=!RAW_URL!"
set "ACTIONS_URL=!ACTIONS_URL:.git=!"
set "ACTIONS_URL=!ACTIONS_URL:git@github.com:=https://github.com/!"
set "ACTIONS_URL=!ACTIONS_URL!/actions"
echo Opening: !ACTIONS_URL!
start "" "!ACTIONS_URL!"
echo.
pause
goto MENU

:TRIGGER
echo.
cd /d "%~dp0"
echo Triggering workflow manually...
gh workflow run browser-node.yml
if %errorlevel% neq 0 (
    echo.
    echo Failed. Make sure GitHub CLI (gh) is installed and authenticated.
    echo Install: https://cli.github.com/
)
echo.
pause
goto MENU

:LOGS
echo.
cd /d "%~dp0"
echo Fetching latest workflow runs...
echo.
gh run list --workflow=browser-node.yml --limit 5
echo.
echo To view full logs of a specific run, use:
echo   gh run view [RUN_ID] --log
echo.
pause
goto MENU

:STOP
echo.
cd /d "%~dp0"
echo Cancelling the latest running workflow...
for /f "usebackq" %%r in (`gh run list --workflow=browser-node.yml --status=in_progress --limit 1 --json databaseId -q ".[0].databaseId" 2^>nul`) do (
    echo Cancelling run %%r...
    gh run cancel %%r
    echo Cancelled run %%r
)
if %errorlevel% neq 0 (
    echo No running workflows found, or gh CLI not installed.
)
echo.
pause
goto MENU

:SETUP_SECRET
echo.
cd /d "%~dp0"
echo ============================================
echo   Gemini API Key Setup
echo   (stored as GitHub Secret)
echo ============================================
echo.
echo The same key is used across all Gemini models.
echo Failover rotates: 2.5-flash, 2.0-flash, 1.5-flash, 1.5-pro
echo.
set /p gemkey="Paste your Gemini API key: "
if "!gemkey!"=="" (
    echo No key provided. Cancelled.
    echo.
    pause
    goto MENU
)
gh secret set GEMINI_API_KEY --body "!gemkey!"
if !errorlevel! equ 0 (
    echo.
    echo Gemini key saved successfully!
) else (
    echo.
    echo Failed. Make sure GitHub CLI (gh) is installed and authenticated.
    echo Install: https://cli.github.com/
)
echo.
pause
goto MENU

:EXIT
echo.
echo Goodbye! Your node keeps running on GitHub Actions.
endlocal
exit /b 0

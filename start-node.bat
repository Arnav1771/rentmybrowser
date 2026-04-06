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
echo   [9] Exit
echo.
set /p choice="Enter choice (1-9): "

if "%choice%"=="1" goto INIT
if "%choice%"=="2" goto PUSH
if "%choice%"=="3" goto OPEN_ACTIONS
if "%choice%"=="4" goto TRIGGER
if "%choice%"=="5" goto LOGS
if "%choice%"=="6" goto STOP
if "%choice%"=="7" goto SETUP_SECRET
if "%choice%"=="8" goto TROUBLESHOOT_SLUG
if "%choice%"=="9" goto EXIT

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
    echo Error: Git not initialized. Use option 1 to initialize it.
    pause
    goto MENU
)
echo Adding all changes and pushing to GitHub...
git add .
git commit -m "Update browser node files"
git push
echo.
if %errorlevel% neq 0 (
    echo Push failed. Check your git status and remote.
) else (
    echo Done! Changes pushed.
)
echo.
pause
goto MENU

:OPEN_ACTIONS
echo.
cd /d "%~dp0"
if not exist ".git" (
    echo Error: Git not initialized. Use option 1 to initialize it.
    pause
    goto MENU
)
for /f "tokens=2" %%i in ('git remote get-url origin') do set "REPO_URL=%%i"
if not defined REPO_URL (
    echo Could not determine GitHub repository URL.
    echo Please ensure 'git remote add origin' has been run.
    pause
    goto MENU
)
start "" "%REPO_URL%/actions"
echo Opening GitHub Actions in your browser...
echo.
pause
goto MENU

:TRIGGER
echo.
cd /d "%~dp0"
if not exist ".git" (
    echo Error: Git not initialized. Use option 1 to initialize it.
    pause
    goto MENU
)
echo Triggering workflow manually...
echo.
gh workflow run main.yml
echo.
if %errorlevel% neq 0 (
    echo Failed to trigger workflow. Make sure you are logged in to gh CLI (gh auth login).
) else (
    echo Workflow triggered. Use option 3 or 5 to check status/logs.
)
echo.
pause
goto MENU

:LOGS
echo.
cd /d "%~dp0"
if not exist ".git" (
    echo Error: Git not initialized. Use option 1 to initialize it.
    pause
    goto MENU
)
echo Viewing latest workflow logs...
echo.
gh run view --log
echo.
if %errorlevel% neq 0 (
    echo Failed to view logs. Make sure you are logged in to gh CLI (gh auth login)
    echo and a workflow run exists.
)
echo.
pause
goto MENU

:STOP
echo.
cd /d "%~dp0"
if not exist ".git" (
    echo Error: Git not initialized. Use option 1 to initialize it.
    pause
    goto MENU
)
echo Attempting to cancel the latest running workflow...
echo.
REM Check if there's an active run before trying to cancel
gh run list --workflow main.yml --json databaseId,status --jq '.[0] | select(.status == "in_progress" or .status == "queued") | .databaseId' | findstr /r ".*" > NUL
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('gh run list --workflow main.yml --json databaseId,status --jq '.[0] | select(.status == "in_progress" or .status == "queued") | .databaseId'') do set "RUN_ID=%%i"
    if defined RUN_ID (
        echo Cancelling run ID: %RUN_ID%
        gh run cancel %RUN_ID%
        if %errorlevel% neq 0 (
            echo Failed to cancel workflow run.
        ) else (
            echo Workflow run cancelled.
        )
    ) else (
        echo No active workflow runs found to cancel.
    )
) else (
    echo No active workflow runs found to cancel.
)
echo.
pause
goto MENU

:SETUP_SECRET
echo.
cd /d "%~dp0"
if not exist ".git" (
    echo Error: Git not initialized. Use option 1 to initialize it.
    pause
    goto MENU
)
echo ============================================
echo   Setup: Add Gemini API Key
echo ============================================
echo.
echo This will add your Gemini API key as a GitHub secret
echo named 'GEMINI_API_KEY' to your repository.
echo This key is used by the OpenClaw agent in your workflow.
echo.
set /p GEMINI_KEY="Enter your Gemini API Key: "
if "%GEMINI_KEY%"=="" (
    echo No key entered. Skipping secret setup.
    pause
    goto MENU
)
echo Setting GitHub secret 'GEMINI_API_KEY'...
echo %GEMINI_KEY% | gh secret set GEMINI_API_KEY
echo.
if %errorlevel% neq 0 (
    echo Failed to set secret. Make sure you are logged in to gh CLI (gh auth login).
) else (
    echo Secret 'GEMINI_API_KEY' added successfully to your repository.
)
echo.
pause
goto MENU

:TROUBLESHOOT_SLUG
echo.
echo ==================================================================
echo   Troubleshooting: "Error: Invalid slug: 0xPasho/rent-my-browser"
echo ==================================================================
echo.
echo This error indicates that the GitHub Actions workflow is trying
echo to install an OpenClaw skill, but the provided slug is invalid.
echo.
echo **Likely Causes & Solutions:**
echo 1.  **Incorrect Skill Slug:** The workflow (e.g., in .github/workflows/main.yml
echo     or a script like failover.sh) might have a line like:
echo     `openclaw install skill 0xPasho/rent-my-browser`
echo     or similar.
echo     -   **If you intend to install a public skill:** Ensure the slug is
echo         correct (e.g., `openclaw install skill web_search`).
echo     -   **If `rent-my-browser` is your project, not a skill to install:**
echo         The command might be misplaced or incorrect. You might be trying
echo         to run your project, not install it as a skill.
echo         Check if the command should be `openclaw start` or similar,
echo         or if the skill installation is even necessary.
echo     -   **If it's a custom skill from a GitHub repo:** The `openclaw install skill`
echo         command usually expects a simple slug, not a full GitHub path.
echo         You might need to clone the repo manually and then use `openclaw install skill --local /path/to/skill`
echo         or ensure the skill is properly published/configured for direct installation.
echo.
echo 2.  **Hardcoded/Outdated Slug:** The slug `0xPasho/rent-my-browser` might be
echo     hardcoded from an example. If your repository is different (e.g.,
echo     `your_user/your_repo`), you need to update this in your workflow files.
echo.
echo **Action Steps:**
echo a.  **View Workflow Logs:** Use option [5] to view the full logs and pinpoint
echo     where the `openclaw install skill` command is being executed.
echo b.  **Inspect Workflow Files:** Go to your GitHub repository, navigate to
echo     the `.github/workflows/` directory, and open your `.yml` workflow file
echo     (e.g., `main.yml`). Also, check any scripts called by the workflow
echo     (like `failover.sh` if it exists).
echo     Look for `openclaw install skill` commands and verify the slug.
echo c.  **Consult OpenClaw Docs:** Refer to the OpenClaw documentation for
echo     the correct way to install skills or run your specific project.
echo     (https://docs.openclaw.ai/)
echo.
pause
goto MENU

:EXIT
echo.
echo Exiting Rent My Browser - Node Manager.
echo.
exit /b
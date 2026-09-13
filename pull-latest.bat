@echo off
REM Guardian System - Pull Latest Changes
REM This script pulls the latest hardware designs from the remote repository

echo ========================================
echo Guardian System - Pull Latest Changes
echo ========================================
echo.

REM Get the current directory
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

echo Repository location: %REPO_DIR%
echo.

REM Check if this is a git repository
if not exist ".git" (
    echo ERROR: This does not appear to be a git repository!
    echo Please run this script from the root of the repository.
    pause
    exit /b 1
)

REM Get current branch
for /f "tokens=*" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
echo Current branch: %CURRENT_BRANCH%
echo.

REM Fetch latest changes from origin
echo Fetching latest changes from origin...
git fetch origin
if errorlevel 1 (
    echo ERROR: Failed to fetch from origin!
    echo Please check your internet connection and try again.
    pause
    exit /b 1
)
echo.

REM Check if we're on the target branch
set "TARGET_BRANCH=cursor/zone-expander-kicad-skeleton-daa6"
if "%CURRENT_BRANCH%"=="%TARGET_BRANCH%" (
    echo You are already on branch: %TARGET_BRANCH%
    echo Pulling latest changes...
    git pull origin %TARGET_BRANCH%
    if errorlevel 1 (
        echo ERROR: Failed to pull changes!
        echo You may have local modifications that conflict.
        echo Try: git status
        pause
        exit /b 1
    )
) else (
    echo Switching to branch: %TARGET_BRANCH%
    git checkout %TARGET_BRANCH%
    if errorlevel 1 (
        echo ERROR: Failed to checkout branch!
        echo The branch may not exist locally yet.
        echo Trying to create local branch from remote...
        git checkout -b %TARGET_BRANCH% origin/%TARGET_BRANCH%
        if errorlevel 1 (
            echo ERROR: Failed to create local branch from remote!
            pause
            exit /b 1
        )
    )
    echo.
    echo Pulling latest changes...
    git pull origin %TARGET_BRANCH%
    if errorlevel 1 (
        echo ERROR: Failed to pull changes!
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo SUCCESS! Latest changes pulled.
echo ========================================
echo.

REM Show what files were updated
echo Recent files updated:
echo.
git log -1 --name-status --pretty=format:"Commit: %%h%%nAuthor: %%an%%nDate: %%ad%%nMessage: %%s%%n" --date=relative
echo.
echo.

REM Show summary of new files
echo ========================================
echo Summary of Available Files:
echo ========================================
echo.

if exist "hardware\zone-expander\schematics-pdf" (
    echo [Zone Expander Schematics]
    echo   Location: hardware\zone-expander\schematics-pdf\
    dir /b "hardware\zone-expander\schematics-pdf\*.pdf" 2>nul | find /c /v "" > nul && (
        echo   PDF Files:
        dir /b "hardware\zone-expander\schematics-pdf\*.pdf" 2>nul
    )
    dir /b "hardware\zone-expander\schematics-pdf\*.svg" 2>nul | find /c /v "" > nul && (
        echo   SVG Files: ^(open in browser^)
        dir /b "hardware\zone-expander\schematics-pdf\*.svg" 2>nul
    )
    echo.
) else (
    echo   Zone Expander Schematics: Not found
    echo.
)

if exist "docs\hardware\ACCESS_CONTROL_EXPANDER.md" (
    echo [Access Control Expander]
    echo   Specification: docs\hardware\ACCESS_CONTROL_EXPANDER.md
    echo   Project: hardware\access-control-expander\
    echo.
) else (
    echo   Access Control Expander: Not found
    echo.
)

if exist "hardware\zone-expander\SYSTEM_ARCHITECTURE.md" (
    echo [System Architecture]
    echo   Documentation: hardware\zone-expander\SYSTEM_ARCHITECTURE.md
    echo.
) else (
    echo   System Architecture: Not found
    echo.
)

echo ========================================
echo Quick Access Commands:
echo ========================================
echo.
echo Open complete schematic PDF:
echo   start hardware\zone-expander\schematics-pdf\zone-expander-complete.pdf
echo.
echo Open access control specification:
echo   start docs\hardware\ACCESS_CONTROL_EXPANDER.md
echo.
echo Open system architecture:
echo   start hardware\zone-expander\SYSTEM_ARCHITECTURE.md
echo.
echo ========================================
echo.

pause

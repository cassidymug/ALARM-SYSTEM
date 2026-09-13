@echo off
REM Guardian System - Advanced Pull Script with Options
REM This script provides multiple options for syncing the repository

:MENU
cls
echo ========================================
echo Guardian System - Repository Sync
echo ========================================
echo.
echo Current directory: %CD%
echo.
echo Select an option:
echo.
echo 1. Pull latest changes (standard)
echo 2. Pull and view schematic PDF
echo 3. Pull and view access control docs
echo 4. Pull and open schematics folder
echo 5. Show git status
echo 6. Show recent commits
echo 7. Switch to different branch
echo 0. Exit
echo.
set /p CHOICE="Enter your choice (0-7): "

if "%CHOICE%"=="0" goto EXIT
if "%CHOICE%"=="1" goto PULL_STANDARD
if "%CHOICE%"=="2" goto PULL_AND_VIEW_PDF
if "%CHOICE%"=="3" goto PULL_AND_VIEW_ACCESS
if "%CHOICE%"=="4" goto PULL_AND_OPEN_FOLDER
if "%CHOICE%"=="5" goto SHOW_STATUS
if "%CHOICE%"=="6" goto SHOW_COMMITS
if "%CHOICE%"=="7" goto SWITCH_BRANCH

echo Invalid choice. Please try again.
pause
goto MENU

:PULL_STANDARD
cls
echo ========================================
echo Pulling Latest Changes
echo ========================================
echo.
call pull-latest.bat
goto MENU

:PULL_AND_VIEW_PDF
cls
echo ========================================
echo Pull and View Schematic PDF
echo ========================================
echo.
git fetch origin
git pull origin cursor/zone-expander-kicad-skeleton-daa6
if exist "hardware\zone-expander\schematics-pdf\zone-expander-complete.pdf" (
    echo Opening schematic PDF...
    start "" "hardware\zone-expander\schematics-pdf\zone-expander-complete.pdf"
) else (
    echo ERROR: Schematic PDF not found!
    echo The file may not have been pulled yet.
)
pause
goto MENU

:PULL_AND_VIEW_ACCESS
cls
echo ========================================
echo Pull and View Access Control Docs
echo ========================================
echo.
git fetch origin
git pull origin cursor/zone-expander-kicad-skeleton-daa6
if exist "docs\hardware\ACCESS_CONTROL_EXPANDER.md" (
    echo Opening access control specification...
    start "" "docs\hardware\ACCESS_CONTROL_EXPANDER.md"
) else (
    echo ERROR: Access control specification not found!
)
pause
goto MENU

:PULL_AND_OPEN_FOLDER
cls
echo ========================================
echo Pull and Open Schematics Folder
echo ========================================
echo.
git fetch origin
git pull origin cursor/zone-expander-kicad-skeleton-daa6
if exist "hardware\zone-expander\schematics-pdf" (
    echo Opening schematics folder...
    start "" explorer "hardware\zone-expander\schematics-pdf"
) else (
    echo ERROR: Schematics folder not found!
)
pause
goto MENU

:SHOW_STATUS
cls
echo ========================================
echo Git Status
echo ========================================
echo.
git status
echo.
echo ========================================
echo.
pause
goto MENU

:SHOW_COMMITS
cls
echo ========================================
echo Recent Commits
echo ========================================
echo.
git log --oneline --graph --decorate -10
echo.
echo ========================================
echo.
pause
goto MENU

:SWITCH_BRANCH
cls
echo ========================================
echo Available Branches
echo ========================================
echo.
echo Local branches:
git branch
echo.
echo Remote branches:
git branch -r
echo.
set /p NEW_BRANCH="Enter branch name to switch to (or 'cancel' to go back): "
if /i "%NEW_BRANCH%"=="cancel" goto MENU
echo.
echo Switching to branch: %NEW_BRANCH%
git checkout %NEW_BRANCH%
if errorlevel 1 (
    echo.
    echo Failed to switch branch. The branch may not exist locally.
    echo Try pulling from remote first.
)
pause
goto MENU

:EXIT
echo.
echo Goodbye!
exit /b 0

# Guardian System - Interactive Sync Menu (PowerShell)
# This script provides multiple options for syncing the repository

$ErrorActionPreference = "Stop"

function Show-Menu {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Guardian System - Repository Sync" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Pull latest changes (standard)"
    Write-Host "2. Pull and view schematic PDF"
    Write-Host "3. Pull and view access control docs"
    Write-Host "4. Pull and open schematics folder"
    Write-Host "5. Show git status"
    Write-Host "6. Show recent commits"
    Write-Host "7. Switch to different branch"
    Write-Host "0. Exit"
    Write-Host ""
}

function Pull-Standard {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Pulling Latest Changes" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    
    & "$PSScriptRoot\pull-latest.ps1"
}

function Pull-AndViewPDF {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Pull and View Schematic PDF" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    
    git fetch origin
    git pull origin cursor/zone-expander-kicad-skeleton-daa6
    
    $pdfPath = "hardware\zone-expander\schematics-pdf\zone-expander-complete.pdf"
    if (Test-Path $pdfPath) {
        Write-Host "Opening schematic PDF..." -ForegroundColor Green
        Invoke-Item $pdfPath
    } else {
        Write-Host "ERROR: Schematic PDF not found!" -ForegroundColor Red
        Write-Host "The file may not have been pulled yet."
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Pull-AndViewAccess {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Pull and View Access Control Docs" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    
    git fetch origin
    git pull origin cursor/zone-expander-kicad-skeleton-daa6
    
    $accessPath = "docs\hardware\ACCESS_CONTROL_EXPANDER.md"
    if (Test-Path $accessPath) {
        Write-Host "Opening access control specification..." -ForegroundColor Green
        Invoke-Item $accessPath
    } else {
        Write-Host "ERROR: Access control specification not found!" -ForegroundColor Red
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Pull-AndOpenFolder {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Pull and Open Schematics Folder" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    
    git fetch origin
    git pull origin cursor/zone-expander-kicad-skeleton-daa6
    
    $folderPath = "hardware\zone-expander\schematics-pdf"
    if (Test-Path $folderPath) {
        Write-Host "Opening schematics folder..." -ForegroundColor Green
        Invoke-Item $folderPath
    } else {
        Write-Host "ERROR: Schematics folder not found!" -ForegroundColor Red
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Show-Status {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Git Status" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    
    git status
    
    Write-Host ""
    Write-Host "========================================"
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Show-Commits {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Recent Commits" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    
    git log --oneline --graph --decorate -10
    
    Write-Host ""
    Write-Host "========================================"
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Switch-Branch {
    Clear-Host
    Write-Host "========================================"
    Write-Host "Available Branches" -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Local branches:" -ForegroundColor Yellow
    git branch
    Write-Host ""
    Write-Host "Remote branches:" -ForegroundColor Yellow
    git branch -r
    Write-Host ""
    
    $newBranch = Read-Host "Enter branch name to switch to (or 'cancel' to go back)"
    
    if ($newBranch -eq "cancel") {
        return
    }
    
    Write-Host ""
    Write-Host "Switching to branch: $newBranch" -ForegroundColor Yellow
    
    try {
        git checkout $newBranch
        Write-Host "✓ Branch switched successfully" -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "Failed to switch branch. The branch may not exist locally." -ForegroundColor Red
        Write-Host "Try pulling from remote first."
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Main loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (0-7)"
    
    switch ($choice) {
        "0" {
            Write-Host ""
            Write-Host "Goodbye!" -ForegroundColor Green
            exit 0
        }
        "1" { Pull-Standard }
        "2" { Pull-AndViewPDF }
        "3" { Pull-AndViewAccess }
        "4" { Pull-AndOpenFolder }
        "5" { Show-Status }
        "6" { Show-Commits }
        "7" { Switch-Branch }
        default {
            Write-Host ""
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}

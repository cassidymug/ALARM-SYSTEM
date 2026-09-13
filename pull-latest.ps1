# Guardian System - Pull Latest Changes (PowerShell)
# This script pulls the latest hardware designs from the remote repository

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "Guardian System - Pull Latest Changes"
Write-Host "========================================"
Write-Host ""

# Get the script directory (repository root)
$RepoDir = Split-Path -Parent $PSCommandPath
Set-Location $RepoDir

Write-Host "Repository location: $RepoDir"
Write-Host ""

# Check if this is a git repository
if (-not (Test-Path ".git")) {
    Write-Host "ERROR: This does not appear to be a git repository!" -ForegroundColor Red
    Write-Host "Please run this script from the root of the repository."
    Read-Host "Press Enter to exit"
    exit 1
}

# Get current branch
try {
    $CurrentBranch = git branch --show-current
    Write-Host "Current branch: $CurrentBranch" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to get current branch!" -ForegroundColor Red
    exit 1
}

# Fetch latest changes from origin
Write-Host "Fetching latest changes from origin..." -ForegroundColor Yellow
try {
    git fetch origin
    Write-Host "✓ Fetch successful" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to fetch from origin!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again."
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Target branch
$TargetBranch = "cursor/zone-expander-kicad-skeleton-daa6"

# Check if we're on the target branch
if ($CurrentBranch -eq $TargetBranch) {
    Write-Host "You are already on branch: $TargetBranch" -ForegroundColor Cyan
    Write-Host "Pulling latest changes..." -ForegroundColor Yellow
    try {
        git pull origin $TargetBranch
        Write-Host "✓ Pull successful" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to pull changes!" -ForegroundColor Red
        Write-Host "You may have local modifications that conflict."
        Write-Host "Try: git status"
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "Switching to branch: $TargetBranch" -ForegroundColor Yellow
    try {
        git checkout $TargetBranch
        Write-Host "✓ Checkout successful" -ForegroundColor Green
    } catch {
        Write-Host "Branch may not exist locally. Creating from remote..." -ForegroundColor Yellow
        try {
            git checkout -b $TargetBranch "origin/$TargetBranch"
            Write-Host "✓ Branch created and checked out" -ForegroundColor Green
        } catch {
            Write-Host "ERROR: Failed to create local branch from remote!" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
    Write-Host ""
    Write-Host "Pulling latest changes..." -ForegroundColor Yellow
    try {
        git pull origin $TargetBranch
        Write-Host "✓ Pull successful" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to pull changes!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "SUCCESS! Latest changes pulled." -ForegroundColor Green
Write-Host "========================================"
Write-Host ""

# Show what files were updated
Write-Host "Recent commit:" -ForegroundColor Cyan
git log -1 --pretty=format:"Commit: %h%nAuthor: %an%nDate: %ar%nMessage: %s%n"
Write-Host ""
Write-Host ""

# Show summary of available files
Write-Host "========================================"
Write-Host "Summary of Available Files:" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""

# Check for Zone Expander schematics
if (Test-Path "hardware\zone-expander\schematics-pdf") {
    Write-Host "[Zone Expander Schematics]" -ForegroundColor Green
    Write-Host "  Location: hardware\zone-expander\schematics-pdf\"
    
    $pdfFiles = Get-ChildItem "hardware\zone-expander\schematics-pdf\*.pdf" -ErrorAction SilentlyContinue
    if ($pdfFiles) {
        Write-Host "  PDF Files:"
        foreach ($file in $pdfFiles) {
            Write-Host "    $($file.Name)" -ForegroundColor White
        }
    }
    
    $svgFiles = Get-ChildItem "hardware\zone-expander\schematics-pdf\*.svg" -ErrorAction SilentlyContinue
    if ($svgFiles) {
        Write-Host "  SVG Files: (open in browser)" -ForegroundColor Gray
        foreach ($file in $svgFiles) {
            Write-Host "    $($file.Name)" -ForegroundColor White
        }
    }
    Write-Host ""
} else {
    Write-Host "  Zone Expander Schematics: Not found" -ForegroundColor Yellow
    Write-Host ""
}

# Check for Access Control Expander
if (Test-Path "docs\hardware\ACCESS_CONTROL_EXPANDER.md") {
    Write-Host "[Access Control Expander]" -ForegroundColor Green
    Write-Host "  Specification: docs\hardware\ACCESS_CONTROL_EXPANDER.md"
    Write-Host "  Project: hardware\access-control-expander\"
    Write-Host ""
} else {
    Write-Host "  Access Control Expander: Not found" -ForegroundColor Yellow
    Write-Host ""
}

# Check for System Architecture
if (Test-Path "hardware\zone-expander\SYSTEM_ARCHITECTURE.md") {
    Write-Host "[System Architecture]" -ForegroundColor Green
    Write-Host "  Documentation: hardware\zone-expander\SYSTEM_ARCHITECTURE.md"
    Write-Host ""
} else {
    Write-Host "  System Architecture: Not found" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================"
Write-Host "Quick Access Commands (PowerShell):" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""
Write-Host "Open complete schematic PDF:"
Write-Host "  Invoke-Item hardware\zone-expander\schematics-pdf\zone-expander-complete.pdf" -ForegroundColor White
Write-Host ""
Write-Host "Open access control specification:"
Write-Host "  Invoke-Item docs\hardware\ACCESS_CONTROL_EXPANDER.md" -ForegroundColor White
Write-Host ""
Write-Host "Open system architecture:"
Write-Host "  Invoke-Item hardware\zone-expander\SYSTEM_ARCHITECTURE.md" -ForegroundColor White
Write-Host ""
Write-Host "Open schematics folder in Explorer:"
Write-Host "  Invoke-Item hardware\zone-expander\schematics-pdf\" -ForegroundColor White
Write-Host ""
Write-Host "========================================"
Write-Host ""

Read-Host "Press Enter to exit"

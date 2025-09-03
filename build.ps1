# Quick Build Script
# Simple version of the build script for basic usage

# Get current branch name
$currentBranch = git branch --show-current

# Smart version detection based on branch pattern
if ($currentBranch -match "^v(\d+)$") {
    # Branch matches pattern v1, v2, v3, etc.
    $branchVersion = $matches[1]
    $versionPattern = "v$branchVersion.*"
    
    Write-Host "Detected version branch: $currentBranch (looking for $versionPattern tags)" -ForegroundColor Cyan
    
    # Get latest tag matching the branch version pattern
    $version = git tag -l $versionPattern | Sort-Object -Descending | Select-Object -First 1
    
    if (-not $version) {
        $defaultVersion = "v$branchVersion.0.0"
        Write-Host "No $versionPattern tags found. Creating $defaultVersion..." -ForegroundColor Yellow
        git tag $defaultVersion
        $version = $defaultVersion
    }
} else {
    # For main or other branches, use latest tag or default
    Write-Host "Non-version branch: $currentBranch (using latest available tag)" -ForegroundColor Cyan
    $version = git describe --tags --abbrev=0 2>$null
    if (-not $version) {
        Write-Host "No git tags found. Creating v1.0.0..." -ForegroundColor Yellow
        git tag v1.0.0
        $version = "v1.0.0"
    }
}

$versionClean = $version.TrimStart('v')
# Ensure 4-part version for Windows
if ($versionClean.Split('.').Length -eq 3) {
    $versionClean += ".0"
}

Write-Host "Building with version: $version" -ForegroundColor Cyan

# Check if rcedit exists
if (-not (Test-Path ".\rcedit.exe")) {
    Write-Host "Downloading rcedit..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/electron/rcedit/releases/download/v1.1.1/rcedit-x64.exe" -OutFile "rcedit.exe"
}

# Build the Go executable
go build -ldflags "-X main.version=$version" -o hello.exe hello.go

# Add Windows version info
.\rcedit.exe hello.exe --set-file-version $versionClean
.\rcedit.exe hello.exe --set-product-version $versionClean
.\rcedit.exe hello.exe --set-version-string "FileDescription" "Hello World Application"
.\rcedit.exe hello.exe --set-version-string "ProductName" "Hello World"
.\rcedit.exe hello.exe --set-version-string "CompanyName" "Test Company"

Write-Host "Built hello.exe with version $version" -ForegroundColor Green
Write-Host "Test with: .\hello.exe version" -ForegroundColor Cyan

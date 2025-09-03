# Quick Build Script
# Simple version of the build script for basic usage

# Get current branch name
$currentBranch = git branch --show-current

# Get version based on current branch
if ($currentBranch -eq "v1") {
    $version = git tag -l "v1.*" | Sort-Object -Descending | Select-Object -First 1
    if (-not $version) {
        Write-Host "No v1 tags found. Creating v1.0.0..." -ForegroundColor Yellow
        git tag v1.0.0
        $version = "v1.0.0"
    }
} elseif ($currentBranch -eq "v2") {
    $version = git tag -l "v2.*" | Sort-Object -Descending | Select-Object -First 1
    if (-not $version) {
        Write-Host "No v2 tags found. Creating v2.0.0..." -ForegroundColor Yellow
        git tag v2.0.0
        $version = "v2.0.0"
    }
} else {
    # For main or other branches, use latest tag
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

# Complete Build Script for Go Executable with Windows Version Info
# This script builds a Go executable with version information from git tags
# that is visible both in command line and Windows Explorer

param(
    [string]$OutputName = "hello.exe",
    [string]$CompanyName = "Test Company",
    [string]$ProductName = "Hello World Application",
    [string]$Description = "Go Hello World Example with Version Info",
    [string]$Copyright = "Copyright (C) 2025"
)

# Color functions for better output
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }

Write-Info "=== Go Build Script with Windows Version Info ==="
Write-Info "Output: $OutputName"

# Step 1: Check prerequisites
Write-Info "Checking prerequisites..."

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Error "Error: Not in a git repository. Please run 'git init' first."
    exit 1
}

# Check if Go is installed
try {
    $goVersion = go version 2>&1
    Write-Success "Go found: $goVersion"
} catch {
    Write-Error "Error: Go is not installed or not in PATH"
    exit 1
}

# Check if rcedit exists
if (-not (Test-Path ".\rcedit.exe")) {
    Write-Warning "rcedit.exe not found. Downloading..."
    if (Test-Path ".\download-rcedit.ps1") {
        & ".\download-rcedit.ps1"
        if (-not (Test-Path ".\rcedit.exe")) {
            Write-Error "Failed to download rcedit.exe"
            exit 1
        }
    } else {
        Write-Error "rcedit.exe not found and download script missing"
        Write-Info "Please run: .\download-rcedit.ps1"
        exit 1
    }
}

# Step 2: Get version from git
Write-Info "Getting version from git..."

try {
    # Get current branch name
    $currentBranch = git branch --show-current
    Write-Info "Current branch: $currentBranch"
    
    # Get version based on current branch
    if ($currentBranch -eq "v1") {
        $gitTag = git tag -l "v1.*" | Sort-Object -Descending | Select-Object -First 1
        if (-not $gitTag) {
            Write-Warning "No v1 tags found. Creating v1.0.0"
            git tag v1.0.0
            $gitTag = "v1.0.0"
        }
    } elseif ($currentBranch -eq "v2") {
        $gitTag = git tag -l "v2.*" | Sort-Object -Descending | Select-Object -First 1
        if (-not $gitTag) {
            Write-Warning "No v2 tags found. Creating v2.0.0"
            git tag v2.0.0
            $gitTag = "v2.0.0"
        }
    } else {
        # For main or other branches, use latest tag
        $gitTag = git describe --tags --abbrev=0 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "No git tags found. Creating default tag v1.0.0"
            git tag v1.0.0
            $gitTag = "v1.0.0"
        }
    }
    
    Write-Success "Git tag: $gitTag"
    
    # Convert git tag to Windows version format (remove 'v' prefix, add .0 if needed)
    $windowsVersion = $gitTag.TrimStart('v')
    $versionParts = $windowsVersion.Split('.')
    
    # Ensure we have 4 version parts for Windows
    while ($versionParts.Length -lt 4) {
        $versionParts += "0"
    }
    
    $windowsVersion = $versionParts[0..3] -join '.'
    Write-Info "Windows version: $windowsVersion"
    
} catch {
    Write-Error "Error getting git version: $_"
    exit 1
}

# Step 3: Clean previous builds
Write-Info "Cleaning previous builds..."
if (Test-Path $OutputName) {
    Remove-Item $OutputName -Force
}

# Step 4: Build Go executable
Write-Info "Building Go executable..."

try {
    $buildArgs = @(
        "build"
        "-ldflags"
        "-X main.version=$gitTag"
        "-o"
        $OutputName
        "hello.go"
    )
    
    Write-Info "Running: go $($buildArgs -join ' ')"
    & go @buildArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Go build failed"
    }
    
    if (-not (Test-Path $OutputName)) {
        throw "Executable was not created"
    }
    
    $fileSize = (Get-Item $OutputName).Length
    Write-Success "Go build completed ($fileSize bytes)"
    
} catch {
    Write-Error "Error building Go executable: $_"
    exit 1
}

# Step 5: Add Windows version information
Write-Info "Adding Windows version information..."

try {
    # Set file version
    Write-Info "Setting file version to $windowsVersion"
    & ".\rcedit.exe" $OutputName --set-file-version $windowsVersion
    if ($LASTEXITCODE -ne 0) { throw "Failed to set file version" }
    
    # Set product version
    Write-Info "Setting product version to $windowsVersion"
    & ".\rcedit.exe" $OutputName --set-product-version $windowsVersion
    if ($LASTEXITCODE -ne 0) { throw "Failed to set product version" }
    
    # Set version strings
    $versionStrings = @{
        "FileDescription" = $Description
        "ProductName" = $ProductName
        "CompanyName" = $CompanyName
        "LegalCopyright" = $Copyright
        "OriginalFilename" = $OutputName
        "InternalName" = [System.IO.Path]::GetFileNameWithoutExtension($OutputName)
        "FileVersion" = $windowsVersion
        "ProductVersion" = $windowsVersion
    }
    
    foreach ($key in $versionStrings.Keys) {
        $value = $versionStrings[$key]
        Write-Info "Setting $key to '$value'"
        & ".\rcedit.exe" $OutputName --set-version-string $key $value
        if ($LASTEXITCODE -ne 0) { throw "Failed to set $key" }
    }
    
    Write-Success "Windows version info added successfully"
    
} catch {
    Write-Error "Error adding Windows version info: $_"
    exit 1
}

# Step 6: Verify the build
Write-Info "Verifying build..."

try {
    # Test command line version
    Write-Info "Testing command line version..."
    $cliVersion = & ".\$OutputName" version 2>&1
    Write-Success "Command line version: $cliVersion"
    
    # Test Windows version info
    Write-Info "Testing Windows version info..."
    $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(".\$OutputName")
    Write-Success "File version: $($versionInfo.FileVersion)"
    Write-Success "Product version: $($versionInfo.ProductVersion)"
    
    if ($versionInfo.FileVersion -eq $windowsVersion) {
        Write-Success "Version info verification passed!"
    } else {
        Write-Warning "Version info may not be properly embedded"
    }
    
} catch {
    Write-Warning "Error during verification: $_"
}

# Step 7: Summary
Write-Info ""
Write-Info "=== Build Summary ==="
Write-Success "✓ Executable: $OutputName"
Write-Success "✓ Git tag: $gitTag"
Write-Success "✓ Windows version: $windowsVersion"
Write-Success "✓ Command line version: .\$OutputName version"
Write-Success "✓ Windows Explorer: Right-click → Properties → Details"
Write-Info ""
Write-Info "Build completed successfully!"

# Optional: Show file properties
if ($PSVersionTable.PSVersion.Major -ge 5) {
    try {
        $fileInfo = Get-Item $OutputName
        Write-Info "File details:"
        Write-Info "  Size: $($fileInfo.Length) bytes"
        Write-Info "  Created: $($fileInfo.CreationTime)"
        Write-Info "  Modified: $($fileInfo.LastWriteTime)"
    } catch {
        # Ignore errors getting file info
    }
}

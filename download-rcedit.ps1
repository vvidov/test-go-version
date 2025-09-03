# Download rcedit tool for Windows resource editing
# This script downloads the rcedit.exe tool needed to embed version info into Windows executables

Write-Host "Downloading rcedit tool..." -ForegroundColor Yellow

$rcEditUrl = "https://github.com/electron/rcedit/releases/download/v1.1.1/rcedit-x64.exe"
$rcEditPath = ".\rcedit.exe"

try {
    # Check if rcedit already exists
    if (Test-Path $rcEditPath) {
        Write-Host "rcedit.exe already exists." -ForegroundColor Green
        return
    }

    # Download rcedit
    Write-Host "Downloading from: $rcEditUrl"
    Invoke-WebRequest -Uri $rcEditUrl -OutFile $rcEditPath -ErrorAction Stop
    
    # Verify download
    if (Test-Path $rcEditPath) {
        $fileSize = (Get-Item $rcEditPath).Length
        Write-Host "Downloaded rcedit.exe successfully ($fileSize bytes)" -ForegroundColor Green
        
        # Test if the tool works
        Write-Host "Testing rcedit tool..."
        & $rcEditPath --help 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "rcedit tool is ready to use!" -ForegroundColor Green
        } else {
            Write-Warning "rcedit downloaded but may not be working properly"
        }
    } else {
        throw "Failed to download rcedit.exe"
    }
}
catch {
    Write-Error "Failed to download rcedit: $_"
    Write-Host "You can manually download from: $rcEditUrl" -ForegroundColor Yellow
    exit 1
}

Write-Host "Setup complete! You can now run .\build.ps1" -ForegroundColor Cyan

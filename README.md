# Go Executable Version Management

This project demonstrates how to embed git tag versions into Go executables that are visible both in command line and Windows Explorer.

## Overview

This setup provides:
1. **Command-line version**: `.\hello.exe version` shows the git tag (e.g., `v3.0.0`)
2. **Windows Explorer version**: Right-click → Properties → Details shows version info
3. **Automated build process**: Single script builds everything from current git tag

## Project Structure

```
.
├── hello.go              # Main Go application
├── build.ps1             # Automated build script
├── download-rcedit.ps1   # Script to download rcedit tool
├── rcedit.exe            # Windows resource editor (downloaded)
└── README.md             # This file
```

## Prerequisites

1. **Go installed**: https://golang.org/download/
2. **Git repository**: Project must be in a git repository with tags
3. **Windows PowerShell**: For running build scripts
4. **Internet connection**: To download rcedit tool (first time only)

## Setup Instructions

### 1. Initialize Git Repository (if not already done)
```powershell
git init
git add .
git commit -m "Initial commit"
git tag v1.0.0
```

### 2. Download Required Tools
Run the download script:
```powershell
.\download-rcedit.ps1
```

### 3. Build with Version Info
```powershell
.\build.ps1
```

## How It Works

### Go Application Code
The Go application includes a version variable that gets set at build time:

```go
var version = ""  // Set at build time via -ldflags

func main() {
    if len(os.Args) > 1 && os.Args[1] == "version" {
        fmt.Println(version)
        return
    }
    fmt.Println("Hello, world!")
}
```

### Build Process
1. **Get Git Tag**: Extracts the latest git tag (e.g., `v3.0.0`)
2. **Build Go Executable**: Uses `-ldflags` to embed version into the binary
3. **Add Windows Resources**: Uses `rcedit` to embed version info for Windows Explorer

### Version Format Conversion
- Git tag: `v3.0.0` → Windows version: `3.0.0.0`
- Handles tags with or without 'v' prefix
- Automatically adds fourth version component for Windows compatibility

## Usage

### Build Current Version
```powershell
.\build.ps1
```

### Create New Version
```powershell
git tag v1.2.3
.\build.ps1
```

### Check Version
```powershell
# Command line
.\hello.exe version

# Windows Explorer
# Right-click hello.exe → Properties → Details
```

## Troubleshooting

### Common Issues

1. **"rcedit.exe not found"**
   - Run `.\download-rcedit.ps1` first
   - Ensure internet connection for download

2. **"No git tags found"**
   - Create a git tag: `git tag v1.0.0`
   - Ensure you're in a git repository

3. **Version not visible in Windows Explorer**
   - Close all Explorer windows and restart Explorer
   - Try moving/renaming the exe file
   - Check that rcedit commands completed successfully

4. **PowerShell execution policy error**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### Verification Commands

```powershell
# Check if version info is embedded
[System.Diagnostics.FileVersionInfo]::GetVersionInfo(".\hello.exe")

# List git tags
git tag -l

# Check current git tag
git describe --tags --abbrev=0
```

## Advanced Usage

### Custom Version Info
Edit the `build.ps1` script to customize:
- Company name
- Product name
- File description
- Copyright information

### Multiple Architectures
```powershell
# Build for different architectures
$env:GOOS="windows"; $env:GOARCH="amd64"; go build -ldflags "-X main.version=$version" -o hello-amd64.exe hello.go
$env:GOOS="windows"; $env:GOARCH="386"; go build -ldflags "-X main.version=$version" -o hello-386.exe hello.go
```

### CI/CD Integration
The build script can be used in automated build pipelines:
```yaml
# Example GitHub Actions step
- name: Build with version
  run: |
    .\download-rcedit.ps1
    .\build.ps1
  shell: pwsh
```

## Files Description

- **hello.go**: Main application with version support
- **build.ps1**: Complete automated build script
- **download-rcedit.ps1**: Downloads the rcedit tool
- **rcedit.exe**: Windows resource editor (third-party tool)

## External Dependencies

- **rcedit**: https://github.com/electron/rcedit
  - Used to embed Windows version resources
  - Downloaded automatically by script
  - MIT License

## License

This example project is provided as-is for educational purposes.

# Example Go application with version support
# This demonstrates how to embed git tag versions into Go executables

package main

import (
    "fmt"
    "os"
    "runtime"
)

// Version information - set at build time via -ldflags
var (
    version   = "dev"      // Set via: -ldflags "-X main.version=v1.0.0"
    buildTime = "unknown"  // Set via: -ldflags "-X main.buildTime=$(date)"
    gitCommit = "unknown"  // Set via: -ldflags "-X main.gitCommit=$(git rev-parse HEAD)"
)

func main() {
    // Handle command line arguments
    if len(os.Args) > 1 {
        switch os.Args[1] {
        case "version", "-v", "--version":
            showVersion()
            return
        case "help", "-h", "--help":
            showHelp()
            return
        }
    }

    // Default application behavior
    fmt.Println("Hello, world!")
    fmt.Println("Use 'hello version' to see version information")
}

// showVersion displays detailed version information
func showVersion() {
    fmt.Printf("Version: %s\n", version)
    if buildTime != "unknown" {
        fmt.Printf("Built: %s\n", buildTime)
    }
    if gitCommit != "unknown" {
        fmt.Printf("Commit: %s\n", gitCommit)
    }
    fmt.Printf("Go version: %s\n", runtime.Version())
    fmt.Printf("Platform: %s/%s\n", runtime.GOOS, runtime.GOARCH)
}

// showHelp displays usage information
func showHelp() {
    fmt.Println("Hello World Application")
    fmt.Printf("Version: %s\n\n", version)
    fmt.Println("Usage:")
    fmt.Println("  hello              Show greeting")
    fmt.Println("  hello version      Show version information")
    fmt.Println("  hello help         Show this help")
    fmt.Println("")
    fmt.Println("This executable includes Windows version information")
    fmt.Println("visible in File Explorer Properties -> Details.")
}

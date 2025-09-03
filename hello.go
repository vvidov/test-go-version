package main

import (
    "fmt"
    "os"
)

var version = ""

func main() {
    if len(os.Args) > 1 && os.Args[1] == "version" {
        fmt.Println(version)
        return
    }
    fmt.Println("Hello, world! v2")
}

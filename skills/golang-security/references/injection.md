# Command Injection Prevention

## 1. Command Execution Security 【必须】

When using `exec.Command`, `exec.CommandContext`, `syscall.StartProcess`, or `os.StartProcess`:

**Rule 1:** If the first argument (path) comes from external input, use a whitelist of allowed commands. Never allow `bash`, `cmd`, `sh`.

**Rule 2:** When using shell (`sh -c`, `bash -c`), the argument string must be sanitized — filter these characters: `\n $ & ; | ' " ( ) \``

```go
// BAD: command injection via unsanitized input
func foo() {
    userInputedVal := "&& echo 'hello'"
    cmdName := "ping " + userInputedVal
    cmd := exec.Command("sh", "-c", cmdName) // injects "echo 'hello'"
    output, _ := cmd.CombinedOutput()
    fmt.Println(string(output))
}

// BAD: unsanitized command name
cmdName := userInputCommand // could be anything
cmd := exec.Command(cmdName)
```

```go
// GOOD: sanitize shell metacharacters
func checkIllegal(cmdName string) bool {
    dangerous := []string{"&", "|", ";", "$", "'", "`", "(", ")", "\"", "\n"}
    for _, ch := range dangerous {
        if strings.Contains(cmdName, ch) {
            return true
        }
    }
    return false
}

func main() {
    userInputedVal := "&& echo 'hello'"
    cmdName := "ping " + userInputedVal
    if checkIllegal(cmdName) {
        return // reject dangerous input
    }
    cmd := exec.Command("sh", "-c", cmdName)
    output, _ := cmd.CombinedOutput()
    fmt.Println(string(output))
}
```

**Best approach:** Avoid shell invocation entirely. Use `exec.Command(name, args...)` directly with separate arguments instead of `sh -c`:

```go
// BEST: no shell, separate args
cmd := exec.Command("ping", "-c", "4", userHost)
```

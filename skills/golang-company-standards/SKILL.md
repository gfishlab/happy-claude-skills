---
name: golang-company-standards
description: "Company Go coding standards — enforces our internal coding specification covering code style, error handling, naming, control structures, function design, comments, dependency management, and linting. This skill takes precedence over community defaults (samber/cc-skills-golang@golang-code-style, golang-naming, golang-lint). MUST be used whenever writing, reviewing, or modifying Go code in any company project. Triggers on: writing Go code, creating Go files, editing .go files, reviewing Go PRs, setting up Go projects, configuring golangci-lint, writing Go tests, Go code review, or any task involving Go source code. Also triggers when the user mentions Go coding standards, company Go规范, 代码规范, or golangci-lint configuration."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents working on company Go projects.
metadata:
  author: company-standards
  version: "1.0.0"
  openclaw:
    emoji: "📋"
    requires:
      bins:
        - go
        - golangci-lint
    install:
      - kind: custom
        command: "curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.6.2"
        bins: [golangci-lint]
allowed-tools: Read Edit Write Glob Grep Bash(go:*) Bash(golangci-lint:*) Bash(git:*) Agent
---

# Company Go Coding Standards

This skill enforces our internal Go coding specification. It supplements standard Go conventions (Effective Go, Go Code Review Comments) with company-specific requirements. When this skill is active, its rules take precedence over community defaults.

> **Rule levels:** Mandatory = must follow. Preferable = should follow with good reasons to deviate. Optional = recommended guidance.

## Quick Reference

| Area | Key Rule | Level |
|------|----------|-------|
| Formatting | gofmt everything | Mandatory |
| Line length | 120 columns max | Preferable |
| Imports | 4-group separation, no relative paths | Mandatory |
| Error handling | Always handle errors, error last return | Mandatory |
| Panic | Forbidden in business logic | Mandatory |
| Comments | All exported names must have doc comments | Mandatory |
| Naming | MixedCaps, no underscores | Mandatory |
| Nesting | Max 4 levels deep | Mandatory |
| File length | Max 800 lines | Mandatory |
| Function length | Max 80 lines | Preferable |
| Function params | Max 5 parameters | Mandatory |
| Switch | Must have default case | Mandatory |
| Goto | Forbidden in business code | Mandatory |
| Magic numbers | Extract to constant if used 2+ times | Mandatory |
| Tests | All exported functions must have tests | Mandatory |

---

## 1. Code Formatting

### 1.1 gofmt is non-negotiable
All code must be formatted with `gofmt` (or `goimports` which includes gofmt). This eliminates all formatting debates. Enforced by golangci-lint `gofmt` linter.

### 1.2 Line length
Keep lines under 120 characters. Exceptions: import statements, generated code, struct tags. The linter is configured at 140 columns to allow some flexibility. Enforced by `lll` linter.

### 1.3 Spacing
Follow gofmt conventions. Operators get spaces (`a + b`), but function arguments and subscripts don't (`f(a+b)`, `arr[i+1]`).

---

## 2. Import Rules

Organize imports into up to 3 groups separated by blank lines:

```
import (
    "fmt"
    "net/http"

    "github.com/gin-gonic/gin"
    "git.cardinfolink.net/pkgs/field"

    "git.cardinfolink.net/Everonet/online/api"
    "git.cardinfolink.net/Everonet/online/internal/pkg/key"
)
```

Group 1: standard library. Group 2: third-party + other org packages. Group 3: current project sub-packages.

**Mandatory rules:**
- No dot imports in non-test files (`import . "fmt"` is forbidden)
- No relative paths (`import "../net"` is forbidden)
- Use aliases when package names conflict or don't match git paths
- Blank imports get their own group with a comment explaining why

---

## 3. Error Handling

This is the most critical section. Incorrect error handling is the #1 source of bugs in our codebase.

### 3.1 Always handle errors
Every returned error must be checked or explicitly discarded with `_`. The only exception is `defer f.Close()`.

### 3.2 Error is always the last return value
```go
// Wrong
func do() (error, int)

// Correct
func do() (int, error)
```

### 3.3 No error-side else-blocks
Handle errors first, then continue with normal logic. This keeps the happy path unindented:
```go
if err != nil {
    return err
}
// normal code continues here, not in an else block
```

### 3.4 Never combine error checks with other conditions
```go
// Wrong — masks the real failure
x, y, err := f()
if err != nil || y == nil {

// Correct — handle each case independently
x, y, err := f()
if err != nil {
    return err
}
if y == nil {
    return fmt.Errorf("some error")
}
```

### 3.5 Wrap errors with context (Go 1.13+)
Use `fmt.Errorf("module xxx: %w", err)` to wrap errors with context. Error messages should not end with punctuation.

### 3.6 No panic in business logic
- Panic is forbidden in business code
- Only acceptable in `main` for truly fatal startup failures (can't open config, can't connect to DB)
- Exported functions must never panic
- Every goroutine must catch panic at its top level and log the stack trace

### 3.7 Type assertions must use comma-ok
```go
// Wrong — panics on wrong type
t := i.(string)

// Correct — handles mismatch gracefully
t, ok := i.(string)
if !ok {
    // handle error
}
```

---

## 4. Comments

Comments are documentation. They feed into `godoc` and must be written alongside code, not added later.

### 4.1 Every exported name needs a doc comment
This applies to: packages, structs, interfaces, functions, methods, constants, variables, type definitions, and type aliases.

### 4.2 Comment format
Start with the name being commented: `// UserName description of what this is`.

```go
// Package math provides basic constants and mathematical functions.
package math

// User defines basic user information.
type User struct {
    Name  string
    Email string
    // Demographic is the user's demographic group.
    Demographic string
}

// NewAttrModel is the factory method for the attribute data layer.
func NewAttrModel(ctx *common.Context) *AttrModel {

// FlagConfigFile is the command-line flag for the config file path.
const FlagConfigFile = "--config"
```

### 4.3 Delete commented-out code before review
Commented-out code rots and confuses readers. Remove it unless you add a comment explaining why it stays and when it should be removed.

---

## 5. Naming

### 5.1 Packages
- Lowercase, no underscores, no mixedCaps
- Match directory name
- Short and meaningful: `time`, `list`, `http`
- Never use `util`, `common`, `misc`, `global` — these become dumping grounds
- `xx/util/encryption` is fine (scoped utility)

### 5.2 Files
- Lowercase with underscores: `user_service.go`, `http_handler.go`
- Short and descriptive

### 5.3 Structs and types
- MixedCaps (camelCase for unexported, PascalCase for exported)
- Nouns or noun phrases: `Customer`, `WikiPage`, `AddressParser`
- Avoid vague names: `Data`, `Info`

### 5.4 Interfaces
- Single-method interfaces get the `-er` suffix: `Reader`, `Writer`
- Two methods: combine the names
- Three+ methods: name like a struct

### 5.5 Variables
- MixedCaps, no underscores
- Special words follow Go convention: `APIClient`, `repoID`, `UserID`, `urlArray`
- Bool variables: prefix with `Has`, `Is`, `Can`, `Allow`
- Prefer short names for local variables with limited scope: `i` over `sliceIndex`
- Longer, more descriptive names for variables with wider scope

### 5.6 Constants
- MixedCaps (not ALL_CAPS): `AppVersion`, not `APP_VERSION`
- Enum constants need a wrapping type:
```go
type Scheme string
const (
    HTTP  Scheme = "http"
    HTTPS Scheme = "https"
)
```

### 5.7 Functions and methods
- MixedCaps, no underscores
- Exception: test functions (`Test_Foo`, `TestBar_Foo`) and generated code

### 5.8 Method receivers
- Use the first letter of the type (lowercase): `u *User`
- For functions over 20 lines, use a more descriptive name
- Never use `me`, `this`, `self`

---

## 6. Control Structures

### 6.1 if — variable on left, constant on right
```go
if err != nil {        // not: if nil != err
if errorCode == 0 {    // not: if 0 == errorCode
if allowUserLogin {     // not: if allowUserLogin == true
if !allowUserLogin {    // not: if allowUserLogin == false
```

### 6.2 for — use short variable declarations
```go
for i := 0; i < 10; i++ {
```

### 6.3 range — discard what you don't need
```go
for key := range m {           // only key
for _, value := range slice {  // only value
```

### 6.4 switch — must have default
Every switch statement requires a `default` case, even if it just documents the fallthrough.

### 6.5 return early
Handle errors and edge cases immediately, return early. This reduces nesting and keeps the main logic at the top level.

### 6.6 goto — forbidden
Business code must never use `goto`.

---

## 7. Functions

### 7.1 Parameters and returns
- Max 5 parameters
- Prefer value passing; use pointers only when needed
- map, slice, chan, interface — never pass pointers to these
- Use named returns only for same-type multi-returns or when return meaning is unclear
- Return variables start with lowercase

### 7.2 Defer
- Place `defer Close()` immediately after the error check, not before
- Never use `defer` inside a loop — wrap the loop body in an IIFE if needed:
```go
for _, v := range values {
    func() {
        fields, err := db.Query(v)
        if err != nil { /* handle */ }
        defer fields.Close()
        // use fields
    }()
}
```

### 7.3 Size limits
- Files: max 800 lines
- Functions: max 80 lines (preferable)
- Nesting: max 4 levels deep — if you hit 4 levels, extract a helper function

### 7.4 Magic numbers
Any numeric literal used 2+ times must become a named constant. Exception: obvious values like 0, 1, 2, 3.

### 7.5 Variable declaration
Declare variables close to first use, not at the top of the function.

---

## 8. Testing

### 8.1 File naming
Test files: `example_test.go`. Test functions: `TestXxx` or `Test_Xxx` / `TestType_Xxx`.

### 8.2 Coverage requirements
- Every important exported function must have test cases
- Tests commit alongside production code
- Test files can be up to 1600 lines, test functions up to 160 lines
- Unexported helpers in test files don't need comments, but don't export struct types in tests

---

## 9. Dependency Management

- Go 1.11+ must use Go modules
- Internal projects: use `git.cardinfolink.net/group/repo` as module path
- Commit `go.sum`, do not add it to `.gitignore`
- Don't commit `vendor/` directory (preferable)

---

## 10. Linting

The canonical golangci-lint configuration is in `references/.golangci.yml`. Copy it to project root as `.golangci.yml` or `.golangci.yaml`.

Key linters enabled: `gofmt`, `goimports`, `go vet`, `errcheck`, `gosec`, `staticcheck`, `gocyclo` (complexity 15), `funlen` (50 statements), `lll` (140 chars), `gomnd` (magic numbers), `revive`, `gocritic`, `dupl`, `goconst`.

**Install:**
```bash
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.6.2
```

**Run:**
```bash
golangci-lint run ./...
```

To copy the config to a new project, read `references/.golangci.yml` from this skill and write it to the project root.

---

## Applying These Standards

When writing Go code:
1. Format first — let `gofmt`/`goimports` handle spacing and imports
2. Write the happy path with early returns for errors
3. Add doc comments to all exported names as you write them
4. Name things clearly with MixedCaps conventions
5. Keep functions short and nesting shallow — extract helpers early
6. Run `golangci-lint run ./...` before committing

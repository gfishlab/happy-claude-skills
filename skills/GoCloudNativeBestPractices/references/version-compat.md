# Go Version Compatibility Guide (1.20 → 1.26)

When working across multiple Go versions, use the **lowest target version's** syntax to maintain compatibility. Below is a version-by-version breakdown of breaking changes, new features, and syntax differences that affect day-to-day Go development.

---

## Go 1.20 (February 2023)

### New Features
- **`errors.Join`** — combine multiple errors into one
- **Slice to array conversion** — `*[4]byte([]byte{1,2,3,4})` now works
- **`context.WithCancelCause`** — attach a cause to context cancellation
- **`time.Compare`** and **`time.DateTime`** layout constant

### Compatibility Notes
- Safe baseline for most legacy projects
- `errors.Join` is the main quality-of-life improvement
- No generics improvements yet (generics landed in 1.18 but were rough)

### Code Pattern
```go
// Multi-error aggregation (Go 1.20+)
err := errors.Join(
    validateInput(input),
    checkAuth(ctx),
    processRequest(ctx, input),
)
if err != nil {
    return fmt.Errorf("batch operation: %w", err)
}

// Context with cause (Go 1.20+)
ctx, cancel := context.WithCancelCause(context.Background())
cancel(fmt.Errorf("connection lost"))
cause := context.Cause(ctx) // returns the specific cause, not just "context canceled"
```

---

## Go 1.21 (August 2023)

### New Features
- **`log/slog`** — structured logging in standard library
- **`slices`** package — generic slice operations (`Sort`, `Contains`, `Delete`, etc.)
- **`maps`** package — generic map operations (`Keys`, `Values`, `Clone`, etc.)
- **`cmp.Ordered`** and **`cmp.Compare`**
- **`min` / `max`** built-in functions
- **`clear`** built-in for maps and slices
- **`context.WithoutCancel`**, **`context.WithDeadlineCause`**, **`context.WithTimeoutCause`**
- PGO (Profile-Guided Optimization) support

### Compatibility Notes
- `log/slog` is the biggest change — use it instead of `log.Printf` or third-party loggers
- `slices` and `maps` replace most handwritten loops for collection operations
- `min`/`max` builtins replace `math.Min`/`math.Max` (which require float64 conversion)
- **Loop variable capture** still requires `item := item` — this changes in 1.22

### Code Pattern
```go
// Structured logging (Go 1.21+)
slog.Info("request processed",
    "method", r.Method,
    "path", r.URL.Path,
    "duration", time.Since(start),
    "status", rw.status,
)

// Generic slice operations (Go 1.21+)
sorted := slices.Clone(items)
slices.SortFunc(sorted, func(a, b Item) int { return cmp.Compare(a.ID, b.ID) })
if slices.Contains(sorted, target) { ... }

// Built-in min/max (Go 1.21+)
timeout := min(max(d, 100*time.Millisecond), 10*time.Second)
```

---

## Go 1.22 (February 2024)

### New Features
- **Loop variable per-iteration** — `for _, item := range items` creates a new variable each iteration. No more `item := item` needed.
- **`for range` integer** — `for i := range 10` loops 0..9
- **Enhanced ServeMux routing** — method + path patterns: `"POST /tasks"`, `"GET /tasks/{id}"`, `r.PathValue("id")`
- **`math/rand/v2`** — new, faster, cleaner random API
- **`go/version`** package for version detection

### Breaking Changes / Gotchas
- **Loop variable semantics changed** — this is the #1 source of silent behavioral changes when upgrading
- ServeMux patterns with methods (`"POST /tasks"`) will panic at registration on Go < 1.22

### Compatibility Strategy
If your code must compile on Go < 1.22, keep `item := item` captures. If you're Go 1.22+ only, remove them.

```go
// Go 1.21 and earlier: MUST capture
for _, item := range items {
    item := item
    go func() { process(item) }()
}

// Go 1.22+: no capture needed
for _, item := range items {
    go func() { process(item) }()
}

// Go 1.22 routing (NOT compatible with Go < 1.22)
mux.HandleFunc("POST /tasks", submitTask)
mux.HandleFunc("GET /tasks/{id}", getTask)
id := r.PathValue("id")

// Go 1.21 compatible routing
mux.HandleFunc("/tasks/", handleTasks) // manual method dispatch
id := strings.TrimPrefix(r.URL.Path, "/tasks/")
```

---

## Go 1.23 (August 2024)

### New Features
- **Range-over-function iterators** — `iter.Pull`, `iter.Push`, custom iterators via `func(yield func(V) bool)`
- **`unique`** package — interning/canonicalization of values
- **`slices.Collect`**, **`maps.Collect`** for iterator → slice/map conversion
- **`structs`** package — `structs.HostLayout` for C interop
- Timer/Ticker changes: stopped timers are garbage collected; `Reset`/`Stop` methods on both

### Compatibility Notes
- Range-over-func is powerful but adds complexity — use for custom collection types, not everywhere
- `unique` package useful for deduplicating strings (e.g., HTTP header names, cache keys)
- Timer GC change removes a common memory leak pattern

### Code Pattern
```go
// Custom iterator (Go 1.23+)
func Lines(r io.Reader) iter.Seq2[string, error] {
    scanner := bufio.NewScanner(r)
    return func(yield func(string, error) bool) {
        for scanner.Scan() {
            if !yield(scanner.Text(), nil) {
                return
            }
        }
        yield("", scanner.Err())
    }
}

// Usage
for line, err := range Lines(reader) {
    if err != nil { break }
    fmt.Println(line)
}

// String interning (Go 1.23+)
type HeaderName = unique.Handle[string]
contentType := unique.Make("content-type")
// All uses of unique.Make("content-type") return the same underlying pointer
```

---

## Go 1.24 (February 2025)

### New Features
- **Generic type aliases** — `type Set[T comparable] = map[T]struct{}`
- **`os.Root`** — scoped filesystem access (chroot-like without root)
- **`hash/maphash.Comparable`** — hash any comparable value
- **`go tool`** directive in `go.mod`** — manage tool dependencies (`go get -tool`)
- **`testing/synctest`** — test-friendly time manipulation (experimental, requires GOEXPERIMENT=synctest)
- **Weak pointers** — `runtime.LazyValue`, `weak.Pointer[T]`
- **`json.Marshal` / `json.Unmarshal` improvements** — better performance, `omitzero` tag option

### Compatibility Notes
- `omitzero` tag is Go 1.24+ only — use `omitempty` for compatibility
- `go tool` directive is a workflow improvement, no code changes needed
- Generic type aliases enable cleaner generic API designs

### Code Pattern
```go
// Generic type alias (Go 1.24+)
type Set[T comparable] = map[T]struct{}

func NewSet[T comparable](items ...T) Set[T] {
    s := make(Set[T])
    for _, item := range items {
        s[item] = struct{}{}
    }
    return s
}

// omitzero vs omitempty (Go 1.24+)
type Response struct {
    Count     int       `json:"count,omitempty"`   // omits 0 (both tags do this for int)
    CreatedAt time.Time `json:"created_at,omitempty"`  // omitempty does NOT omit time.Time{} (zero value)
    UpdatedAt time.Time `json:"updated_at,omitzero"`   // Go 1.24+: DOES omit time.Time{} (true zero check)
}
// Key difference: omitzero uses a true zero-value comparison, while omitempty
// uses the older "IsEmpty" logic which skips zero values for some types (int, string)
// but NOT for others (time.Time, structs with only non-pointer fields).

// Tool dependency in go.mod (Go 1.24+)
// go.mod:
//   tool (
//       golang.org/x/tools/cmd/stringer
//       github.com/golangci/golangci-lint/cmd/golangci-lint
//   )
// Usage: go run golang.org/x/tools/cmd/stringer -type=Status
```

---

## Go 1.25 (August 2025)

### New Features
- **`maps.Clear`**, **`slices.Reverse`** and additional standard library generics
- Improved **`go test`** output and benchmark infrastructure
- **`crypto/mlkem`** — post-quantum key encapsulation
- Performance improvements to `strings.Builder`, `bytes.Buffer`

### Compatibility Notes
- No breaking syntax changes
- `maps.Clear` is functionally identical to the `clear` builtin for maps, but more explicit

---

## Go 1.26 (February 2026)

### New Features
- **Improved PGO** — automatic binary optimization from production profiles
- **`sync.Map` range improvements** — better iteration performance
- **`net/http` enhancements** — improved connection pooling, `http.Server` metrics
- Further generics ergonomics improvements

### Compatibility Notes
- No breaking syntax changes from 1.25
- PGO improvements are transparent — just provide a `default.pgo` file

---

## Quick Compatibility Matrix

| Feature | Minimum Go Version | Safe to use if target is |
|---------|-------------------|------------------------|
| Generics | 1.18 | 1.18+ |
| `errors.Join` | 1.20 | 1.20+ |
| `log/slog`, `slices`, `maps`, `min`/`max`, `clear` | 1.21 | 1.21+ |
| Loop var per-iteration, ServeMux method routing, `rand/v2` | 1.22 | 1.22+ |
| Range-over-func, `unique`, iterator protocol | 1.23 | 1.23+ |
| Generic aliases, `omitzero`, `os.Root`, `go tool` directive | 1.24 | 1.24+ |
| `maps.Clear`, improved benchmarks | 1.25 | 1.25+ |
| PGO improvements, sync.Map range | 1.26 | 1.26+ |

## Multi-Version Development Tips

### Using goenv
```bash
# Install goenv (macOS)
brew install goenv

# Install and use specific versions
goenv install 1.21.13
goenv install 1.24.4
goenv install 1.26.0

# Per-project version (creates .go-version file)
cd ~/projects/legacy-service && goenv local 1.21.13
cd ~/projects/new-service && goenv local 1.24.4
```

### Using Go's built-in multi-version support
```bash
# Install additional toolchain versions
go install golang.org/dl/go1.21.13@latest
go1.21.13 download

# Use specific version
go1.21.13 test ./...

# go.mod directive automatically selects toolchain (Go 1.21+)
# go.mod: `toolchain go1.24.4` — Go will auto-download if needed
```

### Best Practice for Multi-Version Projects
1. **Set `go` directive in `go.mod` to the minimum required version** — not the version you develop with
2. **Use `go vet` and `go build` with the target version** in CI
3. **When writing shared libraries**, target the lowest version in your fleet
4. **Avoid version-specific syntax** unless the entire project uses that version
5. **Test with `-race` and `-cover`** on the minimum target version to catch compat issues early

---
name: GoCloudNativeBestPractices
description: >
  MANDATORY: This skill MUST be loaded and followed for EVERY Go (Golang) code task — no exceptions.
  Any time the user is writing, reviewing, refactoring, debugging, or generating Go code (.go files,
  go.mod, go.sum, go.work), this skill must be triggered. This includes but is not limited to:
  microservices, HTTP/gRPC servers, CLI tools, concurrent programs, database operations, testing,
  Dockerfile for Go, Makefile for Go projects, and any Go-related question or task.
  Trigger keywords: go, golang, goroutine, channel, context, go.mod, go.sum, go build, go test,
  go vet, interface{}, any, error, fmt.Errorf, sync.Mutex, sync.Map, http.Handler, slog, database/sql,
  docker multistage golang, cobra, viper, errgroup, wire, sql.DB, pgx, chi, gin, echo, testify.
  Even if the user does not explicitly mention "Go" or "best practices," if the task involves .go
  files or Go tooling, this skill MUST be used. The skill enforces Go Proverbs, Effective Go guidelines,
  Uber Go Style Guide conventions, cloud-native community standards, and Go version compatibility
  (1.20 through 1.26).
---

# Cloud-Native Go Best Practices (Go 1.20+)

You are a senior Go engineer who has contributed to core cloud-native projects (Kubernetes, Prometheus, Etcd). Your job is to help write, review, and refactor Go code that is production-grade, cloud-native, and idiomatic.

Go's simplicity is deceptive — it's easy to write code that compiles and runs but harbors goroutine leaks, unchecked errors, missing context propagation, or subtle race conditions. This skill exists to prevent those pitfalls systematically.

## Core Philosophy

Go's design philosophy is "less is more." These principles guide every decision:

- **Clear is better than clever** — write boring, obvious code
- **Composition over inheritance** — embed structs, satisfy small interfaces
- **Explicit over implicit** — errors are values, return them; don't hide control flow
- **Don't panic** — literally. Use error returns everywhere except main/init
- **Interface satisfaction is implicit** — define interfaces where you consume them, not where you implement them

## Workflow

When the user asks you to write or review Go code, follow this sequence:

### 1. Analyze the requirements

Before writing any code, clarify:
- What is the concurrency model? (fan-out/fan-in, worker pool, pipeline, single goroutine)
- Where does cancellation/timeout need to propagate?
- What is the error propagation path? Which errors are fatal vs retryable?
- What are the performance characteristics? (allocation rate, throughput, latency targets)
- What external dependencies exist? (databases, message queues, HTTP APIs)

### 2. Design interfaces first

Define small, focused interfaces at the consumer side:

```go
// Good: small, single-responsibility interface
type UserStore interface {
    Get(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// Bad: god interface with everything
type Store interface {
    GetUser(...) ...
    SaveUser(...) ...
    DeleteUser(...) ...
    ListOrders(...) ...
    ...
}
```

Interfaces with 1-3 methods are ideal. If you need more, consider splitting into smaller interfaces and composing them.

Use dependency injection via constructors — accept interfaces, return structs:

```go
type UserService struct {
    store  UserStore
    logger *slog.Logger
}

func NewUserService(store UserStore, logger *slog.Logger) *UserService {
    return &UserService{store: store, logger: logger}
}
```

This makes testing trivial: pass a mock store, no framework needed.

### 3. Implement with these rules

#### Error handling — the most important rule

Every error must be checked and either returned (wrapped) or handled explicitly. Never ignore errors.

```go
// Good: wrap and return
result, err := doSomething(ctx)
if err != nil {
    return fmt.Errorf("do something: %w", err)
}

// Good: explicit handling with type check
result, err := doSomething(ctx)
if err != nil {
    if errors.Is(err, ErrNotFound) {
        return defaultResult, nil
    }
    return fmt.Errorf("do something: %w", err)
}

// NEVER do this
result, _ := doSomething(ctx)
```

Wrap errors with context using `fmt.Errorf("operation: %w", err)` to build an error chain. This allows callers to use `errors.Is()` and `errors.As()` for inspection.

Define sentinel errors for public APIs:

```go
var ErrNotFound = errors.New("resource not found")

// Custom error type for structured error info
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed: %s: %s", e.Field, e.Message)
}
```

Never use `panic` in library code. Only in `main` or `init` for truly unrecoverable startup failures.

#### Context propagation

`context.Context` is the first parameter of any function that does I/O or might block:

```go
func (s *Service) Process(ctx context.Context, input Input) (Output, error) {
    if err := ctx.Err(); err != nil {
        return Output{}, err
    }

    result, err := s.store.Get(ctx, input.ID)
    if err != nil {
        return Output{}, fmt.Errorf("process: %w", err)
    }
    return result, nil
}
```

Every goroutine you spawn must receive a context. Use `context.WithTimeout` or `context.WithCancel` to bound its lifetime.

Use `context.WithValue` sparingly — only for cross-cutting concerns that truly belong at the request level (request IDs, auth tokens, tenant context). Never use it for optional function parameters.

#### Concurrency

Channel-first thinking. Use channels for communication between goroutines, mutexes only for shared state caching:

```go
// Fan-out with errgroup — note the mutex protecting the shared slice
g, ctx := errgroup.WithContext(ctx)
mu := sync.Mutex{}
var results []Result

for _, item := range items {
    item := item // capture variable (required for Go < 1.22)
    g.Go(func() error {
        r, err := process(ctx, item)
        if err != nil {
            return fmt.Errorf("process item %s: %w", item.ID, err)
        }
        mu.Lock()
        results = append(results, r)
        mu.Unlock()
        return nil
    })
}

if err := g.Wait(); err != nil {
    return fmt.Errorf("fan-out processing: %w", err)
}
```

Key patterns:
- `errgroup.Group` — manage goroutine groups with error propagation
- `sync.WaitGroup` — fire-and-forget goroutine groups (when you don't need errors)
- `sync/atomic` — lock-free counters and state (prefer over mutex for simple cases)
- `sync.Pool` — reuse expensive-to-allocate objects
- Worker pools — use `chan` + fixed goroutine count to bound concurrency

Always guard against goroutine leaks. If you start a goroutine, there must be a way for it to exit (via context cancellation or a done channel). Guard double-close with `sync.Once`.

#### HTTP services

Prefer `net/http` standard library. Use middleware chains for cross-cutting concerns.

For Go 1.21, use manual method dispatch (Go 1.22+ adds method+pattern routing):

```go
mux.HandleFunc("/tasks/", handleTasks) // matches /tasks/ and sub-paths
mux.HandleFunc("/tasks", handleTasks)  // matches exact /tasks
mux.HandleFunc("/healthz", handleHealthz)

func handleTasks(w http.ResponseWriter, r *http.Request) {
    switch r.Method {
    case http.MethodPost:
        submitTask(w, r)
    case http.MethodGet:
        getTask(w, r) // extract ID by trimming "/tasks/" prefix
    default:
        writeError(w, http.StatusMethodNotAllowed, "method not allowed")
    }
}
```

Always capture the response status code in middleware:

```go
type responseWriter struct {
    http.ResponseWriter
    status int
}

func (rw *responseWriter) WriteHeader(code int) {
    rw.status = code
    rw.ResponseWriter.WriteHeader(code)
}

func loggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        rw := &responseWriter{ResponseWriter: w, status: http.StatusOK}
        next.ServeHTTP(rw, r)
        slog.Info("request",
            "method", r.Method,
            "path", r.URL.Path,
            "status", rw.status,
            "duration", time.Since(start),
        )
    })
}
```

Always set timeouts and limits on HTTP servers:

```go
srv := &http.Server{
    Addr:           ":8080",
    Handler:        handler,
    ReadTimeout:    5 * time.Second,
    WriteTimeout:   10 * time.Second,
    IdleTimeout:    120 * time.Second,
    MaxHeaderBytes: 1 << 20, // 1 MB
}
```

Wrap request bodies with `http.MaxBytesReader` to prevent oversized payloads:

```go
func maxBodyMiddleware(max int64) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            r.Body = http.MaxBytesReader(w, r.Body, max)
            next.ServeHTTP(w, r)
        })
    }
}
```

#### Health checks

Every cloud-native service must expose health endpoints for orchestrators:

```go
mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
    // Liveness: is the process alive?
    writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
})

mux.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
    // Readiness: can it serve traffic? Check dependencies here.
    if err := db.PingContext(r.Context()); err != nil {
        writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "not ready"})
        return
    }
    writeJSON(w, http.StatusOK, map[string]string{"status": "ready"})
})
```

#### Database access with database/sql

Always configure connection pool limits and timeouts:

```go
db, err := sql.Open("pgx", dsn)
if err != nil {
    return fmt.Errorf("open db: %w", err)
}

db.SetMaxOpenConns(25)
db.SetMaxIdleConns(5)
db.SetConnMaxLifetime(5 * time.Minute)
db.SetConnMaxIdleTime(1 * time.Minute)
```

Always pass context to queries for cancellation:

```go
func (s *UserStore) Get(ctx context.Context, id string) (*User, error) {
    var u User
    err := s.db.QueryRowContext(ctx,
        "SELECT id, name, email FROM users WHERE id = $1", id,
    ).Scan(&u.ID, &u.Name, &u.Email)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrNotFound
        }
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return &u, nil
}
```

Transactions with proper rollback:

```go
func (s *OrderStore) CreateOrder(ctx context.Context, order *Order) error {
    tx, err := s.db.BeginTx(ctx, nil)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }
    defer tx.Rollback() // no-op after commit

    if _, err := tx.ExecContext(ctx,
        "INSERT INTO orders (id, user_id, total) VALUES ($1, $2, $3)",
        order.ID, order.UserID, order.Total,
    ); err != nil {
        return fmt.Errorf("insert order: %w", err)
    }

    return tx.Commit()
}
```

#### Configuration management

Follow 12-factor app principles. Read config from environment variables with validation at startup:

```go
type Config struct {
    Port            int
    DatabaseURL     string
    WorkerCount     int
    ShutdownTimeout time.Duration
}

func LoadConfig() (*Config, error) {
    cfg := &Config{
        Port:            getEnvInt("PORT", 8080),
        DatabaseURL:     getEnv("DATABASE_URL", "postgres://localhost/app?sslmode=disable"),
        WorkerCount:     getEnvInt("WORKER_COUNT", 4),
        ShutdownTimeout: getEnvDuration("SHUTDOWN_TIMEOUT", 30*time.Second),
    }
    if cfg.Port < 1 || cfg.Port > 65535 {
        return nil, fmt.Errorf("invalid port: %d", cfg.Port)
    }
    return cfg, nil
}

func getEnv(key, fallback string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return fallback
}

func getEnvInt(key string, fallback int) int {
    if v := os.Getenv(key); v != "" {
        n, err := strconv.Atoi(v)
        if err == nil {
            return n
        }
    }
    return fallback
}

func getEnvDuration(key string, fallback time.Duration) time.Duration {
    if v := os.Getenv(key); v != "" {
        d, err := time.ParseDuration(v)
        if err == nil {
            return d
        }
    }
    return fallback
}
```

Never hardcode ports, timeouts, or connection strings. Fail fast on invalid config at startup.

#### Struct design

Use exported/unexported fields to communicate intent. Always use struct tags for serialization:

```go
type User struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
    updatedAt time.Time // unexported: internal state
}
```

Note: `validate` struct tags (e.g., `validate:"required,email"`) require the third-party `github.com/go-playground/validator` package, not the standard library.

#### Logging

Use structured logging. Prefer `log/slog` (stdlib since Go 1.21):

```go
slog.Info("user created",
    "user_id", user.ID,
    "email", user.Email,
    "source", "api",
)
```

Use `zap` only when profiling shows slog is a bottleneck. Never use `fmt.Println` or `log.Printf` in production code.

#### Testing

Write table-driven tests. Include benchmarks for performance-critical code:

```go
func TestShorten(t *testing.T) {
    tests := []struct {
        name    string
        url     string
        wantErr bool
    }{
        {name: "valid url", url: "https://example.com", wantErr: false},
        {name: "empty url", url: "", wantErr: true},
    }

    for _, tt := range tests {
        tt := tt // capture range variable (Go < 1.22)
        t.Run(tt.name, func(t *testing.T) {
            s := NewShortener(NewMemoryStore())
            code, err := s.Shorten(context.Background(), tt.url)
            if (err != nil) != tt.wantErr {
                t.Errorf("Shorten() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !tt.wantErr && code == "" {
                t.Error("Shorten() returned empty code")
            }
        })
    }
}
```

Test coverage target: >80% for production services. Use `go test -race -cover` as the baseline.

For async code, avoid `time.Sleep` in tests. Poll or use channels/sync primitives to wait for completion:

```go
// Good: poll with timeout
assertEventually(t, func() bool {
    task, _ := q.Lookup(ctx, id)
    return task.Status() == StatusCompleted
}, 5*time.Second, 10*time.Millisecond)
```

### 4. Output structure

When generating a complete project, always include:

```
project/
├── go.mod              # Module definition (go 1.21)
├── go.sum              # Dependency checksums
├── main.go             # Entry point with graceful shutdown
├── internal/           # Private application code
│   ├── service/        # Business logic
│   ├── store/          # Data layer
│   └── handler/        # HTTP handlers + middleware
├── Dockerfile          # Multi-stage build
├── Makefile            # Build, test, lint targets
└── doc.go              # Package documentation (optional)
```

Include a `Makefile` with targets for:
- `make build` — compile
- `make test` — run tests with race detector
- `make lint` — run golangci-lint
- `make cover` — coverage report
- `make docker` — build container image

Dockerfile for scratch/distroless images:

```dockerfile
FROM golang:1.21 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./main.go

FROM gcr.io/distroless/base-debian12
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

### 5. Static analysis checklist

Before finalizing any code, verify:
- `go vet` passes with zero warnings
- `staticcheck` passes (integrate via `golangci-lint`)
- No unchecked errors (use `errcheck`)
- No goroutine leaks (use `go.uber.org/goleak` in tests)
- All public symbols have godoc comments starting with the symbol name

## Naming Conventions

- **Packages**: lowercase, single word, no underscores (`store`, `service`, `handler`)
- **Variables**: short but meaningful. Use `ctx` for context, `err` for errors, `ok` for booleans
- **Interfaces**: typically one method named with "-er" suffix (`Reader`, `Writer`, `Stringer`)
- **Acronyms**: keep consistent casing (`HTTPClient`, not `HttpClient`; `userID`, not `userId`)
- **Constants**: avoid embedding units in names. `Timeout` not `TimeoutSeconds`. Use `time.Duration` to carry the unit.

## Version Compatibility

Go 1.20 through 1.26 have significant syntax and standard library differences. **Always check the `go` directive in `go.mod`** before writing code, and use patterns compatible with that version.

Key version gates to remember:
- **Go < 1.22**: Loop variables are shared across iterations — always `item := item`
- **Go < 1.22**: No method-based ServeMux routing (`"POST /tasks"`) — use manual dispatch
- **Go < 1.21**: No `log/slog`, `slices`, `maps`, `min`/`max` builtins
- **Go < 1.20**: No `errors.Join`, `context.WithCancelCause`
- **Go 1.24+**: `omitzero` json tag, generic type aliases, `go tool` directive
- **Go 1.23+**: Range-over-func iterators, `unique` package

For detailed per-version breakdown with code examples and multi-version tooling (goenv, Go toolchain directive), read `references/version-compat.md`.

## Quick Reference: Common Patterns

When in doubt, refer to `references/patterns.md` for detailed examples of:
- Worker pool pattern
- Fan-out/fan-in with errgroup
- Graceful shutdown with signal handling
- Rate limiter implementation
- Circuit breaker pattern
- Retry with backoff

## What NOT to do

- Don't use `panic` in library code
- Don't ignore errors with `_`
- Don't start goroutines without a way to stop them
- Don't use `init()` for complex logic or external I/O
- Don't export state that should be internal
- Don't use `interface{}` — use `any` (available since Go 1.18) or a concrete type
- Don't use global variables for configuration or state
- Don't import massive frameworks when stdlib + small libraries suffice
- Don't close channels from the receiver side. Only the sender should close, and use `sync.Once` when multiple senders might close the same channel

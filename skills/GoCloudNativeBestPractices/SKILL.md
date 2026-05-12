---
name: GoCloudNativeBestPractices
description: >
  Golang cloud-native deployment patterns for containerized Go services. Covers multi-stage
  Dockerfile (scratch/distroless), Makefile templates, project layout for Kubernetes deployments,
  health check endpoints (/healthz, /readyz), and Go version compatibility (1.20-1.26).
  Use when creating Dockerfile for Go, setting up Makefile for Go projects, configuring
  health probes for Kubernetes, or checking Go version-specific syntax compatibility.
  For Go code style, error handling, concurrency, testing, security, and library-specific
  patterns, use samber/cc-skills-golang skills instead.
user-invocable: true
---

# Cloud-Native Go Deployment Patterns

This skill complements `samber/cc-skills-golang` with cloud-native deployment guidance that the Go skills plugin does not cover: containerization, build automation, Kubernetes health probes, and Go version compatibility.

For Go coding best practices (error handling, concurrency, testing, naming, etc.), rely on the samber/cc-skills-golang skills.

## Project Layout

```
project/
├── go.mod              # Module definition
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

## Dockerfile

Multi-stage build for minimal image size. Prefer `distroless` for production — no shell, no package manager, minimal attack surface.

```dockerfile
FROM golang:1.24 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /server ./main.go

FROM gcr.io/distroless/base-debian12
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

For debugging needs, use `debug` variant:

```dockerfile
FROM gcr.io/distroless/base-debian12:debug
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

Key flags:
- `CGO_ENABLED=0` — static binary, required for scratch/distroless
- `-ldflags="-s -w"` — strip debug info and DWARF, reduces binary ~30%
- `go mod download` before `COPY . .` — Docker layer caching for dependencies

## Makefile

```makefile
.PHONY: build test lint cover docker clean

BINARY   := server
IMAGE    := myorg/$(BINARY)
GO_FLAGS := -ldflags="-s -w"

build:
	CGO_ENABLED=0 go build $(GO_FLAGS) -o $(BINARY) ./main.go

test:
	go test -race -cover ./...

lint:
	golangci-lint run ./...

cover:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

docker:
	docker build -t $(IMAGE) .

clean:
	rm -f $(BINARY) coverage.out coverage.html
```

## Health Check Endpoints

Every cloud-native service must expose health endpoints for orchestrators (Kubernetes, ECS, Nomad).

```go
mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
    // Liveness: is the process alive? If this fails, orchestrator restarts the pod.
    w.WriteHeader(http.StatusOK)
}))

mux.HandleFunc("GET /readyz", func(w http.ResponseWriter, r *http.Request) {
    // Readiness: can it serve traffic? Check dependencies here.
    // If this fails, orchestrator removes the pod from service load balancer.
    if err := db.PingContext(r.Context()); err != nil {
        slog.Error("readiness check failed", "error", err)
        http.Error(w, "not ready", http.StatusServiceUnavailable)
        return
    }
    w.WriteHeader(http.StatusOK)
}))
```

Kubernetes probe configuration:

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /readyz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Go Version Compatibility

Go 1.20 through 1.26 have significant syntax and standard library differences. **Always check the `go` directive in `go.mod`** before writing code, and use patterns compatible with that version.

Key version gates:

| Feature | Minimum Go Version |
|---------|-------------------|
| Generics | 1.18 |
| `errors.Join` | 1.20 |
| `log/slog`, `slices`, `maps`, `min`/`max`, `clear` | 1.21 |
| Loop var per-iteration, ServeMux method routing, `rand/v2` | 1.22 |
| Range-over-func, `unique`, iterator protocol | 1.23 |
| Generic aliases, `omitzero`, `os.Root`, `go tool` directive | 1.24 |
| `maps.Clear`, improved benchmarks | 1.25 |
| PGO improvements, sync.Map range | 1.26 |

Critical compatibility notes:
- **Go < 1.22**: Loop variables are shared across iterations — always `item := item`
- **Go < 1.22**: No method-based ServeMux routing (`"POST /tasks"`) — use manual dispatch
- **Go < 1.21**: No `log/slog`, `slices`, `maps`, `min`/`max` builtins
- **Go 1.24+**: `omitzero` json tag distinguishes zero-value from empty for structs like `time.Time`

For detailed per-version breakdown with code examples and multi-version tooling (goenv, Go toolchain directive), read `references/version-compat.md`.

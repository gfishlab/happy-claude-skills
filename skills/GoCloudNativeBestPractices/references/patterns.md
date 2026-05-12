# Common Go Concurrency and Cloud-Native Patterns

## Table of Contents
1. [Worker Pool](#worker-pool)
2. [Fan-out/Fan-in with errgroup](#fan-outfan-in)
3. [Graceful Shutdown](#graceful-shutdown)
4. [Rate Limiter](#rate-limiter)
5. [Circuit Breaker](#circuit-breaker)
6. [Retry with Backoff](#retry-with-backoff)

---

## Worker Pool

Fixed number of goroutines processing work from a channel. Bounds concurrency and resource usage.

```go
package pool

import (
    "context"
    "errors"
    "fmt"
)

type Pool[T any, R any] struct {
    workers int
    process func(context.Context, T) (R, error)
}

func New[T any, R any](workers int, fn func(context.Context, T) (R, error)) *Pool[T, R] {
    return &Pool[T, R]{workers: workers, process: fn}
}

func (p *Pool[T, R]) Run(ctx context.Context, items []T) ([]R, error) {
    in := make(chan T)
    results := make(chan struct {
        val R
        err error
    })

    // Start workers
    for i := 0; i < p.workers; i++ {
        go func() {
            for item := range in {
                val, err := p.process(ctx, item)
                results <- struct {
                    val R
                    err error
                }{val, err}
            }
        }()
    }

    // Feed work
    go func() {
        for _, item := range items {
            select {
            case in <- item:
            case <-ctx.Done():
            }
        }
        close(in)
    }()

    // Collect results
    var errs []error
    var out []R
    for i := 0; i < len(items); i++ {
        select {
        case r := <-results:
            if r.err != nil {
                errs = append(errs, r.err)
            } else {
                out = append(out, r.val)
            }
        case <-ctx.Done():
            // Drain remaining results to unblock workers
            go func() {
                for range results {
                }
            }()
            return out, ctx.Err()
        }
    }

    if len(errs) > 0 {
        return out, fmt.Errorf("pool: %d of %d items failed: %w", len(errs), len(items), errors.Join(errs...))
    }
    return out, nil
}
```

---

## Fan-out/Fan-in

Process items concurrently and collect all results. Use `errgroup` for automatic cancellation on first error.

```go
func ProcessAll(ctx context.Context, items []Item) ([]Result, error) {
    g, ctx := errgroup.WithContext(ctx)
    mu := sync.Mutex{}
    var results []Result

    for _, item := range items {
        item := item // capture loop variable (Go < 1.22)
        g.Go(func() error {
            r, err := processOne(ctx, item)
            if err != nil {
                return fmt.Errorf("process %s: %w", item.ID, err)
            }
            mu.Lock()
            results = append(results, r)
            mu.Unlock()
            return nil
        })
    }

    if err := g.Wait(); err != nil {
        return nil, err
    }
    return results, nil
}
```

---

## Graceful Shutdown

Handle OS signals and drain in-flight requests before exiting. Close all resources (DB, queues) before returning.

```go
func main() {
    db, err := sql.Open("pgx", dsn)
    if err != nil {
        log.Fatal(err)
    }

    srv := &http.Server{Addr: ":8080", Handler: handler()}

    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            slog.Error("server error", "error", err)
            os.Exit(1)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    sig := <-quit

    slog.Info("shutting down", "signal", sig)

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    // Stop accepting new requests, drain in-flight
    if err := srv.Shutdown(ctx); err != nil {
        slog.Error("http shutdown failed", "error", err)
    }

    // Close database connections
    db.Close()

    slog.Info("server stopped")
}
```

---

## Rate Limiter

Token bucket rate limiter using `golang.org/x/time/rate`.

```go
type RateLimitedClient struct {
    client  *http.Client
    limiter *rate.Limiter
}

func NewRateLimitedClient(rps float64, burst int) *RateLimitedClient {
    return &RateLimitedClient{
        client: &http.Client{
            Timeout: 30 * time.Second,
            Transport: &http.Transport{
                MaxIdleConns:        100,
                MaxIdleConnsPerHost: 10,
                IdleConnTimeout:     90 * time.Second,
            },
        },
        limiter: rate.NewLimiter(rate.Limit(rps), burst),
    }
}

func (c *RateLimitedClient) Do(ctx context.Context, req *http.Request) (*http.Response, error) {
    if err := c.limiter.Wait(ctx); err != nil {
        return nil, fmt.Errorf("rate limit wait: %w", err)
    }
    return c.client.Do(req.WithContext(ctx))
}
```

---

## Circuit Breaker

Circuit breaker with three states: closed, open, half-open. Uses typed state constants.
The half-open state atomically allows only a single probe request.

```go
type State int

const (
    StateClosed   State = iota
    StateOpen
    StateHalfOpen
)

type CircuitBreaker struct {
    maxFailures int
    timeout     time.Duration

    mu       sync.Mutex
    failures int
    state    State
    lastFail time.Time
}

func NewCircuitBreaker(maxFailures int, timeout time.Duration) *CircuitBreaker {
    return &CircuitBreaker{
        maxFailures: maxFailures,
        timeout:     timeout,
        state:       StateClosed,
    }
}

func (cb *CircuitBreaker) Execute(fn func() error) error {
    if !cb.allow() {
        return fmt.Errorf("circuit breaker is open")
    }

    err := fn()
    cb.record(err)
    return err
}

// allow checks and transitions state atomically under the lock.
// In half-open state, only one request is allowed through before
// the result is recorded.
func (cb *CircuitBreaker) allow() bool {
    cb.mu.Lock()
    defer cb.mu.Unlock()

    switch cb.state {
    case StateClosed:
        return true
    case StateOpen:
        if time.Since(cb.lastFail) > cb.timeout {
            cb.state = StateHalfOpen
            return true
        }
        return false
    case StateHalfOpen:
        // Only one probe allowed — reject additional requests
        // until the probe result is recorded
        return false
    }
    return false
}

func (cb *CircuitBreaker) record(err error) {
    cb.mu.Lock()
    defer cb.mu.Unlock()

    if err == nil {
        cb.failures = 0
        cb.state = StateClosed
        return
    }

    cb.failures++
    cb.lastFail = time.Now()
    cb.state = StateOpen
}
```

---

## Retry with Backoff

Exponential backoff with full jitter (randomizes within the delay window) and context-aware cancellation.

```go
func Retry(ctx context.Context, maxAttempts int, baseDelay time.Duration, fn func() error) error {
    var err error

    for attempt := 0; attempt < maxAttempts; attempt++ {
        if err = fn(); err == nil {
            return nil
        }

        if attempt == maxAttempts-1 {
            break
        }

        // Exponential backoff: 2^attempt * baseDelay
        delay := baseDelay * time.Duration(1<<uint(attempt))

        // Full jitter: randomize within [0, delay) to spread retries
        jitter := time.Duration(rand.Int63n(int64(delay)))
        delay = jitter

        select {
        case <-ctx.Done():
            return ctx.Err()
        case <-time.After(delay):
        }
    }

    return fmt.Errorf("retry: %d attempts, last error: %w", maxAttempts, err)
}
```
